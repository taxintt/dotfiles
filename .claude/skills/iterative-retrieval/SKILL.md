---
name: iterative-retrieval
description: コンテキスト取得を段階的に絞り込み、subagent のコンテキスト問題を解消するためのパターン
---

# Iterative Retrieval パターン

マルチエージェントワークフローにおいて、subagent が作業を始めるまで「自分に必要なコンテキストが何か」を知らない、という「コンテキスト問題」を解消する。

## 問題

subagent は限られたコンテキストで起動される。以下が事前には分からない:
- 関連コードを含むファイルがどれか
- コードベースに存在するパターン
- プロジェクト固有の用語

標準的なアプローチはいずれも破綻する:
- **すべて渡す**: コンテキスト制限を超える
- **何も渡さない**: agent が重要情報を欠く
- **必要なものを推測する**: しばしば外す

## 解決策: Iterative Retrieval

コンテキストを段階的に絞り込む 4 フェーズのループ:

```
┌─────────────────────────────────────────────┐
│                                             │
│   ┌──────────┐      ┌──────────┐            │
│   │ DISPATCH │─────▶│ EVALUATE │            │
│   └──────────┘      └──────────┘            │
│        ▲                  │                 │
│        │                  ▼                 │
│   ┌──────────┐      ┌──────────┐            │
│   │   LOOP   │◀─────│  REFINE  │            │
│   └──────────┘      └──────────┘            │
│                                             │
│        最大 3 サイクル、その後次へ進む       │
└─────────────────────────────────────────────┘
```

### Phase 1: DISPATCH

候補ファイルを集めるための初回の広いクエリ:

```javascript
// 高レベルの意図から始める
const initialQuery = {
  patterns: ['src/**/*.ts', 'lib/**/*.ts'],
  keywords: ['authentication', 'user', 'session'],
  excludes: ['*.test.ts', '*.spec.ts']
};

// 取得 agent に dispatch
const candidates = await retrieveFiles(initialQuery);
```

### Phase 2: EVALUATE

取得したコンテンツの関連度を評価する:

```javascript
function evaluateRelevance(files, task) {
  return files.map(file => ({
    path: file.path,
    relevance: scoreRelevance(file.content, task),
    reason: explainRelevance(file.content, task),
    missingContext: identifyGaps(file.content, task)
  }));
}
```

スコアリング基準（anchor 例）:
- **0.9 - 1.0 (High)**: ファイルが target を *実装している*。シンボル名や doc が意図に直接一致（例: task = "auth token expiry" → `auth.ts` 内の `refreshToken()`）。
- **0.7 - 0.8 (Useful)**: target が依存するパターン / 型 / 設定を含む（例: `Token` interface を定義する `session-types.ts`）。
- **0.4 - 0.6 (Adjacent)**: 同じドメインだが別の関心事（例: auth を探している時の `user.ts` — 同じ名前空間だが token ロジックなし）。
- **0.1 - 0.3 (Weak)**: キーワードが 1 つ被っているだけで、実質的な関連なし。
- **0.0 (None)**: 偶然のキーワード一致のみ。除外する。

スコアは「*実際に読んだファイル内容*」に基づいて付ける。パスだけでは判断しない。ファイルを開いていない場合は、スコアを 0.6 で上限打ち切り。

### Phase 3: REFINE

評価結果に基づき検索条件を更新する:

```javascript
function refineQuery(evaluation, previousQuery) {
  return {
    // 高関連ファイルで見つかった新しいパターンを追加
    patterns: [...previousQuery.patterns, ...extractPatterns(evaluation)],

    // コードベースで見つかった用語を追加
    keywords: [...previousQuery.keywords, ...extractKeywords(evaluation)],

    // 無関連が確定したパスを除外
    excludes: [...previousQuery.excludes, ...evaluation
      .filter(e => e.relevance < 0.2)
      .map(e => e.path)
    ],

    // 特定のギャップを狙う
    focusAreas: evaluation
      .flatMap(e => e.missingContext)
      .filter(unique)
  };
}
```

### Phase 4: LOOP

LOOP は **制御フロー** であり、独立した作業フェーズではない — 更新したクエリで DISPATCH → EVALUATE → REFINE を再実行するだけ（最大 3 サイクル）。

以下の **いずれか** が成立したら即停止する。3 サイクル上限まで回す必要はない:
1. **飽和 (Saturation)**: 直近サイクルで relevance ≥ 0.7 の新規ファイルがゼロ。これ以上絞り込んでも出てこない。
2. **新用語なし (No new terminology)**: REFINE で新しいキーワード / パターン / 除外が 1 件も増えない。対象領域の語彙を出し尽くした。
3. **target 充足 (Target covered)**: relevance ≥ 0.9 のファイルが少なくとも 1 件あり、*かつ* EVALUATE で挙がった "missingContext" のギャップがすべて relevance ≥ 0.7 のファイルで埋まっている。

「relevance ≥ 0.7 のファイル 3 件以上」というヒューリスティックは、*大規模コードベース専用の下限*。小さいリポジトリや狭いタスクでは、ギャップなしで 0.9 のファイルが 1 件あれば十分 — 停止してよい。

参考実装（擬似コード — 上記ルールが正本）:

```javascript
async function iterativeRetrieve(task, maxCycles = 3) {
  let query = createInitialQuery(task);
  let best = [];

  for (let cycle = 0; cycle < maxCycles; cycle++) {
    const evaluation = evaluateRelevance(await retrieveFiles(query), task);
    const highRelevance = evaluation.filter(e => e.relevance >= 0.7);

    if (saturated(best, highRelevance) || noNewTerminology(query, evaluation) || targetCovered(highRelevance, evaluation)) {
      return highRelevance;
    }

    query = refineQuery(evaluation, query);
    best = mergeContext(best, highRelevance);
  }
  return best;
}
```

## 実例

### Example 1: バグ修正のコンテキスト取得

```
タスク: "認証トークンの期限切れバグを直す"

Cycle 1:
  DISPATCH: "token", "auth", "expiry" を src/** で検索
  EVALUATE: auth.ts (0.9), tokens.ts (0.8), user.ts (0.3) を発見
  REFINE: "refresh", "jwt" を追加、user.ts を除外

Cycle 2:
  DISPATCH: 絞り込んだ用語で検索
  EVALUATE: session-manager.ts (0.95), jwt-utils.ts (0.85) を発見
  REFINE: 十分なコンテキスト（high-relevance 2 件）

結果: auth.ts, tokens.ts, session-manager.ts, jwt-utils.ts
```

### Example 2: 機能実装

```
タスク: "API エンドポイントにレート制限を追加する"

Cycle 1:
  DISPATCH: "rate", "limit", "api" を routes/** で検索
  EVALUATE: 一致なし — コードベースは "throttle" を使用
  REFINE: "throttle", "middleware" を追加

Cycle 2:
  DISPATCH: 絞り込んだ用語で検索
  EVALUATE: throttle.ts (0.9), middleware/index.ts (0.7) を発見
  REFINE: router のパターンが足りない

Cycle 3:
  DISPATCH: "router", "express" パターンを検索
  EVALUATE: router-setup.ts (0.8) を発見
  REFINE: コンテキスト充足

結果: throttle.ts, middleware/index.ts, router-setup.ts
```

## Agent プロンプトへの統合

agent プロンプトに組み込む:

```markdown
このタスクのコンテキストを取得する際:
1. 広いキーワード検索から始める
2. 各ファイルの関連度を 0-1 スケールで評価する
3. まだ足りないコンテキストを特定する
4. 検索条件を絞り込み、繰り返す（最大 3 サイクル）
5. relevance >= 0.7 のファイルを返す
```

## Best Practices

1. **広く始めて段階的に絞る** - 初回クエリを過剰に specify しない
2. **コードベースの用語を学ぶ** - 最初のサイクルで命名規則が見える
3. **足りないものを追跡する** - ギャップを明示すると refine が動く
4. **「十分」で止める** - 高関連 3 件は凡庸な 10 件に勝る
5. **自信を持って除外する** - 低関連のファイルは後から関連にならない

## 関連

- [The Longform Guide](https://x.com/affaanmustafa/status/2014040193557471352) - Subagent orchestration の節
- `~/.claude/agents/` 内の agent 定義
