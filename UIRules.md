# UIRules.md

# JSP / UI 開發規範

版本：1.0

最後更新：2026-07-02

---

# 文件目的

本文件定義 ERP 畫面修改規範。

所有 JSP、HTML、CSS、JavaScript 修改皆須遵守。

---

# 第一原則

未經使用者明確要求，

禁止修改：

- HTML
- JSP
- CSS
- JavaScript
- Table Layout
- 欄位位置
- Button 位置
- 畫面配置
- 顏色
- 字型
- Icon
- Style

---

# JSP

新增功能時：

請保持：

- 原有排版
- 原有縮排
- 原有 Table
- 原有命名

不得重新排版。

---

# HTML

不得：

- 改 HTML 結構
- 改 Table
- 改 DIV
- 改 FORM
- 改 INPUT

除非需求要求。

---

# CSS

不得：

新增 CSS。

不得：

修改 CSS。

不得：

整理 CSS。

除非需求要求。

---

# JavaScript

不得：

新增 Framework。

不得：

重寫 JavaScript。

不得：

整理 JavaScript。

不得：

改 ES6。

保持原寫法。

---

# UI 元件

新增欄位時：

請依照附近欄位。

新增按鈕時：

請依照附近按鈕。

新增查詢條件時：

請依照既有查詢區。

不得自行設計。

---

# 畫面一致性

所有新增畫面，

請完全依照：

附近畫面。

不要自行發明新的 UI。

---

# 共用畫面

若畫面：

共用 Header

共用 Footer

共用 Menu

共用 JS

修改前，

請先分析是否影響其他功能。

---

# 回覆

若需求沒有要求修改 UI，

請假設：

UI 為不可修改區域。

---

# 最後原則

畫面修改，

以需求為主。

沒有要求，

不要修改。