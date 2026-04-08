# Critical Comparison Report: `superpowers` vs `.claude/skills/` (spec-coexist)

**作成日:** 2026-04-09
**対象読者:** プロフェッショナルな開発現場 (規制業界・大規模チーム・エージェント駆動開発)
**比較対象:**
- **Suite A — spec-coexist:** `/workspace/.claude/skills/` (14 skills, 約891行)
- **Suite B — superpowers:** `claude-plugins-official/superpowers/5.0.7/skills/` (14 skills, 約3,159行)

---

## 0. Executive Summary

両スイートは表面上は重なる領域 (debugging, verification, code-review, planning) を扱うが、**設計哲学が根本的に異なる**。

| 観点 | spec-coexist | superpowers |
|------|--------------|-------------|
| 中心思想 | **ドキュメント駆動ガバナンス** (仕様書・evidenceトレース) | **エージェント駆動規律** (TDD Iron Law・subagent dispatch) |
| 標準言語 | 日本語ファースト + 英語併記 | 英語のみ |
| 強制力の所在 | RFC 2119 + ハードゲート + lifecycle | "MUST" + TDD絶対主義 + Red Flagsテーブル |
| ボリューム | 14 skills / 891行 (薄いオーケストレータ + 外出しreferences) | 14 skills / 3,159行 (インライン濃厚) |
| 想定文化 | 規制・監査・日本語仕様文化 | スタートアップ・エージェント自動化・多IDE |

**結論を先に述べる:** どちらも 7点台後半の実用品質だが、**互いに排他的ではなく補完的**。単独採用するなら現場の文化に依存する。両方の良いとこ取りが理想。

---

## 1. Suite A: spec-coexist 詳細評価

### 1.1 概観

`/workspace/.claude/skills/` 配下に 14 スキル + `_shared/` (共通 references / scripts / templates / tests)。各スキルは「**薄いオーケストレータ**」スタイルで、SKILL.md は短く、詳細は `references/*.md` と `scripts/*.sh` に外出ししてある。

カバーする工程:
`exploring-problem-space → creating-requirements → creating-basic-design → implementing-from-spec → revising-spec / revising-implementation → verification-before-completion → requesting/receiving-code-review → finishing-subsystem-work` + `parallelizing-subsystem-work` + `authoring-spec-coexist-skill` + `systematic-debugging` + `using-spec-coexist`。

### 1.2 強み (Pros)

1. **仕様書ライフサイクル管理が一級市民。** `_shared/references/doc-lifecycle.md` で `draft / active / deprecated / superseded` の状態遷移を定義し、`check_doc_links.sh` がリンク整合性を検査する。**監査証跡が必要な現場では決定的アドバンテージ**。
2. **Evidence schema が明示。** `_shared/scripts/write_evidence.sh` で「proof-command / pass-fail / review-ref」を記録。検証を「言ったもの勝ち」にしない仕組みが組み込まれている。
3. **Subsystem 並列化に専用スキル。** `parallelizing-subsystem-work` は worktree 隔離 + dependency graph チェックを強制し、依存があれば HALT する。superpowers の `dispatching-parallel-agents` には無い堅さ。
4. **バイリンガル trigger。** 日本語と英語が併記され、`locale: ja` をデフォルトにできる。Mermaid の CJK 制約まで考慮されている (`beautiful-mermaid-rules`)。
5. **RFC 2119 ベースの hard constraint 言語。** "MUST HALT" ゲートが各スキルに明示。曖昧さが極めて少ない。
6. **Namespace policy の徹底。** `spec-coexist:` プレフィックスでスキル参照を統一。中規模以上の skill suite で必須となる衛生規則。

### 1.3 弱み (Cons)

1. **ドキュメント中心バイアス。** すべての work が `docs/main-requirements.md` や `docs/subsystems/{id}_{name}/` を通る前提。スパイク・プロトタイピング・レガシー移行には**重すぎる**。
2. **TDD・テスト規律のスキルが存在しない。** 実装側の保証は code-review と verification に依存し、テストファースト文化を**強制する仕掛けが無い**。
3. **CI / hook 統合が不在。** すべて人間 (or Claude) による手動 invocation 前提。`settings.json` フックは絡んでいない。
4. **Skill 自体のテスト法が弱い。** `authoring-spec-coexist-skill` に `trigger-tests.md` はあるが、superpowers の RED-GREEN-REFACTOR + pressure scenario ほどの方法論は無い。
5. **1% rule の過剰起動リスク。** わずかな仕様文脈でも skill を呼ぶ設計のため、`negative-triggers.md` で除外していても誤起動の余地がある。
6. **References の散在。** モジュラリティが高い反面、`doc-lifecycle.md` のような共有資産を変更すると 5+ skill に影響する。

### 1.4 観点別スコア

| 観点 | 点数 | コメント |
|------|------|----------|
| Coverage / Completeness | **8** | 仕様→実装の連鎖は完璧。TDD と brainstorming は弱い。 |
| Trigger Specificity | **8** | 1% rule + 否定 trigger + バイリンガル。誤発火と失火のバランス良好。 |
| Enforcement & Verification | **8** | Evidence schema と doc lifecycle は本物。コード側ガードは superpowers より緩い。 |
| Maintainability | **7** | 外出し references で改修しやすいが、共有資産の波及範囲が広い。 |
| Testability | **6** | フィクスチャはあるが自動 CI は無い。 |
| Onboarding | **7** | `using-spec-coexist` のインベントリ表は明快。日本語話者には特に親切。 |
| Localization | **9** | 日本語ファースト設計。CJK 配慮は他に類を見ない。 |
| Production-Readiness | **7** | 規制・監査領域では強い。アジャイル現場ではやや重い。 |
| Composability | **7** | ハンドオフが明示的だが密結合気味。 |
| Misuse Risk (低いほど良) | **6** | ドキュメントゲートが多く、過剰硬直のリスクあり。 |
| **総合 (加重平均)** | **7.3** | |

---

## 2. Suite B: superpowers 詳細評価

### 2.1 概観

`claude-plugins-official/superpowers/5.0.7/skills/` 配下に 14 スキル。各 SKILL.md は 100〜650 行と**インライン濃厚**。`brainstorming → writing-plans → executing-plans / subagent-driven-development → finishing-a-development-branch` を中心に、`test-driven-development`, `writing-skills`, `verification-before-completion`, `using-git-worktrees`, `dispatching-parallel-agents` など、**エージェント駆動開発の汎用ツールキット**として体系化されている。

### 2.2 強み (Pros)

1. **TDD を全面強制する Iron Law。** `test-driven-development` は "NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST" を絶対律にし、違反したコードは**消して書き直す**ことを求める。30 行近い rationalization テーブルで言い訳を潰す。
2. **Skill そのものに TDD を適用 (`writing-skills`)。** baseline 違反 → skill 追加 → 再テストで遵守、という RED-GREEN-REFACTOR をドキュメントに適用するメソドロジは独自で強力。
3. **Subagent dispatch パターンが一級。** `subagent-driven-development` は implementer / spec-reviewer / code-quality-reviewer の prompt テンプレートを持ち、二段階レビューを構造化。`dispatching-parallel-agents` も独立。
4. **Multi-IDE / multi-platform 対応。** Copilot CLI, Codex, Gemini CLI 用の references を持つ。**Claude Code 以外のツールでも転用可能**。
5. **Red Flags + Rationalization Tables。** `using-superpowers` と `verification-before-completion` には「こう考えたらアウト」の心理パターン表があり、サボタージュを未然に防ぐ。
6. **CSO (Claude Search Optimization) ガイドの存在。** `writing-skills` がスキル description を Claude に発見されやすく書く方法を明示。スキルそのもののディスカバラビリティを工学的に扱っている。
7. **`finishing-a-development-branch` の統合判断。** squash / rebase / merge / cleanup の意思決定を支援。実プロダクト運用に即している。

### 2.3 弱み (Cons)

1. **ドキュメントライフサイクルの欠如。** 仕様書の `draft / active / deprecated` のような state machine が無い。**仕様がコードから drift する**。
2. **TDD Iron Law の硬直性。** レガシー移行・調査スパイク・REPL 探索など、テストが書けない (or 書くべきでない) 文脈でも「コード消せ」となる。**現場での反発リスク大**。
3. **Subagent dispatch のオーバーヘッド。** タスクごとに fresh subagent を立てる前提で、コンテキスト消費が嵩む。狭いコンテキスト予算では遅くなる。
4. **Subsystem 依存グラフチェックが無い。** `dispatching-parallel-agents` は独立性を**仮定**するだけ。spec-coexist の `subsystem_deps.sh` のような実証手段が無い。
5. **インラインの密度が高すぎる。** 一部 SKILL.md が 600+ 行に達し、改修時の影響範囲が読みにくい。モジュラ性は spec-coexist より低い。
6. **日本語サポートゼロ。** trigger も英語のみ。日本語チームが導入するには丸ごと re-author が必要。
7. **過剰プロセス強制リスク。** "MUST use brainstorming before any feature" + "MUST TDD" + "MUST writing-plans" を直列に並べると、軽微な変更でも儀式が膨れ上がる。

### 2.4 観点別スコア

| 観点 | 点数 | コメント |
|------|------|----------|
| Coverage / Completeness | **8** | brainstorming + TDD + plan + 並列エージェントが揃う。仕様ガバナンスは弱い。 |
| Trigger Specificity | **9** | EXTREMELY-IMPORTANT 警告 + Red Flags + 多 IDE 対応。発火精度が最も高い。 |
| Enforcement & Verification | **8** | TDD Iron Law と二段階レビューは強烈。Evidence の物的トレースは弱め。 |
| Maintainability | **7** | インライン濃厚で局所改修は容易だが、長文 SKILL.md の認知負荷あり。 |
| Testability | **7** | Pressure scenario + RED-GREEN-REFACTOR の方法論は秀逸。CI 統合は無い。 |
| Onboarding | **8** | CSO ガイドと multi-IDE references が onboarding を底上げ。 |
| Localization | **4** | 英語のみ。CJK / 多言語チームには不向き。 |
| Production-Readiness | **8** | コード規律・統合判断・ブランチ整理まで揃う。仕様 drift リスクが残点。 |
| Composability | **7** | "REQUIRED SUB-SKILL" 参照で疎結合。オーケストレーションは暗黙的。 |
| Misuse Risk (低いほど良) | **6** | TDD 絶対主義 + subagent overhead が現場で過剰になりやすい。 |
| **総合 (加重平均)** | **7.6** | |

---

## 3. 直接対決: 共通領域での差分

| スキル | spec-coexist | superpowers | 評 |
|--------|--------------|-------------|-----|
| `verification-before-completion` | Evidence schema + write_evidence.sh で**物的証拠**を残す | 5-step gate + Red Flags 心理ガード | spec-coexist が監査向き、superpowers が心理ガード向き |
| `systematic-debugging` | RFC 2119 + 1% rule で起動。手順は標準的 | Red Flags + 共通失敗パターン記述が厚い | superpowers の方が「サボれない」 |
| `requesting/receiving-code-review` | severity policy + 再レビュートリガが構造化 | Subagent dispatch 連携、TDD 規律と統合 | spec-coexist が規律志向、superpowers が agentic 志向 |
| 並列実行 | `parallelizing-subsystem-work` + 依存検査 | `dispatching-parallel-agents` (独立性は仮定) | spec-coexist が**安全側**、superpowers が**機動側** |
| Skill 作成 | `authoring-spec-coexist-skill` + trigger-tests.md | `writing-skills` + pressure scenarios + CSO | superpowers の方法論が明らかに進んでいる |

---

## 4. 観点別ヘッドツーヘッド

| 観点 | spec-coexist | superpowers | 勝者 |
|------|:-:|:-:|:-:|
| Coverage | 8 | 8 | 引き分け (補完関係) |
| Trigger Specificity | 8 | 9 | **superpowers** |
| Enforcement | 8 | 8 | 引き分け (軸が違う) |
| Maintainability | 7 | 7 | 引き分け |
| Testability | 6 | 7 | **superpowers** |
| Onboarding | 7 | 8 | **superpowers** |
| Localization | 9 | 4 | **spec-coexist** (圧勝) |
| Production-Readiness | 7 | 8 | superpowers (僅差) |
| Composability | 7 | 7 | 引き分け |
| Misuse Risk (低いほど良) | 6 | 6 | 引き分け |
| **総合** | **7.3** | **7.6** | superpowers わずかに上 |

---

## 5. 現場適合マトリクス

| 現場 | 推奨 | 理由 |
|------|------|------|
| 医療・金融・公共調達など**規制業界** | **spec-coexist** | Doc lifecycle + evidence + 監査トレース |
| 日本語仕様書文化のチーム | **spec-coexist** | バイリンガル trigger + CJK 配慮 |
| 大規模 OSS / 分散開発 | **spec-coexist** | Subsystem 依存検査 + worktree 並列 |
| スタートアップ / 高速プロトタイピング | **superpowers** | brainstorming + TDD + subagent 連携 |
| エージェント駆動 (多 IDE / Copilot 等) | **superpowers** | Multi-platform references |
| TDD ネイティブな組織 | **superpowers** | Iron Law と RED-GREEN-REFACTOR |
| レガシー移行・調査スパイク | **どちらも合わない** | 両者ともに「儀式」が重い |

---

## 6. 批評的提言

1. **どちらか単独では片手落ち。** spec-coexist は「**書かれた仕様の正しさ**」を守るが、コードの書き方への規律が弱い。superpowers は「**書かれるコードの正しさ**」を守るが、仕様の drift を防がない。
2. **理想形は両者の合流。**
   - spec-coexist の `_shared/scripts/`, `doc-lifecycle.md`, `evidence-schema.md`, `parallelizing-subsystem-work` の依存検査
   - superpowers の `test-driven-development`, `writing-skills` (RED-GREEN-REFACTOR), `subagent-driven-development`, `brainstorming`, `using-git-worktrees`
   この組み合わせがプロフェッショナル現場で最も**取りこぼしが少ない**。
3. **両者共通の弱点。** CI / hook 自動化、テストの reproducibility、レガシー親和性。`settings.json` フックや `pre-commit` 統合まで踏み込まないと、本当の意味での「強制」にはならない。
4. **TDD 絶対主義への警鐘。** superpowers の Iron Law は教育的価値が高いが、現実の現場 (legacy refactor, infra spike, ML notebook) で**逐語的に守らせると逆効果**。プロフェッショナル運用では「Iron Law の適用範囲」を CLAUDE.md でローカライズすべき。
5. **日本語チームへの注意。** superpowers をそのまま導入すると trigger が発火しにくい。description を日本語併記に書き換えるか、spec-coexist 側に superpowers のメソドロジを移植する方が現実的。

---

## 7. 最終評定

| Suite | 総合点 (10 点満点) | 一言評 |
|-------|:-:|--------|
| **spec-coexist** | **7.3 / 10** | 「日本語仕様文化と監査現場のための、document-first な統治装置」 |
| **superpowers** | **7.6 / 10** | 「英語圏エージェント駆動開発のための、TDD-first な規律装置」 |

**どちらも単独では 7 点台。両者を統合すれば 9 点台に届く可能性がある。** プロフェッショナル現場での採用判断は、**現場文化 (規制 / アジャイル) × 言語 (日本語 / 英語) × 規律の所在 (ドキュメント / コード)** の 3 軸で決めるのが妥当である。
