# spec-coexist

Claude Code 向けの **仕様駆動開発 (spec-driven development) スキルスイート** です。要件定義 → 基本設計 → 詳細設計 → 実装 → 仕様変更反映 → デバッグという一連のワークフローを、Claude Code の [Skills](https://code.claude.com/docs/en/skills) として提供します。

## 何ができるか

このスキルスイートは、「仕様」と「実装」を常に並走させる (coexist させる) ことをゴールに、以下のスキルを提供します。

### コアスキル

| スキル | 用途 |
| --- | --- |
| `spec-coexist-router` | タスクティアの自動判定 (T0–T3) と適切なスキルへのルーティング |
| `exploring-problem-space` | まだ要件にできないアイデアや課題の整理・問題定義 |
| `creating-requirements` | 新規の要件定義書 (`docs/main-requirements.md` またはサブシステム単位) を作成 |
| `creating-basic-design` | 新規の基本設計書 (`docs/main-basic-design.md` またはサブシステム単位) を作成 |
| `creating-detail-design` | 新規の詳細設計書 (`detail-design/index.md` + モジュール別ファイル) を作成。Mermaid 図で振る舞い・契約を定義し実装ブレを防ぐ |
| `implementing-from-spec` | 既存の要件定義 + 基本設計に沿ってコードを TDD で実装 (詳細設計がある場合は追加入力として参照) |
| `fast-path` | T0/T1 タスク (typo 修正、単関数追加等) を仕様文書なしで最短完了 |
| `revising` | 要件定義 / 基本設計の改訂、および仕様変更の実装反映を統合的に処理 |
| `systematic-debugging` | 仮説駆動の体系的デバッグ |

### 品質保証・統合スキル

| スキル | 用途 |
| --- | --- |
| `test-driven-implementation` | TDD の鉄則 (失敗テスト先行) を強制するサブスキル |
| `pre-review-self-check` | コードレビュー前の自己チェック |
| `verification-before-completion` | 完了宣言前に検証証拠を要求するゲート |
| `code-review-loop` | コードレビューの依頼・フィードバック・修正ループ |
| `finishing-subsystem-work` | 検証済み作業のコミット・プッシュ・マージ |
| `delivery-snapshot` | プロジェクト現状レポートの生成 |
| `parallelizing-subsystem-work` | git worktree による複数サブシステムの並列実装 |

各スキルは「既存ドキュメントを上書きしない」「改訂時は専用スキルを呼ぶ」といったガードレールを持ち、意図しない破壊的変更を防ぎます。また、要件定義・基本設計の対話を視覚的に進めるための **Visual Companion** (標準ライブラリだけで動く軽量 HTTP サーバ) を同梱しています。

> 各スキルの詳細な使い方は [`.claude/skills/_docs/README.md`](.claude/skills/_docs/README.md) (日本語) / [`.claude/skills/_docs/README.en.md`](.claude/skills/_docs/README.en.md) (English) を参照してください。

### タスクティアシステム

spec-coexist-router がユーザーのメッセージを自動的に分類し、ティアに応じた最小限のプロセスだけを適用します。

| ティア | 規模 | 必要なプロセス |
| --- | --- | --- |
| **T0** | trivial (typo, ≤10行) | 直接編集のみ |
| **T1** | small (単関数追加, バグ修正) | TDD + verification |
| **T2** | medium (機能追加) | 要件 + 設計 + TDD + レビュー |
| **T3** | large (新サブシステム) | フル仕様プロセス |

## ディレクトリ構成

```
.
├── .claude/
│   └── skills/                       ← 開発用のスキル本体 (ライブリロード対象)
│       ├── _docs/                    ← スキルパッケージ利用ガイド (日本語・英語)
│       ├── _meta/                    ← スキル作成者向けオーサリングガイド
│       ├── _shared/                  ← 複数スキルで共有するスクリプトと参照資料
│       │   ├── scripts/              ← Visual Companion・補助シェルスクリプト等
│       │   ├── references/
│       │   ├── schemas/
│       │   └── templates/
│       ├── _utils/
│       │   └── github-workflows/     ← 利用者向け CI ワークフロー (コピーして使う)
│       ├── spec-coexist-router/      ← タスクティアルーター
│       ├── exploring-problem-space/
│       ├── creating-requirements/
│       ├── creating-basic-design/
│       ├── creating-detail-design/    ← 詳細設計書作成 (Mermaid 図主体)
│       ├── implementing-from-spec/
│       ├── fast-path/
│       ├── revising/
│       ├── systematic-debugging/
│       ├── test-driven-implementation/
│       ├── pre-review-self-check/
│       ├── verification-before-completion/
│       ├── code-review-loop/
│       ├── finishing-subsystem-work/
│       ├── delivery-snapshot/
│       └── parallelizing-subsystem-work/
├── packaging/
│   └── spec-coexist/
│       └── .claude-plugin/
│           └── plugin.json           ← 配布用プラグインマニフェスト (バージョン等)
├── scripts/
│   └── package-spec-coexist.sh       ← パッケージングスクリプト
└── dist/                             ← パッケージングの出力 (git 管理外)
```

### 開発時はなぜ `.claude/skills/` 配下なのか

Claude Code は `.claude/skills/` をライブリロードの対象として扱います ([公式ドキュメント](https://code.claude.com/docs/en/skills))。そのため、スキル本体はここに置くことで、`SKILL.md` を編集した瞬間から次のターンに反映され、デバッグや試行錯誤がしやすくなります。

一方、配布形態である「プラグイン」としてインストールされた場合は `<plugin>/skills/<skill-name>/SKILL.md` に配置される必要があるため、**配布物はパッケージングスクリプトで組み立てる** という構成を取っています。

## Claude Code 本体での使い方

このリポジトリを Claude Code で開くだけで、`.claude/skills/` 以下のスキルが自動的に認識されます。自然言語で話しかけるだけで、`spec-coexist-router` がタスクの規模を判定し、適切なスキルを呼び出します。

### 発話例

| 発話 | 起動されるスキル |
| --- | --- |
| 「何を作るか迷ってる」「help me figure out the problem」 | `exploring-problem-space` |
| 「新しい要件定義書を作りたい」「draft requirements」 | `creating-requirements` |
| 「基本設計を書きたい」「draft a basic design」 | `creating-basic-design` |
| 「詳細設計を作りたい」「draft a detailed design」 | `creating-detail-design` |
| 「この設計書のとおり実装して」「implement from the spec」 | `implementing-from-spec` |
| 「tier:T0 typo を直して」「quick fix」 | `fast-path` |
| 「要件を変更したい」「revise the spec」 | `revising` |
| 「仕様変更を実装に反映して」「update the code to match the new spec」 | `revising` |
| 「テストが落ちた」「なぜか動かない」 | `systematic-debugging` |
| 「コードレビューして」「review this change」 | `code-review-loop` |
| 「マージしたい」「open a pull request」 | `finishing-subsystem-work` |
| 「プロジェクトの現状を見たい」「delivery snapshot」 | `delivery-snapshot` |
| 「サブシステムを並列で実装したい」 | `parallelizing-subsystem-work` |

## パッケージング

配布用のプラグインアーカイブは、以下のコマンドで生成できます。

```bash
./scripts/package-spec-coexist.sh
```

実行すると次の処理が走ります。

1. `packaging/spec-coexist/.claude-plugin/plugin.json` から `version` を読み取る
2. 一時ディレクトリに公式プラグインレイアウトを組み立てる
   ```
   spec-coexist/
   ├── .claude-plugin/
   │   └── plugin.json
   └── skills/
       ├── _shared/…
       ├── using-spec-coexist/…
       ├── creating-requirements/…
       └── …
   ```
3. `dist/spec-coexist-<version>.tar.gz` として出力

出力例:

```
built /workspace/dist/spec-coexist-1.0.0.tar.gz
contents:
  spec-coexist/
  spec-coexist/.claude-plugin/plugin.json
  spec-coexist/skills/using-spec-coexist/SKILL.md
  …
```

### バージョンを上げる

配布バージョンは `packaging/spec-coexist/.claude-plugin/plugin.json` の `version` フィールドが単一の真実源 (single source of truth) です。リリース時はここを書き換えてからパッケージングスクリプトを実行してください。

```json
{
  "name": "spec-coexist",
  "version": "1.3.0",
  ...
}
```

### マーケットプレイスからのインストール (推奨)

Claude Code CLI から直接インストールできます。

```bash
# プロジェクトスコープでインストール (チーム共有)
claude plugin install spec-coexist --scope project

# ユーザースコープでインストール (個人の全プロジェクト)
claude plugin install spec-coexist --scope user
```

### アーカイブからのインストール

生成された `dist/spec-coexist-<version>.tar.gz` を展開し、Claude Code のプラグインディレクトリに配置することでインストールできます。詳しくは [Claude Code Plugins ドキュメント](https://code.claude.com/docs/en/plugins) を参照してください。

## CI ワークフロー (利用者向け)

`.claude/skills/_utils/github-workflows/` に、スキルを使って開発した成果物を検証するための GitHub Actions ワークフローを同梱しています。

| ファイル | 検証内容 |
| --- | --- |
| `spec-coexist.yml` | ティア自動判定、エビデンススキーマ検証、エビデンス完全性チェック、REQ-ID トレーサビリティ、ドキュメントリンク整合性 |

### 導入方法

利用先リポジトリの `.github/workflows/` にコピーしてください。

```bash
cp .claude/skills/_utils/github-workflows/spec-coexist.yml .github/workflows/
```

> **注意**: このワークフローはスキルを使った開発成果物 (`docs/`、`.spec-coexist/evidence/` 等) を検証するものであり、スキル自体の CI ではありません。

## 依存関係

- Claude Code (skills 機能対応バージョン)
- Bash (パッケージングスクリプト用)
- Python 3.10+ (Visual Companion 機能を使う場合のみ。標準ライブラリのみで動作するため追加インストールは不要)

## ライセンス / 作者

`packaging/spec-coexist/.claude-plugin/plugin.json` を参照してください。
