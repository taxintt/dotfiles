# Regression Testing: 逆フェーズ検証

`tdd-workflow` skill の補助ドキュメント。**バグ修正時の TDD**。

---

## なぜ逆フェーズ検証が必要か

バグ修正で以下のフローに陥りやすい:

```
修正を書く → テストが通る → 「直った」と言う
```

**これは何も証明していない**。テストが修正前から通っていた可能性がある。TDD の Iron Law（「RED を見なかった = 無価値」）をバグ修正にも適用する。

---

## Red-Green 逆フェーズ サイクル

```
1. RED:       バグ再現テストを書く → 失敗することを確認
2. 修正を実装
3. GREEN:     テスト実行 → 成功することを確認
4. 逆フェーズ: 修正を revert → テスト実行 → **失敗することを確認**
5. 修正を restore
6. GREEN:     再度テスト実行 → 成功することを確認
```

ステップ 4 で「テストが本当にバグを検知している」ことが証明される。revert 後に pass してしまうなら、そのテストはバグをテストしていない。

---

## 実例: パスワード長さ検証 bug

### Bug
```go
func ValidatePassword(pwd string) bool {
    if len(pwd) < 8 {
        return true  // ← 逆ロジック
    }
    return false
}
```

### TDD regression flow

**Step 1: RED — バグ再現テスト**
```go
func TestValidatePassword_ShortIsInvalid(t *testing.T) {
    if ValidatePassword("short") != false {
        t.Errorf("短いパスワードは invalid のはず")
    }
}
```

実行:
```
$ go test
--- FAIL: TestValidatePassword_ShortIsInvalid
    want=false got=true
```
期待通り失敗している。

**Step 2: 修正**
```go
if len(pwd) < 8 {
    return false
}
```

**Step 3: GREEN**
```
$ go test
PASS
```
修正が効いている。

**Step 4: 逆フェーズ — 修正を revert**

意図的に元に戻す:
```go
if len(pwd) < 8 {
    return true  // ← 一時的に戻す
}
```

```
$ go test
--- FAIL: TestValidatePassword_ShortIsInvalid
    want=false got=true
```
**テストが本当にバグを検知していることが証明された**。

**Step 5: 修正を restore**
```go
if len(pwd) < 8 {
    return false
}
```

**Step 6: 再度 GREEN**
```
$ go test
PASS
```

→ **ここまでやって初めて「修正完了」と言える**

---

## 手を抜きたくなる瞬間の対処

### 「revert 面倒、たぶん効いてる」

`git stash` を使えば 2 コマンドで revert できる:

```bash
git stash             # 修正を一時退避
go test               # 失敗することを確認
git stash pop         # 修正を戻す
go test               # pass することを確認
```

または 1 行コメントアウトで十分な場合が多い。工数は 30 秒。

### 「修正が trivial だから逆フェーズ不要」

Trivial な修正ほど「テストが修正前から pass していた」リスクが高い。条件式の反転は **1 文字差** で挙動が反転する。逆フェーズ検証 30 秒と production debug の数時間を天秤にかける。

### 「テストが既に落ちてたから、修正で pass に戻せば OK」

落ちていた理由が本当に修正対象のバグか確認する。別の原因で落ちていたテストが、修正とは無関係に pass に戻っただけの可能性。RED の失敗メッセージが期待通りかを Step 1 で必ず確認する。

---

## チェックリスト（PR 作成前）

バグ修正系 PR では以下を必ず確認:

- [ ] バグを再現する失敗テスト（RED）を commit に含めた
- [ ] RED のときの失敗メッセージが期待通りだったことを手元で確認した
- [ ] 修正後に GREEN になることを確認した
- [ ] **修正を revert したときにテストが FAIL することを確認した**
- [ ] 修正を restore して再度 GREEN を確認した

Step 4 を飛ばした PR は「テストがバグを検知している証拠がない」状態。レビュアーに証拠を示せない。

## 関連

- `tdd-workflow/SKILL.md` — Iron Law, RED/GREEN verification checkpoint
- `tdd-workflow/testing-anti-patterns.md` — モックの落とし穴
