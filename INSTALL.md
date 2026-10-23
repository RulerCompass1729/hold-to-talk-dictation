# 按住说话（hold-to-talk）安装指南 · 给 Claude 照做

> as-of 2026-10-17（2026-10-21 加了可选的中文标点后处理，第 5b 步）。参考机器 = Apple Silicon Mac（arm64, macOS 26），在那台上已跑通并做过隐私审计（录音/转写不出本机）。
> 本仓库里与安装有关的文件：`INSTALL.md`（本文）+ `init.lua`（参考机器 `~/.hammerspoon/init.lua` 的副本，只把第 19 行麦克风名换成了占位符 `YOUR_MIC_NAME`）+ `punct.py`（中文标点后处理，可选）+ `test_punct.py`（它的检查）。

## 它是什么

按住**右 Cmd** 说话 → 松开 → 本地 whisper 转写 → 文字贴到当前光标。全本地，不联网。

链路：Hammerspoon 监听右 Cmd（keyCode 54）→ `sox` 从指定麦克风录 16kHz 单声道 wav → `curl` POST 到本机 `whisper-server`（`127.0.0.1:8942`，模型 `ggml-large-v3-turbo.bin`）→（装了第 5b 步时）`punct.py` 给中文补标点 → 结果写剪贴板 → Cmd+V → 0.25s 后恢复原剪贴板。

## 开工前（Claude 必读）

1. 先读完全文，再动手。
2. **只有人能做的步骤**：开工时一次性告诉用户，后面到了再提醒：
   - 有多个候选麦克风时，选哪一个
   - 系统设置里给 Hammerspoon 勾「辅助功能」
   - 弹出麦克风授权时点「允许」
   - 麦克风测试的 3 秒里对着麦说话
   - 最后真按右 Cmd 说一句话
3. **桌面窗口**：打开 TextEdit 或其他窗口之前先问用户；绝不关用户已有的窗口。
4. **`hsTalk.test()` 不要随便跑**：它会把转写结果直接粘贴进当前焦点窗口。
5. 校验本目录的 init.lua 和 punct.py 没被改过：
   ```bash
   shasum -a 256 init.lua punct.py
   # 期望 init.lua  b3047e08d702402c059c864e96d176e554fd5a3ddf288cff9f929d057401fa37
   #      punct.py  5f19b1df0c387d4f6062829ef5afef6be52df39aaf2557bf9e9614b8bc5a1efe
   ```
   对不上就停下问用户。

## 第 1 步 · 探测机器

```bash
uname -m                 # arm64 = Apple Silicon；x86_64 = Intel
sw_vers
brew --prefix            # arm64 一般是 /opt/homebrew，Intel 是 /usr/local
```

记下 `BREW=$(brew --prefix)`，下文都用它。

- 没装 Homebrew：先问用户再装。
- **Intel 机器**：init.lua 第 27–28 行写死了 `/opt/homebrew/bin/sox` 和 `/opt/homebrew/bin/whisper-server`，要改成 `$BREW/bin/...`。其余不变。Intel 没有 Metal 加速，large-v3-turbo 可能很慢；第 8 步测出时延后报给用户，由用户决定是否换小模型。

## 第 2 步 · 备份和冲突检查（防丢数据）

```bash
ls -la ~/.hammerspoon/ 2>/dev/null
lsof -nP -iTCP:8942 -sTCP:LISTEN
pgrep -fl whisper-server
```

- 已有 `~/.hammerspoon/init.lua`：先备份成 `~/.hammerspoon/init.lua.bak-$(date +%Y%m%d-%H%M%S)`，再告诉用户。它原有的功能会被替换，要合并的话先问。
- 8942 端口被别的程序占着：问用户，或者同时改 init.lua 第 18 行的 `SERVER_PORT`。
- 注意 init.lua 第 432 行会 `pkill -f whisper-server`，**这台机器上别的 whisper-server 也会被杀掉**。如果有，先告诉用户。它按整条命令行匹配：Reload 时，命令行里带 `whisper-server` 字样的 shell 命令（例如把 `hs -c 'hs.reload()'` 和 `pgrep -fl whisper-server` 写在同一条里）也会被一起杀掉，所以 reload 和查进程要分两条命令跑。

## 第 3 步 · 装 sox + whisper.cpp

```bash
brew analytics off                 # 隐私：关 Homebrew 的安装统计（参考机器也是关的）
brew install sox whisper-cpp
which sox whisper-server           # 都应该在 $BREW/bin/ 下
whisper-server --help 2>&1 | grep -E -- '-m |-l |-nt|--host|--port'
```

参考机器装的是 1.9.2，新装会更新（10-17 时 stable 是 1.9.5）。必须确认 `-m`、`-l`、`-nt`、`--host`、`--port` 五个参数都还在；有改名的话，同步改 init.lua 第 137–143 行。

## 第 4 步 · 装 Hammerspoon（**首次启动前**先关崩溃上报）

```bash
# 必须在第一次打开 Hammerspoon 之前执行
defaults write org.hammerspoon.Hammerspoon HSUploadCrashData -bool false
defaults write org.hammerspoon.Hammerspoon SUSendProfileInfo -bool false
defaults write org.hammerspoon.Hammerspoon SUAutomaticallyUpdate -bool false
brew install --cask hammerspoon    # 只装，不会自动打开
```

为什么要抢在首次启动前：源码 `MJAppDelegate.m` 里 `registerDefaultDefaults` 把 `HSUploadCrashData` 的默认值注册为 YES，启动时 `if (HSUploadCrashData()) { [SentrySDK start...] }`。等启动后再去关，Sentry 已经初始化过一次了（参考机器上就是这样：首启那天留下了 io.sentry 缓存目录）。

## 第 5 步 · 目录 + 模型

```bash
mkdir -p ~/.local/whisper-dictation/audio ~/.local/whisper-dictation/models
```

**这一步漏掉的症状**：init.lua 不会自己建目录，日志写不进去、sox 也写不了 wav，表现为「按了没反应」。

下载模型（1,624,555,275 字节，约 1.6GB）：

```bash
curl -L --fail -o ~/.local/whisper-dictation/models/ggml-large-v3-turbo.bin \
  https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo.bin
shasum -a 256 ~/.local/whisper-dictation/models/ggml-large-v3-turbo.bin
# 期望 1fc70f774d38eb169993ac391eea357ef47c88757ef72ee5943879b7e8e2bc69
# （10-17 核过：与 HF 的 x-linked-etag 及参考机器本地文件三方一致）
```

在中国大陆、huggingface 连不上时，**首选**从一台已装好的 Mac 拷（例如经 Tailscale + SSH；主机和用户名问用户）：

```bash
scp <user>@<已装好的那台 Mac>:.local/whisper-dictation/models/ggml-large-v3-turbo.bin \
    ~/.local/whisper-dictation/models/
```

备选：`hf-mirror.com` 同路径。从美国访问它只会 308 跳回 huggingface.co，国内能否直连没验证过。

不管从哪来，sha256 对不上就不许用。

## 第 5b 步 · 中文标点模型（可选，推荐）

whisper large-v3-turbo 转中文时经常一个标点都不出（参考机器上的真实转写：「我今天想吃西瓜你看一下现在几点了」），出了也常是半角逗号。`punct.py` 在转写之后处理：

- 没有中文 → 原样输出（英文 whisper 自己会加标点）
- 有中文 → 本地 CT-Transformer 标点模型（sherpa-onnx，int8，约 75MB）把缺的 ，。？ 补上；whisper 已经加了的保留，不在旁边重复加
- 最后把中文旁边的半角 `,?!;:.` 换成全角；`3.5`、`3:30`、`1,000`、`example.com` 里的符号不动

模型只能**插入**标点：原文任何字符被它改动，整句放弃、用原文。参考机器上单句多花约 0.15 秒。跳过这一步也行，init.lua 发现文件不在就自动跳过，行为和以前一样。

为什么不用 whisper 的 prompt：10-21 实测，固定中文 prompt 会让英文语音被翻成中文，静音被幻觉成「字幕志愿者 ×××」；beam search、时间戳模式都不改变中文标点。

```bash
python3 --version     # 需要 3.9+；没有的话 macOS 会提示装 Command Line Tools，先问用户
python3 -m venv ~/.local/whisper-dictation/punct-venv
~/.local/whisper-dictation/punct-venv/bin/pip install "sherpa-onnx==1.13.8"

T=$(mktemp -d)
curl -L --fail -o "$T/punct.tar.bz2" \
  https://github.com/k2-fsa/sherpa-onnx/releases/download/punctuation-models/sherpa-onnx-punct-ct-transformer-zh-en-vocab272727-2024-04-12-int8.tar.bz2
shasum -a 256 "$T/punct.tar.bz2"
# 期望 c0d5aa5f8eeb686032345e180bedf39319dc2e0556781c6264bcadba8328a6e1（与该 release 的 checksum.txt 一致，10-21 核过）
tar xjf "$T/punct.tar.bz2" -C "$T"
mkdir -p ~/.local/whisper-dictation/models/punct-ct-transformer-zh-en-int8
cp "$T"/sherpa-onnx-punct-ct-transformer-zh-en-vocab272727-2024-04-12-int8/model.int8.onnx \
   ~/.local/whisper-dictation/models/punct-ct-transformer-zh-en-int8/
shasum -a 256 ~/.local/whisper-dictation/models/punct-ct-transformer-zh-en-int8/model.int8.onnx
# 期望 65a3fb9f5ad7bfb96bf69e0dc4481df97f6ee60513c1d94ce981ba6effd524b1
```

GitHub 连不上时，同第 5 步：从已装好的 Mac 用 scp 拷 `model.int8.onnx`，sha256 对上才用。

不经过 Hammerspoon 先测一遍：

```bash
~/.local/whisper-dictation/punct-venv/bin/python -I test_punct.py \
  ~/.local/whisper-dictation/models/punct-ct-transformer-zh-en-int8/model.int8.onnx
# 期望最后一行：33 cases, 0 failures
```

## 第 6 步 · 选麦克风（最容易出错的一步）

**绝不用系统默认输入（sox 的 `-d`）**。默认输入会漂：参考机器上它先后漂到过「AirPods - Find My」（AirPods 在找设备模式，录到的是数字静音）和「Background Music」（虚拟设备），结果录到静音，whisper 幻觉出 "Thank you."。

列出设备，只看能输入的：

```bash
sox -V6 -n -t coreaudio __x__ 2>&1 | grep 'Found Audio Device'
system_profiler SPAudioDataType | grep -B3 'Input Channels' | grep -E '^ {8}[^ ].*:$'
```

- 排除虚拟设备：Background Music、Steam Streaming、ZoomAudioDevice、各种 Loopback/BlackHole、「AirPods - Find My」。
- 笔记本通常有内置麦，名字类似「MacBook Air Microphone」；外接摄像头/耳机麦按名字识别。
- 只剩一个真麦就直接用；多个就问用户。

把 init.lua 第 19 行 `INPUT_DEVICE` 改成**完全一致**的设备名（大小写、空格都要一样）。第 8 步会实测这个设备。

## 第 7 步 · 放配置、启动、授权

```bash
cp init.lua ~/.hammerspoon/init.lua            # 已在第 2 步备份过旧文件
cp punct.py ~/.hammerspoon/punct.py            # 没做第 5b 步也可以放，init.lua 会自动跳过
# 按第 1 步 / 第 6 步改好第 19 行（Intel 再加第 27–28 行）
open -a Hammerspoon
open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
```

请用户在「辅助功能」里勾上 Hammerspoon。然后**重启** Hammerspoon，不要只点 Reload Config：刚授完辅助功能权限，只 Reload 有时不生效。

```bash
osascript -e 'quit app "Hammerspoon"'; open -a Hammerspoon
```

装命令行 `hs`（init.lua 第 11 行 `require("hs.ipc")` 已经开了 IPC；配置加载后命令行才连得上）：

```bash
ln -s /Applications/Hammerspoon.app/Contents/Frameworks/hs/hs "$BREW/bin/hs"
hs -c 'hsTalk.state()' 2>&1 | grep -v '^-- Loading'
# 期望 isRecording=false ... serverAlive=true（刚启动时模型要加载几秒，false 就等一会儿再查）
hs -c 'return tostring(hs.accessibilityState())' 2>&1 | grep -v '^-- Loading'   # 期望 true
```

如果屏幕上弹出「缺辅助功能权限」，或 `accessibilityState` 是 false：回到辅助功能设置，把 Hammerspoon 的勾去掉再勾上，然后再重启 Hammerspoon。

开机自启：

```bash
hs -c 'return tostring(hs.autoLaunch(true))' 2>&1 | grep -v '^-- Loading'   # 期望 true
```

## 第 8 步 · 实测（按顺序）

**8a. 转写服务（不碰麦克风）**

```bash
T=$(mktemp -d)
sox -n -r 16000 -c 1 -b 16 "$T/s.wav" synth 2 sine 440 vol 0.01
time curl -s -m 30 -F file=@"$T/s.wav" -F language=auto http://127.0.0.1:8942/inference
# 期望一行 JSON，例如 {"text":" .\n"}；记下耗时（Intel 机器要报给用户）
```

**8b. 麦克风（必须经过 Hammerspoon，走真实的权限路径）**

从终端直接跑 sox，测的是终端的麦克风权限，不是 Hammerspoon 的，所以这里必须让 Hammerspoon 去起 sox。

task 必须存在**全局变量**里：用 local 会被 Lua 垃圾回收，什么都录不到（已实测）。

请用户在下面 3 秒内对着麦说话，然后执行（把 `<DEV>` 换成第 6 步选的设备名）：

```bash
F=$HOME/.local/whisper-dictation/audio/mictest.wav; rm -f "$F"
hs -c "micTestTask = hs.task.new('$BREW/bin/sox', function(c) micTestExit = c end, {'-t','coreaudio','<DEV>','-r','16000','-c','1','-b','16','$F','trim','0','3'}); micTestTask:start(); return 'started'" 2>&1 | grep -v '^-- Loading'
# 等约 4 秒（for i in $(seq 1 20); do perl -e 'select(undef,undef,undef,0.2)'; done）
sox "$F" -n stat 2>&1 | grep -E 'Length|Maximum amplitude'
rm -f "$F"; hs -c 'micTestTask=nil; micTestExit=nil' >/dev/null 2>&1
```

判读（参考机器实测）：

- 真人声：Maximum amplitude 约 0.05（≥0.01 就算有声）
- 静音/虚拟设备：约 0.00003

**第一次跑**会弹「Hammerspoon 想访问麦克风」，这一次录到的是静音。用户点「允许」后再跑一遍。

没弹窗、一直是静音时，打开下面的设置，确认 Hammerspoon 已勾上：

```bash
open "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone"
```

仍然静音就是设备选错了，回到第 6 步。

**8c. 端到端（人来做）**

先问用户能不能开一个空白 TextEdit 文档。然后请用户把光标放进文档，**按住右 Cmd** 说一句中英混合的话（例如「今天测试一下 hold to talk 语音输入」），再松开。

- 屏幕顶部应出现红条「● 录音中…」，菜单栏出现 🎙️ REC。
- 松开后一两秒，文字出现在光标处。

出问题时看日志：

```bash
hs -c 'hsTalk.readlog()' 2>&1 | grep -v '^-- Loading' | tail -30
```

**8d. 中文标点（装了第 5b 步才做；不碰麦克风、不粘贴）**

```bash
hs -c 'punctOut = nil; hsTalk.punctuate("能放草果吗", function(r) punctOut = r end); return "ok"' 2>&1 | grep -v '^-- Loading'
perl -e 'select(undef,undef,undef,1.5)'
hs -c 'return tostring(punctOut)' 2>&1 | grep -v '^-- Loading'
# 期望 能放草果吗？（没装第 5b 步时原样返回 能放草果吗）
```

8c 的日志里，装了第 5b 步时每条会多一行 `标点后=…`。

## 第 9 步 · 隐私核对

```bash
lsof -nP -a -p "$(pgrep -f whisper-server)" -i
# 期望只有 TCP 127.0.0.1:8942 (LISTEN)
defaults read org.hammerspoon.Hammerspoon HSUploadCrashData
# 期望 0
ls ~/Library/Caches/org.hammerspoon.Hammerspoon/io.sentry 2>&1
# 期望 No such file：Sentry 从没启动过，比参考机器更干净
nm -u "$(readlink -f "$(which whisper-server)")" | grep -E '_connect$'
# 期望无输出：whisper-server 没有主动外连的能力
# 装了第 5b 步时再查标点模型的库：
L=$(~/.local/whisper-dictation/punct-venv/bin/python -I -c 'import os, sherpa_onnx; print(os.path.dirname(sherpa_onnx.__file__) + "/lib")')
nm -u "$L"/*.dylib "$L"/*.so 2>/dev/null | grep -E '_connect$|_getaddrinfo$|_NSURLSession'
# 期望无输出：sherpa-onnx / onnxruntime 没有联网能力（10-21 参考机器核过；联网只发生在 pip 安装和下载模型时）
```

## 完成判据（全勾才算装好，SKIP ≠ PASS）

- [ ] 8a：curl 返回 JSON，耗时已记录
- [ ] `hsTalk.state()` 显示 `serverAlive=true`
- [ ] 8b：有人说话时 Maximum amplitude ≥ 0.01
- [ ] 8c：用户真按右 Cmd，中英混合的一句话正确贴进 TextEdit
- [ ] 第 9 步四项全部符合预期
- [ ] （装了第 5b 步时）`test_punct.py` 0 failures；8d 返回「能放草果吗？」；第 9 步标点库的 nm 无输出
- [ ] （先问用户）注销再登录，Hammerspoon 自动起来，`hsTalk.state()` 仍是 alive

最后给用户报一张表：每一项的命令输出或现象，以及改过 init.lua 的哪些行。

## 已知坑（参考机器踩过）

- **全局变量不能改成 local**：eventtap、menubar、drawing 对象如果用 local 声明，会被 Lua 垃圾回收，监听/图标/红条静默失效，表现为「第一次能用，第二次没反应」。init.lua 第 48–52 行已注释，别「优化」成 local。8b 的 `micTestTask` 也是同一个原因。
- **松开检测**：macOS 上 `flagsChanged` 的松开事件不可靠，代码用 100ms 轮询 `checkKeyboardModifiers()` 兜底。所以用 `hs -c 'hsTalk.startRecording()'` 程序化开录会被立刻停掉（录出空文件，whisper 报 `Invalid request`），这不是 bug。
- **识别全错或总出 "Thank you."**：先查录音设备是不是真麦（第 6 步），不要先怀疑模型。
- **`hs -c` 的输出**开头会混入 `-- Loading extension` 之类的行，要先过滤掉再判断。
- **本地残留**（不上传，用户应该知道）：最后一次录音 `~/.local/whisper-dictation/audio/hold_talk.wav` 要等下次按键才会被覆盖；`debug.log` 里有每条转写的前 80 字明文，Reload Config 时清空。
- **`hs.ipc` 的本地风险**：本机任何以该用户身份运行的程序都能用 `hs -c` 让 Hammerspoon 执行代码，而 Hammerspoon 有麦克风和辅助功能权限。参考机器保留了这个功能用来调试；要不要在新机器上去掉第 11 行，由用户决定。
