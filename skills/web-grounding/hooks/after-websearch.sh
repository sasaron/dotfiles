#!/bin/bash
set -euo pipefail
cat >/dev/null
msg='WebSearch の結果は、題と URL の一覧と、検索の側のモデルが書いた要約の段落である。どちらもページの原文ではない。答えを書く前に web-grounding スキルを読み、その手順に従う。要約の段落は次に開くページを選ぶ手がかりにだけ使い、事実として書かない。答えに書く文面、数字、版、日付は、開いたページの原文と ~/.claude/skills/web-grounding/scripts/quote_check.py で照合する。「最新」は一覧の全体を見て決める。Sources には開いて確かめた URL だけを並べる。'
jq -n --arg m "$msg" '{hookSpecificOutput: {hookEventName: "PostToolUse", additionalContext: $m}}'
