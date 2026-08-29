---
status: draft
---

# 第23课：BTP 概览 + abapGit 代码管理

> 45分钟 | 阶段：现代开发篇 | 概念 + 操作课

## 前置依赖

- [第17课](17-transport.md)：传输请求（TR 管"部署"，本课的 Git 管"版本"）；
- [第0课](00-getting-started.md)：你已经用 abapGit 拉过本课程仓库——本课把这件事讲透。

## 问题引入

两个世界正在合流：**SAP 的代码传统上活在系统里**（SE38 里改、TR 里传），**现代软件活在 Git 里**（历史、分支、评审、回滚）。abapGit 是摆渡船——ABAP 对象序列化成文件进 Git 仓库；BTP 则是 SAP 把整套开发运行时搬上云的地方。本课上半场看懂 BTP 版图，下半场把 abapGit 从"会用"升级到"理解机制 + 团队工作流"。

## 时间安排

| 时段 | 内容 | 时长 |
|------|------|------|
| 场景引入 | 两套版本观的碰撞 | 3 分钟 |
| Demo 跟做 | Pull 课程仓库更新 + 本地改动 Push 全流程 | 10 分钟 |
| 知识讲解 | BTP 版图 / abapGit 机制 / 双轨工作流 | 24 分钟 |
| 知识总结 | 操作速查 + 选型表 | 5 分钟 |
| 课后思考 | 练习 | 3 分钟 |

## 本课目标

完成本课你将能够：

- 说清 BTP 的定位、ABAP Environment（Steampunk）与 On-Premise 的差异、RAP 的位置；
- 独立完成 abapGit 的 Pull / Stage / Commit / Push 闭环与分支切换；
- 解释 `.abapgit.xml` 与对象文件命名约定（第0课种过的树）；
- 设计"abapGit + CTS 双轨"的团队协作流程。

## Demo：Pull 与 Push 的完整闭环（分步跟做）

> 课程仓库就是你手边最合适的练习场。以下操作在试用镜像的 abapGit（`ZABAPGIT_STANDALONE`）中进行。

### 步骤 1：Pull 课程更新

1. 运行 abapGit，进入已 Clone 的 `abap-course` 仓库页（第0课克隆的）；
2. **Pull**：远程最新课文对象拉进系统——比如课程发布了对某课程序 bug 的修复，一次 Pull 即到手（比等 TR 传输快得多）；
3. Pull 后对象列表绿色 = 全部激活成功。

### 步骤 2：本地改动并 Push

1. SE38 随便给 `zac_hello_world` 加一行注释并激活；
2. abapGit 仓库页 → **Stage**（打勾选择变更对象）→ 输入 commit 信息（如 `test: 尝试push`）→ **Commit**；
3. **Pull 先行**（拉远程新提交避免冲突）→ **Push** 到远程分支；
4. 到 GitHub 仓库网页刷新，看到你的提交——ABAP 对象已经活在 Git 历史里了。

!!! note "Push 权限提示"

    向课程主仓库 Push 需要写权限（学员通常没有）。团队场景里你推的是自己团队的仓库；练习时可以 Fork 本课程仓库后把 abapGit 远程 URL 指向你的 Fork——完整走一遍零障碍。

<!-- 配图（待截图后启用）：![abapGit stage与commit](https://cdn.jsdelivr.net/gh/jack-liang/abap-course-assets@main/23-btp-abapgit/abapgit-stage.png) -->

## 知识点

### 第一部分：SAP BTP 版图（上半场）

#### 1. BTP 是什么

**Business Technology Platform** = SAP 的云平台总集：数据库（HANA Cloud）、应用运行时（ABAP Environment / Cloud Foundry / Kyma）、集成（CPI，第16课见过）、分析（Analytics Cloud）……一句话：**SAP 把"数据库 + 应用服务器 + 集成 + 分析"打包成云服务**——第1课三层架构的云化售卖。

| 环境 | 形态 | 开发方式 |
|------|------|---------|
| On-Premise（试用镜像/公司系统） | 全功能经典 ABAP | SE38/SE80 + ADT，本课程主线 |
| **ABAP Environment（Steampunk）** | BTP 上的 ABAP 运行时，**仅开放 ABAP Cloud** | 只能 ADT；CDS/RAP/云 API |
| BTP Trial | 免费试用账号 | 体验 Steampunk/BAS/Fiori |

第0课说过 BTP Trial 与本课程兼容性的结论：**传统 ABAP（经典 ALV/FM/BAPI）只有 On-Premise 形态能学全**——所以课程主线在试用镜像，BTP 是"见识"目标。

#### 2. ABAP Cloud 与 RAP 一分钟

ABAP Environment 里只能写 **ABAP Cloud** 代码：只允许调用已发布的 API（released APIs），经典 SE38 报表那套不复存在。应用开发的主力范式是 **RAP**（RESTful Application Programming Model）：

```text
CDS（数据模型，第20/21课的延伸）
  + Behavior Definition（行为：校验/动作/锁定）
  + Service Definition/Binding（暴露成 OData → Fiori/UI）
```

课程终点到 CDS 为止，RAP 是下一段路的起点——参考资料库的 [ABAP Flight Reference Scenario（/DMO/）](https://help.sap.com/docs/abap-cloud/abap-rap/abap-flight-reference-scenario) 就是官方的 RAP 进阶教材。

#### 3. 开发工具终局

- **ADT（Eclipse 插件）**：On-Premise 与 Steampunk 通吃的现代 IDE（第20课已在用）；
- **BAS（Business Application Studio）**：BTP 上的 VS Code 网页版，Fiori/云端开发主场；
- SE38/SE80 不会消失，但新项目的重心正在迁移。

### 第二部分：abapGit 机制与工作流（下半场）

#### 4. abapGit 的本质

开源项目（非 SAP 官方出品，SAP 官方背书其方向）：**把 DDIC 对象序列化成文本文件**（XML + 源码），交给 Git 做版本管理；反向再把文件反序列化回系统对象。第0课你拉课程仓库时，`zac_sql_crud.prog.xml`（元数据）+ `.prog.abap`（源码）这对文件就是序列化产物——**每个对象 = 一个/一组文件**，这就是它的一切魔法。

#### 5. 仓库身份证与命名约定

```xml
<!-- .abapgit.xml：仓库的身份证（课程仓库根目录） -->
<NAME>abap-course</NAME>
<STARTING_FOLDER>/src/</STARTING_FOLDER>
<FOLDER_LOGIC>PREFIX</FOLDER_LOGIC>
```

文件名 `对象名.类型.扩展名`：`zac_flight_ext.tabl.xml`（表）、`zcl_ac_flight_query.clas.abap`（类源码）。约定错了 Git 里也能看，但 abapGit 认不出对象——**改文件名前先想清楚**。

#### 6. 分支管理：一个分支 ≈ 一班车

仓库页面顶部的 **Branch** 菜单是分支的总开关：`Create Branch` 从当前分支拉出新分支（如 `feature/occ-rate`），`Switch Branch` 在分支间切换——切换后 abapGit 会列出对象差异，一次 Pull 就把系统里的对象切到该分支的版本。日常节奏与第17课的"班车"完全同构：

1. `main` 保护起来不直接推（GitHub 仓库设置里开分支保护）；
2. 每个功能开 feature 分支开发——**一个分支 ≈ 一班 TR**：主题单一、可独立评审、不满意整车发回重做；
3. Push 分支 → GitHub 上开 PR → 评审通过 merge 回 main；
4. 系统里切回 main 做一次 Pull，本地与远程重同步。

分支策略与 TR 策略对齐的团队，"Git 历史"和"传输历史"能互相印证——哪次 PR 对应哪班车，一眼可查。

#### 7. 双轨制：abapGit × CTS

| 维度 | abapGit | CTS/TR（第17课） |
|------|---------|------------------|
| 管理 | 版本历史/分支/评审 | 系统间部署 DEV→QAS→PRD |
| 强项 | 协作、回滚、开源、备份 | 审批合规、配置数据、依赖排序 |

**成熟团队的合流姿势**：开发与评审在 abapGit（feature 分支 → PR → merge）；**发布仍走 TR**——merge 后在开发系统 Pull 最新版，把对象收进 TR 走审批传输。Git 管"写成什么样"，TR 管"何时进哪个系统"，各司其职（第17课课后思考的答案在此兑现）。

#### 8. 冲突与纪律

- 冲突 = 远程与本地改了同一对象。abapGit 界面能看 diff，简单冲突覆盖/采用即可，复杂冲突回 Git 客户端处理；
- 纪律：**Push 前必 Pull**；一个功能一个分支；commit 信息写人话（`fix: 上座率列计算错位`，而不是 `update`）；
- 本课程自身的仓库就是活案例：小步 commit、按主题攒批 push、CI 自动部署文档站——你正在读的这节课就是这么发布的。

## 💡 实战经验

!!! tip "生产系统上 abapGit 谨慎评估"

    开源工具 + 直接读写开发对象：测试系统充分验证、限定使用范围（如仅 DEV 系统）、版本与开发者社区保持同步，是上生产前的三件套。

!!! tip "把 abapGit 当"系统的异地备份""

    即使团队不用它协作，定期 Pull 全量对象到 Git 仓库也是廉价的高保真备份——对象连同配置的 XML 都在，灾难恢复多一条路。

!!! tip "双仓模式：代码仓 + 资产仓"

    本课程的实践：ABAP 对象进主仓库，图片等二进制资产进独立仓库（`abap-course-assets`）走 CDN——主仓克隆永远轻快。你的项目有大二进制资产时可复制这套。

## 📖 延伸阅读

- [abapGit 官网](https://abapgit.org)——文档与独立版下载（第0课装过）；
- [ABAP Flight Reference Scenario（/DMO/）](https://help.sap.com/docs/abap-cloud/abap-rap/abap-flight-reference-scenario)——RAP 进阶官方路线；
- [SAP BTP Trial](https://www.sap.com/products/technology-platform/trial.html)——注册体验 Steampunk。

## 课后思考

> 把你的回答写在**页面底部评论区**，注明题号，一起讨论。

1. abapGit 与 TR 的分工边界是什么？为什么"Git 全替 TR"在合规企业里走不通？
2. `.abapgit.xml` 的 STARTING_FOLDER 指向 /src/——如果对象文件被误移到 /src/old/，abapGit 会发生什么？
3. Fork 本课程仓库并完成一次完整 Pull→改→Stage→Commit→Push（指向你的 Fork）——把你仓库的 commit 链接贴出来。
4. ABAP Cloud（Steampunk）为什么禁掉经典 SE38/BAPI？"仅发布 API"解决了什么问题？

---

下一课：[第24课：综合实战——SFLIGHT 航班管理系统](24-capstone.md)（收官）
