# Java16Rules.md

# Java 6 開發規範

版本：1.0

最後更新：2026-07-02

---

# 文件目的

本文件定義本 ERP 專案 Java 開發規範。

所有 Java 程式皆必須遵守。

本文件目的不是介紹 Java。

而是確保：

所有 AI 產生的 Java 程式，

皆可直接於本 ERP 編譯、維護及部署。

---

# Java 版本

本系統固定使用：

Java 6

不得使用：

Java7

Java8

Java11

Java17

Java21

任何新語法。

---

# 禁止使用

不得使用：

Lambda

Stream API

Optional

var

Record

Text Block

Switch Expression

Module

Diamond Operator (<>)

try-with-resources

java.time

Objects.requireNonNull()

List.of()

Map.of()

Set.of()

Collectors

Method Reference

任何 Java7 以上 API。

---

# Collection

請使用：

ArrayList

HashMap

Hashtable（若原系統使用）

Vector（若原系統使用）

LinkedList（若原系統使用）

不得自行改成：

Stream

Parallel Stream

Immutable Collection

---

# String

請保持：

StringBuffer

StringBuilder

若原程式使用 StringBuffer，

不得自行改成 StringBuilder。

請保持與既有程式一致。

---

# Exception

保持原有 Exception Flow。

不要：

大量 catch(Exception)

不要吞 Exception。

不要刪除 Exception。

不要新增 RuntimeException。

---

# JDBC

所有資料庫存取，

請依既有程式寫法。

流程應維持：

Connection

↓

PreparedStatement

↓

ResultSet

↓

finally 關閉

不得自行修改流程。

---

# Resource Close

Java6 不支援：

try-with-resources。

所有：

Connection

PreparedStatement

ResultSet

皆應：

於 finally 關閉。

不得遺漏。

---

# Connection

不得：

自行建立新的 Connection 管理方式。

不得：

自行導入 Connection Pool。

請保持既有取得方式。

---

# SQL

SQL 不得直接串接字串。

請優先使用：

PreparedStatement

避免 SQL Injection。

---

# Null

請保持既有 Null 判斷方式。

不得：

自行大量改寫。

例如：

Objects.requireNonNull()

禁止。

---

# Import

不要整理 Import。

不要刪除 Import。

不要重新排序。

除非此次需求需要。

---

# Method

不要：

拆 Method。

合併 Method。

重新命名 Method。

抽 Utility。

除非使用者要求。

---

# Class

不要：

重新命名。

重新建立繼承。

修改 Package。

建立 Interface。

建立 Abstract。

除非需求要求。

---

# Thread

不得：

自行新增：

Thread

Executor

Future

CompletableFuture

任何多執行緒。

---

# Generic

請保持 Java6 可編譯。

不要使用：

Java7 Diamond Operator。

例如：

禁止：

new ArrayList<>();

應保持：

new ArrayList<String>();

---

# Logging

請依原系統。

不要自行：

導入 Log4j2

SLF4J

Lombok

Spring Logger

保持既有方式。

---

# Utility

若 Repository 已存在：

StringUtil

DateUtil

DBUtil

CommonUtil

請優先使用。

不要自行建立：

StringUtils2

DateHelper

MyDBUtil

避免重複。

---

# 效能

若發現：

SQL

迴圈

大量查詢

可改善。

請先提出建議。

不得直接修改。

---

# 修改原則

所有 Java 修改：

遵守：

最小修改原則。

修改需求範圍即可。

不得順便改善其他程式。

---

# 最後原則

本 ERP 已穩定運作多年。

Java 的目的：

不是展示新語法。

而是：

穩定、

相容、

容易維護。

任何 Java 程式，

都必須：

100%

Java 6 Compatible。

# Import

除非：

新增程式需要。

否則：

不得：

- 刪除 Import
- 整理 Import
- 排序 Import

保持原有 Import。

---

# Method

不得：

- 合併 Method
- 拆 Method
- 刪除空 Method
- 修改 Method 順序

除非使用者要求。

---

# Class

不得：

新增：

Interface

Abstract Class

Enum

Annotation

Generic Utility

Design Pattern

保持目前架構。

---

# 註解

Java 註解屬於程式文件。

禁止：

- 刪除
- 修改
- 精簡

若新增程式，

請依照附近程式風格新增。