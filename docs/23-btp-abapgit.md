# 第23课：BTP 环境与 abapGit

> 45分钟 | 阶段：现代开发篇

## 前置依赖

- 第17课：了解传输请求（理解代码版本管理的基本概念）

## 问题引入

你的代码怎么管理版本？SAP 传输请求只能做"单向传输"，不能像 Git 一样查看历史、分支、回滚。SAP 开发者如何享受 Git 的便利？abapGit 就是答案——让 ABAP 代码也能用 Git 管理。同时，SAP BTP（Business Technology Platform）是 SAP 的云平台，新项目越来越多地运行在 BTP 上。

## 时间安排

| 时段 | 内容 | 时长 |
|------|------|------|
| 场景引入 | SAP 传统开发 vs 现代开发的工具链差异 | 3 分钟 |
| Demo 演示 | 用 abapGit 把代码推送到 GitHub / 从 GitHub 拉取代码 | 8 分钟 |
| 代码拆解 | abapGit 安装配置、仓库操作、BTP 环境介绍、VS Code + ADT | 25 分钟 |
| 知识总结 | abapGit 常用操作速查、BTP vs On-Premise 对比 | 6 分钟 |
| 课后思考 | 练习 | 3 分钟 |

## 本课目标

掌握 abapGit 的基本操作，能将 ABAP 代码与 Git 仓库同步，了解 BTP 平台的开发环境。

## Demo

安装 abapGit，创建在线仓库，将前面课程开发的代码推送到 GitHub，演示从 GitHub 克隆一个开源 ABAP 项目。

## 知识点

### 第一部分：SAP BTP 概览（约 20 分钟）

#### 1. BTP 架构
- Business Technology Platform 定位
- BTP 服务分类
- ABAP Environment（Steampunk / BTP ABAP）vs On-Premise ABAP
- Cloud Foundry 概念（简要）

#### 2. Business Application Studio（BAS）
- 基于 VS Code 的开发环境
- SAP Fiori Tools 插件
- ABAP 语法高亮与代码补全
- 部署到 BTP ABAP Environment

#### 3. RAP 模型
- ABAP RESTful Application Programming Model
- CDS + Behavior Definition + Service Definition
- 与传统 ABAP 开发的对比（简要介绍，不深入）

#### 4. 云与 On-Premise 的区别
- 开发工具差异（SE80 vs BAS）
- 技术差异（经典 DDIC vs CDS / RAP）
- 部署方式差异

### 第二部分：abapGit（约 25 分钟）

#### 5. abapGit 概述
- ABAP 的 Git 客户端
- 开源项目
- 与 CTS（请求传输）的关系

#### 6. 安装方法
- 通过 abapGit 在线安装
- SAP Note 方式
- CTS 导入方式

#### 7. 基本操作
- 创建仓库（在线创建 / abapGit 界面创建）
- Clone 远程仓库到 SAP
- Pull（拉取远程更新）
- Push（推送本地修改）
- Stage / Commit（暂存 / 提交）

#### 8. 分支管理
- 查看分支
- 切换分支
- 创建分支

#### 9. .abapgit.xml 文件
- 作用：标记 Git 仓库根目录
- 配置项

#### 10. 代码冲突处理
- 冲突场景
- 解决方法

#### 11. 与团队协作
- 日常开发流程
- abapGit vs CTS 的配合策略

## 代码

本课无 ABAP 代码。附 BTP 界面截图和 abapGit 操作截图。

## 💡 实战经验

- **abapGit 不是 SAP 官方产品**：abapGit 是开源社区项目，使用前需要仔细评估。生产环境使用前，建议在测试系统充分验证
- **.abapgit.xml 是仓库的身份证**：每个 abapGit 仓库根目录必须有这个文件——它告诉 abapGit 这是一个 ABAP 仓库、主语言是什么、文件夹结构是什么。没有这个文件，abapGit 无法识别仓库
- **文件命名约定**：abapGit 使用 `对象名.类型.扩展名` 的命名规则（如 `zac_sql_crud.prog.abap`、`zcl_xxx.clas.abap`）。严格遵守命名约定，否则 abapGit 无法正确导入导出
- **BTP Trial 账号**：SAP 提供免费的 BTP Trial 账号，可以体验 BTP 上的 ABAP 开发环境（Steampunk）。虽然有限制，但足够学习和实验
- **冲突处理**：如果多人同时修改同一个对象，Git 推送时可能冲突。abapGit 支持在线合并，但复杂冲突建议在 Git 客户端（如 VS Code）中处理

## 课后思考

1. BTP 上的 ABAP 开发和 On-Premise 上的 ABAP 开发最大的区别是什么？
2. abapGit 能替代 CTS（Transport Request）吗？为什么？
3. 如果团队中有人不使用 abapGit，如何保证代码同步？