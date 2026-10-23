#!/usr/bin/env python3
# punct.py 的最小检查：~/.local/whisper-dictation/punct-venv/bin/python -I test_punct.py [MODEL_PATH]
# 不给 MODEL_PATH 时只跑不需要模型的部分，模型用例报 SKIP。

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import punct  # noqa: E402

# 英文 / 静音幻觉：不经过模型，一个字都不许动
NO_CJK_CASES = [
    "Can you check the build? It failed again, so I want to know why.",
    "Thank you.",
    "- Didi da, didi da.",
]

WIDTH_CASES = [
    ("我今天想吃西瓜,你看一下现在几点了。", "我今天想吃西瓜，你看一下现在几点了。"),
    ("这个feature下周上线,你先把PR review 一下.", "这个feature下周上线，你先把PR review 一下。"),
    ("我用了GitHub, 然后发现问题", "我用了GitHub，然后发现问题"),
    ("world ,好的", "world，好的"),
    ("我想想...", "我想想……"),
    ("我想想..", "我想想……"),
    ("U.S.的政策变了", "U.S.的政策变了"),
    ("版本3.5价格1,000时间3:30", "版本3.5价格1,000时间3:30"),
]

SPLICE_CASES = [
    # (原文, 模型输出, 期望)：只收新插入的标点，模型改坏的词一律按原文
    ("下午3:30开会别迟到", "下午3 : 30开会，别迟到。", "下午3:30开会，别迟到。"),
    ("用GPT-4测一下", "用GPT - 4测一下。", "用GPT-4测一下。"),
    ("你好 世界", "你好，世界。", "你好，世界。"),
    ("PR review 一下", "PR review一下。", "PR review 一下。"),
    # whisper 已有标点旁边模型再补的不收；中间缺的补上
    ("西瓜,你看一下几点了我还想去", "西瓜,，你看一下，几点了，我还想去。", "西瓜,你看一下，几点了，我还想去。"),
    ("几点了。", "几点了。。", "几点了。"),
    ("我想想...", "我想想，. . .。", "我想想..."),
    # 不往引号括号里侧插
    ("他说「算了吧」我觉得再试试", "他说「算了吧，」我觉得再试试。", "他说「算了吧」我觉得再试试。"),
    ("（备注）明天交", "（，备注）明天交。", "（备注）明天交。"),
    # 模型把原有标点换掉或丢掉 → 保留原文的
    ("西瓜,你好", "西瓜，你好。", "西瓜,你好。"),
    ("西瓜,你好", "西瓜你好", "西瓜,你好"),
    # 模型改了字（繁→简之类）→ 放弃，返回 None
    ("這個好用", "这个好用。", None),
    # 模型插了半角标点 → 不在白名单，放弃
    ("好的", "好的.", None),
]

LONG_TEXT = "我今天早上起来先去跑了个步然后回来洗了个澡吃了早饭之后就开始写代码" * 20

MODEL_CASES = [
    ("我今天想吃西瓜你看一下现在几点了", ["西瓜，", "了。"]),
    ("能放草果吗", ["吗？"]),
    ("看到这个录音钟了没有", ["没有？"]),
    ("我今天想吃西瓜,你看一下现在几点了我还想去公园走走你要不要一起去", ["西瓜，", "一起去？"]),
    ("我要买苹果、香蕉还有梨你记一下清单明天去超市买", ["苹果、香蕉", "买。"]),
    ("版本号是3.5然后价格是12.99美元", ["3.5", "12.99", "美元。"]),
    ("邮件发到test@example.com就行", ["test@example.com"]),
    ("这个feature我们下周上线你先把PR review 一下", ["PR review 一下"]),
    (LONG_TEXT, ["，"]),
]


def skeleton(text):
    # 去掉空白和所有标点后剩下的字；处理前后必须一模一样
    kept = []
    for ch in text:
        if ch.isspace() or ch in punct.ALL_MARKS:
            continue
        kept.append(ch)
    return "".join(kept)


def main():
    failures = 0
    total = 0

    for text in NO_CJK_CASES:
        total += 1
        got = punct.process(text, "/nonexistent-model")
        if got != text:
            failures += 1
            print(f"FAIL no-cjk {text!r}: got {got!r}")

    for text, expected in WIDTH_CASES:
        total += 1
        got = punct.to_full_width(text)
        if got != expected:
            failures += 1
            print(f"FAIL width {text!r}: got {got!r}, want {expected!r}")

    for original, model_out, expected in SPLICE_CASES:
        total += 1
        got = punct.splice_marks(original, model_out)
        if got != expected:
            failures += 1
            print(f"FAIL splice {original!r} + {model_out!r}: got {got!r}, want {expected!r}")

    if len(sys.argv) < 2:
        print(f"SKIP {len(MODEL_CASES)} model cases (no MODEL_PATH given)")
    else:
        for text, must_contain in MODEL_CASES:
            total += 1
            got = punct.process(text, sys.argv[1])
            if skeleton(got) != skeleton(text):
                failures += 1
                print(f"FAIL model changed words {text[:30]!r}: got {got[:60]!r}")
            for piece in must_contain:
                if piece not in got:
                    failures += 1
                    print(f"FAIL model {text[:30]!r}: got {got[:60]!r}, missing {piece!r}")

    print(f"{total} cases, {failures} failures")
    if failures:
        sys.exit(1)


if __name__ == "__main__":
    main()
