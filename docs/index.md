# ABAP Course

> 从零开始的 SAP ABAP 开发实战课程，24 课时带你掌握 ABAP 开发核心技能。

面向有一定编程基础、零 SAP/ABAP 经验的开发者，通过 **Demo 驱动 + 代码拆解** 的方式系统讲解 ABAP 开发。贯穿数据为 SAP 官方 **Flight Data Model**（SFLIGHT 航班数据模型），方向为传统 ABAP → 新语法 → 现代开发（CDS / BTP / abapGit）。

## 🚀 快速开始

1. 准备一套 ABAP 练习系统（推荐 SAP 官方试用镜像，Docker 部署）；
2. 确认 SFLIGHT 演示数据（官方镜像默认预置）；
3. 用 abapGit 把课程仓库 Clone/Pull 到开发包 `ZABAP_COURSE`。

详细步骤见 [第0课：环境搭建与仓库导入](00-getting-started.md)。

## 📚 课程目录

### 准备篇

| 课 | 主题 |
|----|------|
| [第0课](00-getting-started.md) | 环境搭建与仓库导入 |

### 第一阶段：基础篇（第1-6课）

| 课 | 主题 |
|----|------|
| [第1课](01-sap-overview.md) | SAP 系统入门与开发环境 |
| [第2课](02-hello-world.md) | Hello World 与基本数据类型 |
| [第3课](03-data-dictionary.md) | 数据字典——建一张自定义表 |
| [第4课](04-internal-table.md) | 内表与结构体操作 |
| [第5课](05-open-sql.md) | Open SQL——增删改查 |
| [第6课](06-debugging.md) | ABAP 调试器 |

### 第二阶段：核心篇（第7-13课）

| 课 | 主题 |
|----|------|
| [第7课](07-selection-screen.md) | 选择屏幕 |
| [第8课](08-formatting.md) | 数据格式化 |
| [第9课](09-function-module.md) | Function Module（函数模块） |
| [第10课](10-alv-basic.md) | ALV 报表（基础） |
| [第11课](11-alv-events.md) | ALV 交互事件 |
| [第12课](12-excel.md) | Excel 导入导出 |
| [第13课](13-oo-basic.md) | ABAP 面向对象编程（基础） |

### 第三阶段：高级篇（第14-19课）

| 课 | 主题 |
|----|------|
| [第14课](14-bapi.md) | BAPI 调用 |
| [第15课](15-enhancement.md) | 增强（Enhancement） |
| [第16课](16-external-api.md) | 调用外部接口（REST/SOAP/PO/CPI） |
| [第17课](17-transport.md) | Transport Request（请求与传输） |
| [第18课](18-message-class.md) | 消息处理（Message Class） |
| [第19课](19-new-syntax.md) | 新语法专题 |

### 第四阶段：现代开发篇（第20-24课）

| 课 | 主题 |
|----|------|
| [第20课](20-cds-basic.md) | CDS View（基础） |
| [第21课](21-cds-advanced.md) | CDS View（进阶） |
| [第22课](22-oo-alv.md) | OO ALV（面向对象 ALV） |
| [第23课](23-btp-abapgit.md) | BTP 概览 + abapGit 代码管理 |
| [第24课](24-capstone.md) | 综合实战——SFLIGHT 航班管理系统 |

### 附录

- [参考资料库](references.md)——外部链接集中登记，随课程更新持续扩充

## 📁 源码与文档

课程代码（`zac_*` 开发对象）与课文稿都在 [GitHub 仓库](https://github.com/Jack-Liang/abap-course) 中维护，命名规范与课↔对象对照矩阵见第0课第四节。
