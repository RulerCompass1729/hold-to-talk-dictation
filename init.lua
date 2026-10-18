-- ============================================================================
-- hold-to-talk dictation
--   按住右 Cmd 说话 → 松开 → 本地 whisper 转写 → 贴到当前光标
--   全本地、免费、无订阅。转写走 Apple Silicon Metal，常驻 whisper-server。
--
-- 需要的权限（只授一次，授完点菜单栏锤子图标 → Reload Config）：
--   1. 辅助功能：系统设置 → 隐私与安全 → 辅助功能 → 勾选 Hammerspoon
--   2. 麦克风：  系统设置 → 隐私与安全 → 麦克风 → 勾选 Hammerspoon
-- ============================================================================

require("hs.ipc")

-- ----------------------------------------------------------------------------
-- 配置
-- ----------------------------------------------------------------------------
local TRIGGER_KEYCODE = 54   -- rightCmd（右 Cmd）
local MAX_SECS        = 60
local SERVER_PORT     = 8942
local INPUT_DEVICE    = "YOUR_MIC_NAME"  -- 录音输入设备：写死真麦的完整名字（见 INSTALL.md 第 6 步），别用系统默认输入

local HOME        = os.getenv("HOME")
local AUDIO_DIR   = HOME .. "/.local/whisper-dictation/audio"
local MODEL_PATH  = HOME .. "/.local/whisper-dictation/models/ggml-large-v3-turbo.bin"
local AUDIO_FILE  = AUDIO_DIR .. "/hold_talk.wav"
local LOG_FILE    = AUDIO_DIR .. "/debug.log"

local SOX            = "/opt/homebrew/bin/sox"
local WHISPER_SERVER = "/opt/homebrew/bin/whisper-server"
local CURL           = "/usr/bin/curl"
local SERVER_URL     = "http://127.0.0.1:" .. SERVER_PORT .. "/inference"

-- ----------------------------------------------------------------------------
-- 状态
-- ----------------------------------------------------------------------------
local recorder       = nil   -- 正在跑的 sox（hs.task）
local isRecording    = false
local serverPid      = nil   -- whisper-server 的 PID（nil=没在跑）
local recGen         = 0     -- 录音代数，防旧 sox 回调 clobber 新录音状态
local releasePoller  = nil   -- 松开轮询 timer（被 startPoller/stopRecording 闭包持有，不会 GC）

-- ⚠️ 必须全局保留（不能用 local）：Hammerspoon 的 eventtap/menubar/drawing 对象若被
-- Lua GC 回收，监听/菜单栏图标/overlay 会静默失效——这就是「第一次能摁、第二次没反应」的根因。
recBar         = nil   -- 菜单栏「录音中」指示器
recOverlay     = nil   -- 屏幕持久 overlay（红条）
recOverlayText = nil   -- overlay 文字

-- ----------------------------------------------------------------------------
-- 调试日志：每次 reload 清空，append 记录每个状态迁移，排障靠它
-- ----------------------------------------------------------------------------
local f = io.open(LOG_FILE, "w"); if f then f:close() end
local function log(msg)
  local f = io.open(LOG_FILE, "a")
  if f then
    f:write(os.date("%H:%M:%S") .. " " .. tostring(msg) .. "\n")
    f:close()
  end
end

-- ----------------------------------------------------------------------------
-- 录音指示器：菜单栏 🎙️ REC + 屏幕顶部红条（hs.drawing，不自动消失，全程在）
-- ----------------------------------------------------------------------------
local function showRecording()
  if not recBar then recBar = hs.menubar.new() end
  recBar:setTitle("🎙️ REC")

  local screen = hs.screen.mainScreen():frame()
  local w, h = 240, 46
  local x = screen.x + math.floor((screen.w - w) / 2)
  local y = screen.y + 40
  local r = hs.geometry.rect(x, y, w, h)

  if not recOverlay then
    recOverlay = hs.drawing.rectangle(r)
    recOverlay:setRoundedRectRadii(12, 12)
    recOverlay:setStrokeColor({ red = 1, green = 1, blue = 1, alpha = 0.4 })
    recOverlay:setStrokeWidth(2)
  end
  recOverlay:setFillColor({ red = 0.86, green = 0.15, blue = 0.15, alpha = 0.92 })
  recOverlay:setFrame(r)
  recOverlay:show()

  if not recOverlayText then
    recOverlayText = hs.drawing.text(r, "● 录音中…")
    recOverlayText:setTextColor({ red = 1, green = 1, blue = 1, alpha = 1 })
    recOverlayText:setTextFont("Menlo")
    recOverlayText:setTextSize(17)
  end
  recOverlayText:setFrame(r)
  recOverlayText:show()
end

local function hideRecording()
  if recBar then recBar:setTitle(nil) end
  if recOverlay then recOverlay:hide() end
  if recOverlayText then recOverlayText:hide() end
end

-- ----------------------------------------------------------------------------
-- whisper-server：常驻加载模型。用 PID + 进程存活判断，防端口重复起两个
-- ----------------------------------------------------------------------------
local function pidAlive(pid)
  if not pid then return false end
  local out = hs.execute("/bin/ps -p " .. pid .. " -o pid= 2>/dev/null")
  return (out or "") ~= "" and tonumber(out) == pid
end

local function startServer()
  if serverPid and pidAlive(serverPid) then
    log("startServer: 已在跑 pid=" .. tostring(serverPid) .. "，跳过")
    return
  end
  log("startServer: 起服务")
  serverPid = nil
  local task = hs.task.new(WHISPER_SERVER, function(code, stdout, stderr)
    log("server 退出 code=" .. tostring(code) .. " err=" .. tostring(stderr):sub(-200))
    serverPid = nil
  end, {
    "-m", MODEL_PATH,
    "-l", "auto",
    "--host", "127.0.0.1",
    "--port", tostring(SERVER_PORT),
    "-nt",
  })
  task:start()
  serverPid = task:pid()
  log("startServer: pid=" .. tostring(serverPid))
end

-- ----------------------------------------------------------------------------
-- 贴到光标：保存原剪贴板 → 写入结果 → Cmd+V → 0.25s 后恢复
-- ----------------------------------------------------------------------------
local function pasteText(text)
  text = text:gsub("^%s+", ""):gsub("%s+$", "")
  if text == "" then
    return false
  end
  -- 静音幻觉过滤：whisper 对「没说话」会输出 "." "……" 这类纯标点。
  -- 只有含英文字母/数字（%w）或 CJK 表意文字（UTF-8 0xE4–0xE9 开头）才算有效。
  if not (text:match("%w") or text:find("[\228-\233]")) then
    hs.alert.show("没听清（无有效文字），再试一次")
    return false
  end
  local prev = hs.pasteboard.getContents()
  hs.pasteboard.setContents(text)
  hs.eventtap.keyStroke({ "cmd" }, "v")
  hs.timer.doAfter(0.25, function()
    if prev ~= nil then
      hs.pasteboard.setContents(prev)   -- 原剪贴板是文本，恢复
    else
      hs.alert.show("⚠️ 原剪贴板是非文本内容（如图片），已被本次转写覆盖")
    end
  end)
  return true
end

-- ----------------------------------------------------------------------------
-- 转写（POST 到本地 whisper-server），带一次失败重试
-- ----------------------------------------------------------------------------
local function transcribe(attempt)
  attempt = attempt or 1
  log("transcribe attempt=" .. attempt)

  hs.task.new(CURL, function(code, stdout, stderr)
    log("curl exit=" .. tostring(code) .. " out=" .. tostring(stdout):sub(1, 120))
    local text = nil
    if code == 0 and stdout and stdout ~= "" then
      local ok, data = pcall(hs.json.decode, stdout)
      if ok and data and data.text then
        text = data.text
      end
    end

    if text and text ~= "" then
      log("转写结果=" .. text:sub(1, 80))
      local pasted = pasteText(text)
      log("粘贴=" .. tostring(pasted))
      if not pasted then
        hs.alert.show("没听清（空转写），再试一次")
      end
      return
    end

    if attempt == 1 then
      log("失败 → 重启 server + 3s 后重试")
      startServer()
      hs.timer.doAfter(3.0, function() transcribe(2) end)
    else
      log("重试后仍失败")
      hs.alert.show("转写失败，请检查 whisper 服务，再试一次")
    end
  end, {
    "-s", "-m", "30",
    "-F", "file=@" .. AUDIO_FILE,
    "-F", "language=auto",
    SERVER_URL,
  }):start()
end

-- ----------------------------------------------------------------------------
-- 松开检测：轮询键盘状态（不依赖 flagsChanged 的 release，那个在 macOS 上不可靠）
-- 定义顺序注意：stopPoller → stopRecording → startPoller → startRecording
-- （Lua 无前向引用，startPoller 要用 stopPoller/stopRecording，必须先定义）
-- ----------------------------------------------------------------------------
local function stopPoller()
  if releasePoller then
    releasePoller:stop()
    releasePoller = nil
  end
end

local function stopRecording()
  if not isRecording then
    log("stopRecording: 没在录音，忽略")
    return
  end
  log("stopRecording gen=" .. recGen)
  isRecording = false
  stopPoller()
  hideRecording()
  if recorder then
    recorder:terminate()   -- SIGTERM：sox 写全 wav 头再退出（已验证），退出触发转写
  end
end

local function startPoller()
  stopPoller()
  local polls = 0
  releasePoller = hs.timer.doEvery(0.1, function()
    local m = hs.eventtap.checkKeyboardModifiers()
    polls = polls + 1
    local held = m and (m.cmd or m.rcmd)
    if polls <= 5 then
      log(string.format("poller#%d cmd=%s rcmd=%s held=%s",
        polls, tostring(m and m.cmd), tostring(m and m.rcmd), tostring(held)))
    end
    if not held then
      log("poller: 检测到松开")
      stopRecording()
    end
  end)
end

-- ----------------------------------------------------------------------------
-- 录音：sox 录 16kHz 单声道 wav；进程退出触发转写
-- ----------------------------------------------------------------------------
local function startRecording()
  if isRecording then
    log("startRecording: 已在录音，忽略")
    return
  end
  recGen = recGen + 1
  local gen = recGen
  isRecording = true
  os.remove(AUDIO_FILE)   -- 清残留
  showRecording()
  startPoller()
  log("startRecording gen=" .. gen)

  recorder = hs.task.new(SOX, function(code, stdout, stderr)
    log("sox 退出 code=" .. tostring(code) .. " gen=" .. gen)
    if gen ~= recGen then
      log("stale sox 回调（gen " .. gen .. " != " .. recGen .. "），忽略")
      return
    end
    recorder = nil
    isRecording = false
    stopPoller()
    hideRecording()
    transcribe()
  end, {
    "-t", "coreaudio", INPUT_DEVICE,
    "-r", "16000",
    "-c", "1",
    "-b", "16",
    AUDIO_FILE,
    "trim", "0", tostring(MAX_SECS),
  })
  recorder:start()
end

-- ----------------------------------------------------------------------------
-- 按键监听：按下开始录；松开由 poller 兜底（flagsChanged release 不可靠）
-- ----------------------------------------------------------------------------
local function makeTap(types, onEvent)
  local tap = hs.eventtap.new(types, onEvent)
  if tap then
    tap:start()
    return tap
  end
  return nil
end

cmdTap = makeTap({ hs.eventtap.event.types.flagsChanged }, function(e)
  local kc = e:getKeyCode()
  local flags = e:getFlags()
  -- 诊断：记录右 Cmd 事件 + 录音期间所有 flagsChanged（看 release 到底发不发、keyCode 是啥）
  if kc == TRIGGER_KEYCODE or isRecording then
    log(string.format("flagsChanged kc=%d cmd=%s rcmd=%s (isRecording=%s)",
      kc, tostring(flags.cmd), tostring(flags.rcmd), tostring(isRecording)))
  end
  if kc ~= TRIGGER_KEYCODE then
    return false
  end
  local ok, err = pcall(function()
    if flags.cmd then
      startRecording()
    else
      stopRecording()
    end
  end)
  if not ok then
    log("ERROR 按键回调抛错: " .. tostring(err))
  end
  return false   -- 不吞事件
end)

-- ----------------------------------------------------------------------------
-- 调试接口：`hs -c 'hsTalk.xxx()'` 远程驱动/内省
-- ----------------------------------------------------------------------------
hsTalk = {
  startRecording = startRecording,
  stopRecording  = stopRecording,
  transcribe     = transcribe,
  pasteText      = pasteText,
  startServer    = startServer,
  state = function()
    return string.format(
      "isRecording=%s recGen=%d serverPid=%s serverAlive=%s",
      tostring(isRecording), recGen, tostring(serverPid), tostring(pidAlive(serverPid)))
  end,
  test = function()
    startRecording()
    -- 程序化测试没有物理按键，poller 会立刻「检测到松开」秒停录音——手动停掉 poller
    if releasePoller then releasePoller:stop(); releasePoller = nil end
    hs.timer.doAfter(2.0, function() stopRecording() end)
    return "test: 录 2 秒后自动停止（已跳过 poller）"
  end,
  readlog = function()
    local f = io.open(LOG_FILE, "r")
    if not f then return "(无日志)" end
    local s = f:read("*a")
    f:close()
    return s
  end,
}

-- ----------------------------------------------------------------------------
-- 启动
-- ----------------------------------------------------------------------------
hs.execute("/usr/bin/pkill -f whisper-server 2>/dev/null")
hs.timer.doAfter(0.5, startServer)

if not cmdTap then
  hs.alert.show("Hammerspoon 缺辅助功能权限，按键监听没生效：\n"
    .. "系统设置 → 隐私与安全 → 辅助功能 → 勾选 Hammerspoon，然后 Reload Config")
end

log("===== init.lua 加载完成，cmdTap=" .. tostring(cmdTap ~= nil) .. " =====")
hs.notify.show("hold-to-talk dictation ready", "按住右 Cmd 说话，松开即转写", "")
