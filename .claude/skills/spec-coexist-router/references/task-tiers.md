# Task Tiers — タスクティア定義

spec-coexist スキルスイートは、すべてのタスクを 4 つのティアに分類し、**ティアに応じた最小限のプロセス** だけを適用する。

## 判定基準

| 基準 | T0 | T1 | T2 | T3 |
|---|---|---|---|---|
| 差分予測行数 | ≤10 | ≤50 | ≤300 | >300 or 不明 |
| 変更ファイル数 | 1–2 | 1–3 | 1–10 | 多数 or 不明 |
| サブシステム横断 | No | No | No | Yes |
| 振る舞い変更 | No | 軽微 | Yes (既存内) | Yes (新規/跨ぎ) |

判定ルール:

- 2 つ以上の基準で上位ティアに該当する場合、そのティアを採用する。
- 判断に迷ったら **1 つ下のティアから始めて、途中で昇格** してよい。

## ティア定義

### T0: trivial

**例**: typo 修正、変数リネーム、import 整理、コメント修正、設定値の微調整。

**必要スキル**: なし — 直接編集してよい。
**スキップ可能**: spec, design, problem-space, TDD, verification, code-review。
**最低限**: diff 目視 + lint/format 通過。

### T1: small

**例**: 単一関数の追加・修正、単一バグ修正、テスト追加、小さなリファクタ。

**必要スキル**: `spec-coexist:fast-path` → 内部で `test-driven-implementation` + `verification-before-completion`。
**スキップ可能**: spec 文書作成、design 文書作成、problem-space 探索。
**最低限**: テストが先 (TDD)、verification 通過。

### T2: medium

**例**: 既存サブシステム内の機能追加、API エンドポイント追加、画面追加、中規模リファクタ。

**必要スキル**: `spec-coexist:implementing-from-spec` (light mode: 既存設計の skim のみ)。
**スキップ可能**: requirements の新規作成 (既存 spec に追記で十分な場合)。
**最低限**: 既存 spec との整合確認、TDD、verification、code-review。

### T3: large

**例**: 新サブシステム、サブシステム横断機能、アーキテクチャ変更、振る舞いの根本変更。

**必要スキル**: フルパイプライン (exploring-problem-space → creating-requirements → creating-basic-design → implementing-from-spec → code-review-loop → verification)。
**スキップ可能**: なし。

## ティア判定の主体

1. **ルータースキル (`spec-coexist-router`)** がユーザメッセージから判定基準を推論する。
2. ユーザは **`tier:T0`〜`tier:T3`** プレフィックスで明示上書きできる。ユーザ指定は常に優先。
3. 作業中にスコープが膨らんだら、エージェントはティアを **昇格** し、必要なスキルを追加適用する。降格は原則しない。

## ティアと RFC 2119

- T0/T1 の文脈では "SHOULD" / "MAY" を基本とする。開発者の判断を尊重する。
- T2/T3 の文脈では "MUST" / "SHALL" を使用する。プロセスの省略は明示的な理由を要する。
