# SQLRules.md

# IBM DB2 SQL 開發規範

版本：1.0

最後更新：2026-07-02

---

# 文件目的

本文件定義本 ERP 專案 DB2 SQL 開發規範。

所有 SQL 修改皆必須遵守。

本文件目的：

不是追求最快 SQL。

而是：

安全

穩定

容易維護

避免影響正式 ERP。

---

# 第一原則

SQL 屬於高風險修改。

任何 SQL 修改，

皆不得直接修改。

請先：

分析

↓

說明

↓

取得使用者確認

↓

再開始修改。

---

# 修改 SQL 前

必須先回答：

1. 修改目的

2. 修改哪些 SQL

3. 是否影響 Index

4. 是否可能 Full Table Scan

5. 是否影響其他功能

6. 是否影響交易(Transaction)

7. 是否需要 RUNSTATS

8. 是否需要 REORG

---

# SQL 修改原則

除非使用者要求，

否則：

不得：

重寫 SQL

最佳化 SQL

修改 JOIN

修改 WHERE

修改 ORDER BY

修改 GROUP BY

修改 HAVING

修改 UNION

修改 INDEX Hint

不要因為你認為可以更快，

就自行修改。

---

# PreparedStatement

所有 SQL：

優先使用：

PreparedStatement

不得：

SQL 字串直接串接變數。

避免：

SQL Injection。

---

# MERGE

若功能已使用 MERGE，

請保持 MERGE。

不要自行改成：

INSERT

UPDATE

DELETE

三段式。

---

# DELETE

大量 DELETE：

不得一次刪除全部資料。

應：

分批執行。

例如：

每1000筆

COMMIT一次。

避免：

Lock Table。

---

# UPDATE

大量 UPDATE：

請考慮：

分批 Commit。

避免：

Transaction 過大。

---

# INSERT

大量 INSERT：

請依原系統。

建議：

每500~1000筆 Commit。

避免：

Log 過大。

---

# COMMIT

大量資料異動：

不得：

最後一次才 Commit。

請依：

既有程式。

或：

每500~1000筆 Commit。

---

# SELECT

SELECT 前：

請確認：

是否有 Index。

是否會 Full Scan。

若可能：

請提醒使用者。

不要直接修改。

---

# Index

不得：

自行新增 Index。

不得：

自行修改 Index。

若有建議，

請先提出。

等待確認。

---

# Lock

修改 SQL 前，

請評估：

是否可能：

Table Lock

Row Lock

Long Transaction

Deadlock

若有風險，

請先提醒。

---

# Explain

若 SQL 效能不佳，

建議：

Explain Plan。

分析後，

提出改善建議。

不得直接修改正式 SQL。

---

# RUNSTATS

若：

大量資料異動。

Index 大量變更。

請提醒：

可能需要：

RUNSTATS。

---

# REORG

若：

大量 DELETE。

大量 UPDATE。

大量 INSERT。

請提醒：

是否需要：

REORG。

不得自行執行。

---

# Utility

不得：

自行執行：

REORG

RUNSTATS

LOAD

IMPORT

EXPORT

除非使用者要求。

---

# DB2 特性

請注意：

DB2 與：

Oracle

SQL Server

MySQL

PostgreSQL

不同。

不得套用：

其他資料庫最佳化方式。

---

# SQL 命名

保持：

既有 Alias。

既有 Table 順序。

既有格式。

不要重新排版。

不要重新命名。

---

# 中文

SQL 中：

中文註解。

中文 Alias。

中文說明。

全部保留。

---

# 修改完成後

請回報：

【修改 SQL】

【修改原因】

【影響範圍】

【是否需要 RUNSTATS】

【是否需要 REORG】

【是否可能 Lock】

【是否需要測試】

---

# 效能建議

若發現：

可改善 SQL。

請：

提出建議。

分析原因。

等待確認。

不得直接修改。

---

# 最後原則

ERP 的 SQL：

第一目標不是最快。

而是：

安全。

穩定。

可維護。

任何 SQL 修改，

皆應遵守：

分析

↓

確認

↓

修改

↓

驗證

↓

上線。