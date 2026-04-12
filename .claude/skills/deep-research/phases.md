# Deep Research フェーズ別実行ガイド

各フェーズの詳細な実行手順とチェックリストです。

## Phase 1: Wait for User Input

### 目的
- ユーザーからの明示的な調査依頼を待つ
- 自律的な調査開始を防ぐ（`disable-model-invocation: true`）

### チェックリスト
- [ ] ユーザーが調査トピックを明示しているか確認
- [ ] `/deep-research [topic]` の形式で呼び出されているか確認
- [ ] 質問形式の場合は調査を開始せず、質問に答える

### 注意事項
- ユーザーが単に質問している場合は調査を開始しない
- 「調査してください」「リサーチしてください」などの明示的な指示を待つ

---

## Phase 2: Clarify Scope

### 目的
- 調査範囲を明確化し、効率的な調査を実現
- ユーザーの期待と調査方針をアラインメント

### 実行手順

#### 1. AskUserQuestionで以下を確認

```markdown
以下の点について確認させてください：

1. **調査の目的**
   - 技術選定、アーキテクチャ決定、問題解決、市場分析など

2. **重視する観点** (優先順位をつけてください)
   - パフォーマンス
   - セキュリティ
   - 開発体験
   - コスト
   - スケーラビリティ
   - メンテナンス性
   - その他: _____

3. **対象範囲**
   - 特定の技術バージョン（例: React 18+）
   - 期間（例: 2024年以降の情報）
   - 規模（例: エンタープライズ向け）

4. **成果物の用途**
   - 意思決定資料
   - 提案書
   - 技術文書
   - 学習用
```

#### 2. 回答を整理

```markdown
## 調査スコープ

- **トピック**: [ユーザー指定のトピック]
- **目的**: [確認した目的]
- **重視する観点**: [優先順位付きリスト]
- **対象範囲**: [制約条件]
- **成果物**: [レポートの用途]
```

### チェックリスト
- [ ] 調査目的が明確か
- [ ] 評価軸が3つ以上定義されているか
- [ ] 対象範囲の制約が明示されているか
- [ ] 成果物の用途が明確か

---

## Phase 3: Research Plan

### 目的
- 調査を構造化し、網羅性を確保
- 効率的な情報収集戦略を立案

### 実行手順

#### 1. トピックをサブ質問に分解（3～8個）

例: "Next.js vs Remix for enterprise apps"

```markdown
## Research Plan

### Core Questions
1. パフォーマンス: SSR/SSG/ISRの実装と性能は？
2. 開発体験: DX、エコシステム、学習曲線は？
3. エンタープライズ対応: 認証、認可、セキュリティ機能は？
4. スケーラビリティ: 大規模アプリでの実績は？
5. コスト: ホスティング、運用コストは？
6. 採用状況: 企業での採用事例、コミュニティサイズは？
7. 移行容易性: 既存アプリからの移行難易度は？
```

#### 2. 情報源の優先順位を設定

| 優先度 | 情報源 | 例 |
|--------|--------|-----|
| 1 (最優先) | 公式ドキュメント | Next.js公式、Remix公式 |
| 2 (高) | 公式ブログ、リポジトリ | Vercel Blog, GitHub Issues |
| 3 (中) | 信頼性の高い技術ブログ | LogRocket, CSS-Tricks |
| 4 (低) | コミュニティ | Stack Overflow, Reddit |

#### 3. 検索戦略を立案

```markdown
## Search Strategy

### Phase 1: Overview (5-10 searches)
- "Next.js vs Remix comparison 2025"
- "Remix enterprise use cases"
- "Next.js scalability limitations"

### Phase 2: Deep Dive (15-30 searches)
- 各サブ質問に対して2～5個の検索クエリ
- 公式ドキュメントの該当セクション
- GitHub Issues/Discussions

### Phase 3: Validation (5-10 searches)
- 実装事例、ベンチマーク結果
- セキュリティ脆弱性情報
- 最新のロードマップ、アップデート
```

### チェックリスト
- [ ] 3～8個のサブ質問が定義されているか
- [ ] 各サブ質問が調査可能な具体性を持つか
- [ ] 情報源の優先順位が設定されているか
- [ ] 20～50の検索クエリが計画されているか

---

## Phase 4: Iterative Search and Analysis

### 目的
- 計画に基づいて情報を収集
- 複数ソースで交差検証
- エビデンスを蓄積

### 実行手順

#### 1. Overview検索（広く浅く）

```bash
# WebSearchで全体像を把握
WebSearch("Next.js vs Remix 2025")
WebSearch("Remix enterprise adoption")
WebSearch("Next.js performance benchmarks")
```

収集した情報から：
- 主要な論点を特定
- 詳細調査が必要なトピックを洗い出し
- 信頼性の高いソースをピックアップ

#### 2. Deep Dive検索（深く詳しく）

```bash
# WebFetchで詳細分析
WebFetch("https://nextjs.org/docs/app/building-your-application/rendering")
WebFetch("https://remix.run/docs/en/main/guides/performance")

# GitHub調査
gh api repos/vercel/next.js | jq '.stargazers_count, .open_issues_count'
gh api repos/remix-run/remix | jq '.stargazers_count, .open_issues_count'
gh search issues --repo vercel/next.js "enterprise authentication" --limit 10
```

各サブ質問ごとに：
- 最低2つのソースで確認
- 矛盾する情報は両論併記
- エビデンスのURLを記録

#### 3. Validation検索（検証と最新化）

```bash
# 最新情報の確認
WebSearch("Next.js security vulnerabilities 2025")
WebSearch("Remix roadmap 2025")

# 実装事例
WebSearch("Next.js enterprise case studies")
gh search code "remix enterprise" --language typescript
```

### 並列検索の活用

独立したサブ質問は並列で調査：

```bash
# 並列実行可能
WebSearch("Next.js performance") & WebSearch("Remix performance")
WebFetch("https://nextjs.org/docs/security") & WebFetch("https://remix.run/docs/security")
```

### 情報の記録フォーマット

各検索結果を以下の形式で記録：

```markdown
### [サブ質問1: パフォーマンス]

**情報**: Next.jsはISR (Incremental Static Regeneration) をサポート

**エビデンス**:
- [Next.js ISR Documentation](https://nextjs.org/docs/basic-features/data-fetching/incremental-static-regeneration) - 公式ドキュメント
- [Vercel Blog: ISR Performance](https://vercel.com/blog/...) - ベンチマーク結果

**信頼性**: High（公式ドキュメント）

**相反する情報**: なし
```

### チェックリスト
- [ ] 20～50の検索クエリを実行したか
- [ ] 各サブ質問に最低2つのソースがあるか
- [ ] 公式ドキュメントを最優先で確認したか
- [ ] GitHub Issues/PRで既知の問題を確認したか
- [ ] 情報の日付（鮮度）を確認したか
- [ ] 矛盾する情報は両論併記したか

---

## Phase 5: Synthesis and Report

### 目的
- 収集した情報を構造化
- 意思決定に使えるレポートを生成

### 実行手順

#### 1. Executive Summaryの作成

```markdown
## Executive Summary

**調査トピック**: [トピック名]

**目的**: [Phase 2で確認した目的]

**主要な発見事項**:
1. [最も重要な発見] - [エビデンス]
2. [2番目に重要な発見] - [エビデンス]
3. [3番目に重要な発見] - [エビデンス]

**推奨事項**:
[調査結果に基づく具体的な推奨]
```

#### 2. 本文セクションの構成

各サブ質問を1つのセクションに：

```markdown
## 1. パフォーマンス比較

### 概要
[サブ質問に対する結論を2～3文で]

### Next.jsの特徴
- SSR: [詳細]
  - エビデンス: [ソース1](URL), [ソース2](URL)
- ISR: [詳細]
  - エビデンス: [ソース](URL)

### Remixの特徴
- Nested Routing: [詳細]
  - エビデンス: [ソース](URL)

### ベンチマーク結果
| 指標 | Next.js | Remix | ソース |
|------|---------|-------|--------|
| TTFB | 50ms | 45ms | [Benchmark](URL) |

### 評価
[比較結果のサマリー]
```

#### 3. 結論セクション

```markdown
## 結論

### 総合評価
[全体を通しての評価]

### ユースケース別推奨
| ユースケース | 推奨 | 理由 |
|-------------|------|------|
| 大規模エンタープライズ | Next.js | [理由] |
| 高速な読み込み重視 | Remix | [理由] |

### 推奨アクション
1. [具体的なアクション1]
2. [具体的なアクション2]

### 未解決の課題
- [さらに調査が必要な項目]
- [技術的制約]
```

#### 4. ソース一覧

```markdown
## ソース一覧

### 公式ドキュメント (信頼性: High)
1. [Next.js Documentation](URL) - 公式ドキュメント
2. [Remix Documentation](URL) - 公式ドキュメント

### 技術ブログ (信頼性: High-Medium)
3. [Vercel Blog: Next.js Performance](URL)
4. [LogRocket: Remix vs Next.js](URL)

### コミュニティ (信頼性: Medium-Low)
5. [Stack Overflow: Next.js scalability](URL)

### GitHub (信頼性: High)
6. [vercel/next.js](https://github.com/vercel/next.js)
7. [remix-run/remix](https://github.com/remix-run/remix)
```

### 品質チェック

レポート完成前に確認：

- [ ] Executive Summaryは1ページ以内か
- [ ] 各セクションに最低2つのエビデンスがあるか
- [ ] 矛盾する情報は両論併記されているか
- [ ] 推奨事項は具体的か（"検討すべき"ではなく具体的なアクション）
- [ ] すべてのソースにURLが記載されているか
- [ ] 情報の鮮度が明記されているか（特に2年以上前の情報）
- [ ] 未解決の課題が明示されているか

### 出力形式

Markdownファイルとして出力、またはチャット内に直接表示。

完全なテンプレートは [output-template.md](output-template.md) を参照。

---

## 全体を通してのベストプラクティス

### 効率化
- 独立したサブ質問は並列で調査
- WebSearchで候補を絞り、WebFetchで詳細確認
- GitHub APIで効率的にリポジトリ情報を取得

### 品質担保
- 単一ソースのみでの結論を避ける
- 公式ドキュメントを最優先
- 古い情報（2年以上前）は注意書きを付ける
- 推測と事実を明確に区別

### ユーザーとの対話
- Phase 2でスコープを確実に確認
- 調査中に新たな疑問が生じた場合はユーザーに確認
- 最終レポートの形式についても確認（詳細度、技術レベル）
