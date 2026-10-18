# 竞品对照与本项目的区别

> as-of 2026-10-17。价格、星数、功能都会变，重看前先复核。
> ✔ = 我本人打开一手页面或调用 GitHub API 复核过。其余行来自调研时读过的官网、README 或隐私政策原文（一手页面，但没有第二次核）。
> 「—」= 没查到，不代表没有。

## 一、对照表

| 产品 | 价格 | 默认引擎 | 开源 | 统计 / 遥测 | 模型体积 | 中文 / 中英混说 | 备注 |
|---|---|---|---|---|---|---|---|
| **本项目** | 免费（自用） | 本地 whisper.cpp large-v3-turbo | 自写，约 360 行 Lua | 无，已实测（见下文「本项目的区别」） | 1.6 GB | whisper 自动识别语种；混说没有公开基准 | 没有 GUI，要手动装 |
| Handy ✔ | 免费（接受捐赠） | 本地 | MIT，34,057★ | 隐私政策："does not contain advertising, behavioral analytics, or user-tracking telemetry" | 487 MB–1.6 GB（推荐 Parakeet 731 MB） | 官方未宣称支持中文 | 和本项目定位几乎一样 |
| Ghost Pepper ✔ | 免费 | 本地 | 有源码，未声明许可证，3,207★ | README："No Firebase, Mixpanel, Sentry, or any tracking SDK" | 默认 small.en 约 466 MB | 默认是英文模型 | Show HN 467 分，标题 "Local hold-to-talk speech-to-text for macOS" |
| OpenWhispr ✔(星数) | 本地免费；Pro $6.67/月 | 本地默认，可选云 | MIT，9,528★ | README："No data collection, no telemetry" | 75 MB–1.6 GB | 语言列表里有「中文」 | 自称 15 万+ 下载 |
| VoiceInk ✔(星数) | $25 起一次性买断；源码 GPL 可自编译 | 本地 | GPL-3.0，6,848★ | 依赖清单里没发现统计 SDK | — | — | 自称 20 万+ 下载 |
| FluidVoice | 免费 | 本地默认 | GPL-3.0，12,267★ | **匿名统计默认开启**（README 自述，可关） | 75 MB–2.9 GB | 未点名中文 | 自称 35 万+ 下载 |
| VoiceTypr | $69 一次性买断 | 本地默认 | AGPL-3.0 | **依赖里有 posthog-rs** | 未写 | 未点名中文 | 宣传 "Offline by default" |
| superwhisper ✔(免费档) | 免费档 "Unlimited use of Whisper models"；Pro $8.49/月；终身约 $250 | 本地 + 云 | 否 | 隐私政策："We do not collect any usage data" | — | 100+ 种语言 | ✔ 收入 "in the seven-figures"，无外部融资（Globe and Mail 2026-05-12） |
| MacWhisper | 免费；Pro €64 一次性买断 | 本地 | 否 | — | — | 100 种语言（没点名中文） | 主打文件转写 |
| Spokenly | 本地免费；Local+ $29；Pro $99.99/年 | **默认云**，可选本地 | 否 | 匿名使用统计（Local Only 模式可关） | app 33.6 MB | 界面支持中文 | |
| Sotto | $49 一次性买断 | 本地默认 | 否 | **网站没有隐私政策页** | 66 MB–2.7 GB | 未点名中文 | |
| BetterDictation | $39 起终身授权 | 基础版本地，Pro 走云 | 否 | 隐私政策承认收集基础遥测 | — | 支持中文 | |
| Wispr Flow ✔(估值) | 免费档；Pro $12–15/月 | **云**（"Transcription always happens in the cloud"） | 否 | 会读取你正在输入的 app 里的文字（可关） | — | — | 2026-08 估值 $20 亿（Wikipedia 引 Reuters） |
| Typeless | 免费档限字数；Pro $12/月（年付）或 $30/月（月付） | 云 | 否 | — | — | **中英混说口碑最好**（V2EX 用户） | |
| Aqua Voice | 免费 1,000 词；$8–30/月 | 云，没有离线模式 | 否 | — | — | 支持普通话 | YC W24 |
| 微信输入法 Mac ✔ | 免费 | **云**（隐私政策：语音上传至腾讯服务器） | 否 | — | — | 宣称「中文、英文及多种方言自由混说」；长按 fn 说话 | 2.2.0 版加了去口水词、自动标点 |
| 闪电说 | 免费 / ¥19.9 每月 | 宣称本地优先 | 否 | — | — | 中文好；有用户称混说不如 Typeless | |
| macOS 自带听写 | 免费 | Apple Silicon 上本地（含普通话） | 否 | 只在打开「改进 Siri 与听写」时收集 | 系统自动下载 | 一次只能一种语言，混说要手动切 | 按一下开始/结束，不是按住说话 |
| Apple SpeechAnalyzer（开发者 API） | 免费 | 本地，模型由系统托管 | — | — | app 里不带模型 | 每次只能设一个语言区域 | Yap 等免费工具用它 |
| Google AI Edge Eloquent | 官方页未写价格（报道称免费） | 官方："runs 100% on-device" | 否 | — | 报道称要 16 GB 内存 | 报道称首发只有英文 | 2026-06 发布 |
| CapsWriter-Offline ✔ | 免费 | 本地 | MIT，6,974★ | — | — | 中文很强 | **不支持 macOS**（README 原文） |

另外，有个开源清单 awesome-voice-typing 收了 26 个以上的开源 macOS 听写工具。Hacker News 上从 2025 年起有 77 个 Mac 听写类的 Show HN 发布帖，其中 53 个标题就写着 local / offline / private。

## 二、本项目的区别

**有的：**
- **整个工具就一个文件**，`init.lua` 约 360 行，五分钟能读完。没有 app、没有账号、没有更新服务器。
- **外连情况实测过，不是只看声明**：
  - whisper-server 只监听 `127.0.0.1:8942`。
  - 它的二进制没有导入 `connect`，没有主动外连的能力。
  - 发一段测试音频，处理期间只看到本机回环连接。
- **Hammerspoon 的崩溃上报在首次启动前就关掉**。它的源码默认是开的，见 INSTALL.md 第 4 步。
- **用法**：按住右 Cmd 说话，松开就贴到光标处；贴完会恢复原来的剪贴板。
- **语种自动识别**（`-l auto`），中英混说直接靠 whisper 本身。

**没有的（大多数竞品有）：**
- 没有 GUI 和设置面板；要手动安装，还要授两个系统权限。
- 不小：模型 1.6 GB，和别家同一个量级。真正小的做法是调苹果的 SpeechAnalyzer，app 不带模型。
- 没有 LLM 润色、去口水词、自定义词表，也没有边说边出字。
- 只有 whisper 一个引擎。中文用 SenseVoice 会快很多，苹果自带引擎不用下载模型。
- `hs.ipc` 让本机其他程序能借用 Hammerspoon 已有的麦克风和辅助功能权限。
- `debug.log` 会留下每条转写的前 80 个字（明文）；最后一次录音的 wav 要等下次按键才会被覆盖。
- 只在 Apple Silicon + macOS 26 上验证过。

## 三、为什么没做成产品

判决：**不按「本地 + 小巧 + 干净」做成收费产品，保持自用。**

1. **本地、干净已经是免费标配。** Handy、Ghost Pepper、OpenWhispr 免费又不带统计；superwhisper 免费档本地模型不限量；苹果、谷歌都在免费提供本地听写。
2. **小巧这一点本项目做不到**：模型 1.6 GB。
3. **付钱的人买的是准确率、LLM 润色、企业合规，不是本地。**
   - Hacker News 13 个帖子共 741 条评论里，提到价格的占 4.5%，推荐免费替代品的占 17%。
   - V2EX 中文帖里提隐私的在 0–6% 之间。
4. **反面证据**：superwhisper 没有外部融资，收入做到了七位数（美元）。但它 2023 年就入场，现在 11 个人，在往企业客户转，卖的是打磨和合规。

**唯一真实的缺口：Mac 上的中英混说。**
- 需求是真的：V2EX 帖子「中英混说，语音输入法哪家最强？」，正文只有一句「收费软件也行，有付费意愿。」
- 但阻力很大：
  - 微信输入法 Mac 版免费支持混说（走云端）。
  - 用户反馈混说最准的是云端的 Typeless。
  - 没有人公开测过本地模型和云端在混说上谁更准。

**重开条件**：录 20 句自己真实的中英混说（带英文术语、命令名），本地跑 whisper large-v3-turbo、SenseVoice、macOS 自带听写三个引擎，拿微信输入法当对照。最好的本地引擎在英文术语上明显少错，才值得往下想。

## 四、来源（2026-10-17 打开）

```
https://handy.computer/privacy
https://github.com/cjpais/Handy
https://github.com/matthartman/ghost-pepper
https://hn.algolia.com/api/v1/search?query=ghost%20pepper%20speech&tags=story
https://github.com/OpenWhispr/openwhispr
https://github.com/Beingpax/VoiceInk
https://tryvoiceink.com/
https://github.com/altic-dev/FluidVoice
https://github.com/ideaplexa/voicetypr
https://superwhisper.com/
https://www.theglobeandmail.com/business/article-toronto-ai-startup-superwhisper-dictation-app/
https://www.macwhisper.com/
https://spokenly.app/pricing
https://sotto.to/pricing
https://betterdictation.com/privacy
https://wisprflow.ai/pricing
https://en.wikipedia.org/wiki/Wispr_Flow
https://typeless.ai/pricing
https://aquavoice.com/pricing
https://z.weixin.qq.com/web/change-log/144
https://z.weixin.qq.com/web/privacy
https://shandianshuo.cn/
https://www.apple.com/macos/feature-availability/
https://www.apple.com/apple-intelligence/
https://developer.apple.com/videos/play/wwdc2025/277/
https://developers.googleblog.com/bringing-gemma-4-12b-to-your-laptop-unlocking-local-agentic-workflows-with-google-ai-edge/
https://github.com/HaujetZhao/CapsWriter-Offline
https://github.com/primaprashant/awesome-voice-typing
https://www.v2ex.com/t/1214538
https://www.v2ex.com/t/1193285
```
