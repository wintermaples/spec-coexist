# spec-coexist 拡張プラン

`SKILLS_COMPARISON.md` の減点項目を潰し、spec-coexist を "仕様駆動の骨格 + プロ現場の欠落ピース" まで引き上げるための拡張計画。観点ごとに章を分けて記述する。

各章の構成:
- **課題**: 現状で何が欠けているか
- **方針**: どう埋めるか(原則)
- **具体アクション**: 追加/改訂すべき skill・references・scripts
- **完了条件(DoD)**: 何が揃えば "埋まった" と言えるか
- **優先度**: P0(必須)/P1(強く推奨)/P2(あれば良い)
- **リスク**

---

## 1. 上流発散フェーズ(ブレスト/仮説出し)の欠落を埋める

### 課題
現状の spec-coexist は `creating-requirements` から始まるため、"そもそも何を作るか" を探索するフェーズが skill として存在しない。要件以前の発散・仮説整理が人間の暗黙知に依存している。

### 方針
要件定義に入る **前段** に、収束ではなく発散を担う skill を置く。ただし superpowers:brainstorming を呼ばない(独立性宣言の維持)。

### 具体アクション
- 新規 skill: `exploring-problem-space`
  - `user-invocable: true`
  - 目的: 未整理の要望から "解くべき問題" を 1 つに絞り込む。
  - Ordered Steps: (1) 課題を列挙 → (2) ステークホルダと制約を特定 → (3) 仮説を 3 つ出す → (4) 各仮説の反証実験を書く → (5) 次段 `creating-requirements` に引き渡す引継ぎメモを `docs/handoff/exploration-{date}.md` に書く。
  - references: `one-question-per-message.md`(既存の brainstorming-rules と整合)、`hypothesis-template.md`、`handoff-format.md`。
- `using-spec-coexist` の Skill Inventory に追記。

### DoD
- `docs/handoff/exploration-*.md` が生成され、その内容を `creating-requirements` が入力として参照できる。
- 1% ルールの例に "まだ要件化されていない相談" を追加済み。

### 優先度
P1

### リスク
発散フェーズが曖昧になり `creating-requirements` との境界が溶ける。引継ぎメモのスキーマを強制することで境界を保つ。

---

## 2. 実装ループ(TDD 相当)の強化

### 課題
`implementing-from-spec` は "仕様どおりに書く" 単一ステップで、Red-Green-Refactor のループが MUST として組み込まれていない。バグ予防の最大のレバーを取り損ねている。

### 方針
`implementing-from-spec` の内部プロセスとして TDD を MUST 化する。独立した skill に切り出すのではなく、**既存 skill の手順内に RFC 2119 で強制** する(skill 数の膨張を避ける)。

### 具体アクション
- `implementing-from-spec/SKILL.md` の Ordered Steps を改訂:
  1. 基本設計から受入基準を抽出 → `docs/acceptance/{feature}.md`
  2. **RED**: 失敗するテストを書き、失敗ログを記録(MUST)
  3. **GREEN**: 最小実装(MUST: 追加コード行数を RED テストに必要な分のみに制限)
  4. **REFACTOR**: 重複除去(MUST: テストが緑のまま)
  5. 以降は既存の verification / review ゲートへ
- 新規 reference: `implementing-from-spec/references/tdd-discipline.md`
  - "Iron Law" 相当を RFC 2119 で記述: `Production code MUST NOT be added unless a failing test exists in the working tree and its failure has been observed in the current session.`
- 新規 script: `_shared/scripts/record_test_failure.sh <test-cmd>` — 失敗ログと exit code を `docs/evidence/red-{timestamp}.log` に保存。証跡化する。
- `revising-implementation` 側にも同じ TDD ゲートを挿入。

### DoD
- `docs/evidence/red-*.log` が `verification-before-completion` の入力として参照される。
- RED 証跡なしの実装は `verification-before-completion` が HALT する。

### 優先度
P0

### リスク
テストが書けないドメイン(UI 微調整、探索的データ解析)で摩擦。`tdd-discipline.md` に MAY 適用除外節を明記し、適用除外時は理由を `docs/evidence/tdd-waiver-*.md` に残す運用で逃がす。

---

## 3. 並列実行 / worktree / サブエージェント駆動

### 課題
並列実装や worktree 隔離が一切無い。大規模改訂(複数サブシステム同時)で人間の手作業に丸投げされる。

### 方針
**spec-coexist の独立性宣言を守りつつ**、並列実行そのものは suite 内に自前で持つ。superpowers を呼ばない。

### 具体アクション
- 新規 skill: `parallelizing-subsystem-work`
  - 前提: `docs/subsystems/` 配下が複数存在し、それぞれに要件+基本設計が揃っている。
  - Ordered Steps: (1) 依存グラフを抽出(`_shared/scripts/subsystem_deps.sh`)→(2) 独立なサブシステム集合を列挙 →(3) 集合ごとに worktree を用意(`_shared/scripts/make_worktree.sh {subsystem}`)→(4) 各 worktree で `implementing-from-spec` を起動 →(5) 全完了後に統合レビュー。
  - MUST: 共有ファイル(`docs/main-*.md`)を触る skill は並列集合に入れない。
- 新規 reference: `parallelizing-subsystem-work/references/isolation-rules.md` — 並列化可否の判定基準。
- 新規 scripts:
  - `_shared/scripts/subsystem_deps.sh`
  - `_shared/scripts/make_worktree.sh <name>`
  - `_shared/scripts/cleanup_worktree.sh <name>`

### DoD
- `parallelizing-subsystem-work` が独立な 2 サブシステムを実際に worktree で並列実装できる。
- 依存のあるサブシステムを渡した場合に HALT する。

### 優先度
P1

### リスク
worktree とブランチ戦略はチーム慣習に強く依存する。`isolation-rules.md` を "このリポジトリのブランチ前提" として明文化し、他プロジェクトに輸出する場合は書き換え前提にする。

---

## 4. ブランチ締め / PR / マージ手順

### 課題
`verification-before-completion` → `requesting-code-review` の先、すなわち "実際にマージする・ PR を閉じる" 工程が skill 化されていない。最後の一歩が属人化。

### 方針
`finishing-subsystem-work` を新設し、**done 判定の後** に置く。

### 具体アクション
- 新規 skill: `finishing-subsystem-work`
  - Ordered Steps: (1) `verification-before-completion` 通過を確認 →(2) `receiving-code-review` の Critical/Important ゼロを確認 →(3) 変更サマリを `docs/changelog/{subsystem}-{date}.md` に追記 →(4) コミット整形(MUST: 1 論理変更 = 1 コミット)→(5) PR 作成 or マージ(ユーザ確認必須、HALT して確認)→(6) `docs/handoff/post-merge-{date}.md` を残す。
  - MUST: 破壊的操作(force push、reset --hard 等)は禁止。
- references: `finishing-subsystem-work/references/merge-safety.md`。

### DoD
- レビュー通過済みの変更がこの skill を経由してのみマージ提案される運用が可能。
- `docs/changelog/` にエントリが積み上がる。

### 優先度
P0

### リスク
PR 作成は環境(gh の有無、権限)に依存。skill 内で検出し、無ければ "手順書を表示するだけ" モードにフォールバック。

---

## 5. メタスキル(skill を書くための skill)

### 課題
spec-coexist には `writing-skills` 相当がなく、suite の拡張手順が暗黙知。本プランを実装する段階でまず躓く。

### 方針
**この拡張プラン自体を最初に実行可能にする**ために、メタスキルを P0 で入れる。

### 具体アクション
- 新規 skill: `authoring-spec-coexist-skill`
  - Ordered Steps: (1) 新 skill の目的を 1 文で書く →(2) `user-invocable` を判定 →(3) description を RFC 2119 語彙とトリガフレーズ(日英)で書く →(4) SKILL.md を 80 行以内に収める(MUST)、規範は `references/` へ →(5) scripts は `_shared/scripts/` へ集約 →(6) `using-spec-coexist` の Skill Inventory を更新 →(7) `tests/skill-triggering/` にトリガテストを追加(下章参照)。
  - references: `authoring-spec-coexist-skill/references/skill-template.md`, `naming-conventions.md`, `description-trigger-rules.md`(1% ルールとの整合)。
- MUST: 新 skill 内から `superpowers:*` を呼ばない(独立性宣言のテンプレ節を自動挿入)。

### DoD
- 本プラン章 1〜4 の新 skill が、この skill に従って生成されている。

### 優先度
P0

### リスク
メタスキルが肥大するとそれ自体が保守対象になる。SKILL.md 80 行制約を自分自身にも適用。

---

## 6. テスト資産 / 回帰検知

### 課題
description 改訂やリネームで自動起動が壊れても検知する術がない。superpowers の `tests/skill-triggering` に相当するものが無い。

### 方針
リポジトリに "プロンプト → 期待 skill" の対応テーブルを置き、CI(または手動)で検証する。

### 具体アクション
- 新規ディレクトリ: `.claude/skills/_shared/tests/`
  - `trigger-cases.jsonl`: `{prompt, expected_skill, language}` の行リスト。日英両方を含む。
  - `run_trigger_tests.sh`: 各 prompt を Claude に流し、実際に起動した skill 名を回収して照合(手元では手動実行で可、CI では headless モード)。
- `authoring-spec-coexist-skill` の Ordered Steps に "新 skill ごとに最低 3 ケース追加(MUST)" を組み込む。
- 新規 skill は不要。テストハーネスと規律で十分。

### DoD
- 既存 10 skill それぞれに 3 ケース以上のトリガテストが登録。
- 1 件でも外れたら赤で落ちる実行系がある。

### 優先度
P0

### リスク
headless 実行コストと非決定性。まずは "手動で月次回帰" 運用から始め、安定したら CI 化。

---

## 7. ガバナンス / 監査適性の強化

### 課題
すでに RFC 2119・HALT・独立性宣言という強みを持つが、**証跡(evidence)の集約場所** が skill ごとにバラけている。監査時に "この変更が全ゲートを通ったこと" を一箇所で見せられない。

### 方針
証跡を `docs/evidence/` に集約し、`verification-before-completion` を監査点にする。

### 具体アクション
- `verification-before-completion/SKILL.md` を改訂: 通過時に `docs/evidence/verification-{timestamp}.md` を生成(MUST)。内容は (i) 対象、(ii) 実行コマンド、(iii) 出力ハッシュ、(iv) 参照したレビュー結果のリンク、(v) 最終 `Review:` 行。
- `_shared/scripts/write_evidence.sh` を追加。
- 新規 reference: `verification-before-completion/references/evidence-schema.md`。
- `finishing-subsystem-work`(第 4 章)はこのファイルの存在を HALT 条件にする。

### DoD
- すべての完了宣言が `docs/evidence/verification-*.md` と 1:1 で対応。
- 過去分を `git log` から辿れる。

### 優先度
P0

### リスク
証跡ファイルの肥大。古いものは `docs/evidence/archive/` にローテーション。

---

## 8. 国際化とテンプレート輸出性

### 課題
テンプレート(`main-basic-design-template.md` 等)と用語("基本設計")が日本市場前提。海外チームに渡すと文化摩擦。

### 方針
日本語を第一言語に保ったまま、テンプレートを **ロケール切替** 可能にする。

### 具体アクション
- `_shared/templates/{ja,en}/` にテンプレートを分離。既存の `creating-basic-design/references/*-template.md` は `ja/` 側に移動。
- 新規 reference: `_shared/templates/README.md` — ロケール決定手順("ユーザの最初のメッセージ言語を判定、迷ったら日本語")。
- `creating-requirements` / `creating-basic-design` / `revising-spec` を改訂し、ロケール解決を最初のステップに挿入。

### DoD
- 英語プロンプトから en テンプレートで、日本語プロンプトから ja テンプレートで成果物が生成される。

### 優先度
P2

### リスク
en テンプレートの品質が ja に追い付くまで時間がかかる。最初は "en は ja の直訳 + TODO" で出し、運用で磨く。

---

## 9. クロスプラットフォーム(スクリプトの移植性)

### 課題
`_shared/scripts/` が bash 前提で、Windows 素の環境では動かない。

### 方針
`.sh` を維持しつつ、**呼び出しを一枚ラップ** して OS 差分を隠す。

### 具体アクション
- 新規: `_shared/scripts/run.py`(python 3 依存のみ)。各 `.sh` の薄いラッパ。
- 既存 skill の Script 節を "スクリプト名" 指定に統一し、実行エントリを `run.py <name> [args...]` に変更。
- references に `_shared/scripts/README.md` を追加して OS サポート状況を明記。

### DoD
- Windows(PowerShell)・macOS・Linux で同一の skill フローが完走する。

### 優先度
P2

### リスク
Python 依存が新たに発生する。チームのベースライン(既に Python あり)を確認してから進める。

---

## 10. 1% ルールの誤発火対策

### 課題
`using-spec-coexist` の 1% ルールは "使わない事故" を防ぐ一方、**無関係な雑談でも skill が走る** 誤発火の温床になりうる。プロ現場では "余計な skill が走ってトークン浪費・出力汚染" が信頼を削る。

### 方針
1% ルールは維持しつつ、**除外リスト(negative triggers)** を明記する。

### 具体アクション
- 新規 reference: `using-spec-coexist/references/negative-triggers.md`
  - 明確に除外するケース: 環境構築トラブル、CLI 使い方質問、ドキュメント閲覧のみ、過去コミットの要約依頼、等。
- `using-spec-coexist/SKILL.md` の Flow に "negative-triggers に該当するか" の判定ノードを挿入。
- 6 章のトリガテストに negative ケースを追加(MUST: 各 negative ケースで skill が起動しないことを確認)。

### DoD
- negative ケースでの誤発火率を回帰テストで監視できる。

### 優先度
P1

### リスク
negative リストが肥大すると 1% ルールの精神が骨抜きになる。上限(例: 20 件)を設ける。

---

## 11. skill 名の名前空間衝突対策

### 課題
`systematic-debugging` 等は superpowers と同名。併用リポジトリで description 自動発火が競合する。

### 方針
**プロジェクト内運用では常に `spec-coexist:` プレフィックス** で呼ぶ規律を文書化する。skill 名自体は改名しない(歴史が壊れる)。

### 具体アクション
- `using-spec-coexist/references/namespace-policy.md` を新規作成。
- `using-spec-coexist/SKILL.md` に "MUST: 参照時は `spec-coexist:` 修飾を付ける" を追加。
- トリガテスト(6 章)で修飾なし呼び出しが発火時に警告を出す軽い lint を追加。

### DoD
- 併用環境での skill 解決ログに衝突が記録されない。

### 優先度
P1

### リスク
既存の会話ログや CLAUDE.md に無修飾の記述が残っている。grep して一括改訂。

---

## 12. ロードマップ(優先度順)

| フェーズ | 含める章 | ゴール |
|---|---|---|
| **Phase 0(基盤)** | 5, 6, 7 | メタスキル + 回帰テスト + 証跡集約。以後の全拡張の土台。 |
| **Phase 1(致命的な穴を塞ぐ)** | 2, 4 | TDD ゲート + ブランチ締め。実装品質の底上げ。 |
| **Phase 2(運用堅牢化)** | 10, 11 | 誤発火と名前空間衝突を潰す。 |
| **Phase 3(カバレッジ拡張)** | 1, 3 | 発散フェーズと並列実行。suite の適用範囲を広げる。 |
| **Phase 4(輸出性)** | 8, 9 | 多言語・多 OS。社外展開の準備。 |

各 Phase は **完了条件(DoD)を満たしたら次へ** という gate 式で進める。特に Phase 0 を飛ばすと、後続の拡張が "テストなし・証跡なし" で堆積する。これは superpowers が落ちた罠なので繰り返さない。

---

## 13. 拡張後に目指すスコア(比較レポート基準)

| 観点 | 現状 | 拡張後目標 | 主な効いた章 |
|---|---:|---:|---|
| 成熟度 / 保守体制 | 6 | 8 | 5, 6 |
| カバレッジ(SDLC 横断) | 5 | 8 | 1, 2, 3, 4 |
| 規範の厳密さ | 9 | 9 | 維持 |
| LLM コンテキスト効率 | 9 | 9 | 維持(SKILL.md 80 行制約) |
| ドメイン適合 | 9 | 9 | 維持 |
| ガバナンス/監査適性 | 9 | 10 | 7 |
| 多言語 | 8 | 9 | 8 |
| 拡張性 | 5 | 8 | 5 |
| 並列実行 / worktree | 2 | 7 | 3 |
| **総合** | **6.9** | **8.5 前後** | — |

superpowers に並列実行で完全に勝つつもりはない(ユースケースが違う)が、"仕様駆動フレームワークとして穴がない" レベルには到達できる見込み。
