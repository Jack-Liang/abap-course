---
status: draft
---

# 第21课：CDS View（进阶）—— 聚合与注解

> 45分钟 | 阶段：现代开发篇

## 前置依赖

- 第20课：能创建基本 CDS View
- 第5课：了解 SQL 聚合（COUNT / SUM / AVG）

## 问题引入

基础 CDS 已经能把多张表关联起来了，但管理层需要的是"汇总数据"——每个航空公司的航班数量、平均票价、最繁忙航线排行。怎么在 CDS 中做聚合统计？怎么让 CDS View 在 SAP UI（如 Fiori）中展示时有更友好的标题和格式？CDS 注解就是控制展示元数据的机制。

## 时间安排

| 时段 | 内容 | 时长 |
|------|------|------|
| 场景引入 | 从"明细数据"到"统计报表"的需求升级 | 3 分钟 |
| Demo 演示 | 展示基于 CDS 的航班统计报表 | 5 分钟 |
| 代码拆解 | GROUP BY、聚合函数、CASE WHEN、CDS 注解、@UI / @EndUserText | 28 分钟 |
| 知识总结 | CDS 注解速查、聚合最佳实践 | 6 分钟 |
| 课后思考 | 练习 | 3 分钟 |

## 本课目标

掌握 CDS View 的聚合查询和注解机制，能为 CDS 添加 UI 元数据，支持 Fiori 应用开发。

## Demo

创建航班统计 CDS View（ZAC_FLIGHT_STATS），按航空公司聚合航班数量和平均票价，使用 CDS 注解定义列标题和格式。

## 知识点

### 1. CDS 函数
- 聚合：COUNT / SUM / AVG / MIN / MAX
- 标量：COALESCE / CAST / DIVISION / CONCAT / UPPER / LOWER / SUBSTRING / LENGTH
- 日期：DATS_DAYS_BETWEEN / DATS_ADD_DAYS

### 2. Session 变量
- $session.user
- $session.system_date
- 在 WHERE 条件中使用

### 3. 访问控制（DCL）
- @AccessControl.authorizationCheck: #CHECK
- DEFINE ROLE / DEFINE ROLE WITH CONDITION
- CDS Role 分配

### 4. View Entity（ABAP 7.55+ 新语法）
- DEFINE VIEW ENTITY zve_xxx AS SELECT FROM ...
- View Entity vs CDS View 的区别
- 更简洁的语法、更多函数支持
- $self 关键字

### 5. CDS 在报表中的使用模式
- CDS 做数据源，ABAP 做展示
- 与 ALV 结合

### 6. 性能考量
- 下推到数据库执行 vs ABAP 层处理
- CDS vs ABAP OpenSQL 的性能差异

## Demo 代码

参数化 CDS View：
```sql
@AbapCatalog.sqlViewName: 'ZV_SFLIGHT_STATS'
@EndUserText.label: '航班统计视图'
define view ZAC_FLIGHT_STATS
  with parameters p_carrid : abap.char3
  as select from sflight
{
    key sflight.carrid,
    count(*)            as flight_count,
    sum(sflight.price)  as total_price,
    avg(sflight.price)  as avg_price,
    max(sflight.price)  as max_price,
    sflight.seatsmax    as total_seats,
    sum(sflight.seatsocc) as total_occupied
}
where sflight.carrid = $parameters.p_carrid
group by sflight.carrid, sflight.seatsmax
```

DCL 访问控制：
```sql
@MappingRole: true
define role zr_flight_data {
  grant select on ZAC_FLIGHT_DETAIL
    where carrid = aspect zcds_flight_auth.carrid;
}
```

ABAP 调用参数化 CDS：
```abap
REPORT zac_cds_advanced.

START-OF-SELECTION.
  " 使用参数化 CDS View
  SELECT * FROM ZAC_FLIGHT_STATS( p_carrid = 'AA' )
    INTO @DATA(lt_stats).

  IF lt_stats IS NOT INITIAL.
    READ TABLE lt_stats INTO @DATA(ls_stats) INDEX 1.
    WRITE: / |航空公司: { ls_stats-carrid }|.
    WRITE: / |航班数量: { ls_stats-flight_count }|.
    WRITE: / |平均票价: { ls_stats-avg_price }|.
    WRITE: / |最高票价: { ls_stats-max_price }|.
    WRITE: / |总占座/总座位: { ls_stats-total_occupied }/{ ls_stats-total_seats }|.
  ELSE.
    WRITE: / '未找到统计数据'.
  ENDIF.
```

## 代码拆解要点

1. WITH PARAMETERS 的定义与使用
2. $parameters 的引用语法
3. GROUP BY 在 CDS 中的使用
4. DCL 访问控制的定义方式
5. View Entity 的语法差异

## 💡 实战经验

- **GROUP BY 必须包含所有非聚合字段**：这是 SQL 的基本规则，CDS 也不例外。SELECT 了哪些非聚合字段，GROUP BY 就要列全——否则会报语法错误
- **@UI 注解决定 Fiori 展示**：`@UI.lineItem: [ { position: 10 } ]` 控制字段在 Fiori 列表中的位置。position 数字越小越靠前——建议用 10 的倍数（10, 20, 30...），方便后续插入新字段
- **CASE WHEN 替代 IF**：CDS 中不支持 ABAP 的 IF 语句，条件判断统一用 `CASE WHEN ... THEN ... ELSE ... END`。嵌套超过三层时考虑拆成多个 CDS View
- **CDS 的性能优化**：CDS 在 HANA 上运行时，确保字段上有合适的索引。如果 CDS 查询很慢，在 HANA Studio 中查看执行计划（Explain Plan），找到瓶颈

## 课后思考

1. CDS 的聚合函数和 ABAP OpenSQL 的聚合函数写法有什么不同？
2. $session.user 在实际场景中有什么用途？
3. View Entity 在 7.55 以下版本能用吗？
