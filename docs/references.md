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

<!-- 格式：
### 第N课：课题
| 主题 | 链接 | 说明 |
-->

（待补充——每课打磨时在此登记该课延伸阅读，课次与 docs/ 编号一致）
