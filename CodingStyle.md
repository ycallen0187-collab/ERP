# CodingStyle.md

# ERP Coding Style 規範

版本：1.0

最後更新：2026-07-02

---

# 文件目的

本文件定義 ERP 專案 Coding Style。

所有 AI 修改程式時，

必須遵守。

本文件目的：

不是建立新的 Coding Style。

而是保持既有 ERP 的 Coding Style。

---

# 第一原則

請遵守：

「入境隨俗」

修改程式時，

請保持：

原作者 Coding Style。

不要套用自己的 Coding Style。

不要因個人偏好修改程式。

---

# 原則一

不要修改：

縮排

空白

空行

排版

括號位置

Tab

Space

若非此次需求，

請保持原樣。

---

# 原則二

不要修改命名。

例如：

Class

Method

Variable

Parameter

SQL Alias

JSP Name

Java Name

若沒有需求，

不得重新命名。

---

# 原則三

不要整理程式。

例如：

不要：

重新排序

重新排版

重新換行

重新排列 if

重新排列 switch

重新整理 import

除非使用者要求。

---

# 原則四

不要重構。

不得：

拆 Method

合併 Method

抽 Utility

抽 Base Class

抽 Common Function

修改 Layer

建立 Design Pattern

除非使用者要求。

---

# 原則五

保持原有註解。

禁止：

刪除註解

修改註解

翻譯註解

整理註解

若新增程式，

可新增註解。

既有註解不得修改。

---

# 原則六

保持中文。

所有：

中文欄位

中文訊息

中文 Exception

中文 SQL

中文註解

全部保留。

不得英文化。

不得簡化。

---

# 原則七

保持既有流程。

例如：

原本：

A

↓

B

↓

C

↓

D

不要改成：

A

↓

D

↓

B

↓

C

即使結果相同，

也不要修改。

---

# 原則八

優先沿用既有程式。

若 Repository 已存在：

相同功能

相同畫面

相同 SQL

相同 Utility

請優先沿用。

不要重新寫一套。

---

# 原則九

新增程式，

請模仿附近程式。

例如：

新增：

bqjj053.jsp

請參考：

bqjj052.jsp

不要自行發明新的 Coding Style。

---

# 原則十

保持一致性。

同一支程式：

不要同時出現：

兩種命名方式。

兩種排版。

兩種 Coding Style。

請與既有程式一致。

---

# Java

Java Coding Style

請完全遵循：

Repository 既有程式。

不要套用：

Google Style

Oracle Style

Spring Style

Apache Style

一律保持 ERP 既有風格。

---

# JSP

保持：

HTML

Table

FORM

INPUT

SELECT

BUTTON

既有排列方式。

不得重新排版。

---

# SQL

保持：

SQL 排版。

SQL Alias。

SQL 命名。

若沒有需求，

不得重新格式化 SQL。

---

# Javascript

保持：

Function 名稱。

Event。

呼叫方式。

不要改寫。

不要整理。

不要升級。

---

# CSS

不得：

重新排版。

重新命名。

重新整理。

除非需求要求。

---

# Commit 原則

Commit 應只包含：

需求相關修改。

不得夾帶：

排版修改。

Coding Style 修改。

Import 修改。

空白修改。

---

# 最後原則

ERP 是長期維護系統。

Coding Style 的一致性，

比個人偏好重要。

AI 修改程式時，

請讓其他工程師看不出：

「這段是 AI 寫的。」

而應該像：

「原作者自己寫的。」

# 保持原始風格

AI 修改程式時，

請讓修改後的程式，

看起來像：

原作者自己修改的。

而不是：

AI 修改的。

修改完成後，

請再次確認：

- 是否改變 Coding Style
- 是否改變排版
- 是否改變命名
- 是否改變縮排
- 是否改變空白行
- 是否改變註解
- 是否改變 Import

若上述答案為：

是。

請恢復原本風格。