# Red Flags — Self-Review Rationalizations

Bilingual table of thoughts that tempt the implementing agent to skip, shorten, or soften the
self-review. If the agent catches itself thinking any of these, it **MUST** reject the thought and
return to the protocol.

Conformance keywords follow RFC 2119.

| # | Red-flag thought (JA) | Red-flag thought (EN) | Reality / rebuttal |
|---|------------------------|------------------------|---------------------|
| 1 | 「どうせレビュアーが見てくれる」 | "The reviewer will catch it anyway" | The reviewer sees only the diff. They do not know what you almost did wrong. Self-review is the cheap layer; waste it and the expensive layer gets cluttered. |
| 2 | 「差分が小さいから飛ばしていい」 | "The diff is tiny, skip it" | Secret leaks and contract breaks are usually one line. Size is not a proxy for risk. |
| 3 | 「時間がないので後でやる」 | "No time now, I'll self-review later" | "Later" = "after the reviewer finds it". The point of self-review is to do it **before** the expensive step. |
| 4 | 「テストが通ってるから大丈夫」 | "Tests pass, it's fine" | Tests prove behavior, not hygiene. Naming, boundaries, secrets, dead code are all test-invisible. |
| 5 | 「自分が書いたコードだから間違ってない」 | "I wrote it, I know it's right" | Author bias is exactly what self-review corrects. Walk the checklist anyway. |
| 6 | 「チェックリストは大げさ」 | "The checklist is overkill for this" | The checklist is the contract. "Overkill" is a feeling; the contract is evidence. |
| 7 | 「Minor だから無視していい」 | "It's just Minor, ignore" | Minor may be deferred **with a written rationale**. "Ignore" is not defer; it is sabotage. |
| 8 | 「エラー握りつぶしたけど、どうせ起きない」 | "I swallowed the error but it can't happen" | "Can't happen" errors are the ones that wake you at 3am. Re-raise or document explicitly. |
| 9 | 「ログに API キーが入ってるけど dev だけ」 | "Secret in logs, but only in dev" | Dev logs get copied to issue trackers, chat, screenshots. Secrets in logs are **Critical**, always. |
| 10 | 「この関数は長いけど分かりやすいから」 | "The function is long but readable" | Readability is subjective; complexity is measurable. If it exceeds the threshold, justify in writing. |
| 11 | 「ダミー変数だから未使用でも気にしない」 | "Unused var is a dummy, whatever" | Unused vars are noise that trains the eye to ignore noise. Delete or prefix `_` per language. |
| 12 | 「境界チェックは呼び出し側の責任」 | "The caller should validate, not me" | Boundary validation lives **at** the boundary. "Caller's responsibility" is how untrusted data gets deep. |
| 13 | 「リファクタはこの PR のスコープ外」 | "Refactor is out of scope for this PR" | Correct for large refactors; wrong for a broken name or a dead import **you just introduced**. Fix what you touched. |
| 14 | 「レビュー前に直しても同じこと」 | "Fixing now vs after review is the same" | It is not. Post-review fixes invalidate the reviewer's context and waste a subagent round-trip. |

Rejection protocol: when a red flag is recognized, the agent **MUST** write `rejected: #<row>` in
the red-flag scan field of the evidence body and continue the self-review from Step 3.
