# ERP AI 開發專案

版本：1.0

最後更新：2026-07-02

---

# 專案介紹

本 Repository 為 ERP AI 協同開發專案。

主要用途：

- ERP 功能開發
- ERP 功能維護
- Bug 修正
- Java 開發
- JSP 開發
- SQL 分析
- AI 協同開發
- Code Review

本 Repository 為 AI 開發 Sandbox。

正式 ERP 不直接於此 Repository 修改。

所有 AI 修改內容皆須經人工 Review 後，才能併入正式系統。

---

# 系統環境

## 開發工具

- Eclipse

## 程式語言

- Java 6

## Web Framework

- Struts

## Application Server

- Tomcat 6

## Database

- IBM DB2

## Database Access

- JDBC
- PreparedStatement
- ResultSet

## 專案編碼

- CP950 (Big5)

---

# 專案架構

目前專案採用傳統 ERP 架構。

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

# 各資料夾用途

## bq/html

存放畫面所需圖片、HTML 資源及相關靜態檔案。

---

## bq/jsp

存放所有 JSP 畫面。

每一支 JSP 通常代表一個功能畫面。

例如：

- bqjj001.jsp
- bqjj042.jsp
- bqjj052.jsp

部分功能會拆分：

- List
- Tab
- Popup
- 明細畫面

例如：

- bqjj042List.jsp
- bqjj042_tabOrder.jsp
- bqjj042_tabFactory.jsp

---

## bq/src

存放 Java 原始碼。

目前採用公司既有 ERP 架構。

```
com
 └── icsc
      └── bq
           └── core
```

所有 Java Controller、商業邏輯及資料處理程式皆位於此目錄。

---

# 命名規則

目前系統採固定命名方式。

例如：

```
bqjj042.jsp

↓

bqjc042.java
```

通常：

- jj 代表 JSP 畫面
- jc 代表 Java Controller / Core

AI 修改程式前，

請優先搜尋是否存在相同編號之 Java 與 JSP。

避免重複開發。

---

# Repository 使用方式

本 Repository 不追求最新技術。

本 Repository 優先考量：

- 系統穩定
- 商業邏輯
- Java 6 相容
- 最小修改
- 可維護性

---

# AI 開發流程

AI 修改程式前，

請依序閱讀：

1. AGENTS.md
2. README.md
3. Architecture.md
4. Workflow.md
5. Java16Rules.md
6. SQLRules.md
7. UIRules.md
8. CodingStyle.md
9. OutputFormat.md

---

# 修改原則

除非使用者明確要求，

否則不得：

- 重構
- 更換 Framework
- 升級 Java
- 修改 UI
- 修改 Javascript
- 修改 SQL
- 修改 Repository 結構

所有修改皆須遵守：

最小修改原則（Minimal Change Principle）。

---

# Pull Request 原則

每次 Pull Request 應說明：

- 修改目的
- 修改內容
- 影響範圍
- 測試方式
- 已知風險

方便後續 Review。

---

# 持續改善

本 Repository 採持續改善方式維護。

若未來發現：

- AI 常犯錯
- 新增 Coding Rule
- 新增維護經驗
- 新增開發規範

請更新對應 Markdown 文件。

讓 Repository 與 AI 一同成長。

---

# Repository 目標

本 Repository 的目的不是重新開發 ERP。

而是建立一套可長期維護的 ERP AI 協同開發環境。

AI 應像資深維護工程師一樣思考。

優先保護既有系統。

而不是重新設計既有系統。