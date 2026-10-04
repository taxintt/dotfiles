---
name: deep-research
description: 包括的な調査を実施し、構造化されたレポートを生成します。複数のソースから情報を収集し、交差検証を行い、エビデンスベースの洞察を提供します。技術調査、市場分析、競合分析、アーキテクチャ選定などで使用します。
argument-hint: "[research topic]"
disable-model-invocation: true
allowed-tools: ["AskUserQuestion", "WebSearch", "WebFetch", "Bash", "Read", "Grep", "Glob"]
model: opus
---

[共通本文](shared/instructions.md) を読み、手順に従う。本文中の参考資料は shared/ を基準に解決する。

## Claude Codeでの連携

- スコープ確認: `AskUserQuestion`
- Web検索 / ページ取得: `WebSearch` / `WebFetch`
- ローカル調査: `Read` / `Grep`、GitHub調査: Bash経由の`gh`
- 明示呼び出し: `/deep-research [topic]`
