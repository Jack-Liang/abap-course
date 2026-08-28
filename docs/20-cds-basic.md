---
status: draft
---

# 第20课：CDS View（基础）—— 数据模型新范式

> 45分钟 | 阶段：现代开发篇

## 前置依赖

- 第3课：了解数据字典（Domain / Data Element / Table）
- 第5课：了解 Open SQL（理解 JOIN 和聚合）

## 问题引入

你的 SQL 写在 ABAP 程序里——每次修改查询都要改程序、测试、传输。能不能把"查询逻辑"从程序中分离出来，变成一个独立的"数据对象"——多个程序共享同一个查询，DBA 可以在数据库层面优化？CDS View 就是 SAP 的答案。

## 时间安排

| 时段 | 内容 | 时长 |
|------|------|------|
| 场景引入 | SQL 嵌在程序里的问题 / 数据模型与业务逻辑分离 | 3 分钟 |
| Demo 演示 | 创建 CDS View 查询航班详细信息 | 5 分钟 |
| 代码拆解 | CDS 语法结构、JOIN、参数化 CDS、字段映射、激活与测试 | 28 分钟 |
| 知识总结 | CDS vs Open SQL 对比表、ADT 操作要点 | 6 分钟 |
| 课后思考 | 练习 | 3 分钟 |

## 本课目标

掌握 CDS View 的基本创建和使用方法，理解 CDS 与 Open SQL 的区别和优势。

## Demo

创建一个 CDS View（ZAC_FLIGHT_DETAIL），关联 SFLIGHT、SCARR、SPFLI 三张表，在 ABAP 程序中通过 Open SQL 访问该 CDS。

## 知识点

### 1. CDS 概述
- Core Data Services
- CDS vs ABAP DDIC View
- 为什么用 CDS（性能、可复用、注解驱动、Fiori 基础）

### 2. ADT（ABAP Development Tools）
- Eclipse 安装 ABAP 插件
- 连接 SAP 系统
- ADT vs SE80

### 3. CDS DDL 语法
- DEFINE VIEW zcds_xxx AS SELECT FROM ... { ... }
- 字段选择与别名
- 多表 JOIN（内连接）
- WHERE 条件
- GROUP BY / HAVING / 聚合
- 参数化 View：WITH PARAMETERS

### 4. Association（关联）
- JOIN vs Association 的区别
- Association 语法
- $projection 投影
- 路径表达式：_spfli.cityfrom

### 5. @Annotation（注解）
- @AbapCatalog.sqlViewName
- @AbapCatalog.compiler.compareFilter
- @AccessControl.authorizationCheck
- @EndUserText.label
- @UI 系列注解（简要介绍）

### 6. 在 ABAP 程序中使用 CDS View
- SELECT * FROM zcds_xxx INTO TABLE @DATA(lt)
- SELECT * FROM zcds_xxx( p_carrid = 'AA' ) 参数传递

## Demo 代码

CDS DDL 定义：
```sql
@AbapCatalog.sqlViewName: 'ZV_SFLIGHT_DETAIL'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '航班详情视图'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZAC_FLIGHT_DETAIL
  as select from sflight
    inner join scarr on sflight.carrid = scarr.carrid
    inner join spfli on sflight.carrid = spfli.carrid
                      and sflight.connid = spfli.connid
{
    key sflight.carrid,
    key sflight.connid,
    key sflight.fldate,
    sflight.price,
    sflight.seatsmax,
    sflight.seatsocc,
    scarr.carrname,
    scarr.currcode,
    spfli.cityfrom,
    spfli.cityto,
    spfli.distance,
    spfli.deptime,
    spfli.arrtime
}
```

ABAP 程序使用 CDS：
```abap
REPORT zac_cds_basic.

START-OF-SELECTION.
  " 使用 CDS View 查询数据
  SELECT * FROM ZAC_FLIGHT_DETAIL
    INTO TABLE @DATA(lt_flights)
    UP TO 20 ROWS.

  LOOP AT lt_flights INTO @DATA(ls).
    WRITE: / |{ ls-carrname } | { ls-cityfrom } → { ls-cityto } | { ls-price } { ls-currcode }|.
  ENDLOOP.

  WRITE: / |共 { lines( lt_flights ) } 条|.
```

## 代码拆解要点

1. CDS DDL 的基本语法结构
2. @Annotation 的作用与常用注解
3. CDS 中的 JOIN vs ABAP OpenSQL 的 JOIN
4. CDS View 在 ABAP 程序中的使用方式
5. 参数化 CDS 的定义与调用

## 💡 实战经验

- **CDS 在数据库层执行**：CDS View 的 JOIN 和聚合是在 HANA 数据库层面完成的（不是 ABAP 应用层），性能通常比等价的 ABAP Open SQL 好——特别是涉及大数据量时
- **CDS 不支持所有 Open SQL 语法**：CDS 目前不支持 `UP TO N ROWS`、`PACKAGE SIZE`、`CLIENT SPECIFIED` 等。复杂查询逻辑仍需在 ABAP 层处理
- **参数化 CDS 的性能**：带参数的 CDS（WITH PARAMETERS）每次调用会生成新的 SQL 语句。高频调用场景要注意数据库的 SQL 缓存命中率
- **ADT 是 CDS 开发的推荐工具**：虽然可以在 SE80 中创建 CDS，但 ADT（Eclipse-based ABAP Development Tools）提供语法高亮、代码补全、实时错误检查——体验好很多

## 课后思考

1. CDS View 和 SE11 中的 DDIC View 有什么区别？
2. 为什么要用 Association 而不是直接 JOIN？
3. 尝试创建一个包含聚合的 CDS View（按航空公司统计航班数和平均票价）。
