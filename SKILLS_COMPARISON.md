# Skill スイート比較レポート: `superpowers` vs `.claude/skills` (spec-coexist)

対象:
- `superpowers` v5.0.7 (`~/.claude/plugins/.../superpowers/5.0.7/skills`) — 14 skills
- `.claude/skills` (プロジェクトローカル, 通称 *spec-coexist*) — 10 skills + `_shared/`

評価視点: プロフェッショナル現場(チーム開発・規制産業・長期保守)での運用に耐えるか。一般ユーザ向けの"触って楽しい"観点は除外。

---

## 1. 概観

| 観点 | superpowers | spec-coexist (`.claude/skills`) |
|---|---|---|
| 配布形態 | 公式プラグイン(バージョン管理済・CHANGELOG・tests 同梱) | プロジェクト直置き(リポジトリと一体で版管理) |
| スキル数 | 14 (brainstorming / TDD / worktree / plans / debug / review 等) | 10 (要件・基本設計・実装・改訂・デバッグ・レビュー・検証) |
| 粒度 | 汎用 SDLC の横断ツールボックス | 仕様駆動開発(日本式 "要件定義→基本設計→実装") に特化したパイプライン |
| SKILL.md 規模 | 中〜大 (70〜655 行、TDD 371 行、writing-skills 655 行) | 小 (35〜71 行)。本体は `references/` へ外出し |
| 構造 | SKILL.md に規範と例を同居 | SKILL.md は薄いオーケストレータ、規範は `references/`、副作用は `_shared/scripts/` |
| ドキュメント言語 | 英語のみ | 英語ベース + 日本語トリガフレーズ (`基本設計を作る` 等) |
| RFC 2119 準拠宣言 | なし(MUST/SHOULD は散発的) | 明示 (RFC 2119 / 8174) |
| テスト資産 | `tests/skill-triggering` 等、実行可能な回帰テスト同梱 | なし |
| 外部スキルへの依存 | `using-superpowers` を経由して自己完結 | `独立性 (Independence)` 節で `superpowers:*` 呼出しを明示的に禁止 |

---

## 2. superpowers — 批評

### 強み
- **成熟度**: v5.0.7、CHANGELOG、tests、agents、hooks、commands を束ねたフルパッケージ。プラグインとして配布/更新可能。
- **思想の明快さ**: "Iron Law"("NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST" / "NO FIXES WITHOUT ROOT CAUSE") を冒頭で叩き込み、LLM が抜け道を作りにくい。
- **カバレッジ**: brainstorming → writing-plans → executing-plans → subagent-driven-development → worktree → TDD → review → finishing-branch、と SDLC を通す導線が存在する。
- **writing-skills** の存在: スキルそのものを生成・検証するメタスキルがあり、エコシステム拡張性が高い。
- **並列エージェント運用** (`dispatching-parallel-agents`, `subagent-driven-development`) という現場ニーズに直接応える要素がある。

### 弱み / 現場での引っ掛かり
- **肥大化**: `writing-skills` 655 行、`test-driven-development` 371 行。LLM コンテキスト消費が大きく、1 セッションで複数 skill を積むとプロンプト予算を圧迫する。分割(references 外出し)がされていない点は spec-coexist に劣る。
- **規範性の根拠が薄い**: "Iron Law" は強いが RFC 2119 宣言がなく、"MUST" の拘束力は LLM の気分次第で揺れる。監査や review ゲートに組み込むにはもう一段の形式化が要る。
- **ドメイン不在**: 汎用 TDD / debug 論で止まっており、"要件→基本設計→実装" のような日本企業で現実に求められるフェーズ成果物に対応しない。成果物テンプレートも存在しない。
- **日本語トリガ未対応**: 日本語プロンプトでの自動起動が description の英語語彙に依存。多言語チームでは誤起動/未起動が起きやすい。
- **副作用スクリプトの扱いがスキル内雑居**: `scripts/` はあるが各 skill の責務境界が spec-coexist ほどクリーンではない。
- **自己宣伝的**: `using-superpowers` を "あらゆる会話の開始時に呼べ" と要求する設計は、プロジェクトルールを外部プラグインに人質に取られる構図で、エンタープライズのガバナンスと相性が悪い。
- **"rationalization 禁止" 文言** のようなコーチング調は、プロ開発者にはノイズ。

### 点数(10 点満点)

| 観点 | 点 | 所見 |
|---|---|---|
| 成熟度 / 保守体制 | 8 | バージョニング・tests・CHANGELOG あり |
| カバレッジ(SDLC 横断) | 8 | brainstorm〜finish-branch を揃える |
| 規範の厳密さ | 6 | Iron Law はあるが RFC 未準拠、形式性不足 |
| LLM コンテキスト効率 | 4 | SKILL.md が肥大、references 分離が不徹底 |
| ドメイン適合(仕様駆動) | 3 | テンプレート/成果物の概念が弱い |
| ガバナンス/監査適性 | 5 | トレーサビリティ薄、レビュー強制は一応ある |
| 多言語 | 3 | 英語前提 |
| 拡張性 | 8 | writing-skills によるメタ拡張 |
| 並列実行 / worktree | 9 | この領域は他を圧倒 |
| **総合** | **6.2** | "汎用ツールボックス" として良質、だが企業用フレームワークとしては粗い |

---

## 3. spec-coexist (`.claude/skills`) — 批評

### 強み
- **薄い SKILL.md + `references/` 外出し**: 本体 35〜71 行。オーケストレーション層と規範層を分離しており、LLM のコンテキスト節約と保守性の双方で優れる。これは skill 設計のベストプラクティス。
- **RFC 2119 準拠**の明示宣言。MUST/SHOULD/MAY の語彙が法的/監査的文脈でそのまま通用する。
- **ドメイン特化**: "要件定義 → 基本設計 → 実装 → 改訂 → デバッグ → レビュー → 検証完了ゲート" という日本式仕様駆動フローを、テンプレート・ルール・ガード付きで実装。`check_doc_exists.sh` のような **ハードガード** が HALT 条件として組み込まれている。
- **独立性宣言**: "MUST NOT invoke any `superpowers:*` skill" と明記し、外部プラグインの breakage に引きずられないよう境界を守る。これは企業システムとして正しい設計判断。
- **`_shared/`** によるスクリプト/Mermaid ルールの共有化。DRY。
- **1% ルール** (`using-spec-coexist`) による **過剰発動寄り** の起動戦略。プロ現場では "skill を使わなかった" 事故の方が "使いすぎた" より高コストなので、この非対称は合理的。
- **日英バイリンガルのトリガ**(`基本設計を作る`, `draft a basic design`)。日本企業で即戦力。
- **レビューと検証の二重ゲート**: `verification-before-completion` + `requesting-code-review` を多くの skill が MUST で呼び込む構造。"done" の定義がブレない。
- **リポジトリ同梱**: バージョンは git 履歴と一致、差分レビュー可、CI で検証可能。プラグイン外部化より監査に向く。

### 弱み / 引っ掛かり
- **カバレッジの狭さ**: brainstorming / writing-plans / executing-plans / worktree / parallel-agents / TDD に相当するスキルが **ない**。仕様駆動の前段(発散)と下流(並列実装・統合)が空白。
- **テスト資産ゼロ**: `superpowers/tests/skill-triggering` に相当する回帰テストが無い。description 改訂で起動が壊れても検知できない。
- **writing-skills 不在**: メタスキルがないため、この suite 自体の拡張手順が人間の暗黙知に依存。
- **"1% ルール" は両刃**: 誤起動(無関係な会話でも skill が走る)リスクを内包。description の記述品質に寿命が強く依存する。
- **日本市場ローカル感**: 海外チームにそのまま配るとテンプレートや用語 ("基本設計") の文化適合でコストが出る。
- **superpowers 非依存宣言の裏返し**: 優秀な上流機能(並列・TDD・worktree)を **意図的に捨てている**。現場によっては二重運用が必要。
- **finishing-a-development-branch / git 周り が欠落**: マージ・PR 締めの手順が明文化されておらず、最後の一歩が個人裁量。
- **スクリプトの移植性**: `.sh` 前提で Windows 開発機にそのまま乗らない。

### 点数(10 点満点)

| 観点 | 点 | 所見 |
|---|---|---|
| 成熟度 / 保守体制 | 6 | リポジトリ一体で版管理は強いがテスト無し |
| カバレッジ(SDLC 横断) | 5 | 上流発散と並列/worktree が空白 |
| 規範の厳密さ | 9 | RFC 2119 準拠、HALT ガード、MUST レビューゲート |
| LLM コンテキスト効率 | 9 | 薄い SKILL.md + references 外出しが秀逸 |
| ドメイン適合(仕様駆動) | 9 | 要件→基本設計→実装→改訂 を一貫提供 |
| ガバナンス/監査適性 | 9 | 独立性宣言・テンプレ・HALT・レビュー必須 |
| 多言語 | 8 | 日英トリガを両立 |
| 拡張性 | 5 | メタスキル無し、属人的に成長する |
| 並列実行 / worktree | 2 | 非対応 |
| **総合** | **6.9** | "仕様駆動に寄せた企業フレームワーク" として完成度高い、ただし穴がある |

---

## 4. 正面比較(領域別)

| 領域 | 勝者 | 差の実質 |
|---|---|---|
| 要件定義/基本設計の成果物生成 | **spec-coexist** | superpowers にはそもそも概念が無い |
| TDD / 実装ループ | **superpowers** | spec-coexist は `implementing-from-spec` 止まりで赤緑リファクタは持たない |
| デバッグ手順の強度 | ほぼ互角 | superpowers は文章量で押し、spec-coexist は MUST レビュー接続で押す |
| コードレビュー往復 | **spec-coexist** | `requesting` と `receiving` を他スキルから MUST で呼び込ませる統合がきつい |
| 並列エージェント / worktree | **superpowers** | 代替が無い |
| ブレスト / プラン策定 | **superpowers** | `brainstorming` / `writing-plans` が強い |
| 検証(done の定義) | **spec-coexist** | `verification-before-completion` を他全スキルのゲートに挿している |
| ガバナンス/監査 | **spec-coexist** | RFC 2119、HALT、独立性宣言、リポジトリ同梱 |
| 国際化 | **spec-coexist** | 日英トリガ |
| プラグイン配布性 | **superpowers** | 他プロジェクトへの横展開が容易 |
| コンテキスト予算 | **spec-coexist** | SKILL.md の薄さが効く |
| 自己拡張 | **superpowers** | `writing-skills` の存在 |

---

## 5. 現場別 推奨

- **日本の SI / 規制産業 / 仕様駆動が契約要件**: `spec-coexist` を主軸に採用。superpowers からは `writing-plans`, `executing-plans`, `using-git-worktrees`, `dispatching-parallel-agents`, `test-driven-development` だけを **補助チャンネル** として併用。ただし spec-coexist が宣言する独立性は尊重し、spec-coexist 側 skill の中からは superpowers を呼ばない運用に留める(呼ぶのは人間または orchestrator レイヤ)。
- **OSS / 英語圏スタートアップ / 発散多めのプロダクト開発**: `superpowers` 単独で十分。spec-coexist の要件・基本設計テンプレートは不要なオーバーヘッドになりがち。
- **両者を同一リポジトリに置く場合の注意**: skill 名の衝突(`systematic-debugging`, `verification-before-completion`, `requesting-code-review`, `receiving-code-review`)。名前空間プレフィックス(`spec-coexist:` / `superpowers:`)で常に修飾して呼ぶこと。description 自動発火時の競合は現実に起きる。

---

## 6. 総合スコア

| スイート | 総合点 | 一言 |
|---|---|---|
| superpowers | **6.2 / 10** | 汎用 SDLC ツールボックスとして良質。肥大と形式性不足が企業採用の足を引っ張る。 |
| spec-coexist | **6.9 / 10** | 仕様駆動フレームワークとして設計思想が鋭い。上流発散と並列実装の空白、テスト資産の欠如が減点。 |

**結論**: どちらも "単独で現場の全要求を満たす" レベルには未達。spec-coexist は **規律・監査・ドメイン適合** で勝ち、superpowers は **カバレッジ・並列・メタ拡張** で勝つ。プロ現場では *spec-coexist を骨格、superpowers を部品棚* として併用する構成が現時点で最も実利的。ただし併用時は skill 解決の名前空間衝突と、spec-coexist の独立性宣言の運用境界を **書面で固定** しておく必要がある。
