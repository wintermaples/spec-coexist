---
title: spec-coexist 8点化アッププラン
date: 2026-04-09
basis: SKILL_SUITE_COMPARISON.md
constraint: 未配布のため破壊的変更可
goal: 24軸すべて 8/10 以上 (現状 平均 5.96 / 中央値 6)
---

# spec-coexist を全軸 8/10 に引き上げる実行プラン

## 0. 出発点 — 24 軸スコアと不足ポイント

| 軸 | 現状 | 目標 | 不足 | 評価者 |
|---|---:|---:|---:|---|
| 戦略価値 | 7 | 8 | 1 | CTO |
| リスクプロファイル | 6 | 8 | 2 | CTO |
| 保守性 | **5** | 8 | **3** | CTO |
| チームスケール | 7 | 8 | 1 | CTO |
| 要件管理 | 7 | 8 | 1 | PM |
| 変更管理 | 7 | 8 | 1 | PM |
| ステークホルダー可視性 | 6 | 8 | 2 | PM |
| 配信スピード | 6 | 8 | 2 | PM |
| ドキュメント品質 | 7 | 8 | 1 | PM |
| アーキテクチャ | 7 | 8 | 1 | SE |
| 合成可能性 | 7 | 8 | 1 | SE |
| TDD 厳格性 (SE) | 7 | 8 | 1 | SE |
| 並列作業支援 | 6 | 8 | 2 | SE |
| 障害耐性 | 6 | 8 | 2 | SE |
| 日次エルゴノミクス | **4** | 8 | **4** | PG |
| 小タスクオーバーヘッド | **3** | 8 | **5** | PG |
| 中タスクスピード | **5** | 8 | **3** | PG |
| 認知負荷 | **4** | 8 | **4** | PG |
| 使う喜び | **4** | 8 | **4** | PG |
| TDD 厳格性 (QA) | 7 | 8 | 1 | QA |
| トレーサビリティ | 6 | 8 | 2 | QA |
| 欠陥予防 | 7 | 8 | 1 | QA |
| 検証強制可能性 | **5** | 8 | **3** | QA |
| 監査適合 | 6 | 8 | 2 | QA |

**最大ギャップは PG 観点 (5軸合計 -20)**。次が QA の検証強制可能性と CTO 保守性。
よって本プランは **PG ergonomics の救済を最優先**、次いで強制可能性と保守性、最後に各レイヤの磨き込みという順で構成する。

---

## 1. プランの 5 ワーク・パッケージ

| WP | 名前 | 主担当軸 | 期待スコア寄与 |
|---|---|---|---|
| **WP1** | Ergonomics 再設計 (1%ルール撤廃 + tier化) | PG 全軸, PM 配信スピード | PG +4〜5 / PM 配信 +2 |
| **WP2** | 強制可能性 (CI ゲート + 証跡 schema) | QA 検証/監査, CTO リスク | QA +3 / CTO リスク +2 |
| **WP3** | トレーサビリティマトリクス + ステークホルダー成果物 | QA トレース, PM 可視性/ドキュ | QA +2 / PM +2 |
| **WP4** | 並列・worktree メカニクス取り込み | SE 並列, SE 障害耐性 | SE +2 |
| **WP5** | 保守性・配布・実戦化 | CTO 保守/戦略/チーム | CTO +3 / 全般 +1 |

各 WP は独立適用可能だが、WP1 は他すべての前提 (PG が触らないツールは育たない)。

---

## WP1 — Ergonomics 再設計 (最優先)

### 課題 (再掲)
PG 評価が壊滅的 (3〜4点)。原因は 3 つに集約される:
1. **1% ルールが全メッセージに発火** (CTO/PM/SE/PG/QA 全員指摘)
2. **小タスクでも spec 4 文書を要求する重力**
3. **`enforcing` / `discipline` という説教的命名** (PG 指摘)

### 1.1 1% ルールの破壊的廃止 → "task-tier router" に置換

**捨てる**: `using-spec-coexist` の現行 1% ルール、`references/1pct-rule.md`、negative-triggers の散文判定。

**新設**: タスクを 4 ティアに分類するルータースキル。

| Tier | 例 | 必要スキル | スキップ可能 |
|---|---|---|---|
| T0: trivial | typo, rename, ≤10 行差分 | (なし) → 直接編集 | spec, design, problem-space |
| T1: small | 単一関数の追加・バグ修正 | TDD + verification | spec, design, problem-space |
| T2: medium | 既存サブシステム内の機能追加 | implementing-from-spec (light: 設計のみ skim) | requirements 新規作成 |
| T3: large | 新サブシステム / 跨ぎ機能 / 振る舞い変更 | フルパイプライン | — |

**判定キー**: 差分予測行数、変更ファイル数、サブシステム横断有無、振る舞い変更有無。
**判定主体**: ルータースキル本体 (LLM 推論) + ユーザの **明示 tier 上書きフラグ** (`tier:T1` のようなプレフィックス)。

**ファイル変更**:
- 削除: `using-spec-coexist/references/1pct-rule.md`
- 削除: `using-spec-coexist/references/negative-triggers.md` (T0 ルールに吸収)
- 改訂: `using-spec-coexist/SKILL.md` を tier router に書き直し
- 新設: `using-spec-coexist/references/task-tiers.md` (定義表)
- 新設: `using-spec-coexist/references/tier-examples.md` (各 tier ≥10 例)

**寄与**: PG 全軸 +3〜4、PM 配信スピード +2、CTO チームスケール +1。

### 1.2 "fast path" スキルの導入

新スキル: **`spec-coexist:fast-path`** (T0/T1 専用、≤200 行スキル本体)。
- 役割: spec を一切要求せず、TDD と verification のみ通す最短経路。
- 内部委譲: `test-driven-implementation` (T1 のみ) → `verification-before-completion`。
- T0 では verification すら省略 (差分目視 + lint)。

### 1.3 説教的命名の刷新

**破壊的リネーム**:
| 旧 | 新 | 理由 |
|---|---|---|
| `enforcing-code-discipline` | `pre-review-self-check` | PG 指摘: "enforcing/discipline" は開発者を欠陥扱い |
| `using-spec-coexist` | `spec-coexist-router` | 役割を名前に反映 |

スキル本文中の RFC 2119 "MUST/SHALL" を T2/T3 文脈にだけ残し、T0/T1 文脈の散文からは除去 (PG 認知負荷)。

### 1.4 認知負荷削減 — スキル統廃合

17 → **12 スキル** に圧縮。

| 統合元 | 統合先 | 根拠 |
|---|---|---|
| `revising-spec` + `revising-implementation` | `revising` (1スキル, 内部分岐) | ペアで使うのが常 |
| `requesting-code-review` + `receiving-code-review` | `code-review-loop` | 依頼と受領は 1 ループ |
| `creating-requirements` + `creating-basic-design` | 残す (粒度が違う) | — |
| `authoring-spec-coexist-skill` | `_meta/authoring-skill.md` に格下げ | 日次で使わない |

### 検証
WP1 完了後、**現状再採点**: PG 4軸を 8 以上に戻すかを 10 サンプルタスクで人手評価 (typo / バグ / 機能 / リファクタ / 新サブシステム × 各 2)。

---

## WP2 — 強制可能性 (Enforceability)

### 課題
QA 評価: verification は **散文ではシアター**。`tdd-red`/`tdd-green` 証跡は前進だが、CI ゲート無しに「真の強制可能」には届かない (5/10)。

### 2.1 証跡ファイルの schema 化

新設: `_shared/schemas/evidence.schema.json` — `tdd-red`, `tdd-green`, `verification-result`, `self-check-result` の JSON Schema。

**破壊的変更**: 現行の自由形式 markdown 証跡を **`.spec-coexist/evidence/<task-id>/*.json`** に移行。
- ファイル命名規則 + タイムスタンプ + コミット SHA を必須化。
- 散文の物語は別ファイルに分離 (`notes.md`) し、機械検証対象から外す。

### 2.2 CI ゲート (実物の git hook + GitHub Actions)

新設: `_shared/scripts/`
- `verify_evidence.sh` — 変更タスクに対し、tier に応じた証跡完全性を検査
- `verify_traceability.sh` — REQ-ID と test-ID の双方向リンクを検査 (WP3 と接続)
- `pre-commit.sh` — pre-review-self-check の必須項目を検査
- `.github/workflows/spec-coexist.yml` — PR でこれらを実行し、不足ならブロック

**ゲートポリシ**:
- T0: 差分行数閾値のみ (lint で十分)
- T1: tdd-red → tdd-green の順序検査 + verification-result 必須
- T2/T3: 上記 + REQ→test マトリクス完全性 + doc-link checker

### 2.3 evidence backdating 防止

`tdd-red` の git commit を `tdd-green` の **親** に置くことを Iron Law に追加。
`verify_evidence.sh` は `git log --follow` で先後関係を検査。

### 寄与
QA 検証強制可能性 5→8、QA 監査適合 6→8、QA TDD 厳格性 7→8、CTO リスク +1。

---

## WP3 — トレーサビリティマトリクス + ステークホルダー成果物

### 課題
- QA: REQ-ID → test-ID の **明示マトリクス成果物が無い** (前提インフラのみ)
- PM: ステークホルダー可視性 6 — 要件は読めるが PM/デザイナが「いま何が動いているか」を一覧できない

### 3.1 ID 規約と双方向リンク

**新設**: `_shared/references/id-conventions.md`
- 要件 ID: `REQ-<subsystem>-<n>`
- 設計要素 ID: `DES-<subsystem>-<n>`
- テスト ID: テスト名内の `[REQ-xxx]` タグ (Pytest/Jest どちらも grep 可)

**新設**: `_shared/scripts/build_traceability_matrix.sh`
- REQ-ID をスキャン → 各 ID に対して: 設計参照、テスト参照、コミット SHA、verification 証跡を集約
- 出力: `docs/_generated/traceability.md` (人間可読) + `traceability.json` (機械可読)
- 未カバー REQ / 孤立テストを警告

### 3.2 ステークホルダー成果物 — `delivery-snapshot`

新スキル: **`spec-coexist:delivery-snapshot`**
- 入力: ブランチ or タグ
- 出力: `docs/_generated/snapshot-<date>.md`
  - 完了 REQ 一覧 (lifecycle=active)
  - 進行中 REQ 一覧 (lifecycle=draft、所有者付き)
  - 直近改訂された設計要素
  - 未カバー REQ + 孤立テスト
  - mermaid 依存グラフ (`_shared/beautiful-mermaid-rules` を継承)

PM/デザイナは `snapshot` を 1 ファイル読めば現状把握可能になる (PM 可視性 6→8)。

### 3.3 doc-lifecycle の機械検証

既存の `check_doc_links.sh` を拡張し、`active` 状態の REQ が必ず `verification-result` を 1 つ以上持つことを保証。
`draft` のまま N 日経過したら警告。

### 寄与
QA トレース 6→8、PM 可視性 6→8、PM ドキュ 7→8、PM 配信 +1。

---

## WP4 — 並列・worktree メカニクス

### 課題
SE: 並列 6/10 — `parallelizing-subsystem-work` は **いつ・なぜ** は説明するが **どうやって** が薄い。superpowers の `using-git-worktrees` + `dispatching-parallel-agents` の方がメカニクスは強い。

### 4.1 `parallelizing-subsystem-work` の補強

サブセクションを追加 (新規スキルを増やさない、認知負荷観点):
- worktree 作成・破棄の正確な手順 (branch 命名規則・cleanup フック)
- worktree 間の依存検出 (`_shared/scripts/detect_worktree_conflicts.sh`)
- subagent dispatch のテンプレート (本数 / プロンプト構造 / 結果集約フォーマット)
- マージ時の競合解決順序 (sub-system topological)

### 4.2 障害耐性 — partial-failure の playbook

新設: `parallelizing-subsystem-work/references/partial-failure.md`
- ある worktree が落ちた時、他の継続判断をどうやるか
- 集約コミット前にロールバックする条件
- evidence ファイルの worktree 間マージ規則

### 寄与
SE 並列 6→8、SE 障害耐性 6→8。

---

## WP5 — 保守性・配布・実戦化

### 課題
- CTO 保守性 5 — 17 スキル、暗黙合成、テスト無し
- CTO リスク 6 — 外部採用ゼロ、実戦未検証
- CTO 戦略価値 7 — 成功事例が無い

### 5.1 スキル間依存の **マニフェスト化** (破壊的)

新設: `_shared/manifest.yml` — 全スキルの:
- 名前 / tier / role (router|gate|primary|sub|meta)
- 依存スキル (DAG)
- 必須 evidence kinds
- 適用 tier

**ロード時検証**: `using-spec-coexist` (router) が起動時にマニフェスト整合性を検査 (循環・dangling reference 検出)。

### 5.2 スキル本体テスト

新設: `.claude/skills/_tests/`
- 各スキルに対し ≥3 サンプルタスク (入力プロンプト + 期待される invoked-skill-trace)
- `_shared/scripts/run_skill_tests.sh` で CI で回す
- 既存の `_shared/tests/` が空でないなら統合

これは superpowers にも無い差別化要素になる (CTO 戦略価値 +1)。

### 5.3 配布準備

- `LICENSE` (MIT)
- `README.md` (本リポジトリ root) — 採用判断者向けに WP1〜5 の到達点を明記
- `CHANGELOG.md` — 本プラン適用を v1.0.0 として記録 (破壊的変更を明示)
- `examples/` — 実プロジェクトで T0〜T3 を回したスナップショット

### 5.4 ドッグフード実績の収集

本リポジトリ自身でのスキル使用ログを `_shared/dogfooding/` に蓄積。
`delivery-snapshot` が自動的に拾い、README に統計を表示。
"自分自身で 6 ヶ月使い、N タスク捌いた" は外部採用シグナルになる。

### 寄与
CTO 保守性 5→8、CTO リスク 6→8、CTO 戦略価値 7→8、CTO チームスケール 7→8。

---

## 2. 実行順序と依存

```
WP1 (ergonomics)  ──┬──> WP3 (traceability + snapshot)
                     ├──> WP4 (parallel mechanics)
                     │
WP2 (CI gates) ──────┴──> WP5 (maintainability + distribution)
```

- WP1 と WP2 は並列着手可能
- WP3 は WP1 のスキル統廃合後でないと配線が無駄になる
- WP5 は他全てが落ち着いてから (マニフェスト化が他 WP の最終構造に依存)

## 3. 破壊的変更サマリ

| 変更 | 影響 |
|---|---|
| 1% ルール撤廃 | `using-spec-coexist` 全面書き換え |
| `enforcing-code-discipline` → `pre-review-self-check` | 全参照リネーム |
| `using-spec-coexist` → `spec-coexist-router` | 全参照リネーム |
| 17 → 12 スキル | revising/code-review ペア統合、authoring を _meta/ へ |
| evidence の JSON Schema 化 | 既存 markdown 証跡は移行不可 (破棄) |
| ID 規約 (`REQ-/DES-`) | 既存 docs を全リネーム必要 (今は docs が薄いので可) |
| `_shared/manifest.yml` 必須化 | 全スキルに front-matter 拡張 |

未配布なので **すべて即時適用可**。

## 4. 受け入れ基準 (本プラン完了の定義)

1. WP1 完了: 10 サンプルタスク (typo×2, bug×2, feature×2, refactor×2, new-subsystem×2) で **PG 5軸を再評価し全て ≥8**。
2. WP2 完了: `verify_evidence.sh` + `verify_traceability.sh` が CI で動き、**意図的に証跡を欠落させた PR が 100% ブロック** される。
3. WP3 完了: `traceability.md` と `snapshot-*.md` が自動生成され、未カバー REQ を 0 件にできる。
4. WP4 完了: 2 サブシステムを並列 worktree で実装し、partial-failure シナリオ 1 件をプレイブック通りに復旧できる。
5. WP5 完了: マニフェスト整合性検査 + スキルテスト + LICENSE + README + ドッグフードログが揃い、**v1.0.0 タグ** を打てる。
6. 24 軸再採点で **全軸 ≥8、平均 ≥8.0**。

## 5. 期待最終スコア

| 評価者 | 現在平均 | 目標平均 | 根拠 |
|---|---:|---:|---|
| CTO | 6.25 | 8.0 | WP5 (保守性/配布/実戦化) + WP2 (リスク低減) |
| PM | 5.0 | 8.0 | WP1 (配信) + WP3 (可視性/ドキュ) |
| SE | 6.2 | 8.0 | WP4 (並列/耐性) + WP1 (合成) + WP2 (TDD) |
| PG | 4.8 | 8.0 | WP1 全部 |
| QA | 5.0 | 8.0 | WP2 (強制) + WP3 (トレース) + WP1.2 (T1 fast path で TDD 強制) |
| **総合** | **5.96** | **≥8.0** | — |

## 6. やらないこと (スコープ外)

- 9+/10 を狙わない (例外的領域は本プランの目的ではない)
- superpowers との実行時統合 (`independence` ポリシは維持)
- 多言語化 (日英以外)
- IDE プラグイン化
- spec-coexist 外のスキル (claude-api 等) との結合

## 7. 一行要約

> **PG を救え (WP1)、CI で証明しろ (WP2)、ステークホルダーに見せろ (WP3)、並列を磨け (WP4)、配布できる形に固めろ (WP5)** — この順番で破壊的に走れば全軸 8 に届く。
