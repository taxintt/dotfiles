# Testing Anti-Patterns

`tdd-workflow` skill の補助ドキュメント。特にモック関連の落とし穴と、production code を汚染するテストパターンを扱う。

**Core principle**: *「コードが何をするかをテストせよ。モックが何をするかをテストするな」*

---

## 1. モックの振る舞いをテストする

### Anti-Pattern (誤)

```typescript
it('calls onClick handler', () => {
  const handleClick = jest.fn()
  render(<Button onClick={handleClick} />)
  fireEvent.click(screen.getByRole('button'))
  expect(handleClick).toHaveBeenCalledTimes(1)
})
```

このテストは `jest.fn()` がちゃんと動くことを確認しているだけ。Button コンポーネントの振る舞いは何もテストしていない。

### Correct (正)

```typescript
it('disables submit until form is filled', () => {
  render(<Form />)
  const input = screen.getByLabelText('Email')
  const submit = screen.getByRole('button', { name: /submit/i })

  expect(submit).toBeDisabled()                           // initial state
  fireEvent.change(input, { target: { value: 'a@b.c' } })
  expect(submit).not.toBeDisabled()                       // observable behavior
})
```

コンポーネントの観察可能な振る舞い（disabled → enabled）を確認している。

---

## 2. テスト専用メソッドを production に足す

### Anti-Pattern (誤)

```typescript
class Cache {
  private data = new Map()

  set(k: string, v: unknown) { this.data.set(k, v) }
  get(k: string) { return this.data.get(k) }

  // テストからだけ呼ばれる
  _clearForTest() { this.data.clear() }
  _getInternalMap() { return this.data }
}
```

`_clearForTest` / `_getInternalMap` は production code を汚染する。テスト専用の private 状態リークを生む。

### Correct (正)

- テストごとに **新しいインスタンス** を作る（独立テスト原則）
- どうしても必要なら `Cache` を public API だけで検証可能に設計し直す
- セットアップは `beforeEach(() => cache = new Cache())` で

---

## 3. 依存を理解せずモックする

### Anti-Pattern (誤)

```typescript
jest.mock('@/lib/analytics')   // 何が起きるか分からないけどとりあえず mock
```

副作用（network call / error throw / side effect）が何かを把握しないままモックすると、production と乖離したテストができあがる。

### Correct (正)

モックする前に:

1. 実コードを読み、**どの副作用を遮断したいか** を言語化する（「HTTP 呼び出しを防ぐ」「乱数を固定する」等）
2. 最小限のインターフェースだけをモック（全体を差し替えない）
3. モックが削除されたら何が壊れるか予測できるか自問する

---

## 4. 不完全なモックデータ

### Anti-Pattern (誤)

```typescript
jest.mock('@/lib/api', () => ({
  fetchUser: () => ({ id: '1', name: 'Alice' })
  // 実 API は email / role / preferences も返すが省略
}))
```

downstream の実コードが `user.email` にアクセスした瞬間 undefined で落ちる。テストは通るが production は壊れている可能性。

### Correct (正)

- 実レスポンスの **完全な shape** を再現する
- TypeScript なら型定義を共有し、モックが型を満たしていることをコンパイラに保証させる
- Fixture は 1 箇所に集約（`__fixtures__/users.ts` 等）

---

## 5. モックが過剰

### Red flag: **モック setup がテスト全体の 50% を超える**

```typescript
it('does something', () => {
  // 40 行の mock setup
  jest.mock(...)
  jest.spyOn(...)
  ...

  // 5 行の assertion
  expect(result).toBe(...)
})
```

50% を超えたら「このコードは integration test で検証すべき」のサイン。unit test で無理に isolate しようとしている。

### Correct (正)

- 外部システム（DB / HTTP / fs）だけをモック。内部関数はモックしない
- 純関数は直接呼ぶ
- 複雑な組み合わせは **integration test** に移す

---

## Red Flags チェックリスト

下記のいずれかに当てはまったら **止めて設計を見直す**。テストを修正する前に実装をテスト可能に直す:

- [ ] テストファイルに `*-mock` を含む test ID が出現
- [ ] production class にテストからしか呼ばれないメソッドがある
- [ ] mock setup が assertion より多い
- [ ] モックを削除するとテストが失敗する（= モック自体をテストしている）
- [ ] 「なぜモックが必要か」を 1 文で説明できない
- [ ] 「念のため」でモック化している
- [ ] テスト同士が特定の実行順序に依存している
- [ ] テスト内で `await sleep(100)` / `time.Sleep(100*time.Millisecond)` を使っている
- [ ] テストが flaky だが「たまに落ちるだけ」で放置している

## 関連

- `tdd-workflow/SKILL.md` — Iron Law と Rationalization Table
- `tdd-workflow/regression-testing.md` — バグ修正時の逆フェーズ検証
- `tdd-workflow/patterns-ts.md` — TS 具体パターン
- `golang-testing` skill — Go specific
