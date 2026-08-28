---
hide:
  - navigation
  - toc
---

<div class="ac-hero" markdown>

![ABAP Course](assets/images/logo.svg)

# ABAP Course

**从零开始的 SAP ABAP 开发实战课程**

24 课时 · Demo 驱动 · SAP 官方 SFLIGHT 数据模型 · 传统 ABAP → 新语法 → 现代开发

[开始学习 :material-rocket-launch:](00-getting-started.md){ .md-button .md-button--primary }
[:material-github: GitHub 仓库](https://github.com/Jack-Liang/abap-course){ .md-button }

</div>

## 课程阶段

<div class="grid cards" markdown>

-   :material-console: **准备篇**

    ---

    官方试用镜像部署、SFLIGHT 演示数据确认、abapGit 导入课程仓库。

    [:octicons-arrow-right-24: 第0课 环境搭建](00-getting-started.md)

-   :material-school: **基础篇 · 第1-6课**

    ---

    SAP 入门、数据类型、数据字典、内表、Open SQL、调试器。

    [:octicons-arrow-right-24: 从第1课开始](01-sap-overview.md)

-   :material-code-braces: **核心篇 · 第7-13课**

    ---

    选择屏幕、格式化、函数模块、ALV 报表、Excel、面向对象。

    [:octicons-arrow-right-24: 从第7课开始](07-selection-screen.md)

-   :material-rocket-launch: **高级篇 · 第14-19课**

    ---

    BAPI、增强、外部接口、传输请求、消息处理、新语法专题。

    [:octicons-arrow-right-24: 从第14课开始](14-bapi.md)

-   :material-cloud: **现代开发篇 · 第20-24课**

    ---

    CDS View、OO ALV、BTP 与 abapGit、综合实战航班管理系统。

    [:octicons-arrow-right-24: 从第20课开始](20-cds-basic.md)

-   :material-bookshelf: **附录**

    ---

    参考资料库（外部链接集中登记）与许可声明。

    [:octicons-arrow-right-24: 参考资料](references.md)

</div>

## :material-rocket-launch: 快速开始

1. 准备一套 ABAP 练习系统（推荐 SAP 官方试用镜像，Docker 部署）；
2. 确认 SFLIGHT 演示数据（官方镜像默认预置）；
3. 用 abapGit 把课程仓库 Clone/Pull 到开发包 `ZABAP_COURSE`。

详见[第0课：环境搭建与仓库导入](00-getting-started.md)。

## :material-file-code: 源码与命名

课程代码（`zac_*` 开发对象）与课文稿都在 GitHub 仓库中维护：对象统一 `zac_` 课程前缀，课号不进对象名，命名规范与课↔对象对照矩阵见[第0课第四节](00-getting-started.md#四命名规范与对象对照)。
