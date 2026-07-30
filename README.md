# ABAP Course

> 从零开始的 SAP ABAP 开发实战课程，24课时带你掌握 ABAP 开发核心技能

## 🎯 课程简介

本课程面向有一定编程基础、零 SAP/ABAP 经验的开发者，通过 **Demo 驱动 + 代码拆解** 的方式，系统讲解 ABAP 开发的核心知识。

**教学模式：** 每节课先运行 Demo 看效果，再逐行拆解代码，从中提炼知识点。

## 📋 课程信息

- **总课时：** 24 课时
- **每课时：** 45 分钟
- **语言：** 中文授课，中文代码注释
- **贯穿数据：** SAP 标准 SFLIGHT 航班模型（SCARR / SPFLI / SFLIGHT / SBOOK）
- **方向：** 传统 ABAP → 新语法 → 现代开发（CDS / BTP / abapGit）

## 📚 课程目录

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
| [第8课](docs/08-formatting.md) | 数据格式化 —— 字符串、日期、货币 | 字符串操作、字符串模板 `|{ }|`、日期函数、货币格式 |
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

## 📁 仓库结构

```
abap-course/
├── .abapgit.xml          # abapGit 仓库配置
├── .gitignore            # Git 忽略规则
├── README.md             # 课程总介绍
├── docs/                  # 课文稿（Markdown）
│   ├── 01-sap-overview.md
│   ├── 02-hello-world.md
│   ├── ...
│   └── 24-capstone.md
├── src/                   # ABAP 开发对象（abapGit 标准）
│   ├── package.devc.xml   # 开发包定义
│   ├── zdemo02_hello_world.prog.abap
│   ├── zdemo02_hello_world.prog.xml
│   ├── zdemo05_sql.prog.abap
│   ├── zdemo05_sql.prog.xml
│   ├── ...                # 所有报表程序
│   ├── zfm_calc_flight_duration.fugr.*  # Function Module
│   ├── zcl_flight_query.clas.abap        # Class
│   ├── zcl_flight_query.clas.xml
│   ├── zflight_ext.tabl.xml              # 自定义表
│   ├── zcds_sflight_detail.ddls.xml      # CDS View
│   ├── zflight_msg.msag.xml              # 消息类
│   └── ...
└── outline.md             # 完整课程提纲
```

## 🔧 常用事务码速查

| 事务码 | 功能 | 对应课程 |
|--------|------|---------|
| SE38 | ABAP Editor | 第1课 |
| SE80 | Object Navigator | 第1课 |
| SE11 | Data Dictionary | 第1课 |
| SE16N | Data Browser | 第1课 |
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

- [SAP Help Portal](https://help.sap.com)
- [SAP Community](https://community.sap.com)
- [abapGit](https://abapGit.org)
- [ABAP 7.4+ 新语法官方文档](https://help.sap.com/doc/abapdocu_752_index_htm/7.52/en-US/index.htm)

## 📄 License

本课程内容仅供学习参考。
