# 第3课：数据字典 —— 建一张自定义表

> 45分钟 | 阶段：基础篇

## 前置依赖

- 第1课：会用 SE11 查看表结构，了解 SFLIGHT 模型

## 问题引入

SFLIGHT 是 SAP 自带的标准表，但实际项目中你一定会需要自己的表——比如要记录航班的"备注"信息，标准表里没有这个字段。怎么在 SAP 中创建一张新表？为什么 SAP 要把"建表"搞得这么复杂——Domain、Data Element、Table 三层？

## 时间安排

| 时段 | 内容 | 时长 |
|------|------|------|
| 场景引入 | 为什么需要自定义表 / 为什么 SAP 要分三层 | 3 分钟 |
| Demo 演示 | 在 SE11 中创建 ZAC_FLIGHT_EXT 表 | 10 分钟 |
| 代码拆解 | Domain → Data Element → Table 完整流程 | 25 分钟 |
| 知识总结 | 三层结构关系图、激活顺序 | 5 分钟 |
| 课后思考 | 练习 | 2 分钟 |

## 本课目标

掌握数据字典核心对象（Domain / Data Element / Table）的创建流程，理解 SAP 数据模型的分层设计思想。

## Demo

在 SE11 中创建一张航班补充信息表（ZAC_FLIGHT_EXT），包含航班号、备注、优先级等字段，并在 SE16 中录入测试数据。

## 知识点

### 1. 数据字典三层结构
- Domain（域）：定义数据类型的技术属性（类型、长度、值范围）
- Data Element（数据元素）：连接 Domain 与 Table，添加语义描述
- Table/Structure：最终的数据容器

### 2. Domain 创建
- Short Description
- Data Type（CHAR / NUMC / CURR / QUAN 等）
- Length / Decimals
- Output Length
- Value Range（Fixed Values / Single Values / Intervals）
- Conversion Routine（如 ALPHA）

### 3. Data Element 创建
- Short Description
- Domain 分配
- Field Label（Short / Medium / Long / Heading）
- F1 Help 自动继承 Domain 的文档
- F4 Help 继承 Domain 的 Fixed Values

### 4. 透明表（Transparent Table）创建
- Delivery & Maintenance 设置
  - Data Browser/Table View Maint.：是否允许直接维护
- 字段类型选择
  - Data Element 类型
  - 预定义类型
- 主键定义
- 技术设置
  - Data Class（APPL0 / APPL1 / APPL2）
  - Size Category
  - Buffering（缓冲设置）
- 外键关系
  - Cardinality（1:1 / 1:N / N:1）
  - Check Field / Value Tab
- 索引创建

### 5. Structure 创建
- 不可持久化，仅作为数据容器
- 在程序中作为 TYPE 使用

### 6. Append Structure
- 在标准表上追加字段
- Namespace 前缀要求

### 7. 激活与检查
- 激活顺序：Domain → Data Element → Table
- 激活错误修复

## 代码

本课无 ABAP 代码，纯 SE11 操作。课件中附建表结果的 SQL 展示。

## 💡 实战经验

- **激活顺序很重要**：先激活 Domain → 再激活 Data Element → 最后激活 Table。如果反过来，Table 会因为找不到 Data Element 而激活失败
- **修改已激活的表要小心**：如果表中已经有数据，删除字段或缩短字段长度可能导致数据丢失——生产环境务必先备份数据
- **命名规范**：自定义对象以 `Z` 或 `Y` 开头是 SAP 的惯例（`Z` = 客户开发，`Y` = 合作伙伴开发），严格遵守可以避免与标准对象冲突
- **Client 依赖**：在技术设置中注意"Delivery & Maintenance"标签页，勾选"Data Browser/Table View Maint."后才能在 SE16N 中直接维护表数据

## 课后思考

1. 为什么 SAP 要把数据定义拆成 Domain → Data Element → Table 三层？有什么好处？
2. 如果两张表都需要"航空公司代码"字段，应该怎么复用？
3. 试着在 SE11 中查看 SFLIGHT 表的外键关系。
