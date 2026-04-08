# Rationalization Table — Excuses and Rebuttals

Conformance keywords follow RFC 2119.

When the agent (or the user) is about to skip RED, it **MUST** scan this table first. If the rationalization is listed, the rebuttal applies and the skip **MUST NOT** proceed.

| # | 言い訳 / Excuse | 反論 / Rebuttal |
|---|-----------------|-----------------|
| 1 | 「このバグは小さいから先に直す」 | Small bugs cause the loudest regressions. Write the test first. |
| 2 | 「テストを書く時間がない」 | Debugging time > testing time. Measured, not opinion. |
| 3 | 「仕様が固まっていないからテストが書けない」 | Then it is not a spec-driven implementation. Return to `revising-spec`. |
| 4 | 「実装を見ないとテストが書けない」 | Tests derive from the basic design, not the code. Re-read `docs/main-basic-design.md`. |
| 5 | 「リファクタだけだから」 | Prove existing tests are green first. No green baseline, no refactor. |
| 6 | "It's just a one-liner" | One-liners produce the highest defect density per LOC. Test it. |
| 7 | "The framework is hard to mock" | The seam is wrong. Fix the seam, not the discipline. |
| 8 | "I'll add the test right after" | A test never seen to fail is not a test. RED first, always. |
| 9 | 「既に手元で動いたから大丈夫」 | Local success is not evidence. The `tdd-red` → `tdd-green` pair is. |
| 10 | "CI will catch it" | CI runs existing tests. It cannot conjure the test you did not write. |
| 11 | 「これはテストしにくいコードだ」 | Hard-to-test code is hard-to-change code. Test pressure is the point. |
| 12 | "This is a trivial getter" | Then the test is also trivial. Write it. |
| 13 | 「スパイクだから TDD 要らない」 | If committed to the spec-driven branch, it is not a spike. See `negative-triggers.md`. |
| 14 | "I already know what the test would say" | Then typing it costs nothing and gives a regression net forever. |
| 15 | 「レガシー領域だから」 | Valid only if listed in `negative-triggers.md` §Legacy. Otherwise rebutted. |
| 16 | "The user is waiting" | A broken ship is slower than a tested one. The user is waiting for correctness. |
| 17 | 「テストを書くと実装に引きずられる」 | Write the test from the spec, not from the code. Discipline, not impossibility. |
| 18 | "Mocks make the test useless" | Use a fake, a fixture, or a contract test. Pick the right double. |
| 19 | 「UI だから落とせない」 | Use the `ui` test strategy tier declared in the basic design. |
| 20 | "Pipeline code can't be unit-tested" | Use the `pipeline` tier. Stage-level RED is still RED. |
| 21 | 「型を変えるだけだから」 | Type changes are behaviour changes in statically-typed code. Test it. |
| 22 | "I'll squash the test commit in later" | Evidence lives in `docs/evidence/`, not in git history. The record must exist now. |
| 23 | 「コードレビューで捕まえればいい」 | Review is the third net, not the first. TDD is net one. |
| 24 | "It's experimental" | Experimental-and-committed still needs tests. |
