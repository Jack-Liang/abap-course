# 参考资料库

> ABAP Course 的外部资料索引。课程基于 **SAP 官方 Flight Data Model（SFLIGHT 航班数据模型）** 与传统 ABAP → 新语法 → 现代开发（CDS / BTP / abapGit）的主线展开，本文件集中登记全部外部参考资料。
>
> **维护规则：**
> - 新资料**一律先登记到本文件**（按下方分类归位，标注适用课次）；
> - 课文内可以贴同一链接保持就近可点，但每个链接只在资料库登记一次；
> - 链接失效集中修复本文件即可；README 的"推荐学习资源"只保留核心入口并指向这里。

## 一、通用资源

| 主题 | 链接 | 适用课次 | 说明 |
|------|------|---------|------|
| SAP Help Portal | <https://help.sap.com> | 全部 | SAP 官方文档总入口 |
| SAP Community | <https://community.sap.com> | 全部 | 官方社区，问答与博客（试用系统问题加 #abap_trial 标签） |
| ABAP Keyword Documentation（7.52） | <https://help.sap.com/doc/abapdocu_752_index_htm/7.52/en-US/index.htm> | 第2-19课 | ABAP 语句与新旧语法权威参考 |
| abapGit 官网 | <https://abapgit.org> | 第0/23课 | 独立版程序下载（`zabapgit_standalone`）、文档 |
| abapGit GitHub | <https://github.com/abapGit/abapGit> | 第23课 | abapGit 上游仓库与 Releases |

## 二、环境与工具

| 主题 | 链接 | 适用课次 | 说明 |
|------|------|---------|------|
| ABAP Cloud Developer Trial（Docker） | <https://hub.docker.com/r/sapse/abap-cloud-developer-trial> | 第0课 | 官方免费试用系统，课程推荐的练习环境；镜像自带 `ZABAPGIT_STANDALONE` 与 SFLIGHT 预置数据 |
| ABAP Cloud Developer Trial 2025 官方公告 | <https://community.sap.com/t5/technology-blog-posts-by-sap/abap-cloud-developer-trial-2025-available-now/ba-p/14376009> | 第0课 | 产品官方说明与历年版本公告（2022/2023/2025，按 ABAP Platform 年份发版）；常见问题见 SAP-docs 的 abap-platform-trial-image 仓库 FAQ |
| SAP GUI 家族与版本 | <https://pages.community.sap.com/topics/gui/family> | 第0课 | Windows / Java 版 GUI 的版本、系统要求与发布说明入口（Java 版 7.80 起原生支持 Apple Silicon） |
| SAP Support Portal 软件下载 | <https://support.sap.com/en/my-support/software-downloads.html> | 第0课 | 桌面版 SAP GUI 的下载位置；需 S-user 授权，无渠道时用浏览器版 SAP GUI for HTML（见第0课） |
| SAP 开发者许可证（minisap） | <https://www.sap.com/minisap> | 第0课 | 试用系统 ABAP 许可到期后（约 3 个月）在此续期 |
| SAP BTP Trial | <https://www.sap.com/products/technology-platform/trial.html> | 第23课 | BTP 试用注册；注意其 ABAP 环境为 ABAP Cloud，仅部分课程适用（见第0课兼容性说明） |

## 三、背景资料

| 主题 | 链接 | 适用课次 | 说明 |
|------|------|---------|------|
| Flight Model（SFLIGHT 数据模型） | <https://help.sap.com/docs/SAP_NETWEAVER_700/12a2d87e6c531014bec0e63ea0208c21/cf21f304446011d189700000e8322d00.html> | 第1/3课起全程 | 课程贯穿数据的官方出处；完整表族含 SCARR / SPFLI / SFLIGHT / SBOOK / SCUSTOM / SAIRPORT |
| What Is SFLIGHT...（SAP Press 博客） | <https://blog.sap-press.com/what-is-sflight-and-the-flight-and-booking-data-model-for-abap> | 背景 | SFLIGHT 与 Flight Data Model 的科普文章 |
| ABAP Flight Reference Scenario（/DMO/） | <https://help.sap.com/docs/abap-cloud/abap-rap/abap-flight-reference-scenario> | 第20-23课 | Flight 数据模型在 ABAP Cloud / RAP 的现代传承（`/DMO/` 命名空间） |
| abap-platform-refscen-flight | <https://github.com/SAP-samples/abap-platform-refscen-flight> | 第20-23课 | 上述场景的官方示例仓库（含数据生成类） |

## 四、按课延伸（随课程更新逐课补充）

按课次登记各课"📖 延伸阅读"小节中的外部链接；课内交叉引用（如指向其他课文或仓库对象）不在此重复登记。

### 第0课：环境搭建与仓库导入

（无——本课未设延伸阅读小节；环境类外链见"二、环境与工具"）

### 第1课：SAP 系统入门与开发环境

- [Flight Model——本课程贯穿数据的官方出处](https://help.sap.com/docs/SAP_NETWEAVER_700/12a2d87e6c531014bec0e63ea0208c21/cf21f304446011d189700000e8322d00.html)
- [SAP Help Portal](https://help.sap.com) / [SAP Community](https://community.sap.com)

### 第2课：Hello World 与基本数据类型

- [ABAP Keyword Documentation](https://help.sap.com/doc/abapdocu_752_index_htm/7.52/en-US/index.htm)（`DATA`、`WRITE`、`SELECT SINGLE` 条目）

### 第3课：数据字典 —— 建一张自定义表

- [Flight Model 官方文档](https://help.sap.com/docs/SAP_NETWEAVER_700/12a2d87e6c531014bec0e63ea0208c21/cf21f304446011d189700000e8322d00.html)
- [ABAP Keyword Documentation](https://help.sap.com/doc/abapdocu_752_index_htm/7.52/en-US/index.htm)（DDIC 对象部分）

### 第4课：内表与结构体操作

- [ABAP Keyword Documentation](https://help.sap.com/doc/abapdocu_752_index_htm/7.52/en-US/index.htm)（`VALUE / FOR / REDUCE / CORRESPONDING` 各条目）

### 第5课：Open SQL —— 增删改查

- [ABAP Keyword Documentation](https://help.sap.com/doc/abapdocu_752_index_htm/7.52/en-US/index.htm)（`SELECT` / `INSERT` / `UPDATE` / `COMMIT` 条目）

### 第6课：ABAP 调试器

- [ABAP Keyword Documentation](https://help.sap.com/doc/abapdocu_752_index_htm/7.52/en-US/index.htm)（`BREAK-POINT` 条目与调试器文档链接）

### 第7课：选择屏幕

- [ABAP Keyword Documentation](https://help.sap.com/doc/abapdocu_752_index_htm/7.52/en-US/index.htm)（`PARAMETERS` / `SELECT-OPTIONS` / `SELECTION-SCREEN` 条目）

### 第8课：数据格式化 —— 字符串、日期、货币

- [ABAP Keyword Documentation](https://help.sap.com/doc/abapdocu_752_index_htm/7.52/en-US/index.htm)（String Templates / String Functions 章节，内置函数全表）

### 第9课：Function Module（函数模块）

- [ABAP Keyword Documentation](https://help.sap.com/doc/abapdocu_752_index_htm/7.52/en-US/index.htm)（`FUNCTION` / `CALL FUNCTION` / `RAISE` 条目）

### 第10课：ALV 报表（基础）

- [ABAP Keyword Documentation](https://help.sap.com/doc/abapdocu_752_index_htm/7.52/en-US/index.htm)（REUSE_ALV_* / SALV 类族文档）

### 第11课：ALV 交互事件

- [ABAP Keyword Documentation](https://help.sap.com/doc/abapdocu_752_index_htm/7.52/en-US/index.htm)（`slis_selfield` 结构与 REUSE 回调文档）

### 第12课：Excel 导入导出

- [ABAP Keyword Documentation](https://help.sap.com/doc/abapdocu_752_index_htm/7.52/en-US/index.htm)（`GUI_DOWNLOAD` / `GUI_UPLOAD`）
- [abapGit 官网](https://abapgit.org)（ABAP2XLSX 安装与文档）

### 第13课：ABAP 面向对象编程（基础）

- [ABAP Keyword Documentation](https://help.sap.com/doc/abapdocu_752_index_htm/7.52/en-US/index.htm)（ABAP Objects 章节：CLASS / INTERFACE / RAISE）

### 第14课：BAPI 调用 —— SAP 标准业务接口

- [ABAP Keyword Documentation](https://help.sap.com/doc/abapdocu_752_index_htm/7.52/en-US/index.htm)（BAPI 与 `BAPI_TRANSACTION_COMMIT` 条目）
- [SAP Help Portal](https://help.sap.com)（搜 "BAPI"——各业务模块的 BAPI 清单）

### 第15课：增强（Enhancement）—— 不改标准代码扩展功能

- [ABAP Keyword Documentation](https://help.sap.com/doc/abapdocu_752_index_htm/7.52/en-US/index.htm)（Enhancement Framework 章节）
- [SAP Help Portal](https://help.sap.com)（搜各业务模块的 "Customer Exit" 清单）

### 第16课：调用外部接口 —— REST / SOAP / PO / CPI

- [ABAP Keyword Documentation](https://help.sap.com/doc/abapdocu_752_index_htm/7.52/en-US/index.htm)（`IF_HTTP_CLIENT` / JSON 章节）
- [SAP Help Portal](https://help.sap.com)（搜 "CPI" / "Process Orchestration"——两位中间件的官方文档）

### 第17课：Transport Request（请求与传输）

- [SAP Help Portal](https://help.sap.com)（搜 "Transport Management System"——官方传输体系文档）
- [ABAP Keyword Documentation](https://help.sap.com/doc/abapdocu_752_index_htm/7.52/en-US/index.htm)（Change & Transport System 章节）

### 第18课：消息处理（Message Class）

- [ABAP Keyword Documentation](https://help.sap.com/doc/abapdocu_752_index_htm/7.52/en-US/index.htm)（`MESSAGE` 条目，六种类型完整语义表）

### 第19课：新语法专题

- [ABAP Keyword Documentation](https://help.sap.com/doc/abapdocu_752_index_htm/7.52/en-US/index.htm)（ABAP Expressions 章节，本课全部操作符的官方定义与更多示例）

### 第20课：CDS View（基础）—— 数据模型新范式

- [ABAP Flight Reference Scenario（/DMO/）](https://help.sap.com/docs/abap-cloud/abap-rap/abap-flight-reference-scenario)（SAP 官方 CDS/RAP 参考实现，课程模型的现代版）
- [ABAP Keyword Documentation](https://help.sap.com/doc/abapdocu_752_index_htm/7.52/en-US/index.htm)（ABAP CDS 章节）

### 第21课：CDS View（进阶）—— 聚合、参数与访问控制

- [ABAP Flight Reference Scenario（/DMO/）](https://help.sap.com/docs/abap-cloud/abap-rap/abap-flight-reference-scenario)（官方场景里 DCL 与参数化视图的成熟样例）
- [ABAP Keyword Documentation](https://help.sap.com/doc/abapdocu_752_index_htm/7.52/en-US/index.htm)（ABAP CDS → Data Control Language 章节）

### 第22课：OO ALV —— 面向对象的 ALV

- [ABAP Keyword Documentation](https://help.sap.com/doc/abapdocu_752_index_htm/7.52/en-US/index.htm)（`CL_GUI_ALV_GRID` / `CL_GUI_DOCKING_CONTAINER` 类文档）

### 第23课：BTP 概览 + abapGit 代码管理

- [abapGit 官网](https://abapgit.org)（文档与独立版下载）
- [ABAP Flight Reference Scenario（/DMO/）](https://help.sap.com/docs/abap-cloud/abap-rap/abap-flight-reference-scenario)（RAP 进阶官方路线）
- [SAP BTP Trial](https://www.sap.com/products/technology-platform/trial.html)（注册体验 Steampunk）

### 第24课：综合实战 —— SFLIGHT 航班管理系统（收官）

- [ABAP Flight Reference Scenario（/DMO/）](https://help.sap.com/docs/abap-cloud/abap-rap/abap-flight-reference-scenario)（课程之后的下一站）
