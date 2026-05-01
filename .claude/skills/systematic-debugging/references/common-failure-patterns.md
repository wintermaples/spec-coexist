# systematic-debugging — Common Failure Patterns / 典型失敗パターン

Conformance keywords follow [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119) / [RFC 8174](https://www.rfc-editor.org/rfc/rfc8174).

`anti-patterns.md` が "やってはいけない行動" を列挙するのに対し、このファイルは **debugging session 全体が失敗に至る典型フロー** を扱う。各パターンは次の 3 点セットで記述する:

1. **Definition / 定義** — そのパターンが何か。
2. **Detection signal / 検出シグナル** — 自分が陥っていることに気付くための手掛かり。
3. **Counter-action / 対抗アクション** — 抜け出すために取るべき行動。

---

## 1. Fix Masks Symptom / 症状隠蔽型修正

**Definition.** Root cause を理解せずに症状だけを抑え込む修正。例: `try/except: pass`、エラーログの削除、assertion の無効化、default 値で NaN を覆い隠す、等。

**Detection signal.**
- Diff の中に新しい `except`, `ignore`, `silent`, `// eslint-disable`, `# type: ignore` が現れる。
- Fix 後、「なぜ直ったか」を 1 文で説明できない。
- 同じファイルの別の caller が同じ症状を出す可能性を検討していない。

**Counter-action (MUST).** Hypothesis を立て直し、root cause が特定できるまで fix を revert。`hypothesis-evidence-loop.md` のループに戻る。

---

## 2. No Regression Test / 再発テスト欠落

**Definition.** Root cause は分かったが、同じバグが再発したことを捕まえるテストを追加していない状態で完了宣言する。

**Detection signal.**
- Fix commit にテストファイルの変更が含まれない。
- 「後で書く」「今回は急ぎだから」が出た (→ `rationalization-table.md` #2)。

**Counter-action (MUST).** `principles.md` §3 に従い、reproducing test を同一 commit に含める。合理的に追加できない場合は理由を evidence に記録する。

---

## 3. Premature Celebration / 早期完了宣言

**Definition.** ローカルで 1 回動いた時点で「直った」と宣言する。`verification-before-completion` の fresh run を通していない。

**Detection signal.**
- "works now", "fixed it", "should be good" をフレッシュな proof 無しで発言。
- Evidence ファイルが無い / `proof_hash` が無い。

**Counter-action (MUST NOT).** `verification-before-completion` を通すまで "done" を名乗らない。

---

## 4. Hypothesis Drift / 仮説漂流

**Definition.** 一つの仮説を検証せずに次々と新しい仮説を試し、結論として何を確かめたかが分からなくなる。

**Detection signal.**
- Session 内で 3 個以上の仮説が連続して部分検証のまま捨てられる。
- 「あれ、何を確かめてたんだっけ」が発生する。

**Counter-action (MUST).** 仮説 / 実験 / 観察 / 判定の 4 点セットを書き下す (`hypothesis-evidence-loop.md`)。書けない仮説は捨てる。

---

## 5. Fix-in-the-Wrong-Layer / レイヤ違いの修正

**Definition.** Root cause は下層 (DB schema, config, upstream lib) にあるのに、上層 (UI, handler) でパッチを当てる。

**Detection signal.**
- 同じ bug が別の entry point から再発する可能性を否定できない。
- Fix が下層のバグを "workaround" している自覚がある。

**Counter-action (SHOULD).** レイヤを一段下げて fix を再配置する。上層でのみ直す場合、下層 issue を切って link する (MUST link)。

---

## 6. Shotgun Debugging / 散弾デバッグ

**Definition.** 一度に複数箇所を変更し、どれが効いたか分からなくなる。

**Detection signal.**
- 1 つの debugging session の diff が複数の無関係ファイルに渡る。
- Commit message に "and also fixed" が含まれる。

**Counter-action (MUST).** Fix は **最小変更**。無関係な修正は別 commit / 別 PR に切り出す。`anti-patterns.md` "This looks suspicious, let me clean it up too." と連動。

---

## 7. Survivor-Bias Reasoning / 生存者バイアス推論

**Definition.** 「前回これで直ったから今回もこれだろう」と過去の成功パターンに依存して新しい root cause 探索を怠る。

**Detection signal.**
- 「前にも見た」「いつものやつ」が出る (→ `red-flags.md` #4)。
- Fix が過去 commit の cherry-pick / コピペになる。

**Counter-action (MUST).** 症状の一致は仮説の一つでしかない。独立に検証すること。

---

## 8. Silent Retry Loop / 無音リトライ

**Definition.** `verification-before-completion` が FAIL を返したあと、evidence に `result: fail` を残さず再試行を繰り返す。

**Detection signal.**
- `docs/evidence/` に該当 subject の `fail` レコードが無い。
- Session 履歴上では FAIL → 再試行 → PASS の経路が見える。

**Counter-action (MUST).** FAIL は **必ず** evidence に残す。Silent retry は `evidence-schema.md` の invariant を破壊する。

---

## 使い方 / Usage

- Step 7 (Fix) 前に **全 8 パターンをスキャン** すること (MUST)。
- ヒットしたら evidence に `proof-type: debug-hypothesis` として pattern ID (1-8) と counter-action の実施結果を記録すること (MUST)。

参照: `references/red-flags.md`, `references/rationalization-table.md`, `references/hypothesis-evidence-loop.md`, `references/anti-patterns.md`.
