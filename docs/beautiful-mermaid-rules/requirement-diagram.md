# 美しく読みやすい Mermaid Requirement Diagram の原則

## 概要と用途

Mermaid の **Requirement Diagram** は、SysML の要件図記法に準拠したダイアグラムで、システム要件とその関係性、設計要素やテスト要素との紐付けを可視化するために用いる。日本語の要件定義書やシステム仕様書において、特に以下の用途で力を発揮する。

- **要件のトレーサビリティ可視化**: 上位要件から下位要件、設計、テストまでの追跡可能性を一枚で示す
- **要件間の依存関係の把握**: 派生 (derive)、詳細化 (refine)、参照 (trace) といった関係を明示する
- **設計・実装・テストとの紐付け**: `element` を介して、要件がどのコンポーネントで満たされ (satisfies)、どのテストで検証される (verifies) かを示す
- **レビュー時の合意形成**: 表形式のトレーサビリティマトリクスでは見えにくい構造的な関係を直感的に共有する

文章だけの要件定義書に補助図として添えることで、要件の抜け漏れや関係の矛盾を早期に発見できる。

---

## 要件種別 (Requirement Types) の使い分け

Mermaid がサポートする要件種別は 6 種類。粒度をそろえて使い分けることが重要。

| 種別 | 用途 | 例 |
|---|---|---|
| `requirement` | 一般的な要件。種別が明確でないとき、または最上位のビジネス要件 | 「ユーザは商品を購入できる」 |
| `functionalRequirement` | 機能要件。システムが「何をするか」 | 「商品検索 API を提供する」 |
| `performanceRequirement` | 性能要件。応答時間、スループット、容量 | 「検索応答は 200ms 以内」 |
| `interfaceRequirement` | インタフェース要件。外部システムや UI との接点 | 「決済 API は ISO 8583 準拠」 |
| `physicalRequirement` | 物理要件。ハードウェア、設置環境、寸法 | 「サーバ筐体は 2U 以下」 |
| `designConstraint` | 設計制約。技術選定、規約、法令などの制約 | 「個人情報は国内 DC に保管」 |

**指針**: 一つの図の中で粒度を混ぜないこと。ビジネス要件の図と機能要件の図は分離する。種別を正しく選ぶことで、レビュー時に「これは要件か制約か」という議論を避けられる。

---

## id / text / risk / verifymethod の書き方と命名規則

```
functionalRequirement 商品検索機能 {
    id: FR-SEARCH-001
    text: ユーザはキーワードで商品を検索できること
    risk: Medium
    verifymethod: Test
}
```

### id の命名規則

- **プレフィックスで種別を示す**: `BR-` (Business)、`FR-` (Functional)、`PR-` (Performance)、`IR-` (Interface)、`PHR-` (Physical)、`DC-` (Design Constraint)
- **ドメインを含める**: `FR-SEARCH-001`、`FR-PAYMENT-002` のように機能領域を中段に
- **連番はゼロパディング**: `001` 形式で並び順を安定させる
- **一意性を保証**: 図をまたいでも ID は重複させない (後述のアンチパターン参照)

### text の書き方

- 主語 + 動詞 + 目的語の能動形で 1 文に収める
- 「〜できること」「〜であること」で要件であることを明示
- 改行や長文は避け、詳細は別途仕様書にリンク

### risk

- `Low` / `Medium` / `High` の 3 段階のみ
- 要件の不確実性、変更頻度、未達成時の影響度から評価
- リスクの根拠は別表で管理し、図では値のみ

### verifymethod

- `Analysis` (解析)、`Inspection` (査閲)、`Test` (試験)、`Demonstration` (実演)
- 必須項目として扱う。空欄は禁止 (アンチパターン参照)
- 性能要件は `Test`、設計制約は `Inspection`、UX 系は `Demonstration` が定石

---

## element の使い方

`element` は要件以外の成果物 (設計書、ソースコード、テストケース、物理部品など) を表す。要件と現実世界の成果物を結び付けるための「アンカー」として機能する。

```
element 検索サービス実装 {
    type: module
    docref: src/services/search.ts
}

element 検索E2Eテスト {
    type: testcase
    docref: tests/e2e/search.spec.ts
}
```

- `type` は自由文字列だが、組織内で語彙を統一する (`module` / `class` / `testcase` / `document` / `hardware` など)
- `docref` には**実在するパスや URL** を書く。ドキュメント参照のないエレメントは価値が半減する
- 設計要素は `satisfies` で、テスト要素は `verifies` で要件と結ぶ

---

## 関係種別の使い分け

| 関係 | 意味 | 使う場面 |
|---|---|---|
| `contains` | 包含 (親が子を含む) | 上位要件を複数の下位要件に分解 |
| `copies` | 複製 | 別文書から要件を引用・複製 |
| `derives` | 派生 | 上位要件から論理的に導出された要件 |
| `satisfies` | 充足 | 設計要素が要件を満たす |
| `verifies` | 検証 | テスト要素が要件を検証する |
| `refines` | 詳細化 | 抽象的な要件を具体化 |
| `traces` | 追跡 | 直接的な導出はないが関連がある |

**指針**:
- `contains` と `derives` の混同に注意。分解なら `contains`、論理的導出なら `derives`
- `refines` は「同じことをより具体的に言い換えた」場合のみ
- `traces` は最弱の関係。乱用すると図がスパゲッティ化する

---

## 方向性の統一

読み手の認知負荷を下げるため、矢印の流れを一定方向にそろえる。

- **上位要件 → 下位要件** の流れ: `contains`、`derives`、`refines` は親から子へ
- **要件 → 設計/テスト** の流れ: `satisfies`、`verifies` は element 側から要件側へ向かう (SysML の慣習)
- 一枚の図の中で「上から下」「左から右」のいずれかに固定する
- 双方向の関係は描かない。必要なら 2 本に分ける

---

## 大規模化への対処

要件が 30 個を超えると一枚図は破綻する。以下の戦略で分割する。

1. **階層別分割**: ビジネス要件図、機能要件図、性能要件図を別ファイルに
2. **ドメイン別分割**: 検索、決済、認証などサブシステム単位で図を分ける
3. **トレースマトリクス併用**: 図は構造を示し、網羅性は表 (Markdown テーブルや Excel) で管理
4. **ハブ要件の活用**: 共通要件は別図に切り出し、各図からは ID 参照のみ
5. **凡例図の用意**: 大規模プロジェクトでは「種別と関係の凡例」を別図として提示

---

## アンチパターン

### 1. ID 重複

複数の図で同じ ID `FR-001` を使ってしまうと、トレーサビリティが崩壊する。プロジェクト全体で ID 採番台帳を持つこと。

### 2. verifymethod 未記入

```
functionalRequirement 悪い例 {
    id: FR-001
    text: ログインできること
    risk: Low
}
```

検証方法が空だと「どうやって完了を確認するか」が決まらず、要件として未完成。

### 3. 関係の方向逆転

`satisfies` を要件 → 設計の向きで描いてしまうと SysML の慣習と逆になり、ツール間連携や読者の認知を混乱させる。

### 4. 一枚図に詰め込み

50 個の要件と 30 個の element を 1 つの図に押し込むと、読めない・更新できない・レビューできない。必ず分割する。

### 5. text に長文を埋め込む

要件文が 3 行を超えるとレイアウトが崩れる。要約を text に、詳細は外部文書に。

### 6. element の docref が空

`docref` がないと、図上の element と現実の成果物が対応せず、絵に描いた餅になる。

---

## Good / Bad の具体例

### Bad 例 1: 種別混在 + verifymethod 欠落 + 方向不統一

```mermaid
requirementDiagram

requirement R1 {
    id: 1
    text: 速くて使いやすいシステム
    risk: high
}

requirement R2 {
    id: 1
    text: 検索する
}

element E1 {
    type: code
}

R1 - satisfies -> E1
R2 - contains -> R1
```

問題点: ID が両方 `1` で重複、種別が `requirement` のまま、`verifymethod` 欠落、`satisfies` の向きが逆、`contains` が子から親、text が曖昧。

### Good 例 1: 機能要件の分解

```mermaid
requirementDiagram

requirement 商品購入 {
    id: BR-PURCHASE-001
    text: ユーザはオンラインで商品を購入できること
    risk: High
    verifymethod: Demonstration
}

functionalRequirement 商品検索 {
    id: FR-SEARCH-001
    text: ユーザはキーワードで商品を検索できること
    risk: Medium
    verifymethod: Test
}

functionalRequirement カート機能 {
    id: FR-CART-001
    text: ユーザは商品をカートに追加できること
    risk: Low
    verifymethod: Test
}

functionalRequirement 決済処理 {
    id: FR-PAY-001
    text: ユーザはクレジットカードで決済できること
    risk: High
    verifymethod: Test
}

商品購入 - contains -> 商品検索
商品購入 - contains -> カート機能
商品購入 - contains -> 決済処理
```

### Good 例 2: 性能要件と検証要素の紐付け

```mermaid
requirementDiagram

performanceRequirement 検索応答性能 {
    id: PR-SEARCH-001
    text: 検索応答は95パーセンタイルで200ms以内
    risk: High
    verifymethod: Test
}

functionalRequirement 商品検索 {
    id: FR-SEARCH-001
    text: ユーザはキーワードで商品を検索できること
    risk: Medium
    verifymethod: Test
}

element 検索サービス実装 {
    type: module
    docref: src/services/search.ts
}

element 検索負荷テスト {
    type: testcase
    docref: tests/perf/search_load.js
}

検索応答性能 - derives -> 商品検索
検索サービス実装 - satisfies -> 商品検索
検索サービス実装 - satisfies -> 検索応答性能
検索負荷テスト - verifies -> 検索応答性能
```

### Good 例 3: 設計制約と詳細化

```mermaid
requirementDiagram

designConstraint 国内DC制約 {
    id: DC-DATA-001
    text: 個人情報は国内データセンタに保管すること
    risk: High
    verifymethod: Inspection
}

interfaceRequirement 決済IF {
    id: IR-PAY-001
    text: 決済代行APIはTLS1.3で接続すること
    risk: High
    verifymethod: Inspection
}

functionalRequirement 個人情報保管 {
    id: FR-PII-001
    text: ユーザ個人情報は暗号化して保管すること
    risk: High
    verifymethod: Test
}

element 国内DCポリシー文書 {
    type: document
    docref: docs/policy/datacenter.md
}

国内DC制約 - refines -> 個人情報保管
国内DCポリシー文書 - satisfies -> 国内DC制約
```

---

## まとめ

- 要件種別と関係種別を**正しく**使い分けることが、Requirement Diagram の価値の 9 割
- `id`、`text`、`risk`、`verifymethod` は**4 点セットで必須**
- `element` と `docref` を活用して現実の成果物と接続
- 方向性をそろえ、一枚図の規模を抑え、トレースマトリクスと併用する
- 図はトレーサビリティの「索引」であり、詳細は別文書で管理する
