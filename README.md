# ABAP Course

> 从零开始的 SAP ABAP 开发实战课程，24课时带你掌握 ABAP 开发核心技能

## 🎯 课程简介

本课程面向有一定编程基础、零 SAP/ABAP 经验的开发者，通过 **Demo 驱动 + 代码拆解** 的方式，系统讲解 ABAP 开发的核心知识。

**教学模式：** 每节课先运行 Demo 看效果，再逐行拆解代码，从中提炼知识点。

## 🚀 快速开始

1. 准备一套 ABAP 练习系统（推荐官方试用镜像 `sapse/abap-cloud-developer-trial`）；
2. 确认 SFLIGHT 演示数据（官方镜像默认预置，为空时跑 `SAPBC_DATA_GENERATOR`）；
3. 用 abapGit 把本仓库 Clone/Pull 到开发包 `ZABAP_COURSE`。

详细步骤见 **[第0课：环境搭建与仓库导入](docs/00-getting-started.md)**。

## 📋 课程信息

- **总课时：** 24 课时
- **每课时：** 45 分钟
- **语言：** 中文授课，中文代码注释
- **贯穿数据：** SAP 官方 Flight Data Model（SFLIGHT 航班数据模型：SCARR / SPFLI / SFLIGHT / SBOOK，SAP 官方培训同款演示模型）
- **方向：** 传统 ABAP → 新语法 → 现代开发（CDS / BTP / abapGit）
- **练习环境：** 推荐 SAP 官方试用镜像（Docker）或公司开发系统，详见[第0课](docs/00-getting-started.md)

## 📚 课程目录

**[第0课：环境搭建与仓库导入](docs/00-getting-started.md)**（准备篇，开课前完成）

### 第一阶段：基础篇（第1-6课）

| 课 | 主题 | 核心内容 |
|----|------|---------|
| [第1课](docs/01-sap-overview.md) | SAP 系统入门与开发环境 | SAP 架构、GUI 操作、常用事务码、查表技巧、F1 帮助 |
| [第2课](docs/02-hello-world.md) | Hello World 与基本数据类型 | 程序结构、数据类型、DATA 声明、WRITE 输出、`@DATA` 内联声明 |
| [第3课](docs/03-data-dictionary.md) | 数据字典 —— 建一张自定义表 | Domain、Data Element、Table、Structure、外键、索引 |
| [第4课](docs/04-internal-table.md) | 内表与结构体操作 | 内表类型、APPEND/SORT/LOOP/READ/DELETE、`FOR`/`CORRESPONDING` |
| [第5课](docs/05-open-sql.md) | Open SQL —— 增删改查 | SELECT/INSERT/UPDATE/DELETE、JOIN、聚合、`@` 占位符 |
| [第6课](docs/06-debugging.md) | ABAP 调试器 | 断点、F5/F6/F7/F8、Watchpoint、变量查看与修改 |

### 第二阶段：核心篇（第7-13课）

| 课 | 主题 | 核心内容 |
|----|------|---------|
| [第7课](docs/07-selection-screen.md) | 选择屏幕 | PARAMETERS、SELECT-OPTIONS、屏幕事件、输入校验 |
| [第8课](docs/08-formatting.md) | 数据格式化 —— 字符串、日期、货币 | 字符串操作、字符串模板 `\|{ }\|`、日期函数、货币格式 |
| [第9课](docs/09-function-module.md) | Function Module（函数模块） | Function Group、Import/Export/Changing、RFC 概念 |
| [第10课](docs/10-alv-basic.md) | ALV 报表（基础） | REUSE_ALV_GRID_DISPLAY、Field Catalog、Layout |
| [第11课](docs/11-alv-events.md) | ALV 交互事件 | USER_COMMAND、Hotspot、Top-of-Page、Drill-Down |
| [第12课](docs/12-excel.md) | Excel 导入导出 | GUI_UPLOAD/GUI_DOWNLOAD、ABAP2XLSX、数据校验 |
| [第13课](docs/13-oo-basic.md) | ABAP 面向对象编程（基础） | CLASS、METHOD、Interface、TRY/CATCH、`NEW` 操作符 |

### 第三阶段：高级篇（第14-19课）

| 课 | 主题 | 核心内容 |
|----|------|---------|
| [第14课](docs/14-bapi.md) | BAPI 调用 | BAPI Explorer、调用模式、RETURN_INFO、事务控制 |
| [第15课](docs/15-enhancement.md) | 增强（Enhancement） | User Exit、BADI、Enhancement Spot、隐式增强点 |
| [第16课](docs/16-external-api.md) | 调用外部接口（REST/SOAP/PO/CPI） | CL_HTTP_CLIENT、JSON 解析、PO/CPI 概览 |
| [第17课](docs/17-transport.md) | Transport Request（请求与传输） | Transport Request、SE09、请求释放、传输验证 |
| [第18课](docs/18-message-class.md) | 消息处理（Message Class） | SE91、消息类型、`MESSAGE` 语句、多语言支持 |
| [第19课](docs/19-new-syntax.md) | 新语法专题 | VALUE/CORRESPONDING/COND/SWITCH/FOR/REDUCE/FILTER |

### 第四阶段：现代开发篇（第20-24课）

| 课 | 主题 | 核心内容 |
|----|------|---------|
| [第20课](docs/20-cds-basic.md) | CDS View（基础） | CDS DDL 语法、JOIN、Association、参数化 View |
| [第21课](docs/21-cds-advanced.md) | CDS View（进阶） | 聚合、函数、Session 变量、DCL 访问控制、View Entity |
| [第22课](docs/22-oo-alv.md) | OO ALV（面向对象 ALV） | CL_GUI_ALV_GRID、Container、事件注册、Function ALV 对比 |
| [第23课](docs/23-btp-abapgit.md) | BTP 概览 + abapGit 代码管理 | BTP 架构、Business App Studio、abapGit Clone/Pull/Push |
| [第24课](docs/24-capstone.md) | 综合实战 —— SFLIGHT 航班管理系统 | 全流程整合：CDS → OO ALV → BAPI → 消息 → Excel → 传输 → Git |

## 📊 SFLIGHT 数据模型

```
SCARR（航空公司）──1:N──► SFLIGHT（航班）──1:N──► SBOOK（航班预订）
                             ▲
                             │
SPFLI（航线规划）────────────┘
```

| 表名 | 描述 | 关键字段 |
|------|------|---------|
| SCARR | 航空公司 | CARRID, CARRNAME, CURRCODE, URL |
| SPFLI | 航线规划 | CARRID, CONNID, CITYFROM, CITYTO, DISTANCE, DEPTIME, ARRTIME |
| SFLIGHT | 航班 | CARRID, CONNID, FLDATE, PRICE, SEATSMAX, SEATSOCC, PLANETYPE |
| SBOOK | 航班预订 | CARRID, CONNID, FLDATE, BOOKID, CUSTOMID, LOCCURAM |

> 这是 SAP 官方交付的演示数据模型（**Flight Data Model**），除上表四张核心表外还包括 SCUSTOM（客户）、SAIRPORT（机场）等；数据可用 `SAPBC_DATA_GENERATOR` 生成/重置。[官方文档与延伸资料](docs/references.md)见参考资料库。

## 📁 仓库结构

```
abap-course/
├── .abapgit.xml          # abapGit 仓库配置
├── .github/workflows/    # CI：文档站点自动部署
├── .gitignore            # Git 忽略规则
├── LICENSE               # 双许可（代码 MIT / 文档 CC BY-NC-SA）+ SAP 关系声明
├── mkdocs.yml            # 文档站点配置（Material for MkDocs，同 hello-algo 技术栈）
├── README.md             # 课程总介绍
├── docs/                  # 课文稿（Markdown，同时作为站点源文件）
│   ├── index.md                # 站点首页
│   ├── 00-getting-started.md   # 环境搭建与仓库导入
│   ├── 01-sap-overview.md
│   ├── 02-hello-world.md
│   ├── ...
│   ├── 24-capstone.md
│   └── references.md           # 参考资料库（外部链接集中登记）
├── src/                   # ABAP 开发对象（abapGit 标准）
│   ├── package.devc.xml   # 开发包定义
│   ├── zac_hello_world.prog.abap   # 报表程序源码
│   ├── zac_hello_world.prog.xml   # 对应的 abapGit 序列化文件
│   ├── ...                # 每个 demo 程序均含 .abap + .xml 成对文件
│   ├── zcl_ac_flight_query.clas.abap      # Class（源码 + .xml）
│   ├── zcl_ac_flight_service.clas.abap    # Class（源码 + .xml）
│   ├── zac_flight_ext.tabl.xml            # 自定义表
│   ├── zac_flight_detail.ddls.abap   # CDS View（源码 + .xml）
│   ├── zac_flight_stats.ddls.abap    # CDS View（源码 + .xml）
│   └── zac_flight_msg.msag.xml            # 消息类
└── outline.md             # 完整课程提纲
```

## 🏷️ 命名规范

课程所有开发对象统一带课程前缀 **`zac_`**（Z + ABAP Course），避免与系统里其他项目的 Z 对象重名；**课号不写进对象名**，课与对象的对应关系（含一对象服务多课的情况）维护在[第0课的对照矩阵](docs/00-getting-started.md#四命名规范与对象对照)中。

| 对象类型 | 命名规则 | 示例 |
|---------|---------|------|
| 报表程序 / INCLUDE | `zac_<语义名>` | `zac_sql_crud`、`zac_flight_top` |
| 类 / 接口 | `zcl_ac_` / `zif_ac_<语义名>` | `zcl_ac_flight_query` |
| 函数组 / 函数模块 | `zac_<语义名>` | `zac_flight_utils` / `zac_calc_flight_duration` |
| CDS 视图 | `zac_<语义名>` | `zac_flight_detail` |
| 表 / 消息类 | `zac_<语义名>` | `zac_flight_ext` / `zac_flight_msg` |

> **待补充对象：** 第9课函数组 `ZAC_FLIGHT_UTILS`（FM `ZAC_CALC_FLIGHT_DURATION`，参考源码见 `ref-source/`）与第24课综合实战 `ZAC_FLIGHT_MANAGER` 将随后续课程更新逐步加入，详见[第0课的对象对照矩阵](docs/00-getting-started.md#四命名规范与对象对照)。其中第24课的完整参考源码（含 Screen 100 元素清单）已先行提供在 [`capstone-source/zac_flight_manager/`](capstone-source/zac_flight_manager/README.md)，可手工建对象激活体验。

## 🖼️ 插图管理

课文插图存放在专用图片仓库 [abap-course-assets](https://github.com/Jack-Liang/abap-course-assets)（不进本仓库，避免膨胀），通过 jsDelivr CDN 引用：

- **URL 前缀**：`https://cdn.jsdelivr.net/gh/jack-liang/abap-course-assets@main/`（不直连 raw.githubusercontent.com，其大陆访问不稳）；
- **路径结构**：图片仓库内按课文编号分目录（如 `05-open-sql/`），跨课复用图放 `common/`；
- **文件命名**：英文 `kebab-case`（如 `alv-event-flow-02.png`），语义化、带序号，入库前压缩至 ≤500KB；
- **引用格式**：`![说明](https://cdn.jsdelivr.net/gh/jack-liang/abap-course-assets@main/05-open-sql/join-diagram.png)`，alt 文本必填；
- **缓存**：jsDelivr 对 `@main` 有约 12 小时缓存，更新同名图后可用 `purge.jsdelivr.net` 强制刷新；
- **优先 Mermaid**：ER 图、流程图等结构性图优先用 Mermaid 语法直接写在课文里（版本化、永不失效），截图类才走图片仓库；
- **可迁移**：URL 前缀统一约定，将来如需迁移对象存储/CDN，批量替换前缀即可。

## 🔧 常用事务码速查

| 事务码 | 功能 | 对应课程 |
|--------|------|---------|
| SE38 | ABAP Editor | 第1课 |
| SE80 | Object Navigator | 第1课 |
| SE11 | Data Dictionary | 第1课 |
| SE16 / SE16N | Data Browser（试用镜像只有 SE16） | 第1课 |
| SE37 | Function Builder | 第9课 |
| SE24 | Class Builder | 第13课 |
| SE19 | BADI Implementation | 第15课 |
| SE09/SE01 | Transport Organizer | 第17课 |
| SE91 | Message Maintenance | 第18课 |
| STMS | Transport Management | 第17课 |
| SOAMANAGER | Web Service 管理 | 第16课 |
| CMOD | Enhancement Projects | 第15课 |
| BAPI | BAPI Explorer | 第14课 |

## 📖 推荐学习资源

- 核心入口：[SAP Help Portal](https://help.sap.com) · [SAP Community](https://community.sap.com) · [abapGit](https://abapgit.org) · [ABAP Keyword Documentation（7.52）](https://help.sap.com/doc/abapdocu_752_index_htm/7.52/en-US/index.htm)
- 背景与延伸（SFLIGHT 数据模型出处、ABAP Cloud 参考场景、试用镜像等）：见 **[参考资料库 docs/references.md](docs/references.md)**，随课程更新持续登记

## 📄 License 与声明

本仓库采用双许可（详见 [LICENSE](LICENSE)）：

- **代码**（`src/` 及仓库配置）：**MIT License**——学员与企业可自由复制使用，包括商业场景；
- **文档**（`docs/`、README、outline）：**CC BY-NC-SA 4.0**（署名-非商业性使用-相同方式共享，详见[文档许可](docs/LICENSE.md)）。

> **与 SAP 的关系：** 本项目为独立的教学项目，与 SAP SE 无任何关联，亦未获得其认可或赞助。SAP、ABAP、SFLIGHT、BAPI、BTP 等名称为 SAP SE 的商标；课程引用的 SAP 标准开发对象仅出于教学演示目的，相关权利归 SAP SE 所有。
