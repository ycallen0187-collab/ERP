# Architecture.md

# ERP 系統架構說明

版本：1.0

最後更新：2026-07-02

---

# 文件目的

本文件用於說明本 ERP 專案的整體架構。

目的：

- 讓 AI 快速理解專案結構。
- 讓新進工程師快速了解系統。
- 降低修改時誤判架構的風險。

本文件僅描述目前系統架構。

不得依本文件自行重構系統。

---

# 系統架構

本系統採用傳統 Java Web ERP 架構。

```
Browser
    │
    ▼
JSP 畫面
    │
    ▼
Java Core
    │
    ▼
DB2 Database
    │
    ▼
JSP 顯示結果
```

---

# Repository 結構

```
ERP
│
├── AGENTS.md
├── README.md
├── Architecture.md
├── Workflow.md
├── CodingStyle.md
├── Java16Rules.md
├── SQLRules.md
├── UIRules.md
├── OutputFormat.md
│
└── bq
    ├── html
    ├── jsp
    └── src
        └── com
            └── icsc
                └── bq
                    └── core
```

---

# 各目錄說明

## html

存放：

- 圖片
- HTML
- Icon
- 畫面共用資源

AI 不得任意修改。

---

## jsp

存放：

所有畫面。

通常：

一支 JSP

=

一個功能畫面。

例如：

```
bqjj042.jsp
```

若功能較複雜，

可能包含：

```
bqjj042List.jsp

bqjj042_tabOrder.jsp

bqjj042_tabFactory.jsp

bqjj042_tabPP.jsp
```

表示：

- 主畫面
- 查詢結果
- Tab
- 子畫面

---

## src

存放：

Java 原始程式。

目前皆位於：

```
com.icsc.bq.core
```

AI 不得自行建立新的 Package。

除非使用者要求。

---

# 命名規則

目前 ERP 採固定命名方式。

例如：

```
JSP

bqjj042.jsp

↓

Java

bqjc042.java
```

通常：

相同流水號，

代表同一支功能。

AI 修改前，

應優先搜尋：

是否存在相同編號。

例如：

```
042

↓

搜尋：

042
```

不要自行新增新的命名方式。

---

# 一個功能的流程

一個 ERP 功能，

通常流程如下：

```
Browser

↓

JSP

↓

Java

↓

DB2

↓

Java

↓

JSP

↓

Browser
```

AI 修改時，

應先確認：

資料從哪裡來。

最後送到哪裡。

不要只修改畫面。

---

# 修改 JSP 時

必須確認：

是否有對應 Java。

例如：

```
bqjj052.jsp

↓

bqjc052.java
```

若找不到，

請先搜尋：

相同流水號。

不要自行建立新的 Java。

---

# 修改 Java 時

必須確認：

是否有對應 JSP。

避免：

Java 已修改。

畫面未修改。

造成功能不一致。

---

# 共用程式

若發現：

Utility

Connection

共用 Function

共用 SQL

共用 Javascript

請先確認：

是否已有其他畫面使用。

避免影響其他功能。

---

# AI 修改流程

AI 收到需求後：

第一步：

找到 JSP。

第二步：

找到對應 Java。

第三步：

分析流程。

第四步：

分析是否有共用程式。

第五步：

確認影響範圍。

最後：

才開始修改。

不得直接修改。

---

# 架構原則

本 ERP 已穩定運作多年。

修改時，

應優先遵守：

保持原架構。

保持原流程。

保持原命名。

保持原商業邏輯。

不得：

自行重構。

自行拆 Class。

自行新增 Layer。

自行新增 Framework。

除非使用者明確要求。

---

# 最後原則

理解架構，

永遠比開始修改重要。

請先理解：

畫面

↓

Java

↓

Database

的完整流程。

確認理解後，

再開始修改程式。