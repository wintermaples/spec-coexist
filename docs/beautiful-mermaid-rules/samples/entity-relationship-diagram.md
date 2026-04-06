# ECサイト 受注ドメインの論理 ER 図

## 題材

中規模 EC サイトにおける **受注ドメイン (Sales Context)** のデータモデル。顧客が商品を発注し、注文明細・出荷・請求・支払までを 1 枚の論理 ER 図で俯瞰する。

## 前提

- 図の用途: **論理 ER 図** (基本設計書向け)。物理 DDL の直前ではない
- スコープ: 受注ドメインのみ。在庫マスタや会計仕訳は別図 (コンテキストマップで連携)
- 命名規則: エンティティは **単数形 PascalCase**、物理列名は snake_case
- 型は SQL 型 (`bigint`, `varchar`, `decimal`, `datetime`) で統一
- 監査列 (`created_at` / `updated_at` / `deleted_at`) は論理 ER 図のため省略
- 関係はすべて Crow's Foot 多重度 + 動詞句ラベル (両方向から読めるよう統一)

## 図

```mermaid
erDiagram
  direction LR

  Customer ||--o{ Order : "発注する / 発注される"
  Order ||--|{ OrderLine : "明細を持つ / に属する"
  Product ||--o{ OrderLine : "明細に現れる / が参照する"
  Order ||--o| Shipment : "出荷される / が出荷する"
  Shipment ||--|{ ShipmentLine : "出荷明細を持つ / に属する"
  OrderLine ||--o{ ShipmentLine : "出荷される / を出荷する"
  Order ||--|| Invoice : "請求される / が請求する"
  Invoice ||--o{ Payment : "支払われる / を支払う"

  Customer {
    bigint id PK "顧客ID"
    string customer_code UK "顧客コード NOT NULL"
    string name "氏名 NOT NULL"
    string email UK "メール NOT NULL"
    string tel "電話番号"
    string status "有効/休眠/退会 NOT NULL"
  }

  Order {
    bigint id PK "注文ID"
    string order_no UK "注文番号 NOT NULL"
    bigint customer_id FK "顧客ID NOT NULL"
    datetime ordered_at "受注日時 NOT NULL"
    decimal total_amount "合計金額 NOT NULL"
    string status "受注/引当済/出荷済/キャンセル NOT NULL"
  }

  OrderLine {
    bigint order_id PK,FK "注文ID"
    int line_no PK "行番号"
    bigint product_id FK "商品ID NOT NULL"
    int quantity "数量 NOT NULL"
    decimal unit_price "単価 NOT NULL"
    decimal line_amount "明細金額 NOT NULL"
  }

  Product {
    bigint id PK "商品ID"
    string sku UK "SKU NOT NULL"
    string name "商品名 NOT NULL"
    decimal list_price "定価 NOT NULL"
    string status "販売中/廃番 NOT NULL"
  }

  Shipment {
    bigint id PK "出荷ID"
    string shipment_no UK "出荷番号 NOT NULL"
    bigint order_id FK "注文ID NOT NULL"
    datetime shipped_at "出荷日時"
    string carrier "配送業者 NOT NULL"
    string tracking_no "追跡番号"
  }

  ShipmentLine {
    bigint shipment_id PK,FK "出荷ID"
    int line_no PK "行番号"
    bigint order_id FK "注文ID NOT NULL"
    int order_line_no FK "注文行番号 NOT NULL"
    int quantity "出荷数量 NOT NULL"
  }

  Invoice {
    bigint id PK "請求ID"
    string invoice_no UK "請求番号 NOT NULL"
    bigint order_id FK "注文ID NOT NULL"
    datetime issued_at "発行日時 NOT NULL"
    decimal billed_amount "請求金額 NOT NULL"
    string status "未収/一部入金/完済 NOT NULL"
  }

  Payment {
    bigint id PK "支払ID"
    bigint invoice_id FK "請求ID NOT NULL"
    datetime paid_at "入金日時 NOT NULL"
    decimal amount "入金金額 NOT NULL"
    string method "クレカ/銀行振込/コンビニ NOT NULL"
  }
```

## 解説

### エンティティ構成 (8 個)

集約ルートである `Order` を中心に、上流に顧客マスタ (`Customer`) と商品マスタ (`Product`)、下流に出荷 (`Shipment` / `ShipmentLine`)、請求 (`Invoice`)、支払 (`Payment`) を配置している。エンティティ数は 8 で、論理 ER 図の上限 (10 程度) に収まるよう在庫や会計は意図的に切り出した。

### 多重度の意味

- `Customer ||--o{ Order`: 1 顧客は 0 件以上の注文を持つ。新規登録直後の未発注顧客も許容するため `o{`
- `Order ||--|{ OrderLine`: 注文には必ず 1 行以上の明細が必要 (`|{`)。空注文は業務上ありえない
- `Product ||--o{ OrderLine`: 商品は明細から参照されるだけで、未注文商品 (0 件) もある
- `Order ||--o| Shipment`: 1 注文に対し出荷は 0 または 1 (分割出荷は本スコープ外)
- `Order ||--|| Invoice`: 1 注文に対し請求は必ず 1 件発行される
- `Invoice ||--o{ Payment`: 分割入金を許容するため 0..多

### キー設計のポイント

- すべてのエンティティに代理キー `id PK` を置き、業務的な識別子は `UK` (`order_no`, `sku`, `email` 等) で重複防止
- `OrderLine` / `ShipmentLine` は **複合主キー** (`PK,FK` + `line_no`) で親に従属する識別関係を表現
- `ShipmentLine` は `OrderLine` を `(order_id, order_line_no)` の複合 FK で参照し、何の明細を出荷したかを追跡

### 関係ラベルの統一

すべての関係に `"左から読む / 右から読む"` 形式の動詞句ラベルを付与した。例えば `Customer ||--o{ Order : "発注する / 発注される"` は、左から読めば「顧客は注文を発注する」、右から読めば「注文は顧客から発注される」と双方向に成立する。これにより読者がどちら側から辿っても業務的意味が壊れない。

### この図に載せていないもの

監査列、住所マスタ、在庫引当、会計仕訳、配送先テーブルなどは意図的に省略している。これらは別のサブジェクトエリア図 (在庫管理 / 会計 / 顧客マスタ) に分離し、コンテキストマップで全体関係を別途示す方針である。論理 ER 図 1 枚に詰め込むと線が交差して読めなくなるためである。
