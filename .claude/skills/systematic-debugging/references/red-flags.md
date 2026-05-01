# systematic-debugging — Red Flags / 危険思考リスト

Conformance keywords follow [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119) / [RFC 8174](https://www.rfc-editor.org/rfc/rfc8174).

デバッグ中に頭をよぎった時点で **立ち止まるべき** 思考パターン。いずれかが発火したら、コードを触る前に `references/principles.md` §1 と `references/hypothesis-evidence-loop.md` に戻ること。

A debugging session **MUST** halt and re-enter the hypothesis loop whenever any of the following thoughts occurs — these are **not** hypotheses, they are excuses disguised as intuition.

| # | 危険思考 (JA) | Red flag (EN) | 反論 / Counter |
|---|---------------|---------------|----------------|
| 1 | 「たぶんこれが原因」 | "This is probably it." | 仮説は検証されるまで仮説。コードを書く前にログ・再現・計測で確かめよ (MUST). |
| 2 | 「とりあえず再起動したら直った」 | "Restarting fixed it, moving on." | 再現条件を特定するまで「直った」と言ってはならない (MUST NOT). Intermittent = unfixed. |
| 3 | 「このログは無関係そう」 | "This log is probably unrelated." | 「無関係」と断定するには根拠がいる。Irrelevance is a claim requiring evidence. |
| 4 | 「前にも同じ症状を見た」 | "I have seen this symptom before." | 同じ症状 = 同じ root cause ではない。Verify independently. |
| 5 | 「たぶん環境依存」 | "Must be an environment issue." | 環境差を示す証拠を出せ。Produce the delta or drop the hypothesis. |
| 6 | 「一箇所だけ try/except 入れれば済む」 | "Just wrap it in try/except." | 症状を隠蔽して root cause を失う (MUST NOT). |
| 7 | 「このテストは flaky だから無視」 | "That test is flaky, ignore it." | Flaky は測定値であって意見ではない。Run N>=20 first. |
| 8 | 「動いたからヨシ」 | "It runs, ship it." | 動く != 正しい。verification-before-completion を通すまで完了ではない (MUST). |
| 9 | 「後でちゃんと直す」 | "I'll properly fix it later." | Later never comes. Fix now or file and link an issue. |
| 10 | 「再現しないから無かったことにする」 | "Cannot reproduce, closing." | 再現できないのは情報不足。Try 3 levels of reduction before giving up. |
| 11 | 「コードを読めば分かるはず」 | "I can see it just from the code." | 静的読解は仮説生成であって検証ではない。Reading forms hypotheses, not proofs. |
| 12 | 「ユーザの使い方が悪い」 | "User held it wrong." | 再現手順をその場で踏め。If you can reproduce the misuse, it is a bug. |
| 13 | 「テストを書く時間がない」 | "No time to add a regression test." | Regression test なき fix は同じバグを再生産する (SHOULD add). |
| 14 | 「AI にサジェストされたから多分正しい」 | "The AI suggested it, so it's likely right." | サジェストは仮説。Not a reason to skip verification. |
| 15 | 「related file を全部読むのは面倒」 | "Reading all related files is overkill." | Root cause は読まなかったファイルに潜む。 |
| 16 | 「git blame で書いた人が悪い」 | "Blame the author and move on." | Blame is not debugging. |

## 使い方 / Usage

1. このリストは `procedure.md` の step 3 (Hypothesize) と step 7 (Fix) の直前に **MUST** 読み返すこと。
2. ヒットした危険思考は evidence に記録 (`proof-type: debug-hypothesis`) し、どの反論で棄却したかを残すこと (MUST)。
3. 2 件以上ヒットした場合、session を一旦 pause し `hypothesis-evidence-loop.md` に戻ること (MUST)。

参照: `references/rationalization-table.md`, `references/common-failure-patterns.md`, `references/hypothesis-evidence-loop.md`.
