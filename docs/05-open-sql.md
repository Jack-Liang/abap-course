---
status: beta
---

# 第5课：Open SQL —— 增删改查

> 45分钟 | 阶段：基础篇 | 建议边读边做

## 前置依赖

- [第4课](04-internal-table.md)：会用内表承接批量数据；
- [第3课](03-data-dictionary.md)：了解 SFLIGHT / SCARR / SPFLI 结构与主外键。

## 问题引入

内表里的数据从哪来？数据库。写进数据库的数据怎么改、怎么删？ABAP 给的答案是 **Open SQL**：一套内嵌在 ABAP 里的数据库操作语法——不用拼 SQL 字符串、自动处理 Client 隔离、同一套写法跑在任意 SAP 支持的数据库上。本课把增删改查一次打齐，并建立起"事务"的概念。

## 时间安排

| 时段 | 内容 | 时长 |
|------|------|------|
| 场景引入 | Open SQL 与内表的分工 | 3 分钟 |
| Demo 跟做 | 七连操作：查×4 + 增 + 改 + 删 | 10 分钟 |
| 代码拆解 | SELECT 家族 / JOIN / 聚合 / 写操作 / LUW | 25 分钟 |
| 知识总结 | 语句速查表、事务检查单 | 5 分钟 |
| 课后思考 | 练习 | 2 分钟 |

## 本课目标

完成本课你将能够：

- 用 SELECT SINGLE / INTO TABLE / UP TO n ROWS / WHERE / ORDER BY 完成日常查询；
- 写多表 INNER/LEFT JOIN 并知道连接字段为什么要走索引；
- 用 GROUP BY + 聚合函数做统计；
- 用 `@变量` 占位符和 `@DATA(...)` 内联接收写"现代风格"的 SQL；
- 安全地执行 INSERT / UPDATE / DELETE / MODIFY，并理解 COMMIT / ROLLBACK 背后的 LUW。

## Demo：SFLIGHT 七连操作（分步跟做）

运行 `zac_sql_crud`（已随仓库下发），对照下面七段看输出：

```abap
REPORT zac_sql_crud.

START-OF-SELECTION.
  " 1. 单行查询：按键取一条
  SELECT SINGLE * FROM sflight
    WHERE carrid = 'AA' AND connid = '0017'
    INTO @DATA(ls_sflight).
  IF sy-subrc = 0.
    WRITE: / |找到航班: { ls_sflight-carrid }-{ ls_sflight-connid }|.
  ENDIF.

  " 2. 多行查询 + @占位符 + 限量
  DATA(lv_rows) = 10.
  SELECT * FROM sflight
    WHERE fldate >= '20260101'
    INTO TABLE @DATA(lt_sflight)
    UP TO @lv_rows ROWS.
  WRITE: / |查询到 { lines( lt_sflight ) } 条记录|.

  " 3. 三表 JOIN
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

  " 4. 聚合统计
  SELECT carrid, COUNT(*) AS cnt, SUM( seatsocc ) AS total
    FROM sflight WHERE carrid = 'AA'
    GROUP BY carrid
    INTO TABLE @DATA(lt_stats).
  READ TABLE lt_stats INTO @DATA(ls_st) INDEX 1.
  IF sy-subrc = 0.
    WRITE: / |AA 航班共 { ls_st-cnt } 条, 总座位 { ls_st-total }|.
  ENDIF.

  " 5. 新增一条航班（演示数据，随便编一个日期）
  DATA(ls_new) = VALUE sflight(
    carrid = 'AA' connid = '0017' fldate = '20260730'
    seatsmax = 200 seatsocc = 0 ).
  INSERT sflight FROM @ls_new.

  " 6. 修改：占座 +1
  UPDATE sflight SET seatsocc = seatsocc + 1
    WHERE carrid = 'AA' AND connid = '0017' AND fldate = '20260730'.

  " 7. 删除：清理演示数据
  DELETE FROM sflight
    WHERE carrid = 'AA' AND connid = '0017' AND fldate = '20260730'.

  COMMIT WORK.
  WRITE: / |操作已完成|.
```

**你会看到什么：** 依次输出找到的航班、多行查询条数、JOIN 出的城市对列表、AA 的统计行，最后增→改→删一气呵成（第 5-7 步操作的是同一条演示数据，跑完不留痕）。

## 知识点

### 1. SELECT 家族选型

| 写法 | 场景 | 没找到时 |
|------|------|---------|
| `SELECT SINGLE ... WHERE 全键` | 按主键取一条 | `sy-subrc = 4` |
| `SELECT ... INTO TABLE` | 批量取回内表 | `sy-subrc = 4` |
| `SELECT ... UP TO n ROWS` | 看样本、防大结果集 | — |
| `SELECT ... UP TO 1 ROWS`（配 `ENDSELECT`） | 非全键条件"随便取一条" | `sy-subrc = 4` |

注意 **`SELECT SINGLE` 与 `UP TO 1 ROWS` 不能连用**——那是非法组合。两者语义有别：`SINGLE` 承诺"条件唯一定位一条"（典型是全键）；条件可能命中多条、你只要任意一条时，老实用 `UP TO 1 ROWS` + `ENDSELECT`。

- **WHERE 工具箱**：`= <> > <`、`BETWEEN`、`LIKE 'A%'`、`IN @s_option`（选择屏幕区间直接进 SQL，第7课）、`IS NULL`；
- **ORDER BY** 在数据库端排序（占用排序区，大结果集慎用，能排早排）；
- **DISTINCT** 去重——`SELECT DISTINCT carrid FROM sflight` 一行拿到全部航空公司。

!!! tip "SELECT * 的罪与罚"

    原型期随便用；生产代码请列出字段——`SELECT *` 会把用不到的长文本/大字段也搬进内存，宽表上代价显著。例外：真要全字段（`INTO TABLE` 接整行结构）时 `*` 反而合理。

### 2. JOIN：把分开的表拼成业务视图

```abap
FROM sflight AS f
INNER JOIN scarr AS c ON f~carrid = c~carrid     " 只留两边都有的
LEFT OUTER JOIN ...                               " 保左全量，右边补空
```

- SFLIGHT 模型的业务语义天然靠 JOIN 还原：航班（事实）+ 公司/航线（维表）；
- **性能直觉：ON 的连接字段走索引**（主键自带，第3课建的外键/索引在此刻发挥作用）；
- 三表以上 JOIN 或 JOIN + 复杂聚合时，想想是不是该做成 CDS 视图（第20课的正主）。

### 3. 聚合与分组

```abap
SELECT carrid, COUNT(*) AS cnt, SUM( seatsocc ) AS total, AVG( price ) AS avg_price
  FROM sflight
  WHERE fldate >= '20260101'
  GROUP BY carrid
  HAVING COUNT(*) > 10          " 分组后再过滤
  INTO TABLE @DATA(lt_stats).
```

- **WHERE 过滤行（分组前），HAVING 过滤组（分组后）**；
- SELECT 列表里出现的非聚合字段必须出现在 GROUP BY 里；
- 聚合在数据库端完成——别把几百万行拉到 ABAP 里再 REDUCE，**能下推就下推**。

### 4. 现代语法三件套

```abap
WHERE carrid = @lv_carrid          " ① @ 占位符：宿主变量，新旧分界线
INTO @DATA(ls_flight)              " ② 内联声明接收
UP TO @lv_rows ROWS                " ③ 动态限量
```

7.40 之前写 `WHERE carrid = lv_carrid`（靠位置约定），之后必须 `@` 前缀——看到 `@` 就知道这是"ABAP 与 SQL 的交界处"。`%_HINTS` 数据库提示（如 Oracle 的 hints）属于优化末期手段，知道有这东西即可。

### 5. 写操作：INSERT / UPDATE / MODIFY / DELETE

```abap
" 单行 & 批量（批量性能远好于循环单行）
INSERT sflight FROM @ls_new.
INSERT sflight FROM TABLE @lt_new.

UPDATE sflight SET seatsocc = seatsocc + 1 WHERE ...   " 条件更新（也可 FROM @wa 全行覆盖）
UPDATE sflight FROM TABLE @lt_changes.                  " 批量按主键更新

MODIFY sflight FROM @ls_new.        " 存在则 UPDATE，不存在则 INSERT（省心但有歧义感）

DELETE FROM sflight WHERE ....      " 条件删除
```

- `sy-dbcnt`：每条写操作影响的**行数**——UPDATE 后检查它比只看 sy-subrc 更能发现"条件写歪了只改了 0 行"；
- **UPDATE/DELETE 不带 WHERE = 全表操作**，生产环境十大事故榜首。

### 6. 事务与 LUW：写完不 COMMIT = 白写

```abap
INSERT sflight FROM @ls_new.   " 此时改动只在当前数据库会话可见
...
COMMIT WORK.                   " 落盘，对所有人可见
" 或者反悔：
ROLLBACK WORK.                 " 撤销本次 LUW 的全部写操作
```

- **数据库 LUW**：从上一条修改语句到 COMMIT/ROLLBACK 之间的一段；
- **SAP LUW**：SAP 的逻辑工作单元概念——一个对话步骤/一个 BAPI 事务块，可能横跨多个数据库 LUW，第14课讲 BAPI 时会看到 `BAPI_TRANSACTION_COMMIT` 正是 SAP LUW 的标准收口；
- 本课记住三条：**写操作默认不自动提交；要么 COMMIT 要么 ROLLBACK，别悬着；一个业务动作的所有写操作放进同一个 LUW**（要么全成，要么全撤）。

## 💡 实战经验

!!! tip "改生产数据的保命三连"

    UPDATE/DELETE 前先跑一遍同条件的 SELECT 看命中范围 → 在开发库演练 → 执行后核对 `sy-dbcnt`。三条都做到，你就能安心下班。

!!! tip "sy-subrc 与 sy-dbcnt 一起看"

    `sy-subrc = 0` 只说"语句成功"，`sy-dbcnt = 0` 才告诉你"其实一行都没改到"。写操作后两个都检查。

!!! warning "别在 LOOP 里 SELECT"

    循环里逐行查库（N 次 DB 往返）是 ABAP 性能反模式之首。正确姿势：进循环前 `SELECT ... FOR ALL ENTRIES` 或 JOIN 批量取回内表，循环里 `READ TABLE`（第4课的 HASHED 表）。

## 📖 延伸阅读

- [ABAP Keyword Documentation](https://help.sap.com/doc/abapdocu_752_index_htm/7.52/en-US/index.htm)——`SELECT` / `INSERT` / `UPDATE` / `COMMIT` 条目；
- SFLIGHT 表族关系见[第1课](01-sap-overview.md)与参考资料库的 Flight Model 文档。

## 课后思考

> 把你的回答写在**页面底部评论区**，注明题号，一起讨论。

1. `SELECT SINGLE` 与 `SELECT ... INTO TABLE` 各适合什么场景？非主键条件取一条时为什么推荐 `UP TO 1 ROWS`？
2. WHERE 与 HAVING 的区别是什么？
3. 改写 Demo 第 3 段：不用 JOIN，改用两次 `SELECT ... FOR ALL ENTRIES` 实现，比较两者代码量与你的直觉性能判断。
4. 为什么说"写完不 COMMIT = 白写"？COMMIT 之前这些改动对别的会话可见吗？（可以开两个 `/o` 会话实测——第1课学的 `/o` 正好用上。）

---

下一课：[第6课：ABAP 调试器](06-debugging.md)
