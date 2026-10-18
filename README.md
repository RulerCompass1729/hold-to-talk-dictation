# hold-to-talk-dictation

在 Mac 上**按住右 Cmd 说话，松开后本地转写，文字直接贴到光标处**。全程不联网。

> 状态：**自用工具的存档**，不打算做成产品（理由见 [COMPETITORS.md](COMPETITORS.md)）。as-of 2026-10-17。

## 怎么工作

```
按住右 Cmd ──> Hammerspoon 监听（keyCode 54）
          ──> sox 从指定麦克风录 16kHz 单声道 wav
松开      ──> curl POST 到本机 whisper-server（127.0.0.1:8942，模型 ggml-large-v3-turbo）
          ──> 结果写剪贴板 ──> Cmd+V ──> 0.25 秒后恢复原剪贴板
```

- 依赖：Hammerspoon、sox、whisper.cpp（都用 Homebrew 装），外加约 1.6 GB 的 whisper 模型。
- 需要的系统权限：辅助功能、麦克风。

## 文件

| 文件 | 内容 |
|---|---|
| [init.lua](init.lua) | 整个工具，放到 `~/.hammerspoon/init.lua`；第 19 行要改成自己真麦的名字 |
| [INSTALL.md](INSTALL.md) | 分步安装指南，写给 Claude Code 照着做：带验证命令、完成判据、已知坑 |
| [COMPETITORS.md](COMPETITORS.md) | 24 个竞品分 5 类逐个说明、本项目的区别、为什么没做成产品 |

## 竞品速览（as-of 2026-10-17，详情见 [COMPETITORS.md](COMPETITORS.md)）

| 类别 | 代表 | 和本项目的关系 |
|---|---|---|
| 免费开源、本地运行 | Handy（34k★）、Ghost Pepper、OpenWhispr、VoiceInk、FluidVoice | 同样免费、本地，还多了界面；本项目的「本地 + 干净」已被它们免费做到 |
| 独立开发者的付费 app | superwhisper、MacWhisper、Spokenly、Sotto、BetterDictation、Whisper Notes | superwhisper 免费档就含本地 whisper 不限量；收费卖的是打磨、云端功能和企业合规 |
| 云端 + AI 润色 | Wispr Flow（估值 $20 亿）、Typeless、Willow、Aqua Voice | 准确率和润色更强，但语音全部上云 |
| 中文输入法与中文工具 | 微信输入法、豆包输入法、闪电说、CapsWriter-Offline | 微信输入法免费支持中英混说（云端）；中文开源本地的 CapsWriter 不支持 Mac |
| 系统和大厂免费提供 | macOS 自带听写、Apple SpeechAnalyzer、Google Eloquent | 本地识别已是免费的基础设施；但不能按住说话、不能中英混说 |

**本项目剩下的特点**：一个约 360 行的文件就是全部；外连情况实测过；按住右 Cmd 说话；中英混说靠 whisper 自动识别语种。
**本项目缺的**：图形界面、AI 润色、自定义词表、中文专用引擎。

## 隐私核对（参考机器实测）

- **whisper-server**：只监听 `127.0.0.1:8942`。它的二进制只导入了 `socket / bind / listen / getaddrinfo`，没有 `connect`，没有主动外连的能力。处理一段测试音频期间，只看到本机回环连接。
- **Hammerspoon**：
  - 崩溃上报（Sentry）关闭，`HSUploadCrashData=0`。要在**首次启动前**就关，见 INSTALL.md 第 4 步。
  - 唯一的定期外连是 Sparkle 每 6 小时查一次更新，不发系统信息（`SUSendProfileInfo=0`）。
- **按键监听**：只看修饰键（`flagsChanged`），不记录其他按键。
- **本地残留**：最后一次录音的 wav，以及 `debug.log` 里每条转写的前 80 个字。都不上传，但会留在磁盘上。

## 已知限制

- 没有 GUI，要手动安装。
- 模型 1.6 GB。
- 没有 LLM 润色和自定义词表。
- `hs.ipc` 是本地风险：本机其他程序能借 Hammerspoon 的权限。

完整列表见 COMPETITORS.md 第二节。
