---
status: beta
---

# 第20课：CDS View（基础）—— 数据模型新范式

> 45分钟 | 阶段：现代开发篇 | 建议边读边做

## 前置依赖

- [第3课](03-data-dictionary.md)：DDIC 三层（Domain/Data Element/Table）；
- [第5课](05-open-sql.md)：JOIN 与聚合——CDS 是它们的"搬家"。

## 问题引入

三表 JOIN 的 SQL 散在每个报表里：改一次查询逻辑，五个程序跟着改。**CDS（Core Data Services）**把查询逻辑提升为**独立的 DDIC 数据对象**：定义一次，处处 SELECT；注解驱动元数据；在数据库层执行；还是 Fiori/RAP 的地基。本课把第5课手写的三表 JOIN 变成一个课程资产 `zac_flight_detail`。

!!! note "对象状态"

    CDS 视图 `zac_flight_detail` 与消费端 demo 程序 `zac_cds_basic` 均已随仓库下发，Pull 后可直接运行。

## 时间安排

| 时段 | 内容 | 时长 |
|------|------|------|
| 场景引入 | SQL 嵌在程序里的痛 → 数据模型独立 | 3 分钟 |
| Demo 跟做 | 打开课程 CDS → ADT 里看数据预览 → 程序消费 | 10 分钟 |
| 代码拆解 | DDL 结构 / 注解 / Association / 消费方式 | 24 分钟 |
| 知识总结 | CDS vs Open SQL 对比 | 5 分钟 |
| 课后思考 | 练习 | 3 分钟 |

## 本课目标

完成本课你将能够：

- 说清 CDS 是什么、和 DDIC View / Open SQL 的关系；
- 读懂并写出三表 JOIN 的 `define view entity`；
- 理解头部注解（EndUserText / AccessControl / Metadata）的作用；
- 在 ABAP 程序里像查表一样 SELECT CDS 视图；
- 用 ADT 的 Data Preview 调试 CDS。

## Demo：从 JOIN 到资产（分步跟做）

### 步骤 1：看课程自带的 CDS

仓库 `src/zac_flight_detail.ddls.asddls`（ADT 或 SE11 → DDL Sources 可见）：

```sql
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
    sflight.planetype,
    scarr.carrname,
    scarr.currcode,
    spfli.cityfrom,
    spfli.cityto,
    spfli.distance,
    spfli.deptime,
    spfli.arrtime
}
```

这就是第5课 Demo 第 3 段的那个三表 JOIN——现在它是**一个对象**：有名字、有描述、可激活、可传输（第17课的货物）、可被任何程序消费。

### 步骤 2：ADT 数据预览

ADT（Eclipse 装 ABAP Development Tools，连接试用镜像）打开 `ZAC_FLIGHT_DETAIL` → 右键 **Open with → Data Preview** → 直接看到三表拼好的数据——**不写一行 ABAP 就能调试数据层**，这是 CDS + ADT 的标志性体验。

### 步骤 3：程序消费

SE38 运行 `zac_cds_basic`（或对照源码自建一遍）：

```abap
REPORT zac_cds_basic.

START-OF-SELECTION.
  " CDS 视图当"表"用——JOIN 已经住在视图里
  SELECT * FROM zac_flight_detail
    INTO TABLE @DATA(lt_flights)
    UP TO 20 ROWS.

  LOOP AT lt_flights INTO DATA(ls).
    WRITE: / |{ ls-carrname } { ls-cityfrom } → { ls-cityto } { ls-price } { ls-currcode }|.
  ENDLOOP.

  WRITE: / |共 { lines( lt_flights ) } 条|.
```

**你会看到什么：** 20 行"公司名 起飞城 → 到达城 票价 币种"——程序里再也没有一行 JOIN。

## 知识点

### 1. CDS 在 SAP 数据层的坐标

| 对象 | 时代 | 特点 |
|------|------|------|
| SE11 DDIC View | 经典 | 纯数据库视图，无注解无语义 |
| **CDS View（DDLS）** | 7.40 | 注解驱动、Association、参数化；底层仍生成 SQL 视图 |
| **CDS View Entity** | 7.55+（本课） | 直接的 DDIC 实体，**无中间 SQL 视图**，更多函数支持——现代默认选择 |

课程用 **View Entity** 写法（`define view entity`）。老项目里 `define view` + `@AbapCatalog.sqlViewName: 'ZV_...'`（要额外给底层 SQL 视图起名）满地都是——看到能认出即可。

### 2. DDL 解剖

```sql
@注解…                          " ① 头部注解（元数据）
define view entity ZAC_…        " ② 名字（对象，走命名规范 zac_）
  as select from sflight        " ③ 主数据源
    inner join scarr on …       " ④ JOIN（语法同 Open SQL）
{                               " ⑤ 字段清单（投影）
    key sflight.carrid,         " key = 语义主键（消费方/关联用）
    …
}
```

- WHERE / GROUP BY / 聚合 / 表达式（`concat_with`、算术）都可用——第5课的 SQL 能力这里几乎全保留；
- 字段直接继承 DDIC 数据元素语义（标签、币种引用）——第3课"能引用就不手填"在 CDS 继续生效。

### 3. 注解：CDS 的灵魂

| 注解 | 作用 |
|------|------|
| `@EndUserText.label` | 对象描述（SE11/ADT 里看到的名字） |
| `@AccessControl.authorizationCheck` | DCL 访问控制开关（#CHECK = 有 DCL 就执行，第21课） |
| `@Metadata.ignorePropagatedAnnotations` | 元数据传递控制（本课了解即可） |
| `@Analytics.dataCategory` / `@UI.*` / `@OData.*` | 分析场景 / Fiori 界面 / OData 发布——CDS 通往应用的桥 |

注解让"数据模型"自带"如何被使用"的说明——这是 CDS 区别于普通视图的本质。

### 4. Association：把 JOIN 变成可沿的路径

```sql
define view entity ZAC_X
  as select from sflight
  association [1..1] to scarr as _carrier
    on $projection.carrid = scarr.carrid
{
  key sflight.carrid,
  sflight.price,
  _carrier                          " 暴露关联
}
```

- Association 是**声明式的关系**：默认不产生 JOIN 开销，消费时 `SELECT ... FROM zac_x { _carrier.carrname }` 才"沿路径展开"；
- 对比第5课"每次 JOIN 都写 ON"：关联定义一次，路径随处引用（`_carrier.url`）——数据模型的"合同"更完整；
- 第24课综合实战的取数视图会用到它。

### 5. 消费方式

```abap
SELECT * FROM zac_flight_detail INTO TABLE @DATA(lt).        " 当表查
SELECT carrid, price FROM zac_flight_detail WHERE ...        " 投影+条件照常
SELECT * FROM zac_flight_stats( p_carrid = @lv_carrid ) ... " 参数化视图（第21课）
```

注意：CDS 本体不支持 `UP TO n ROWS` 进视图定义——限量在消费端 SELECT 写（Demo 步骤 3 正是这样）。

## 💡 实战经验

!!! tip "JOIN 逻辑进 CDS，展示逻辑留 ABAP"

    分层直觉：数据怎么拼（JOIN/语义/权限）→ CDS；怎么呈现（ALV/格式化）→ ABAP。三层代码各说各的话，改动互不牵连。

!!! tip "Data Preview 先行"

    写消费程序前先 Data Preview 看一眼视图结果——数据层对了再往上搭，比在 ALV 里猜数据哪来的快十倍。

!!! warning "View Entity 与老 CDS 别混写"

    `define view entity` **不要**再写 `@AbapCatalog.sqlViewName`（那是老 `define view` 的专属）；两者混写会激活报错。新项目一律 View Entity。

## 📖 延伸阅读

- [ABAP Flight Reference Scenario（/DMO/）](https://help.sap.com/docs/abap-cloud/abap-rap/abap-flight-reference-scenario)——SAP 官方 CDS/RAP 参考实现（课程模型的现代版）；
- [ABAP Keyword Documentation](https://help.sap.com/doc/abapdocu_752_index_htm/7.52/en-US/index.htm)——ABAP CDS 章节。

## 课后思考

> 把你的回答写在**页面底部评论区**，注明题号，一起讨论。

1. CDS View Entity 与 SE11 经典 DDIC View 的三个本质区别？
2. Association 与 JOIN 的核心差异是什么？什么时候 Association 更划算？
3. 动手：给 `zac_flight_detail` 的消费程序加"只看经济舱满座航班"的 WHERE（提示：上座率可由 seatsocc/seatsmax 算）——贴出你的 SELECT。
4. 头部 `@AccessControl.authorizationCheck: #CHECK` 在等什么？答案下节课揭晓——先猜猜它和权限有什么关系。

---

下一课：[第21课：CDS View（进阶）](21-cds-advanced.md)
