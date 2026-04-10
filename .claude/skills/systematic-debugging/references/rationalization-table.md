# systematic-debugging — Rationalization Table / 言い訳 → 反論表

Conformance keywords follow [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119) / [RFC 8174](https://www.rfc-editor.org/rfc/rfc8174).

`red-flags.md` が **検証前の瞬間的な危険思考** を扱うのに対し、このファイルは debugging session が終盤に近づいた時点で agent が自分に語りかけがちな **手続きをスキップするための言い訳** を扱う。各行は一対の 言い訳 (JA/EN) と反論 (JA/EN) からなる。

| # | 言い訳 (JA) | Rationalization (EN) | 反論 / Rebuttal |
|---|-------------|----------------------|-----------------|
| 1 | 「ほぼ直ったので完了でいい」 | "It's basically fixed, good enough." | "Basically" は完了ではない。`verification-before-completion` の PASS evidence を出すまで完了を名乗ってはならない (MUST NOT). |
| 2 | 「regression test はあとで追加する」 | "I'll add the regression test later." | 「あとで」は来ない。Fix と regression test は同一 commit に入れる (SHOULD). `principles.md` §3. |
| 3 | 「このバグは小さいからそのまま push」 | "The bug is tiny, just push." | Size は correctness の proxy ではない (`anti-patterns.md`). Review を通すこと (MUST). |
| 4 | 「verification gate は前回通したからスキップ」 | "Gate passed earlier, skipping this time." | Fresh gate でなければ無効 (`principles.md` §5). 前の PASS は今の PASS ではない (MUST re-run). |
| 5 | 「root cause は分かったので fix 前に commit しちゃう」 | "Root cause is clear, commit before the fix." | Fix 未完で commit する場合は WIP と明示し、完了 claim に使ってはならない (MUST NOT). |
| 6 | 「hypothesis を書き出すのは時間の無駄」 | "Writing hypotheses down is overhead." | 書かない仮説は検証できない。`hypothesis-evidence-loop.md` invariant #1 (MUST write). |
| 7 | 「再現手順は頭にあるから書かなくていい」 | "Repro steps are in my head." | 頭の中の repro は re-run できない。evidence に残せ (MUST). |
| 8 | 「ログを読むより grep で十分」 | "grep is enough, no need to read full logs." | grep はサンプリングであって観察ではない。Step 5 Observe には verbatim log が必要 (MUST). |
| 9 | 「fix は最小にしたつもり」 | "I think the fix is minimal." | 「つもり」は evidence ではない。diff を Read で全行確認 (MUST) — `pre-review-self-check` と連動. |
| 10 | 「review を自分で兼ねれば早い」 | "I'll self-review and skip the reviewer." | Self-review は第三者 review の代替ではない。`procedure.md` step 9 (MUST route). |
| 11 | 「型システムが通ったから OK」 | "Types compile, ship it." | 型は仮説 subset を除去するだけで全 bug を除去しない。Runtime proof を出せ (MUST). |
| 12 | 「テストが 1 回通ったから直ったはず」 | "Test passed once, must be fixed." | Flaky check のため fresh run を繰り返す (SHOULD N>=3 for intermittent bugs). |
| 13 | 「upstream のバグだから仕方ない」 | "It's upstream's fault, nothing to do." | Workaround を取るか pin するかを決めて evidence に残す (MUST). 放置は禁止. |
| 14 | 「TODO コメント残しておけば大丈夫」 | "Leaving a TODO is good enough." | Orphan TODO は debt を隠す。Issue を切って link (MUST link). |
| 15 | 「lint warning は無視していい」 | "These lint warnings don't matter." | Warning が関連している可能性を否定する証拠を出せ (MUST justify). |
| 16 | 「ユーザの期待が間違っている」 | "The user's expectation is wrong." | 仕様に戻って確認せよ。`docs/main-requirements.md` / subsystem requirements を読む (MUST re-check). |
| 17 | 「debugging に飽きたのでここで止める」 | "I'm tired, stopping here." | Fatigue は stop condition ではない。`hypothesis-evidence-loop.md` termination 条件を満たすまで続けるか、明示的に escalate (MUST). |
| 18 | 「以前のコミット blame で済む」 | "git blame shows someone else wrote it." | Blame は debugging ではない (`red-flags.md` #16). |

## 使い方 / Usage

1. Fix を commit する **直前** に全行をスキャンすること (MUST)。
2. ヒットした言い訳は evidence に `proof-type: debug-hypothesis` として記録し、反論の採用を明示すること (MUST).
3. 3 件以上ヒットした session は、user に状況報告して判断を仰ぐこと (SHOULD escalate).

参照: `references/red-flags.md`, `references/common-failure-patterns.md`, `references/hypothesis-evidence-loop.md`, `references/principles.md`.
