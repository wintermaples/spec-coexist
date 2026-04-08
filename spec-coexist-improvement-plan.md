# spec-coexist 改善プラン: コード規律の強化

**作成日:** 2026-04-09
**対象:** `/workspace/.claude/skills/` (spec-coexist suite)
**起点ドキュメント:** `skills-comparison-report.md`
**目的:** 比較レポートで指摘された 3 つの弱点を解消し、spec-coexist を「ドキュメント統治 + コード規律」を両立する suite に昇格させる。

---

## 0. 解決すべき指摘事項

| # | 指摘 | 出典 (report 内) | 重大度 |
|---|------|------------------|--------|
| **W1** | **TDD・テスト規律スキルが存在しない**。実装側の保証が code-review/verification に依存し、テストファースト文化を強制する仕組みが無い | §1.3-2, §6-1 | **Critical** |
| **W2** | **「書かれるコードの正しさ」を守る規律が弱い**。仕様統治は強いがコード品質ガードは superpowers より緩い | §6-1 | **High** |
| **W3** | **`systematic-debugging` が弱い**。RFC 2119 と 1% rule で起動はするが、サボタージュを防ぐ心理ガード (Red Flags / Rationalization Table) や共通失敗パターン記述が薄い | §3 表 | **High** |

副次的に解消すべきもの (本プランの範囲内で同時対応):

- **W4:** スキル自体のテスト方法論が弱い (`authoring-spec-coexist-skill` に RED-GREEN-REFACTOR が無い)
- **W5:** CI / hook 自動化が無く、規律が「人間の善意」依存

---

## 1. 設計方針

1. **spec-coexist の哲学を壊さない。** ドキュメント駆動・evidence schema・RFC 2119・1% rule・バイリンガル trigger・薄いオーケストレータ + `references/` 外出しを**全部維持**する。
2. **superpowers の良いところは「移植」ではなく「翻訳」する。** 設計思想 (Iron Law, RED-GREEN-REFACTOR, Rationalization Table) を spec-coexist の文体・命名規則・日本語ファースト trigger に適合させる。
3. **Iron Law は適用範囲を絞る。** 比較レポート §6-4 の警鐘に従い、レガシー移行・調査スパイクなどを `negative-triggers.md` に明示。「全コードに TDD」ではなく「**仕様駆動な実装には TDD**」とスコープする。
4. **Evidence schema と統合する。** TDD の RED/GREEN/REFACTOR ステップは `_shared/scripts/write_evidence.sh` に proof として記録。これにより「テスト書いた」が監査可能になる。
5. **既存スキルへの破壊的変更を避ける。** 新規スキルの追加と、既存スキルからの**参照追加**で実現する。

---

## 2. 新規追加スキル

### 2.1 `test-driven-implementation` (W1, W2 の中核解)

**位置づけ:** `implementing-from-spec` と `revising-implementation` から **REQUIRED SUB-SKILL** として参照される、spec-coexist 流の TDD 規律スキル。

**ファイル構成:**

```
.claude/skills/test-driven-implementation/
├── SKILL.md                              # 薄いオーケストレータ
├── references/
│   ├── iron-law.md                       # スコープ付き Iron Law (適用範囲・例外)
│   ├── red-green-refactor.md             # 3 フェーズ定義 + spec-coexist 文体
│   ├── rationalization-table.md          # 言い訳 → 反論 (日本語 + 英語、20+ 行)
│   ├── tdd-evidence-protocol.md          # write_evidence.sh への記録ルール
│   ├── negative-triggers.md              # レガシー / spike / notebook の除外条件
│   └── failure-patterns.md               # よくある TDD 失敗 (テストが implementation を後追い等)
└── scripts/
    ├── record_red_phase.sh               # RED の証拠 (失敗ログ + コミット SHA) を evidence に追記
    ├── record_green_phase.sh             # GREEN の証拠 (パスログ) を追記
    └── verify_test_first.sh              # git log を辿り、テスト追加 commit が実装より先かを検証
```

**SKILL.md frontmatter (抜粋案):**

```yaml
name: test-driven-implementation
description: |
  Use whenever code is about to be written or modified as part of a spec-driven
  implementation — whole-system or subsystem. Trigger on phrases like
  "実装する", "コードを書く", "implement this", "TDD で進めて", "テスト先に書く".
  This skill MUST halt if the failing test does not exist before production code.
type: process
user-invocable: false
required-by:
  - implementing-from-spec
  - revising-implementation
hard-constraints: RFC2119
```

**Hard constraints (RFC 2119, references/iron-law.md):**

- 仕様駆動実装において、production code の追加・変更は **失敗するテストが先に存在しなければならない (MUST)**。
- RED フェーズの失敗ログは `_shared/scripts/write_evidence.sh` で **記録しなければならない (MUST)**。
- テストの存在しないコード変更を発見した場合、当該変更は **取り消し、テストから書き直さなければならない (MUST)**。
- ただし以下は **適用除外 (MAY skip)**:
  - レガシー移行で test harness が未整備な領域 (`negative-triggers.md` で列挙)
  - 調査スパイク (一時的、commit されないコード)
  - notebook / REPL ベースの探索
  - インフラ・設定ファイル・ドキュメントのみの変更
- 適用除外を選択した場合、その理由を **evidence に記録しなければならない (MUST)**。

**Rationalization Table (references/rationalization-table.md, 抜粋):**

| 思考 (言い訳) | 現実 |
|---------------|------|
| 「このバグは小さいから先に直す」 | 小さいバグほど regression を起こす。テストを書け |
| 「テストを書く時間がない」 | デバッグ時間 > テスト時間。実証済み |
| 「仕様が固まっていないからテストが書けない」 | それは仕様駆動実装ではない。`revising-spec` に戻れ |
| 「実装を見ないとテストが書けない」 | テストは仕様から書く。`docs/main-basic-design.md` を読め |
| 「リファクタだけだから」 | 既存テストが緑であることを証明してから始めよ |
| ... (合計 20+ 行) | |

### 2.2 `enforcing-code-discipline` (W2 の補強)

**位置づけ:** TDD だけでは拾えない「コードの正しさ」(命名・複雑度・境界・error handling 漏れ・dead code) を、`requesting-code-review` の前段に配置するチェックリスト型スキル。

**ファイル構成:**

```
.claude/skills/enforcing-code-discipline/
├── SKILL.md
├── references/
│   ├── code-quality-checklist.md         # SOLID / 命名 / 複雑度 / 境界
│   ├── self-review-protocol.md           # 自己レビュー手順 (Read で diff を全件確認)
│   └── red-flags.md                      # 「とりあえず動いた」「後でリファクタする」等
└── scripts/
    └── run_self_review.sh                 # diff のサマリ生成 + チェックリスト出力
```

**役割分担:**
- `test-driven-implementation` が **動くこと** を保証
- `enforcing-code-discipline` が **正しく書けていること** を保証
- `requesting-code-review` が **第三者視点** を保証

3 段構えで superpowers の TDD Iron Law + 二段階レビューに匹敵する規律を構築する。

---

## 3. 既存スキルの強化 (破壊的変更なし)

### 3.1 `systematic-debugging` の強化 (W3)

現状の SKILL.md は手順中心で、**サボタージュ防止の心理ガードが薄い**。以下を追加する。

**追加ファイル:**

```
.claude/skills/systematic-debugging/references/
├── red-flags.md                # NEW: デバッグ中の危険思考 14+ 行
├── rationalization-table.md    # NEW: 言い訳 → 反論
├── common-failure-patterns.md  # NEW: 7 種以上の典型失敗
└── hypothesis-evidence-loop.md # NEW: 仮説 → 証拠 → 棄却 のループ強制
```

**Red Flags (例):**

| 危険思考 | 現実 |
|----------|------|
| 「たぶんこれが原因」 | 仮説は **検証されるまで仮説**。コードを書くな、ログを取れ |
| 「とりあえず再起動したら直った」 | 再現条件を特定するまで「直った」と言うな |
| 「このログは無関係そう」 | 「無関係」と断定するには根拠がいる |
| 「前にも同じ症状を見た」 | 同じ symptom = 同じ root cause ではない |
| ... | |

**SKILL.md への追記 (破壊的変更なし):**

```markdown
## Hard Constraints (RFC 2119)
- 仮説を立てたら、コードを変更する前に証拠を集めなければならない (MUST)
- 修正後、元の症状が再現しないことを **証拠付きで** 確認しなければならない (MUST)
- 「たぶん」「おそらく」「気がする」を含む完了報告を出してはならない (MUST NOT)
```

これにより比較レポート §3 の「superpowers の方がサボれない」差分を埋める。

### 3.2 `implementing-from-spec` への REQUIRED SUB-SKILL 追加

SKILL.md の "Process" セクションに 1 行追加するだけ:

```markdown
## REQUIRED SUB-SKILLS
- `spec-coexist:test-driven-implementation` — 全てのコード変更の前に呼び出すこと (MUST)
- `spec-coexist:enforcing-code-discipline` — `requesting-code-review` の前に呼び出すこと (MUST)
```

### 3.3 `revising-implementation` への同様の追記

同じ 2 つの REQUIRED SUB-SKILL を追加。

### 3.4 `verification-before-completion` の evidence schema 拡張

`_shared/references/evidence-schema.md` に新しい proof type を追加:

- `proof-type: tdd-red` — RED フェーズの失敗ログ
- `proof-type: tdd-green` — GREEN フェーズのパスログ
- `proof-type: self-review` — `enforcing-code-discipline` のチェックリスト結果
- `proof-type: debug-hypothesis` — `systematic-debugging` の仮説と棄却記録

これで「テストを書いた」「自己レビューした」「デバッグ仮説を検証した」が**すべて監査トレースに乗る**。

### 3.5 `authoring-spec-coexist-skill` への RED-GREEN-REFACTOR 統合 (W4)

superpowers `writing-skills` の方法論を spec-coexist 文体で取り込む。

**追加ファイル:**

```
.claude/skills/authoring-spec-coexist-skill/references/
├── skill-tdd-protocol.md         # NEW: skill 自体への RED-GREEN-REFACTOR
└── pressure-scenarios.md         # NEW: subagent に圧力シナリオを与えて遵守を測る
```

既存の `trigger-tests.md` と組み合わせ、「skill を書く前に **遵守されない baseline** を測る → skill を書く → 再測する」フローを必須化する。

---

## 4. CI / hook 統合 (W5)

`.claude/settings.json` に以下のフックを追加する案 (別 PR で扱う):

| Event | Hook | 効果 |
|-------|------|------|
| `PostToolUse` (Edit/Write on `*.py`, `*.ts` etc.) | `verify_test_first.sh` を実行 | テストより先に実装が書かれたら警告 |
| `Stop` | `run_gate_checklist.sh` を実行 | 完了報告前に verification gate を強制 |
| `PreToolUse` (Bash with `git commit`) | evidence の存在チェック | proof 無しで commit させない |

これにより「人間の善意依存」を脱却し、**ハーネスレベルで規律を強制**する。

---

## 5. 実行計画 (フェーズ分け)

### Phase 1 — TDD コア (W1 解消, 1 PR)
- [ ] `test-driven-implementation/` 一式を作成 (SKILL.md + 6 references + 3 scripts)
- [ ] `_shared/references/evidence-schema.md` に `tdd-red`, `tdd-green` proof type を追加
- [ ] `implementing-from-spec/SKILL.md` に REQUIRED SUB-SKILL 行を 1 行追加
- [ ] `revising-implementation/SKILL.md` に同上
- [ ] `MEMORY.md` 等の index ファイル更新 (必要なら)
- [ ] **検証:** subagent に「TDD なしで実装」を試みさせ、Iron Law が発火することを確認

### Phase 2 — コード規律 (W2 解消, 1 PR)
- [ ] `enforcing-code-discipline/` 一式を作成
- [ ] `requesting-code-review/SKILL.md` の前段に REQUIRED SUB-SKILL を追加
- [ ] evidence schema に `self-review` proof type を追加

### Phase 3 — Debugging 強化 (W3 解消, 1 PR)
- [ ] `systematic-debugging/references/` に 4 ファイル追加 (red-flags, rationalization, failure-patterns, hypothesis-loop)
- [ ] `systematic-debugging/SKILL.md` に Hard Constraints セクションを追記
- [ ] evidence schema に `debug-hypothesis` proof type を追加

### Phase 4 — Skill TDD (W4 解消, 1 PR)
- [ ] `authoring-spec-coexist-skill/references/` に 2 ファイル追加
- [ ] 既存 `trigger-tests.md` との接続を文書化

### Phase 5 — Hook 自動化 (W5 解消, 1 PR, 慎重)
- [ ] `verify_test_first.sh` の信頼性を上げる (false positive を抑える)
- [ ] `.claude/settings.json` への hook 追加案を**ドキュメントとして提案**し、実装はユーザ承認後

各 Phase は独立して merge 可能で、roll back 単位も Phase 単位とする。

---

## 6. 完了条件 (Definition of Done)

本プランが完了したと見なすための条件:

1. `test-driven-implementation`, `enforcing-code-discipline` の 2 スキルが追加されている
2. `implementing-from-spec` / `revising-implementation` / `requesting-code-review` から REQUIRED SUB-SKILL として参照されている
3. `systematic-debugging` に Red Flags / Rationalization / Failure Patterns / Hypothesis Loop の 4 references が存在する
4. evidence schema が 4 種類の新 proof type をサポートしている
5. 比較レポートを subagent に再評価させ、以下のスコアが改善している:
   - **Enforcement & Verification:** 8 → **9**
   - **Testability:** 6 → **8**
   - **Production-Readiness:** 7 → **8 以上**
   - **総合:** 7.3 → **8.0 以上**
6. すべての追加に対して `authoring-spec-coexist-skill` の trigger-tests.md にテストケースが追加されている
7. 既存スキルへの破壊的変更が無いことを `git diff` で確認 (追加のみ)

---

## 7. 非ゴール (やらないこと)

- **superpowers をそのまま import すること。** 命名規則・哲学・言語が違うため、コピペは衛生を損なう。
- **TDD を全コードに適用すること。** 適用範囲は `negative-triggers.md` で明示し、現場の現実に合わせる。
- **doc-lifecycle / evidence schema の既存仕様を変更すること。** 既存スキルへの影響を避けるため、**追加のみ**で対応する。
- **日本語 trigger を英語化すること。** バイリンガルを維持する。
- **他言語スキル (Rust専用、Go専用 等) の導入。** スコープ外。

---

## 8. リスクと緩和策

| リスク | 緩和策 |
|--------|--------|
| TDD Iron Law がレガシーコードで暴走 | `negative-triggers.md` を最初から手厚く書く。Phase 1 PR の review で list を確定 |
| Skill 数が増えてオンボーディングが重くなる | `using-spec-coexist` のインベントリ表を更新し、新規スキルの位置付けを 1 行で示す |
| `verify_test_first.sh` の false positive | Phase 5 まで hook 化を遅らせ、人間運用で精度を上げてから自動化 |
| evidence schema の breaking change | 既存 proof type は触らず、追加のみとする |
| 既存ユーザの混乱 | 各 Phase の PR 説明に「破壊的変更なし、追加のみ」を明記 |

---

## 9. まとめ

このプランは、比較レポートで指摘された **W1 (TDD 不在)**, **W2 (コード規律弱)**, **W3 (debugging 弱)** を、spec-coexist の哲学 (ドキュメント駆動 + 日本語ファースト + RFC 2119 + evidence schema + 薄いオーケストレータ) を**一切壊さずに**解消する。

副次的に **W4 (skill 自体の TDD)** と **W5 (hook 自動化)** にも段階的に対応する。

完了時、spec-coexist は「**ドキュメント統治**」と「**コード規律**」を両立し、比較レポートの総合点 7.3 → **8.0 以上** への到達が見込まれる。
