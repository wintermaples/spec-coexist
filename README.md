# spec-coexist

Claude Code 向けの **仕様駆動開発 (spec-driven development) スキルスイート** です。要件定義 → 基本設計 → 実装 → 仕様変更反映 → デバッグという一連のワークフローを、Claude Code の [Skills](https://code.claude.com/docs/en/skills) として提供します。

## 何ができるか

このスキルスイートは、「仕様」と「実装」を常に並走させる (coexist させる) ことをゴールに、以下の 7 つのスキルを提供します。

| スキル | 用途 |
| --- | --- |
| `using-spec-coexist` | 会話の冒頭で読み込む索引。どの状況でどのスキルを使うかを Claude に伝える「1% ルール」の起点 |
| `creating-requirements` | 新規の要件定義書 (`docs/main-requirements.md` またはサブシステム単位) を作成 |
| `creating-basic-design` | 新規の基本設計書 (`docs/main-basic-design.md` またはサブシステム単位) を作成 |
| `implementing-from-spec` | 既存の要件定義 + 基本設計に沿ってコードを実装 |
| `revising-spec` | 既存の要件定義 / 基本設計を改訂 |
| `revising-implementation` | 仕様改訂を既存コードに反映 |
| `systematic-debugging` | バグ・テスト失敗・想定外挙動が発生したときの体系的デバッグ |

各スキルは「既存ドキュメントを上書きしない」「改訂時は専用スキルを呼ぶ」といったガードレールを持ち、意図しない破壊的変更を防ぎます。また、要件定義・基本設計の対話を視覚的に進めるための **Visual Companion** (標準ライブラリだけで動く軽量 HTTP サーバ) を同梱しています。

## ディレクトリ構成

```
.
├── .claude/
│   └── skills/                       ← 開発用のスキル本体 (ライブリロード対象)
│       ├── _shared/                  ← 複数スキルで共有するスクリプトと参照資料
│       │   ├── scripts/              ← Visual Companion・補助シェルスクリプト等
│       │   └── references/
│       ├── using-spec-coexist/
│       ├── creating-requirements/
│       ├── creating-basic-design/
│       ├── implementing-from-spec/
│       ├── revising-spec/
│       ├── revising-implementation/
│       └── systematic-debugging/
├── packaging/
│   └── spec-coexist/
│       └── .claude-plugin/
│           └── plugin.json           ← 配布用プラグインマニフェスト (バージョン等)
├── scripts/
│   └── package-spec-coexist.sh       ← パッケージングスクリプト
├── docs/                             ← 要件・基本設計テンプレート、ドラフト置き場
└── dist/                             ← パッケージングの出力 (git 管理外)
```

### 開発時はなぜ `.claude/skills/` 配下なのか

Claude Code は `.claude/skills/` をライブリロードの対象として扱います ([公式ドキュメント](https://code.claude.com/docs/en/skills))。そのため、スキル本体はここに置くことで、`SKILL.md` を編集した瞬間から次のターンに反映され、デバッグや試行錯誤がしやすくなります。

一方、配布形態である「プラグイン」としてインストールされた場合は `<plugin>/skills/<skill-name>/SKILL.md` に配置される必要があるため、**配布物はパッケージングスクリプトで組み立てる** という構成を取っています。

## Claude Code 本体での使い方

このリポジトリを Claude Code で開くだけで、`.claude/skills/` 以下のスキルが自動的に認識されます。以下のような発話で各スキルが起動します。

- 「新しい要件定義書を作りたい」「draft requirements」 → `creating-requirements`
- 「基本設計を書きたい」「draft a basic design」 → `creating-basic-design`
- 「この設計書のとおり実装して」「implement from the spec」 → `implementing-from-spec`
- 「要件を変更したい」「revise the spec」 → `revising-spec`
- 「仕様変更を実装に反映して」「update the code to match the new spec」 → `revising-implementation`
- 「テストが落ちた」「なぜか動かない」 → `systematic-debugging`

会話の最初に `using-spec-coexist` が読み込まれていると、Claude がどのスキルを呼ぶべきかを正しく判断できます。

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
  "version": "1.1.0",
  ...
}
```

### 配布物のインストール方法 (受け取る側)

生成された `dist/spec-coexist-<version>.tar.gz` を展開し、Claude Code のプラグインディレクトリに配置することでインストールできます。詳しくは [Claude Code Plugins ドキュメント](https://code.claude.com/docs/en/plugins) を参照してください。

## 依存関係

- Claude Code (skills 機能対応バージョン)
- Bash (パッケージングスクリプト用)
- Python 3.10+ (Visual Companion 機能を使う場合のみ。標準ライブラリのみで動作するため追加インストールは不要)

## ライセンス / 作者

`packaging/spec-coexist/.claude-plugin/plugin.json` を参照してください。
