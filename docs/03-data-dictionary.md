---
status: beta
---

# 第3课：数据字典 —— 建一张自定义表

> 45分钟 | 阶段：基础篇 | 建议边读边做

## 前置依赖

- [第1课](01-sap-overview.md)：会用 SE11 查看表结构，了解 SFLIGHT 模型。

## 问题引入

SFLIGHT 是 SAP 自带的标准表，但实际项目中你一定需要自己的表——比如给航班记一个"备注/优先级"，标准表里没有这个字段，而且**标准表永远不许改**。怎么建自己的表？为什么 SAP 把"建表"拆成 Domain → Data Element → Table 三层，而不是一条 `CREATE TABLE`？本课亲手建出课程的第一张自定义表 `ZAC_FLIGHT_EXT`。

## 时间安排

| 时段 | 内容 | 时长 |
|------|------|------|
| 场景引入 | 为什么分三层 | 3 分钟 |
| Demo 跟做 | 建表 + 录数据 + 验证 | 12 分钟 |
| 知识讲解 | 三层结构、外键、索引、技术设置 | 23 分钟 |
| 知识总结 | 激活顺序与关系图 | 5 分钟 |
| 课后思考 | 练习 | 2 分钟 |

## 本课目标

完成本课你将能够：

- 说清 Domain / Data Element / Table 三层各自的职责；
- 在 SE11 中独立完成"建域 → 建数据元素 → 建表 → 激活"全流程；
- 为表定义主键、外键和索引，配置技术设置；
- 在 SE16 中给自己建的表录入数据；
- 理解 Structure 与 Append Structure 的用途。

## Demo：创建 ZAC_FLIGHT_EXT（分步跟做）

> 表已随课程仓库下发，可直接在 SE11 打开 `ZAC_FLIGHT_EXT` 对照每一步的结果；更建议自己按下述流程建一遍（可用自己的表名前缀）。

**目标：** 一张航班补充信息表——按"公司+航线+日期"定位一个航班，挂备注和优先级两个字段。

| 字段 | 类型 | 键 | 说明 |
|------|------|----|------|
| CARRID | `s_carr_id` | ✔ | 航空公司代码 |
| CONNID | `s_conn_id` | ✔ | 航线编号 |
| FLDATE | `s_date` | ✔ | 航班日期 |
| REMARK | CHAR(100) | | 备注 |
| PRIORITY | CHAR(1) | | 优先级 |

<!-- 配图（待截图后启用）：![SE11 表 ZAC_FLIGHT_EXT 字段列表](https://cdn.jsdelivr.net/gh/jack-liang/abap-course-assets@main/03-data-dictionary/se11-zac-flight-ext.png) -->

### 步骤 1：建 Domain（优先级字段用）

1. SE11 → 选 **Domain** → 名称 `zac_doms_priority` → Create；
2. Short text：`航班优先级`；Data Type `CHAR`，Length `1`；
3. **Value Range → Fixed Values**：`1` 高、`2` 中、`3` 低——这一步同时种下了未来 F4 帮助的候选值；
4. `Ctrl+S` 保存（选课程包）→ **激活**。

### 步骤 2：建 Data Element

1. SE11 → **Data element** → 名称 `zac_de_priority` → Create；
2. Short text：`航班优先级`；**Domain** 字段填 `zac_doms_priority`；
3. **Field Label** 页签：Short `优先级`、Medium `航班优先级`——这些标签将来直接出现在 ALV 列头和屏幕上；
4. 保存 → 激活。

> CARRID 等三个键字段**不需要自建**——直接复用标准数据元素 `S_CARR_ID / S_CONN_ID / S_DATE`，这正是三层的复用红利。

### 步骤 3：建透明表

1. SE11 → **Database table** → 名称 `zac_flight_ext` → Create；
2. Short Description：`航班补充信息表`；Delivery Class 保持 `A`；
3. **Fields 页签**逐行录入上表的五个字段：

| Field | Key | Data Element / Type | ... |
|-------|-----|--------------------|----|
| CLIENT | ✔ | `mandt`（**首字段必填，系统自动要求**） |
| CARRID | ✔ | `s_carr_id` |
| CONNID | ✔ | `s_conn_id` |
| FLDATE | ✔ | `s_date` |
| REMARK | | 直接填预定义类型 CHAR，Length 100 |
| PRIORITY | | `zac_de_priority` |

4. **Technical Settings**（菜单：Extras → ...）：Data Class `APPL0`（主数据/小表）、Size Category `0`（最小量级）、Buffering 不开；
5. 保存 → 激活。

**你会看到什么：** 激活后 SE16 已经能查这张表——一张物理表在数据库里诞生了。

### 步骤 4：录入数据并验证

1. SE16 查 `ZAC_FLIGHT_EXT`——空表；
2. 菜单 **Table Entries → Personalize for editing / Maintain entries**（或用 SM30 配视图维护）插入几行：`AA / 0017 / 2026-07-30 / 金牌客户包机 / 1`；
3. 再查一次，数据在。

<!-- 配图（待截图后启用）：![SE16 维护 ZAC_FLIGHT_EXT 数据](https://cdn.jsdelivr.net/gh/jack-liang/abap-course-assets@main/03-data-dictionary/se16-maintain-ext.png) -->

## 知识点

### 1. 为什么要三层

```mermaid
flowchart LR
    T["Table 字段<br/>（谁、在哪儿用）"] --> DE["Data Element<br/>语义：标签、F1 文档"]
    DE --> D["Domain<br/>技术：类型、长度、值域"]
    D -.-> DB[(数据库表结构)]
```

| 层 | 管什么 | 改动影响 |
|----|--------|---------|
| Domain | 类型、长度、小数位、**固定值域**、转换例程 | 所有引用它的数据元素 |
| Data Element | 业务语义、字段标签（4 种长度）、F1 文档 | 所有引用它的表字段 |
| Table | 字段编排、主键、外键、索引、技术设置 | 数据库对象本身 |

**复用是灵魂：** `S_CARR_ID` 这个数据元素被几十张标准表引用——"航空公司代码"的定义全系统只有一处，改一处生效。这就是"两张表都要航空公司代码字段怎么办"的标准答案：**引用同一个 Data Element**。

### 2. Domain 细节

- **Fixed Values**（固定值）：域级枚举，自动成为 F4 帮助候选并参与校验；
- **Conversion Routine**（转换例程）：最常见的是 `ALPHA`——屏幕输入 `17` 存库自动补成 `0017`（NUMC 补零），出库再剥掉。标准单据号字段几乎都带它；
- Output Length：输出长度，一般自动推导。

### 3. Data Element 细节

- Field Label 四档（Short/Medium/Long/Heading）会被 ALV、屏幕、打印自动取用——**认真填，后面省无数手动改列头的活**；
- Data Element 也可以不经 Domain 直接用预定义类型（像上表 REMARK 那样）——原型期可以，正式对象建议走 Domain（值域和语义有归属）。

### 4. 表的关键配置

- **Client 字段（MANDT）**：SAP 三层里"逻辑租户"隔离的物理实现——每张应用表第一键都是它，程序读写时系统自动带当前 Client（第1课 Client 概念的落地）；
- **Delivery Class**：`A` 应用表（业务数据）最常见；`C` 定制表；`S` 系统表；
- **Data Browser/Table View Maint.**（Delivery & Maintenance 页签）：决定能否在 SE16 直接维护数据——练习库开 `Display/Maintenance Allowed` 方便，生产慎开；
- **Data Class**：`APPL0` 主数据、`APPL1` 事务数据（大）、`APPL2` 组织与定制数据——影响数据库存储优化；
- **Size Category**：量级预估（0 = 千行以内 …），影响空间预分配；
- **Buffering**：单条/全表缓冲——配置表开了很香，交易大表千万别开（第5课性能话题会回收）。

### 5. 外键与索引

**外键（Foreign Key）**：把字段"合同化"地挂在另一张表上。给 ZAC_FLIGHT_EXT 的 CARRID 建外键 → SCARR：

1. 选中 CARRID 字段 → **Foreign Keys** 按钮；
2. 填 Check Table `SCARR`，Cardinality `N:1`（本表 N 行对应主表 1 行）；
3. 确认后，录入不存在的航空公司代码将被数据库字典校验拒绝。

**索引**：主键之外给高频查询字段建的"目录"。原则：

- 给 SELECT 高频 WHERE 字段建，一张表 4~5 个以内；
- 每个索引都有写放大代价——不是越多越好；
- 第5课讲 SQL 性能时回头看这张表的索引设计。

### 6. Structure 与 Append Structure

| 对象 | 用途 | 持久化 |
|------|------|--------|
| Structure | 程序里的数据容器（`TYPE ...` 用）、接口结构、Append 源 | ❌ 无数据库表 |
| Append Structure | 给**标准表**追加自定义字段的正规途径 | ✅ 并入被附加表 |

标准表不能改，但 SAP 在很多标准表上预留了 Append 能力——追加结构里的字段带上你的 `Z`/`Y` 前缀，升级不丢。这是"不改标准代码"原则（第15课增强）在数据层的体现。

### 7. 激活顺序与错误处理

**自底向上激活：Domain → Data Element → Table。** 反过来会因为引用未激活对象而失败。激活报错时看底部错误列表双击跳转；常用工具：SE11 → Utilities → **Database Object → Check/Activate** 重建数据库对象。

## 代码

本课无 ABAP 代码。建好的表在第12课（Excel 导入）和第15课（增强）会作为主角回归。

## 💡 实战经验

!!! tip "改已激活的表要过脑子"

    表里有数据后，删字段、缩长度、改类型都可能**触发数据转换甚至丢失**。SE11 激活时会弹警告——生产环境务必先 SE16 导出备份，再动结构。

!!! tip "能复用就别自建"

    建字段前先搜有没有现成 Data Element（SE11 → Data element → F4 搜索描述）。SAP 标准库几万个数据元素，`ZAC` 开头再造轮子既low又难维护。

!!! tip "CHAR(1) 标志位是重灾区"

    `'X'/space` 之外的标志位值，请像本课 PRIORITY 那样建 Domain + Fixed Values——否则两年后没人记得 `T` 是什么意思。

## 📖 延伸阅读

- [Flight Model 官方文档](https://help.sap.com/docs/SAP_NETWEAVER_700/12a2d87e6c531014bec0e63ea0208c21/cf21f304446011d189700000e8322d00.html)——看看 SAP 自己怎么组织这套表；
- [ABAP Keyword Documentation](https://help.sap.com/doc/abapdocu_752_index_htm/7.52/en-US/index.htm)——DDIC 对象部分。

## 课后思考

> 把你的回答写在**页面底部评论区**，注明题号，一起讨论。

1. Domain → Data Element → Table 三层拆分的好处是什么？如果只有一层（直接建表字段）会丢掉什么？
2. 两张表都需要"航空公司代码"字段，正确的复用姿势是什么？
3. 打开 SE11 查看 SFLIGHT 的外键：它挂在哪些表上？Cardinality 各是多少？
4. 什么场景下你会给表开 Buffering？什么场景绝对不开？

---

下一课：[第4课：内表与结构体操作](04-internal-table.md)
