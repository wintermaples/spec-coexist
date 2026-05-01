# spec-coexist スキルパッケージ 利用ガイド

> 仕様と実装を常に並走させる (coexist) ための Claude Code スキルスイート

## 目次

- [クイックスタート](#クイックスタート)
- [ワークフロー全体像](#ワークフロー全体像)
- [タスクティアシステム](#タスクティアシステム)
- [スキル一覧と使い方](#スキル一覧と使い方)
- [サブシステム開発](#サブシステム開発)
- [Visual Companion](#visual-companion)
- [Tips](#tips)

---

## クイックスタート

### 1. インストール

**開発リポジトリとして使う場合**

このリポジトリを clone するだけで、`.claude/skills/` 配下のスキルが自動的に認識されます。

**プラグインとして別プロジェクトに導入する場合**

```bash
# パッケージを生成
./scripts/package-spec-coexist.sh

# 出力された dist/spec-coexist-<version>.tar.gz を展開し、
# Claude Code のプラグインディレクトリに配置する
```

### 2. 最初の一歩

Claude Code のチャットで自然に話しかけるだけです。

```
「新しいプロジェクトの要件をまとめたい」
→ creating-requirements が起動

「要件が固まったので基本設計を書きたい」
→ creating-basic-design が起動

「この設計書のとおり実装して」
→ implementing-from-spec が起動
```

**spec-coexist-router** がメッセージの内容からタスクの規模を自動判定し、適切なスキルを呼び出します。

---

## ワークフロー全体像

spec-coexist は以下の開発ライフサイクルをカバーします。

```
問題探索 → 要件定義 → 基本設計 → 実装 → レビュー → 完了
   │          │          │        │       │        │
   ▼          ▼          ▼        ▼       ▼        ▼
exploring  creating   creating  impl.   code    finishing
-problem   -require   -basic    -from   -review  -subsystem
 -space     -ments    -design   -spec   -loop    -work
```

### 仕様変更が入ったら

```
仕様変更 → revising (spec) → revising (implementation)
```

### バグが発生したら

```
バグ発見 → systematic-debugging → (必要なら) revising
```

---

## タスクティアシステム

すべてのユーザーメッセージは **spec-coexist-router** によって4段階のティアに分類されます。ティアごとに必要なプロセスが異なります。

| ティア | 規模 | 例 | 必要なプロセス |
| --- | --- | --- | --- |
| **T0** | trivial | typo 修正、変数リネーム (10行以下) | 直接編集のみ |
| **T1** | small | 単一関数の追加、簡単なバグ修正 | TDD + verification |
| **T2** | medium | 機能追加、複数ファイルの変更 | 要件定義 + 基本設計 + TDD + レビュー |
| **T3** | large | 新サブシステム、大規模リファクタ | フル仕様プロセス + サブシステム分割 |

明示的にティアを指定することもできます:

```
「tier:T0 この typo を直して」
「tier:T1 この関数を追加して」
```

---

## スキル一覧と使い方

### 問題探索フェーズ

#### exploring-problem-space

まだ要件にまとまっていないアイデアや課題を整理し、解くべき問題を特定します。

**トリガー例:**
- 「何を作るか迷ってる」
- 「まだ要件にできない相談がある」
- 「ざっくり相談したい」
- "help me figure out the real problem"

**出力:** 問題定義と、creating-requirements への接続ポイント

---

### 仕様作成フェーズ

#### creating-requirements

要件定義書を新規作成します。全体要件 (`docs/main-requirements.md`) またはサブシステム単位で作成できます。

**トリガー例:**
- 「要件定義を作る」
- 「draft requirements」
- 「新しい要件をまとめたい」

**ガードレール:** 既存の要件定義書がある場合は停止し、`revising` スキルへ誘導します。

#### creating-basic-design

基本設計書を新規作成します。対応する要件定義書が存在しない場合は停止します。

**トリガー例:**
- 「基本設計を作る」
- 「draft a basic design」
- 「新しい設計書を書きたい」

**前提条件:** 対応する要件定義書が存在すること。

---

### 実装フェーズ

#### implementing-from-spec

要件定義書と基本設計書に基づいてコードを実装します。内部で `test-driven-implementation` を呼び出し、TDD で進めます。

**トリガー例:**
- 「仕様に従って実装して」
- 「implement from the spec」
- 「この設計書のとおり作って」

**鉄則 (Iron Law):** 失敗するテストが先に存在しなければ、プロダクションコードは書かれません。

#### fast-path

T0/T1 の軽量タスク専用。仕様文書を要求せず、最短経路でタスクを完了します。

**トリガー例:**
- 「tier:T0 typo を直して」
- 「tier:T1 この関数を追加して」
- 「ちょっとした修正」
- "quick fix"

---

### 仕様変更・改訂フェーズ

#### revising

要件定義書・基本設計書の改訂と、仕様変更の実装反映を統合的に扱います。

**トリガー例 (仕様改訂):**
- 「要件を変更したい」
- 「設計を直したい」
- "revise the spec"

**トリガー例 (実装反映):**
- 「仕様変更を実装に反映して」
- 「update the code to match the new spec」
- 「実装を直したい」

---

### デバッグ

#### systematic-debugging

仮説駆動のデバッグプロセスです。修正案を出す前に、証拠収集と仮説検証を行います。

**トリガー例:**
- 「テストが落ちた」
- 「なぜか動かない」
- 「バグっぽい」
- "this is broken"

**プロセス:** 観察 → 仮説生成 → 実験による検証 → 根本原因特定 → 修正

---

### 品質保証

#### pre-review-self-check

コードレビュー前の自己チェック。命名、複雑度、境界値、エラーハンドリングなどを確認します。  
*通常は他スキルから自動的に呼び出されます。*

#### verification-before-completion

タスク完了を宣言する前に、テスト実行やビルド確認などの検証証拠を要求するゲートです。  
*通常は他スキルから自動的に呼び出されます。*

#### code-review-loop

コードレビューの依頼・フィードバック受領・修正を 1 つのループで処理します。

**トリガー例:**
- 「コードレビューして」
- 「レビューが返ってきた」
- "review this change"
- "here is the review feedback"

---

### 完了・統合

#### finishing-subsystem-work

検証済み・レビュー済みの作業をコミット・プッシュ・マージする統合スキルです。

**トリガー例:**
- 「マージしたい」
- 「PR を出して」
- "ready to merge"
- "open a pull request"

#### delivery-snapshot

プロジェクトの現状レポートを生成します。完了した要件、進行中の作業、未カバーの REQ-ID などを一覧化します。

**トリガー例:**
- 「プロジェクトの現状を見たい」
- 「ステークホルダー向けのレポートを作って」
- "generate a delivery snapshot"

---

### 並列開発

#### parallelizing-subsystem-work

複数のサブシステムを git worktree を使って並列に実装します。

**トリガー例:**
- 「サブシステムを並列で実装したい」
- 「複数の基本設計を同時に進めて」
- "implement these in parallel worktrees"

**前提条件:** 2つ以上のサブシステムに要件定義 + 基本設計が揃っていること。

---

## サブシステム開発

大規模プロジェクトでは、機能をサブシステム単位に分割して開発できます。

### ディレクトリ構成

```
docs/
├── main-requirements.md           ← 全体要件
├── main-basic-design.md           ← 全体基本設計
└── subsystems/
    ├── 01_auth/
    │   ├── auth-requirements.md
    │   └── auth-design.md
    ├── 02_api/
    │   ├── api-requirements.md
    │   └── api-design.md
    └── ...
```

### サブシステム開発フロー

1. 全体要件で機能を洗い出す
2. サブシステム単位で要件定義・基本設計を作成
3. `parallelizing-subsystem-work` で並列実装
4. `finishing-subsystem-work` で統合

---

## Visual Companion

要件定義や基本設計の対話を視覚的に進めるための軽量 HTTP サーバーです。Mermaid 図のリアルタイムプレビューなどを提供します。

**起動方法**

スキル実行中に自動で起動します。手動で起動する場合は以下を実行してください。

```bash
python3 .claude/skills/_shared/scripts/visual_server.py
```

**要件:** Python 3.10+ (標準ライブラリのみで動作)

---

## CI ワークフロー

スキルを使った開発成果物 (ドキュメントリンクの整合性、エビデンスの完全性、REQ-ID トレーサビリティなど) を CI で検証するための GitHub Actions ワークフローを同梱しています。

### 導入方法

`.claude/skills/_utils/github-workflows/` にあるワークフローファイルを、利用先リポジトリの `.github/workflows/` にコピーしてください。

```bash
cp .claude/skills/_utils/github-workflows/spec-coexist.yml .github/workflows/
```

| ファイル | 検証内容 |
| --- | --- |
| `spec-coexist.yml` | ティア自動判定、エビデンススキーマ検証、エビデンス完全性、REQ-ID トレーサビリティ、ドキュメントリンク整合性 |

> **注意**: このワークフローはスキルが生成した成果物 (`docs/`、`.spec-coexist/evidence/` 等) を検証するものであり、スキル自体の CI ではありません。

---

## Tips

### スキルの自動選択に任せる

多くの場合、自然な日本語または英語で話しかけるだけで適切なスキルが選択されます。スキル名を覚える必要はありません。

### ティアを明示して効率化する

小さなタスクに `tier:T0` や `tier:T1` を付けると、不要なプロセスをスキップして素早く完了できます。

### 仕様と実装の一貫性を保つ

spec-coexist の核心は「仕様と実装が常に同期している」ことです。コードだけを変更したい場合でも、まず仕様を更新してから実装に反映するフローを推奨します。

### ガードレールを信頼する

各スキルには以下の安全装置が組み込まれています。

- 既存ドキュメントの上書き防止
- 要件定義書なしの基本設計作成防止
- テストなしのプロダクションコード作成防止
- 検証なしの完了宣言防止

これらの HALT は意図的な設計です。迂回せず、指示に従ってください。
