---
name: golang-testing
description: Go testing patterns including table-driven tests, subtests, benchmarks, fuzzing, and test coverage. Follows TDD methodology with idiomatic Go practices. Use when writing or reviewing Go tests, or when invoked as `/go-tdd`.
---

# Go Testing Patterns

Go のテスト / TDD 規律とコアパターン。詳細は以下の補助ドキュメントを必要に応じて読む:

- `advanced.md` — Golden Files / Benchmarks / Fuzzing
- `mocking-http.md` — Interface-based mocking / HTTP Handler testing
- `coverage-ci.md` — Coverage 計測 / CI/CD / Testing Commands 一覧

## When to Activate

- Writing new Go functions or methods
- Adding test coverage to existing code
- Creating benchmarks for performance-critical code
- Implementing fuzz tests for input validation
- Following TDD workflow in Go projects
- Invoked explicitly as `/go-tdd`

## TDD Workflow for Go

### The RED-GREEN-REFACTOR Cycle

```
RED      → Write a failing test first
GREEN    → Write minimal code to pass the test
REFACTOR → Improve code while keeping tests green
REPEAT   → Continue with next requirement
```

### TDD Scaffolding (RED 作成)

初回は「コンパイルエラー」で RED を取るのが Go 流。関数を先に必要とするときは `panic` ではなく明示的にエラーを返す stub を使う。

```go
package validator

import "errors"

var errNotImplemented = errors.New("not implemented")

func ValidateEmail(email string) error {
    return errNotImplemented
}
```

### Step-by-Step TDD in Go

```go
// Step 1: Define the interface/signature
package calculator

func Add(a, b int) int {
    panic("not implemented") // Placeholder
}

// Step 2: Write failing test (RED)
func TestAdd(t *testing.T) {
    got := Add(2, 3)
    want := 5
    if got != want {
        t.Errorf("Add(2, 3) = %d; want %d", got, want)
    }
}

// Step 3: Run test - verify FAIL
//   $ go test
//   --- FAIL: TestAdd (0.00s)

// Step 4: Implement minimal code (GREEN)
func Add(a, b int) int {
    return a + b
}

// Step 5: Run test - verify PASS
// Step 6: Refactor if needed, verify tests still pass
```

## Table-Driven Tests

Go テストの標準パターン。最小コードで網羅的なカバレッジを確保する。

### Basic Form

```go
func TestAdd(t *testing.T) {
    tests := []struct {
        name     string
        a, b     int
        expected int
    }{
        {"positive numbers", 2, 3, 5},
        {"negative numbers", -1, -2, -3},
        {"zero values", 0, 0, 0},
        {"mixed signs", -1, 1, 0},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got := Add(tt.a, tt.b)
            if got != tt.expected {
                t.Errorf("Add(%d, %d) = %d; want %d",
                    tt.a, tt.b, got, tt.expected)
            }
        })
    }
}
```

### With Error Cases

```go
func TestParseConfig(t *testing.T) {
    tests := []struct {
        name    string
        input   string
        want    *Config
        wantErr bool
    }{
        {
            name:  "valid config",
            input: `{"host": "localhost", "port": 8080}`,
            want:  &Config{Host: "localhost", Port: 8080},
        },
        {name: "invalid JSON", input: `{invalid}`, wantErr: true},
        {name: "empty input", input: "", wantErr: true},
        {name: "minimal config", input: `{}`, want: &Config{}},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got, err := ParseConfig(tt.input)

            if tt.wantErr {
                if err == nil {
                    t.Error("expected error, got nil")
                }
                return
            }
            if err != nil {
                t.Fatalf("unexpected error: %v", err)
            }
            if !reflect.DeepEqual(got, tt.want) {
                t.Errorf("got %+v; want %+v", got, tt.want)
            }
        })
    }
}
```

## Subtests

### Organizing Related Tests

```go
func TestUser(t *testing.T) {
    db := setupTestDB(t) // Shared setup

    t.Run("Create", func(t *testing.T) {
        user := &User{Name: "Alice"}
        if err := db.CreateUser(user); err != nil {
            t.Fatalf("CreateUser failed: %v", err)
        }
        if user.ID == "" {
            t.Error("expected user ID to be set")
        }
    })

    t.Run("Get", func(t *testing.T) {
        user, err := db.GetUser("alice-id")
        if err != nil {
            t.Fatalf("GetUser failed: %v", err)
        }
        if user.Name != "Alice" {
            t.Errorf("got name %q; want %q", user.Name, "Alice")
        }
    })
}
```

### Parallel Subtests

```go
for _, tt := range tests {
    tt := tt // Capture range variable
    t.Run(tt.name, func(t *testing.T) {
        t.Parallel()
        // ...
    })
}
```

## Test Helpers

### Helper Functions

```go
func setupTestDB(t *testing.T) *sql.DB {
    t.Helper() // Marks this as a helper function

    db, err := sql.Open("sqlite3", ":memory:")
    if err != nil {
        t.Fatalf("failed to open database: %v", err)
    }
    t.Cleanup(func() { db.Close() })

    if _, err := db.Exec(schema); err != nil {
        t.Fatalf("failed to create schema: %v", err)
    }
    return db
}

func assertNoError(t *testing.T, err error) {
    t.Helper()
    if err != nil {
        t.Fatalf("unexpected error: %v", err)
    }
}

func assertEqual[T comparable](t *testing.T, got, want T) {
    t.Helper()
    if got != want {
        t.Errorf("got %v; want %v", got, want)
    }
}
```

### Temporary Files

```go
func TestFileProcessing(t *testing.T) {
    tmpDir := t.TempDir() // Auto-cleaned

    testFile := filepath.Join(tmpDir, "test.txt")
    if err := os.WriteFile(testFile, []byte("test content"), 0644); err != nil {
        t.Fatalf("failed to create test file: %v", err)
    }

    result, err := ProcessFile(testFile)
    if err != nil {
        t.Fatalf("ProcessFile failed: %v", err)
    }
    _ = result
}
```

## Best Practices

**DO:**
- Write tests FIRST (TDD)
- Use table-driven tests for comprehensive coverage
- Test behavior, not implementation
- Use `t.Helper()` in helper functions
- Use `t.Parallel()` for independent tests
- Clean up resources with `t.Cleanup()`
- Use meaningful test names that describe the scenario

**DON'T:**
- Test private functions directly (test through public API)
- Use `time.Sleep()` in tests (use channels or conditions)
- Ignore flaky tests (fix or remove them)
- Mock everything (prefer integration tests when possible)
- Skip error path testing

## Verify RED / GREEN を省略しない

TDD の Iron Law（`tdd-workflow` skill 参照）は Go でも同じ:

- `panic("not implemented")` stub を置いたら、**実装前に `go test` を実行して panic で落ちることを目で確認する**
- `errNotImplemented` stub を置いたら、**テストが `err = not implemented` で落ちることを確認する**
- 「Go は compile error も RED 扱い」という通説があるが、**compile error では「何を検証しているか」が曖昧**。可能な限り runtime failure の RED を見る

## Red Flags — TDD を破っているサイン

下記に当てはまったら **削除して RED からやり直し**:

- [ ] テストを書く前に実装を書いた（「参考程度に」も禁止）
- [ ] RED を目で見ていない（書いた瞬間 pass してしまった）
- [ ] `time.Sleep()` で待機している（channel / condition を使う）
- [ ] test-only な関数を production に足した（`_forTest` suffix 等）
- [ ] mock 設定がテストの 50% 以上を占める
- [ ] mock を削除するとテストが failing する（= mock の振る舞いをテストしている）
- [ ] なぜこの mock が必要か 1 文で説明できない
- [ ] 非公開関数を直接テストしている（public API 経由に変更）
- [ ] テストが互いに依存している（実行順序で結果が変わる）
- [ ] flaky test を「再実行で通ることもある」と放置している

詳細は `tdd-workflow/testing-anti-patterns.md` を併読。バグ修正時は `tdd-workflow/regression-testing.md` の逆フェーズ検証を必須とする。

## Verification Checklist (コミット前)

Go テストを commit / PR に含める前に:

- [ ] 各関数について、**失敗するテストを先に書いた**
- [ ] 実装前に **RED を目で確認した**（stub / panic / errNotImplemented で落ちることを確認）
- [ ] テストを pass させる **最小コード** を書いた（over-engineering していない）
- [ ] `go test -v` で全テストが pass
- [ ] `go test -cover` で 80%+ のカバレッジ
- [ ] `go test -race` で race condition なし
- [ ] `time.Sleep()` を使っていない
- [ ] 非公開関数を直接テストしていない
- [ ] Table-driven が適用可能な場所で使っている
- [ ] Subtest で `tt := tt` キャプチャしている（parallel の場合）
- [ ] 各テストが独立している（shared state 無し）
- [ ] バグ修正 PR なら逆フェーズ検証（修正 revert → FAIL）まで実施済み

## 補助ドキュメント

詳細パターンが必要なときのみ読む:

- **`advanced.md`** — Golden Files 比較、Benchmarks（basic / sized / memalloc）、Fuzzing（Go 1.18+）
- **`mocking-http.md`** — Interface-based mocking、`httptest` HTTP Handler テスト
- **`coverage-ci.md`** — `go test -cover` / coverage targets / GitHub Actions / Testing Commands 一覧

**Remember**: Tests are documentation. They show how your code is meant to be used. Write them clearly and keep them up to date.
