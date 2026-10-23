# 竞品对照与本项目的区别

> as-of 2026-10-17（Sotto 一条 10-18 复查）。价格、星数、功能都会变，重看前先复核。
> **证据标记**：✔ = 我本人打开一手页面或调用 GitHub API 复核过；没打 ✔ 的，来自调研时读过的官网、README 或隐私政策原文（一手页面，但没有第二次核）。
> 「官网没写」= 查过但官方没说；「未核」= 没查到。两者都不代表「没有」。

## 目录

1. [一眼看全](#一一眼看全)
2. [逐个说明](#二逐个说明)
   - [A. 免费开源、本地运行](#a-免费开源本地运行)
   - [B. 独立开发者的付费 app](#b-独立开发者的付费-app)
   - [C. 云端 + AI 润色](#c-云端--ai-润色)
   - [D. 中文输入法与中文工具](#d-中文输入法与中文工具)
   - [E. 系统和大厂免费提供的](#e-系统和大厂免费提供的)
3. [本项目的区别](#三本项目的区别)
4. [为什么没做成产品](#四为什么没做成产品)
5. [来源](#五来源)

---

## 一、一眼看全

| 产品 | 一句话 | 价格 | 本地 / 云 | 和本项目比 |
|---|---|---|---|---|
| **本项目** | 一个 Lua 文件，按住右 Cmd 说话 | 免费 | 本地 | — |
| **A. 免费开源、本地运行** | | | | |
| Handy ✔ | 最火的开源免费本地听写 | 免费 | 本地 | 同样免费干净，功能更全，基本覆盖本项目 |
| Ghost Pepper ✔ | 和本项目同一个点子：本地按住说话 | 免费 | 本地 | 概念一样，多了 app 界面；默认只认英文 |
| OpenWhispr ✔ | 开源，本地免费，云端收费 | 本地免费；Pro $6.67/月 | 本地默认，可选云 | 支持中文，有界面；安装包较大（Electron） |
| VoiceInk ✔ | 开源，但卖编译好的版本 | $25 起买断 | 本地 | 有界面；源码可免费自己编译 |
| FluidVoice | 开源，模型选择多 | 免费 | 本地默认 | 匿名统计默认开启 |
| VoiceTypr | 开源，卖终身授权 | $69 买断 | 本地默认 | 依赖里带 PostHog 统计 |
| **B. 独立开发者的付费 app** | | | | |
| superwhisper ✔ | 行业头部，免费档本地不限量 | 免费；Pro $8.49/月 | 本地 + 云 | 免费档已覆盖本项目的全部功能 |
| MacWhisper | 老牌，主打音频文件转写 | 免费；Pro €64 买断 | 本地 | 偏文件转写，不是主打按住说话 |
| Spokenly | 默认用云，本地免费可选 | 本地免费；Pro $99.99/年 | 默认云 | 本地档免费，但默认走云 |
| Sotto | 本地优先，一次买断 | $49 买断 | 本地默认 | 常见路径找不到隐私政策 |
| BetterDictation | 本地基础版 + 云端润色 | $39 起买断 | 本地，Pro 走云 | 隐私政策承认收集基础遥测 |
| Whisper Notes | 多引擎，含中文专用引擎 | $7.99（App Store）；Mac 直装版 $14 | 本地 | 中文有 SenseVoice 引擎，比 whisper 快 |
| **C. 云端 + AI 润色** | | | | |
| Wispr Flow ✔ | 融资最多，云端听写 + 润色 | 免费档；Pro $12–15/月 | 云 | 准确率和润色强，但语音全部上云 |
| Typeless | 云端听写，中英混说口碑好 | 免费限字；Pro $12–30/月 | 云 | 中文用户说混说最准；要上云 |
| Willow Voice | YC 公司，云端听写 | 免费档；Pro $12–15/月 | 云 | 官网没提中文 |
| Aqua Voice | YC 公司，纯云端 | 免费 1,000 词；$8–30/月 | 云，无离线 | 支持普通话 |
| **D. 中文输入法与中文工具** | | | | |
| 微信输入法 Mac ✔ | 免费，长按 fn 说话，支持中英混说 | 免费 | 云 | 混说 + 润色都免费，但语音上传腾讯 |
| 豆包输入法 | 字节的输入法，宣称中英混输 | 官网没写 | 官网没写 | 用户说中文快，混说不行 |
| 闪电说 | 国产，本地优先 | 免费；Pro ¥19.9/月 | 宣称本地优先 | 有本地档；用户说混说的英文弱 |
| LazyTyper | 国产，Win + Mac | 免费 | 说法自相矛盾 | 宣称有本地模型，FAQ 又说要联网 |
| CapsWriter-Offline ✔ | 中文开源本地，最火 | 免费 | 本地 | **不支持 Mac** |
| **E. 系统和大厂免费提供的** | | | | |
| macOS 自带听写 | 系统自带 | 免费 | 本地（Apple Silicon，含普通话） | 不能按住说话、不能混说 |
| Apple SpeechAnalyzer | 苹果给开发者的识别接口 | 免费 | 本地，模型由系统管理 | app 不用带模型，比 whisper 快 |
| Google AI Edge Eloquent | 谷歌出的 Mac 听写 app | 官方没写（报道说免费） | 本地 | 有 AI 改写；首发只支持英文（报道） |

---

## 二、逐个说明

### A. 免费开源、本地运行

这一组和本项目最像：免费、本地、开源，而且都比本项目多一个图形界面。

#### Handy ✔
- **是什么**：免费开源的本地听写 app，支持 Whisper 和 Parakeet 两类模型。
- **价格**：免费，接受捐赠。官网原话："Accessibility tooling belongs in everyone's hands, not behind a paywall."
- **开源**：MIT 协议，GitHub 34,057★（10-17）。
- **隐私**：隐私政策原文 "Handy does not contain advertising, behavioral analytics, or user-tracking telemetry"；音频和转写内容不发给维护者或他们的服务器；云端后处理默认关闭。
- **模型体积**：487 MB–1.6 GB，推荐 Parakeet 731 MB。
- **中文**：官方没宣称支持中文。代码里有简繁转换库，但没核实效果。
- **热度**：Hacker News 237 分（2025-09）；第一个版本发布于 2025-06。
- **和本项目比**：同样免费、本地、不带统计，功能还更全（有界面、能选模型）。本项目「本地 + 干净」这两点，它都已经免费做到了。

#### Ghost Pepper ✔
- **是什么**：Mac 上的本地按住说话工具。它在 Hacker News 发布时的标题 "Local hold-to-talk speech-to-text for macOS"，和本项目是同一句话。
- **价格**：免费。
- **开源**：源码公开，但没声明许可证；GitHub 3,207★。
- **隐私**：README 原文 "No Firebase, Mixpanel, Sentry, or any tracking SDK"、"No cloud APIs, no data leaves your machine"。
- **模型体积**：默认 small.en，约 466 MB；安装包 26 MB。
- **中文**：默认模型是纯英文模型（small.en）。
- **热度**：Hacker News 467 分（2026-04-06）。作者自己说："spicy to offer something for free that other apps have raised $80M to build"。
- **和本项目比**：点子完全一样，多了 app 界面；但默认不认中文。

#### OpenWhispr ✔（星数）
- **是什么**：开源听写 app，本地使用免费，云端功能收费。
- **价格**：免费档 "Unlimited local dictation is free for everyone"；Pro $6.67/人/月（年付 $80）；Business $13.33/人/月。
- **开源**：MIT 协议，GitHub 9,528★。
- **隐私**：README 原文 "No data collection, no telemetry, fully open source"；依赖清单里没发现统计 SDK。
- **模型体积**：75 MB–1.6 GB；安装包 313 MB（基于 Electron）。
- **中文**：语言列表里有「中文」，还带简繁转换。
- **热度**：自称 15 万+ 下载。
- **和本项目比**：支持中文、有界面，本地免费；代价是安装包大，而且有云端付费档。

#### VoiceInk ✔（星数）
- **是什么**：开源的本地听写 app，作者卖编译好的版本。
- **价格**：$25（1 台 Mac）/ $39（2 台）/ $49（3 台），一次买断，终身更新；源码 GPL，自己编译可以免费用。
- **开源**：GPL-3.0，GitHub 6,848★。
- **隐私**：官网 "Your voice data never leaves your Mac"；依赖清单里没发现统计 SDK。
- **体积**：安装包 48 MB。
- **热度**：自称 20 万+ 下载，13,469+ 用户。
- **和本项目比**：这是「开源 + 卖买断」的典型做法，也是本项目如果要收费最接近的参照；它已经做了，而且有界面。

#### FluidVoice
- **是什么**：开源的本地听写 app，可选的模型很多，包括苹果自带引擎。
- **价格**：免费。
- **开源**：GPL-3.0（2026-02 之前是 Apache-2.0），GitHub 12,267★。
- **隐私**：**匿名统计默认开启**（README 自己写明），收集安装 ID、活跃日期、版本、系统；不收音频和文字；可在设置里关闭。官网写着 "0 bytes leave this Mac"，和默认开统计有出入。
- **模型体积**：75 MB–2.9 GB。
- **热度**：自称 35 万+ 下载。
- **和本项目比**：功能多，但「干净」打了折扣。

#### VoiceTypr
- **是什么**：开源的本地听写 app，卖终身授权。
- **价格**：$69 一次买断（2 台设备），3 天免费试用。
- **开源**：AGPL-3.0。
- **隐私**：官网写 "Offline by default"；但依赖清单（Cargo.toml）里有 `posthog-rs`（PostHog 统计 / 错误追踪）。官网说设置里有诊断和统计的开关。
- **中文**：官网没点名中文。
- **和本项目比**：宣传本地，实际带了统计 SDK，说明「干净」需要逐个审计，不能只信宣传。

### B. 独立开发者的付费 app

这一组证明有人愿意付钱，但他们都有界面、有打磨，而且基本都有免费档。

#### superwhisper ✔
- **是什么**：Mac 听写的头部产品，本地和云端都支持。
- **价格**：免费档原文 "Voice to text that works in any app / Support for 100+ Languages / Unlimited use of Whisper models / Custom prompt control"，永久免费；Pro $8.49/月；终身版约 $250（报道）。
- **隐私**：隐私政策 "We do not collect any usage data when you use Superwhisper"。
- **生意**：✔ Globe and Mail（2026-05-12）报道：收入 "modest, in the seven-figures, but growing quickly"，"hundreds of thousands of weekly active users"，没拿外部融资，6 名员工 + 5 名合同工。BetaKit（2026-10）报道：收入在从个人用户转向企业客户。
- **和本项目比**：免费档已经包含本项目的全部功能（本地 whisper、任意 app 里输入），还多了界面和自定义提示词。它的钱来自打磨、云端功能和企业单，不是来自「本地」。

#### MacWhisper
- **是什么**：老牌 Mac 转写 app，主打把音频和视频文件转成文字。
- **价格**：免费；Pro €64 一次买断，终身更新。
- **隐私**：官网 "Process sensitive content locally without data ever leaving your Mac"。
- **中文**：官网说支持 100 种语言，没点名中文。
- **热度**：Gumroad 评分 2,779 条，平均 4.5；没公开过收入。
- **和本项目比**：重点在文件转写，不是按住说话。

#### Spokenly
- **是什么**：听写 app，**默认用云端模型**，也免费提供本地的 Whisper 和 Parakeet。
- **价格**：免费 "$0 forever"（本地模型不限量、可离线）；Local+ $29 一次买断；Pro $99.99/年。
- **隐私**：平时会发匿名使用统计（例如选了哪个模型）；开启 Local Only 模式后连统计也会拦掉。
- **中文**：界面支持简体和繁体中文；它的本地润色模型对中文效果较弱（官方自己说）。
- **背景**：一个人开发。
- **和本项目比**：本地档也免费，但默认走云。

#### Sotto
- **是什么**：本地优先的听写 app，一次买断。
- **价格**：$49 一次买断，可用于 3 台 Mac。
- **隐私**：官网 "100% local by default — audio never leaves your Mac"；但 /privacy、/privacy-policy、/legal/privacy 都返回 Page not found（10-18 复查），找不到隐私政策。
- **模型体积**：66 MB–2.7 GB。
- **中文**：官网说支持 90+ 种语言，没点名中文。
- **和本项目比**：同样主打本地，收 $49。

#### BetterDictation
- **是什么**：用苹果神经引擎做本地听写，Pro 版用 OpenAI 润色。
- **价格**：Basic $39 终身；Flex $49 终身 + Pro $2/月；Studio $149。
- **隐私**：首页说 "nothing ever leaves your Mac"，但隐私政策承认会发送 "basic telemetry data"（性能和崩溃报告）。
- **中文**：官网 FAQ 列了中文。
- **热度**：自称 6,000+ 用户。
- **和本项目比**：本地 + 付费买断，但不是零遥测。

#### Whisper Notes
- **是什么**：多引擎的本地转写 app，四个本地引擎里包括 **SenseVoice（中文、粤语都支持）**、Qwen3-ASR 和苹果自带引擎。
- **价格**：App Store $7.99 一次买断；Mac 直装版每周免费 5,000 词，超出后 $14 一次买断。
- **数据**：官方测试里，SenseVoice 转 27 分钟中文播客用 13.83 秒，Whisper Large V3 Turbo 用 2 分 4 秒（M4 Pro）；苹果引擎在中文测试集上的错误率与 Whisper Large V3 Turbo 相同（7.97%）。
- **热度**：Mac App Store 656 条评分，平均 4.68。
- **和本项目比**：中文已经有更快的本地引擎，价格只要 $14。本项目只用 whisper 一个引擎。

### C. 云端 + AI 润色

这一组卖的是准确率和 AI 润色（去口水词、改写），语音都要上云。

#### Wispr Flow ✔（融资）
- **是什么**：融资最多的听写产品，云端转写 + AI 润色。
- **价格**：免费档；Pro $15/月（年付 $12/月）；Growth $23/月（年付 $18/月）；企业版另谈。
- **隐私**：隐私政策原文 "Transcription always happens in the cloud"；音频转写完就删，除非开了云端存储；会读取你正在输入的 app 里的少量文字做上下文（可关）。
- **生意**：截至 2025-11 共融资 $8,100 万，估值 $7 亿（TechCrunch）；2026-08 B 轮 $2.8 亿，估值 $20 亿（Wikipedia 引 Reuters，Reuters 原文未打开）。
- **和本项目比**：准确率和润色强，但所有语音都上云，和「本地」是两条路。

#### Typeless
- **是什么**：云端听写。
- **价格**：免费档有字数限制；Pro 年付 $12/月，月付 $30。
- **中文**：V2EX 用户原话「Typeless 这个中英文混输的时候，识别准确率非常高」，也有人嫌月付 $30 太贵。
- **和本项目比**：中英混说是它的强项，正好是本项目唯一可能的缺口；但它是云端的。

#### Willow Voice
- **是什么**：YC 公司做的云端听写。
- **价格**：免费档；Pro $15/月（年付 $12/月）；Business $35/月。
- **隐私**：SOC 2 Type II、HIPAA；号称默认零数据保留。
- **中文**：官网说支持 100+ 种语言，没点名中文。
- **热度**：自称 150,000+ 专业用户。

#### Aqua Voice
- **是什么**：YC W24 公司，纯云端，没有离线模式（FAQ 原话 "there is no offline mode"）。
- **价格**：免费 1,000 词；Pro $8–10/月；Max $24–30/月；Business $19–24/人/月。
- **中文**：FAQ 写支持普通话。
- **隐私**：SOC 2 Type II、ISO 27001；有隐私模式。

### D. 中文输入法与中文工具

中英混说是中文用户的第一大抱怨，但免费的大厂输入法已经在做了（走云端）。

#### 微信输入法 Mac ✔
- **是什么**：腾讯的输入法，Mac 版 2.0（2026-03-22）起支持语音。
- **功能**：更新日志原文「长按「fn」试试语音输入」「语音可实时转写到输入框」「支持连续语音输入不限时长」「支持中文、英文及多种方言自由混说」；2.2.0（2026-05-27）加了「自动去掉说话时的口水词」「智能加标点、分段落」。
- **价格**：免费。
- **隐私**：**云端**。隐私政策 §1.4.3：「我们需上传你输入的语音信息至腾讯的服务器，经过实时处理后，将向你返回文字结果，我们不会储存你输入的语音信息」。离线语音只在手机端有。
- **用户反馈**：有人说只适合很口语化的短输入，长段落错得多；也有人抱怨它占用 fn 键。
- **和本项目比**：同样是按住说话，混说 + 润色都免费，但语音要上传腾讯。

#### 豆包输入法
- **是什么**：字节的输入法，有 Mac 版。官网写「中英混输」「方言识别」「豆包同款语音识别」。
- **价格、本地还是云**：官网都没写。
- **用户反馈**：V2EX 原话「中文输入的话，微信和豆包速度都还不错，就是不能混合输入」。

#### 闪电说
- **是什么**：国产语音输入工具，有 Mac 版。
- **价格**：基础版免费（含本地语音模型）；Pro ¥19.9/月（¥238.8/年）；Max ¥99/月。
- **隐私**：「桌面端客户端会优先在本机处理语音输入」。
- **用户反馈**：有用户说换成豆包 2.0 流式识别后「纯中文的时候识别效率非常高…但是中英文夹杂的时候，英文识别不太好」。
- **和本项目比**：有本地档，中文好，但混说时英文弱。

#### LazyTyper
- **是什么**：国产语音输入，Windows 和 Mac 都有，免费，号称 12 个模型里有 5 个本地。
- **矛盾之处**：FAQ 又说实时语音输入需要联网，和「本地」的说法对不上。

#### CapsWriter-Offline ✔
- **是什么**：中文社区最火的开源离线语音输入。
- **价格**：免费。
- **开源**：MIT 协议，GitHub 6,974★。
- **Mac**：**不支持**。README 原文「MacOS：由于底层的 keyboard 库已放弃支持 MacOS，且系统限制极多，暂时无法支持」，并推荐 Mac 用户去用 LazyTyper 和闪电说。
- **需求信号**：有 Mac 用户在 issue 里提出众筹一台 Mac mini 请作者做 Mac 版。
- **和本项目比**：Mac 上的中文开源本地语音输入，目前几乎没人做（其余能在 Mac 上跑的中文开源项目都不到 300★）。

### E. 系统和大厂免费提供的

平台方已经把「本地识别」做成免费的基础设施。

#### macOS 自带听写
- **本地**：在 Apple Silicon 上，列出的语言本地处理，包括「Mandarin Chinese (China mainland)」，需要先下载语音模型。
- **用法**：按一下快捷键开始、再按一下结束（官方文档没写按住说话）；说多长都行，但 30 秒没声音会自动停。
- **混说**：一次只能用一种语言，中途要手动点光标旁的语言切换。
- **新模型**：macOS 27（2026-09-14 发布）的新听写模型更准，但官网写 "Available in English"，而且要 M3 以上、12 GB 内存。
- **和本项目比**：免费、本地，但不能按住说话，也不能混说。

#### Apple SpeechAnalyzer（开发者接口）
- **是什么**：苹果在 WWDC 2025 推出的语音识别接口，macOS 26 起可用。
- **本地**：完全本地。模型由系统管理，原文 "does not increase the download or storage size of your application"。
- **速度**：MacStories 用一段 34 分钟的视频测试，基于它的 Yap 用了 45 秒，MacWhisper 的 Large V3 Turbo 用了 1 分 41 秒，"no noticeable difference in transcription quality"（英文，只测了一次）。
- **限制**：每个识别器只能设一个语言区域，不支持混说。
- **和本项目比**：任何开发者都能做一个「app 里不带模型」的本地听写，开源的 Yap 已经这么做了，免费。

#### Google AI Edge Eloquent
- **是什么**：谷歌 2026-06-03 发布的 Mac 听写 app。官方原文 "runs 100% on-device"，用快捷键可以在任何 app 里输入，还能用 Gemma 4 12B 做语音改写。
- **价格**：谷歌页面没写。
- **其他**：第三方报道说免费、首发只支持英文、需要 16 GB 内存（报道原文未打开，未核）。

**补充**：有个开源清单 awesome-voice-typing 收了 26 个以上的开源 macOS 听写工具。Hacker News 上从 2025 年起有 77 个 Mac 听写类的 Show HN 发布帖，其中 53 个标题就写着 local / offline / private。

---

## 三、本项目的区别

**有的：**
- **整个工具就一个文件**，`init.lua` 约 470 行，五分钟能读完（中文标点后处理是可选的 `punct.py`）。没有 app、没有账号、没有更新服务器。
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

## 四、为什么没做成产品

判决：**不按「本地 + 小巧 + 干净」做成收费产品，保持自用。**

1. **本地、干净已经是免费标配**（A 组和 E 组）。Handy、Ghost Pepper、OpenWhispr 免费又不带统计；superwhisper 免费档本地不限量；苹果、谷歌都免费提供本地听写。
2. **小巧这一点本项目做不到**：模型 1.6 GB。
3. **付钱的人买的是准确率、AI 润色、企业合规，不是本地**（B 组和 C 组）。
   - Hacker News 13 个帖子共 741 条评论里，提到价格的占 4.5%，推荐免费替代品的占 17%。
   - V2EX 中文帖里提隐私的在 0–6% 之间。
4. **反面证据**：superwhisper 没有外部融资，收入做到了七位数（美元）。但它 2023 年就入场，现在 11 个人，在往企业客户转，卖的是打磨和合规。

**唯一真实的缺口：Mac 上的中英混说（D 组）。**
- 需求是真的：V2EX 帖子「中英混说，语音输入法哪家最强？」，正文只有一句「收费软件也行，有付费意愿。」；CapsWriter-Offline 不支持 Mac。
- 但阻力很大：
  - 微信输入法免费支持混说（走云端）。
  - 用户反馈混说最准的是云端的 Typeless。
  - 没有人公开测过本地模型和云端在混说上谁更准。

**重开条件**：录 20 句自己真实的中英混说（带英文术语、命令名），本地跑 whisper large-v3-turbo、SenseVoice、macOS 自带听写三个引擎，拿微信输入法当对照。最好的本地引擎在英文术语上明显少错，才值得往下想。

## 五、来源

调研时打开的页面，2026-10-17。

```
https://handy.computer/privacy
https://github.com/cjpais/Handy
https://github.com/matthartman/ghost-pepper
https://hn.algolia.com/api/v1/search?query=ghost%20pepper%20speech&tags=story
https://openwhispr.com/pricing
https://github.com/OpenWhispr/openwhispr
https://tryvoiceink.com/
https://github.com/Beingpax/VoiceInk
https://github.com/altic-dev/FluidVoice
https://voicetypr.com/pricing
https://github.com/ideaplexa/voicetypr
https://superwhisper.com/
https://www.theglobeandmail.com/business/article-toronto-ai-startup-superwhisper-dictation-app/
https://betakit.com/superwhisper-cohere-partner-on-meeting-recorder-to-challenge-enterprise-clients/
https://www.macwhisper.com/
https://goodsnooze.gumroad.com/l/macwhisper
https://spokenly.app/pricing
https://spokenly.app/docs/local-only-mode
https://sotto.to/pricing
https://betterdictation.com/privacy
https://whispernotes.app/llms-full.txt
https://wisprflow.ai/pricing
https://techcrunch.com/2025/11/20/as-its-voice-dectation-app-takes-off-wispr-secures-25m-from-notable-capital/
https://en.wikipedia.org/wiki/Wispr_Flow
https://typeless.ai/pricing
https://willowvoice.com/pricing
https://aquavoice.com/pricing
https://z.weixin.qq.com/web/change-log/144
https://z.weixin.qq.com/web/privacy
https://ime.doubao.com/
https://shandianshuo.cn/
https://lazytyper.com/
https://github.com/HaujetZhao/CapsWriter-Offline
https://support.apple.com/en-us/guide/mac-help/mh40584/mac
https://www.apple.com/macos/feature-availability/
https://www.apple.com/apple-intelligence/
https://developer.apple.com/videos/play/wwdc2025/277/
https://www.macstories.net/stories/hands-on-how-apples-new-speech-apis-outpace-whisper-for-lightning-fast-transcription/
https://developers.googleblog.com/bringing-gemma-4-12b-to-your-laptop-unlocking-local-agentic-workflows-with-google-ai-edge/
https://github.com/primaprashant/awesome-voice-typing
https://www.v2ex.com/t/1214538
https://www.v2ex.com/t/1193285
```
