---
name: deep-research
description: 包括的な調査を実施し、構造化されたレポートを生成します。複数のソースから情報を収集し、交差検証を行い、エビデンスベースの洞察を提供します。技術調査、市場分析、競合分析、アーキテクチャ選定などで使用します。
argument-hint: "[research topic]"
disable-model-invocation: true
allowed-tools: ["AskUserQuestion", "WebSearch", "WebFetch", "Bash", "Read", "Grep", "Glob"]
---

# Deep Research

包括的な調査を実施し、エビデンスに基づいた構造化レポートを生成するスキルです。

## 📋 調査フロー

調査は以下の5フェーズで進行します：

### Phase 1: Wait for User Input
- ユーザーから調査トピックの入力を待つ
- 明示的な質問や指示があるまで開始しない

### Phase 2: Clarify Scope
- `AskUserQuestion`ツールで調査スコープを対話的に確認
- 以下を明確化：
  - 調査の目的（技術選定、市場分析、競合調査など）
  - 重視する観点（セキュリティ、パフォーマンス、コストなど）
  - 対象範囲（特定技術、期間、地域など）
  - 成果物の用途（意思決定、提案書、技術文書など）

### Phase 3: Research Plan
- トピックを3～8個のサブ質問に分解
- 各サブ質問に対する調査戦略を立案
- 情報源の優先順位を設定（公式ドキュメント > 技術ブログ > フォーラム）

### Phase 4: Iterative Search and Analysis
- **20～50の検索クエリ**を実行
- `WebSearch` - トピックの概要把握、最新情報の収集
- `WebFetch` - 個別ページの詳細分析
- `gh` CLI (via Bash) - GitHub上のリポジトリ、Issue、PR調査
- **交差検証**: 複数ソースで情報を確認
- **一次情報優先**: 公式ドキュメント、リポジトリ、論文を重視

### Phase 5: Synthesis and Report
- Markdown形式で構造化レポートを生成
- 出力形式の詳細は [output-template.md](output-template.md) を参照

## 🎯 使用タイミング

以下のような調査が必要な場合に使用：

- **技術選定**: ライブラリ、フレームワーク、ツールの比較評価
- **アーキテクチャ調査**: 設計パターン、ベストプラクティスの調査
- **市場分析**: 競合製品、業界トレンドの分析
- **問題解決**: 技術的課題の原因究明と解決策の調査
- **セキュリティ評価**: 脆弱性、セキュリティパターンの調査

## 🔍 調査ツールの使い分け

| ツール | 用途 | 例 |
|--------|------|-----|
| `WebSearch` | 概要把握、最新情報 | "Claude API structured output best practices" |
| `WebFetch` | 詳細分析 | 公式ドキュメントの特定ページ |
| `gh` CLI | GitHub調査 | `gh api repos/anthropics/anthropic-sdk-python` |
| `Read` | ローカル調査 | プロジェクト内の類似実装を確認 |
| `Grep` | パターン検索 | コードベース内の関連パターン |

## 📊 出力フォーマット

レポートは以下の構造で生成：

```markdown
# [調査トピック]: Deep Research Report

## Executive Summary
- 調査目的
- 主要な発見事項（3～5個）
- 推奨事項

## Table of Contents
- セクション一覧

## [Section 1: トピック名]
### 概要
### 詳細
### エビデンス
- [ソース名](URL) - 引用内容

## [Section 2: ...]

## 結論
- 総合評価
- 推奨アクション
- 未解決の課題

## ソース一覧
1. [タイトル](URL) - 信頼性: High/Medium/Low
2. ...
```

詳細なテンプレートは [output-template.md](output-template.md) を参照。

## 🎨 ベストプラクティス

### 情報源の評価
- ✅ **一次情報**: 公式ドキュメント、リポジトリ、論文
- ✅ **信頼性の高い技術ブログ**: Google Cloud Blog, AWS Blog, Vercel Blog
- ⚠️ **コミュニティ情報**: Stack Overflow, Reddit（複数ソースで検証）
- ❌ **避けるべき**: 古い情報、不明確な出典

### 引用管理
- HTMLアンカータグを使用: `[ソース名](URL){:target="_blank"}`
- 引用には必ず出典URLを明記
- 複数ソースで同じ情報を確認

### 検索戦略
- **広く浅く → 深く**: まず全体像を把握してから詳細調査
- **時系列考慮**: "2024" "2025" など年を指定して最新情報を取得
- **多角的視点**: 技術的、ビジネス的、セキュリティ的視点で調査

### 効率化
- 並列検索を活用（複数の独立したトピックは同時調査）
- GitHub APIで効率的にリポジトリ情報を取得
- WebSearchで候補を絞り、WebFetchで詳細を確認

## 🚫 禁止事項

- ❌ スコープ確認なしで調査開始
- ❌ 単一ソースのみでの結論
- ❌ 出典不明の情報の引用
- ❌ 古い情報（2年以上前）の無批判な採用
- ❌ 推測や憶測に基づく記述（必ず "推測" と明示）

## 📚 詳細ガイド

各フェーズの詳細な実行手順は [phases.md](phases.md) を参照。

## 使用例

```bash
# 技術選定
/deep-research Next.js vs Remix for enterprise apps

# セキュリティ調査
/deep-research OAuth 2.0 implementation security best practices

# アーキテクチャ調査
/deep-research microservices vs monolith for SaaS platform
```

## 📝 Tips

- 調査開始前に`AskUserQuestion`で必ずスコープを確認
- 20～50の検索クエリが目安（少なすぎる場合は網羅性不足）
- 情報の鮮度を確認（特に技術分野は変化が早い）
- 矛盾する情報は両論併記し、信頼性の高いソースを優先
- 最終レポートは意思決定に使えるレベルの具体性を持たせる
