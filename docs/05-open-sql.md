# 第5课：Open SQL —— 增删改查

> 45分钟 | 阶段：基础篇

## 前置依赖

- 第4课：会使用内表存储数据
- 第3课：了解 SFLIGHT / SCARR / SPFLI 表结构

## 问题引入

前几课我们学会了在内表里处理数据——排序、分组、查找。但内表里的数据从哪来？答案是数据库。真实业务中，数据持久化存储在数据库表里，ABAP 程序需要一套标准语法来与数据库交互：查询、新增、修改、删除。Open SQL 就是 ABAP 提供的数据库操作语言，它屏蔽了底层差异，让开发者用统一的语法操作 SAP 数据库。

## 时间安排

| 时段 | 内容 | 时长 |
|------|------|------|
| 场景引入 | 为什么需要 Open SQL？SQL 与内表的关系 | 3 分钟 |
| Demo 演示 | 对 SFLIGHT 执行查询、新增、修改、删除 | 5 分钟 |
| 代码拆解 | SELECT / INSERT / UPDATE / DELETE 语法详解、JOIN、聚合、新语法 | 30 分钟 |
| 知识总结 | Open SQL 操作速查表、事务概念 | 5 分钟 |
| 课后思考 | 练习 | 2 分钟 |

## 本课目标

全面掌握 Open SQL 的 SELECT / INSERT / UPDATE / DELETE 操作，理解不同查询方式的区别和适用场景。

## Demo

对 SFLIGHT 执行多种查询（单行、多行、JOIN），新增一条航班记录，修改已占座位数，删除一条记录。

## 知识点

### 1. SELECT 语句详解
- SELECT SINGLE ... INTO vs SELECT ... INTO TABLE
- SELECT ... UP TO n ROWS
- WHERE 条件、LIKE、IN、BETWEEN、IS NULL/NOT NULL
- ORDER BY
- DISTINCT

### 2. JOIN 查询
- INNER JOIN / LEFT OUTER JOIN
- 多表 JOIN 的注意事项（性能、数据量）

### 3. 聚合函数
- COUNT / SUM / AVG / MIN / MAX
- GROUP BY / HAVING

### 4. 新语法
- `@` 占位符在 WHERE 条件中的使用
- `@DATA` 内联声明结果（INTO @DATA / INTO TABLE @DATA(lt)）
- `%_HINTS` 性能提示（简要提及）

### 5. INSERT 语句
- 单行插入（INSERT dbtab FROM wa）
- 内表批量插入（INSERT dbtab FROM TABLE lt_itab）

### 6. UPDATE 语句
- SET ... WHERE 条件更新
- 内表批量更新

### 7. MODIFY 语句
- 新增或修改，自动判断（存在则改，不存在则增）

### 8. DELETE 语句
- WHERE 条件删除
- 内表批量删除

### 9. 数据库事务与 LUW 概念
- COMMIT WORK：提交事务
- ROLLBACK WORK：回滚事务
- SAP LUW 与数据库 LUW 的区别（简要介绍，第14课深化）

## Demo 代码

```abap
*&---------------------------------------------------------------------*
*& Report ZAC_SQL_CRUD
*&---------------------------------------------------------------------*
*& 第5课：Open SQL —— 增删改查
*& 演示 SELECT/INSERT/UPDATE/DELETE、JOIN、聚合、@占位符
*&---------------------------------------------------------------------*
REPORT zac_sql_crud.

START-OF-SELECTION.
  " 1. 单行查询
  SELECT SINGLE * FROM sflight
    WHERE carrid = 'AA' AND connid = '0017'
    INTO @DATA(ls_sflight).
  IF sy-subrc = 0.
    WRITE: / |找到航班: { ls_sflight-carrid }-{ ls_sflight-connid }|.
  ENDIF.

  " 2. 多行查询 + @占位符
  DATA(lv_rows) = 10.
  SELECT * FROM sflight
    WHERE fldate >= '20260101'
    INTO TABLE @DATA(lt_sflight)
    UP TO @lv_rows ROWS.
  WRITE: / |查询到 { lines( lt_sflight ) } 条记录|.

  " 3. JOIN 查询
  SELECT f~carrid, f~connid, f~fldate, c~carrname,
         p~cityfrom, p~cityto
    FROM sflight AS f
    INNER JOIN scarr AS c ON f~carrid = c~carrid
    INNER JOIN spfli AS p ON f~carrid = p~carrid
                         AND f~connid = p~connid
    WHERE f~carrid = 'AA'
    INTO TABLE @DATA(lt_join).
  LOOP AT lt_join INTO @DATA(ls_j).
    WRITE: / |{ ls_j-carrname } { ls_j-cityfrom } → { ls_j-cityto }|.
  ENDLOOP.

  " 4. 聚合
  SELECT carrid, COUNT(*) AS cnt, SUM( seatsocc ) AS total
    FROM sflight WHERE carrid = 'AA'
    GROUP BY carrid
    INTO TABLE @DATA(lt_stats).
  READ TABLE lt_stats INTO @DATA(ls_st) INDEX 1.
  IF sy-subrc = 0.
    WRITE: / |AA 航班共 { ls_st-cnt } 条, 总座位 { ls_st-total }|.
  ENDIF.

  " 5. INSERT
  DATA(ls_new) = VALUE sflight(
    carrid = 'AA' connid = '0017' fldate = '20260730'
    seatsmax = 200 seatsocc = 0 ).
  INSERT sflight FROM @ls_new.

  " 6. UPDATE
  UPDATE sflight SET seatsocc = seatsocc + 1
    WHERE carrid = 'AA' AND connid = '0017' AND fldate = '20260730'.

  " 7. DELETE
  DELETE FROM sflight
    WHERE carrid = 'AA' AND connid = '0017' AND fldate = '20260730'.

  COMMIT WORK.
  WRITE: / |操作已完成|.
```

## 💡 实战经验

- **COMMIT WORK 不能忘**：INSERT / UPDATE / DELETE 不会自动提交，必须显式 `COMMIT WORK` 才能将修改写入数据库。忘记 COMMIT 是新手最常见的 bug 之一
- **避免 SELECT ***：`SELECT *` 会读取所有字段，包括不需要的大文本字段，浪费内存和网络。生产代码应明确列出所需字段，如 `SELECT carrid, connid, fldate FROM sflight`
- **UPDATE 一定要加 WHERE**：不带 WHERE 的 UPDATE 会修改表中所有行！这在生产环境是灾难性操作。执行前务必确认 WHERE 条件正确
- **JOIN 性能注意**：多表 JOIN 时，连接字段必须有索引（主键默认有索引）。三张以上表 JOIN 时考虑是否可以用视图替代，或者分步查询后在内表中关联
- **sy-subrc 检查**：每次数据库操作后都应检查 `sy-subrc`，0 表示成功，4 表示未找到，其他值表示错误

## 代码拆解要点

1. SELECT SINGLE vs SELECT ... INTO TABLE 的区别与使用场景
2. @ 占位符在 WHERE 条件和 UP TO n ROWS 中的作用
3. INNER JOIN 的 ON 条件写法（表别名 ~ 字段）
4. 聚合函数 GROUP BY 的字段选择规则
5. INSERT / UPDATE / DELETE 的基本语法结构
6. COMMIT WORK 在事务提交中的作用

## 课后思考

1. SELECT SINGLE 和 SELECT ... INTO TABLE 分别适用于什么场景？
2. 为什么 UPDATE 和 DELETE 语句必须加 WHERE 条件？
3. INNER JOIN 和 LEFT OUTER JOIN 的查询结果有什么区别？
4. 尝试用 JOIN 查询出所有航班的城市对信息，并按航空公司分组统计航班数量。
