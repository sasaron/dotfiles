#!/usr/bin/env python3
"""ページの原文に、引用する文面や数字がそのまま載っているかを確かめる。

使い方:
  quote_check.py <URL> '<引用>' ['<引用>' ...]
  quote_check.py --file claims.tsv     # 1 行に「URL<TAB>引用」

WebFetch の要約や検索結果の抜粋ではなく、curl で取った原文を見る。
比べる前に、両方を NFKC で正規化し、空白を詰め、引用符とダッシュをそろえる。
見つからないときは、原文で最も近い箇所と似ている度合いを表示する。
似ているが一致しないものは、言い換えか記憶違いなので、原文の文面に直す。
PDF は pdftotext があれば文字にして比べる。
終了コードは、見つからない引用が 1 つでもあれば 1、取得に失敗すれば 2。
"""
import difflib
import html
import re
import shutil
import subprocess
import sys
import tempfile
import unicodedata

QUOTES = str.maketrans({"“": '"', "”": '"', "„": '"', "‘": "'", "’": "'", "‐": "-", "‑": "-", "–": "-", "—": "-", "−": "-"})


def norm(s: str) -> str:
    s = unicodedata.normalize("NFKC", s).translate(QUOTES)
    return re.sub(r"\s+", " ", s).strip().lower()


def fetch(url: str):
    r = subprocess.run(
        ["curl", "-s", "-L", "--max-time", "40", "-A", "Mozilla/5.0", "-w", "\n%{http_code} %{content_type}", url],
        capture_output=True,
    )
    raw, _, tail = r.stdout.rpartition(b"\n")
    code, _, ctype = tail.decode("ascii", "replace").partition(" ")
    if code != "200":
        return None, f"状態 {code or '接続できない'}"
    if "pdf" in ctype or raw[:5] == b"%PDF-":
        if not shutil.which("pdftotext"):
            return None, "PDF だが pdftotext がない"
        with tempfile.NamedTemporaryFile(suffix=".pdf") as f:
            f.write(raw)
            f.flush()
            out = subprocess.run(["pdftotext", "-layout", f.name, "-"], capture_output=True)
        return out.stdout.decode("utf-8", "replace"), "PDF"
    t = raw.decode("utf-8", "replace")
    if "html" not in ctype:
        return t, ctype or "種類不明"
    t = re.sub(r"<(script|style|noscript)\b.*?</\1>", " ", t, flags=re.S | re.I)
    t = html.unescape(re.sub(r"<[^>]+>", " ", t))
    return t, "HTML"


def nearest(text: str, quote: str):
    n = len(quote)
    best, best_ratio = "", 0.0
    step = max(1, n // 4)
    for i in range(0, max(1, len(text) - n + 1), step):
        w = text[i: i + n]
        r = difflib.SequenceMatcher(None, quote, w).ratio()
        if r > best_ratio:
            best, best_ratio = w, r
    return best, best_ratio


def main() -> int:
    args = sys.argv[1:]
    if not args:
        print(__doc__)
        return 2
    pairs = []
    if args[0] == "--file":
        for line in open(args[1], encoding="utf-8"):
            if line.strip() and "\t" in line:
                u, q = line.rstrip("\n").split("\t", 1)
                pairs.append((u, q))
    else:
        pairs = [(args[0], q) for q in args[1:]]
    cache, missing, failed = {}, 0, 0
    for url, quote in pairs:
        if url not in cache:
            cache[url] = fetch(url)
            body, kind = cache[url]
            if body is None:
                print(f"\n{url}\n  取得できない: {kind}")
            else:
                n = len(norm(body))
                print(f"\n{url}\n  {kind}、本文 {n} 文字" + ("。本文がほとんどない。JavaScript で描画するページなら、ブラウザで本文を取る" if n < 500 else ""))
        body, _ = cache[url]
        if body is None:
            failed += 1
            continue
        text, q = norm(body), norm(quote)
        if q in text:
            i = text.index(q)
            print(f"  あり  「{quote}」\n        …{text[max(0, i - 50): i + len(q) + 50]}…")
            continue
        missing += 1
        near, ratio = nearest(text, q)
        print(f"  なし  「{quote}」\n        最も近い箇所（{ratio:.0%}）: …{near}…")
    return 2 if failed else (1 if missing else 0)


if __name__ == "__main__":
    sys.exit(main())
