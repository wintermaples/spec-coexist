# ブレインストーミング・ルール

`creating-basic-design` のブレインストーミング段階で適用するルール。

## 1 メッセージ 1 質問

1 メッセージにつき質問はちょうど 1 つ。複数の質問を束ねない。

## 質問の形式

- **多肢選択（A / B / C）を優先する。** ユーザの認知負荷を下げ、回答の曖昧さを減らせる。
- **オープン質問は MAY。** 回答空間が本当に開いているとき（例：「中核となるユーザ目標は何か？」）に限り使う。

## 未回答の質問が多くなったとき

未回答の質問が約 4〜5 個を超えたら、1 つずつ聞かずにファイルへまとめて書き出す：

```bash
path=$(.claude/skills/_shared/scripts/gen_questions_path.sh basic-design)
# Write all remaining questions to $path, then HALT.
```

ユーザにファイルパスを伝え、回答が完了したと確認されるまで **HALT** する。完了後にインライン応答を再開する。

未回答が少数なら、ファイル化せずインラインで続けてよい。

## Visual Companion

運用詳細は `../_shared/references/visual-companion.md` を参照する。

**使うのはいつか：** 次の質問が本質的に視覚情報を要するとき（UI レイアウト、ワイヤーフレーム、アーキテクチャ図、画面フロー）に限る。スコープ・文言・API のトレードオフのような概念的な質問は通常のターミナルで扱う。

**同意取得：** 同意確認は 1 回だけ、他の質問を含まない単独メッセージで行う：

> I'd like to switch into Visual Companion mode for the next few questions because they're about screen layout. Is that okay? (yes / no)

ユーザが断った場合は、以降のセッションも通常のターミナルで継続する。

**起動コマンド：**
```bash
.claude/skills/_shared/scripts/start_visual_server.sh <project-dir>
```

出力された `screen_dir`、`state_dir`、`url`、`pid` を取得して記憶する。

## 設計が固まった判定

以下がすべて満たされるまでブレインストーミングを継続する：

- 対象スコープ（全体版 vs サブシステム版）が確定している。
- `docs/main-requirements.md`（またはサブシステム要件）の各要件に、少なくとも仮置きの設計判断が紐付いている。
- 文書の執筆を妨げる未解決の質問が残っていない。
- 非機能要件（性能、セキュリティ、可用性）に高レベルの方針が示されている。
