#!/usr/bin/env python3
# 中文标点后处理：whisper 结果从 stdin 进、stdout 出。没有中文原样输出；有中文就用本地标点模型
# 补上缺的标点（只插标点、不改字，whisper 已有的保留），再把中文旁边的半角标点换成全角。出错一律原样输出。
# 用法：echo "我今天想吃西瓜你看一下现在几点了" | python3 punct.py MODEL_PATH

import sys

# 模型只允许「插入」这些标点；其他任何字符变动都视为失败
ADDED_MARKS = "，。？！、；："
ALL_MARKS = "，。？！；：、,.?!;:…"
OPENING_BRACKETS = "「『（《【“‘("
CLOSING_BRACKETS = "」』）》】”’)"
HALF_TO_FULL = {",": "，", "?": "？", "!": "！", ";": "；", ":": "："}


def is_cjk(ch):
    code = ord(ch)
    if 0x4E00 <= code <= 0x9FFF:
        return True
    if 0x3400 <= code <= 0x4DBF:
        return True
    return False


def is_ascii_alnum(ch):
    return ch.isascii() and ch.isalnum()


def has_cjk(text):
    for ch in text:
        if is_cjk(ch):
            return True
    return False


def is_inside_token(text, k):
    # 3.5 / 1,000 / 3:30 / example.com 里的符号属于词本身，不是句读
    if text[k] not in ",.:":
        return False
    if k == 0 or k == len(text) - 1:
        return False
    return is_ascii_alnum(text[k - 1]) and is_ascii_alnum(text[k + 1])


def prev_non_space(text, k):
    j = k - 1
    while j >= 0 and text[j].isspace():
        j -= 1
    if j < 0:
        return ""
    return text[j]


def next_non_space(text, k):
    j = k + 1
    while j < len(text) and text[j].isspace():
        j += 1
    if j >= len(text):
        return ""
    return text[j]


def drop_trailing_spaces(out):
    while out and out[-1] == " ":
        out.pop()


def to_full_width(text):
    out = []
    k = 0
    while k < len(text):
        ch = text[k]
        if is_inside_token(text, k):
            out.append(ch)
            k += 1
            continue

        before = prev_non_space(text, k)
        after = next_non_space(text, k)
        before_cjk = before != "" and is_cjk(before)
        after_cjk = after != "" and is_cjk(after)

        # 句点只看前面是不是中文：U.S.的 这种英文缩写后面跟中文时不能换
        if ch == "." and before_cjk:
            run_end = k
            while run_end < len(text) and text[run_end] == ".":
                run_end += 1
            drop_trailing_spaces(out)
            if run_end - k >= 2:
                out.append("……")
            else:
                out.append("。")
            k = run_end
            continue

        if ch in HALF_TO_FULL and (before_cjk or after_cjk):
            drop_trailing_spaces(out)
            out.append(HALF_TO_FULL[ch])
            k += 1
            # 全角标点自带间距，吃掉后面的空格
            while k < len(text) and text[k] == " ":
                k += 1
            continue

        out.append(ch)
        k += 1
    return "".join(out)


def touches_existing_mark(out, original, i):
    # 模型常在 whisper 已有的标点旁边再补一个（「西瓜,，你」），或插在引号括号里侧，这种不收
    j = len(out) - 1
    while j >= 0 and out[j].isspace():
        j -= 1
    if j >= 0 and (out[j] in ALL_MARKS or out[j] in OPENING_BRACKETS):
        return True
    while i < len(original) and original[i].isspace():
        i += 1
    if i >= len(original):
        return False
    return original[i] in ALL_MARKS or original[i] in CLOSING_BRACKETS


def splice_marks(original, punctuated):
    # 只把模型新插入的标点放回原文；模型对原文字符的任何改动（拆 GPT-4、3:30 等）都不采用
    out = []
    i = 0
    j = 0
    while j < len(punctuated):
        ch = punctuated[j]
        if i < len(original) and ch == original[i]:
            out.append(ch)
            i += 1
            j += 1
        elif ch in ADDED_MARKS:
            j += 1
            if touches_existing_mark(out, original, i):
                continue
            out.append(ch)
            # 标点顶替了原文里的空格（「你好 世界」→「你好，世界」）
            while i < len(original) and original[i] == " ":
                i += 1
        elif ch.isspace():
            j += 1
        elif i < len(original) and original[i].isspace():
            out.append(original[i])
            i += 1
        elif i < len(original) and original[i] in ALL_MARKS:
            # 模型丢掉或换掉了 whisper 原有的标点：保留原文的
            out.append(original[i])
            i += 1
        else:
            return None

    while i < len(original):
        if original[i].isspace():
            i += 1
        elif original[i] in ALL_MARKS:
            out.append(original[i])
            i += 1
        else:
            return None
    return "".join(out).strip()


def punctuate_with_model(text, model_path):
    import sherpa_onnx

    config = sherpa_onnx.OfflinePunctuationConfig(
        model=sherpa_onnx.OfflinePunctuationModelConfig(ct_transformer=model_path),
    )
    model = sherpa_onnx.OfflinePunctuation(config)
    return model.add_punctuation(text)


def process(text, model_path):
    text = text.strip()
    if text == "" or not has_cjk(text):
        return text
    spliced = splice_marks(text, punctuate_with_model(text, model_path))
    if spliced is None:
        spliced = text
    return to_full_width(spliced)


def main():
    raw = ""
    try:
        raw = sys.stdin.read()
        result = process(raw, sys.argv[1])
    except Exception as err:
        print("punct.py: " + repr(err), file=sys.stderr)
        result = raw.strip()
    sys.stdout.write(result)


if __name__ == "__main__":
    main()
