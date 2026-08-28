---
status: beta
---

# 第15课：增强（Enhancement）—— 不改标准代码扩展功能

> 45分钟 | 阶段：高级篇 | 概念+操作课

## 前置依赖

- [第9课](09-function-module.md)：FM 概念；
- [第13课](13-oo-basic.md)：接口与实现（BADI 的语言基础）；
- [第3课](03-data-dictionary.md)：`zac_flight_ext` 表（本课 Demo 的数据主角）。

## 问题引入

标准程序 99% 贴合需求，就差 1%："输出里想带上我们自建的备注字段"。标准代码**永远不能改**（升级即丢、SAP 不再支持）——这 1% 怎么补？答案是**增强（Enhancement）**：SAP 在标准代码里预留了"注入口"，你的代码从这些口子注入，与标准代码共存且升级不丢。本课看懂增强版图、上手隐式增强点。

!!! note "本课为讲解 + 操作示范课"

    增强对象依赖具体的标准程序入口，且不同镜像的可用出口不同，课程仓库**不随发增强对象**（它是系统内配置型对象）；按 Demo 步骤在自己系统里操作即可，`zac_flight_ext`（第3课建的表）是数据载体。

## 时间安排

| 时段 | 内容 | 时长 |
|------|------|------|
| 场景引入 | 1% 差距与"不能改标准"的铁律 | 3 分钟 |
| Demo 演示 | 在标准程序隐式增强点读取 ZAC_FLIGHT_EXT | 10 分钟 |
| 知识讲解 | 四代增强技术 / 查找方法 / 取舍 | 24 分钟 |
| 知识总结 | 增强选型决策表 | 5 分钟 |
| 课后思考 | 练习 | 3 分钟 |

## 本课目标

完成本课你将能够：

- 说清"不改标准代码"原则与增强框架的存在意义；
- 区分 User Exit / BADI / Enhancement Spot / 隐式增强点四代技术；
- 在任意标准程序的隐式增强点插入自己的代码（含数据读取 `zac_flight_ext`）；
- 用断点+调用栈定位标准程序的可用注入口。

## Demo：给标准读数程序"贴"备注（操作示范）

**目标：** 在一个读取 SFLIGHT 的标准输出位置，追加我们 `ZAC_FLIGHT_EXT` 里维护的备注——标准的归标准，我们的归我们。

### 步骤 1：找一个注入口

1. SE38 打开任意会展示 SFLIGHT 的标准程序（例如数据浏览相关的报表；也可用 SE16N 界面程序）；
2. 命令栏输入 `/h` 再执行（第6课技能：下一动作进调试器）；
3. 调试器里看**调用栈**：找到"即将处理航班数据"的标准程序名与位置——这就是候选注入口。

### 步骤 2：插入隐式增强

1. SE38 打开该标准程序，点 **Enhance 模式按钮**（"小铅笔/增强"图标，或菜单 Edit → Enhancement Operations → Show Implicit Enhancement Options）；
2. 每个过程块首尾会出现**虚线插槽**（implicit enhancement point）；
3. 光标放到目标位置插槽 → 右键 **Enhancement Implementation → Create**，命名 `zac_sflight_remark`（课程前缀规范同样适用于增强对象）；
4. 在插槽里写代码：

```abap
" 读取课程自建的补充信息（第3课的表）
DATA: lv_remark TYPE zac_flight_ext-remark.

SELECT SINGLE remark FROM zac_flight_ext
  WHERE carrid = @ls_sflight-carrid
    AND connid = @ls_sflight-connid
    AND fldate = @ls_sflight-fldate
  INTO @lv_remark.

IF sy-subrc = 0.
  WRITE: / |备注: { lv_remark }|.
ENDIF.
```

5. 激活增强实现。

**你会看到什么：** 标准输出之后多出一行"备注: …"（前提是该航班在第3课的表里维护过数据）。标准代码**一个字符都没改**——升级安全。

!!! warning "隐式增强是"最后的自由"，也是最锋利的刀"

    隐式增强点几乎无处不在，意味着你几乎能在任何标准逻辑里插话——权力越大越要克制：只加不改（别 MODIFY 标准变量语义）、入口集中（一个增强实现管一类事）、写清注释说明为什么。

## 知识点

### 1. 四代增强技术版图

| 代 | 技术 | 入口形态 | 现状 |
|----|------|---------|------|
| 一代 | **User Exit**（CMOD/SMOD） | SAP 预留的 `CALL CUSTOMER-FUNCTION '001'` 调用 + 你写 EXIT 程序 | 老系统/老模块仍在用 |
| 二代 | **BADI**（SE18 定义 / SE19 实现） | 面向接口：标准代码 `GET BADI` 调接口方法，你提供实现类 | 经典主力 |
| 三代 | **Enhancement Spot/Section**（新增强框架） | 显式增强点/增强段（SAP 标记的注入口） | 现代标准 |
| 通用 | **隐式增强点** | 任意过程块首尾（上面 Demo 用的） | 自由度最高、最需克制 |

演进方向：从"SAP 预留固定出口"到"面向接口的插件体系"——BADI 的形态正是第13课的"接口 + 实现"：标准代码持接口，你交实现类。

### 2. BADI 速览（认识形态即可）

```abap
" SE18 里看到的定义（标准侧）
INTERFACE if_ex_badi_xxx.
  METHODS: check_flight CHANGING c_ok TYPE abap_bool.
ENDINTERFACE.

" SE19 里你做的：创建实现类 → 实现方法
CLASS zcl_ac_badi_impl DEFINITION.
  PUBLIC SECTION.
    INTERFACES if_ex_badi_xxx.
ENDCLASS.
" 标准代码运行到调用点时，你的实现被回调
```

经典 BADI 多实例/过滤器（一个 BADI 按条件分发多个实现）属于进阶话题，用到时查 SE18 定义即可。

### 3. 怎么找到"该用哪个出口"

1. **看文档/资料库**：SAP Note 与模块文档列出的官方出口清单（业务扩展点有明确公布）；
2. **断点 + 调用栈**（第6课）：`/h` 进调试器，在目标数据流上停下，栈里逐层看标准程序——哪里能拿到你要的数据、哪里能拦住你要拦的动作，出口就在那附近；
3. **代码搜索**：标准包里搜 `CALL CUSTOMER-FUNCTION`（一代出口）、`GET BADI`（BADI 调用点）、`ENHANCEMENT-POINT`（显式点）。

### 4. 增强选型决策

```mermaid
flowchart TD
    A{"SAP 官方公布了<br/>业务出口？"} -->|"有 BADI/Exit"| B["走 BADI / User Exit<br/>（官方合同，升级最稳）"]
    A -->|"没有"| C{"需求在数据层？<br/>（加字段）"}
    C -->|"是"| D["Append Structure + 数据表<br/>（第3课路线）"]
    C -->|"否，逻辑层"| E["隐式增强点<br/>（自由但克制）"]
```

## 💡 实战经验

!!! tip "增强代码按对象归档"

    所有增强实现统一用 `zac_` 前缀命名，并在项目文档里登记"哪个程序、哪个点、解决什么需求"——三年后升级时，这张清单就是你的救命地图。

!!! tip "先问"真的需要增强吗""

    很多"以为要增强"的需求，其实是：屏幕变式/配置/权限/输出口自定义就能解决。增强是最后手段——每加一个注入口，未来升级就多一个检查点。

!!! warning "增强里别开新世界"

    隐式增强里做 COMMIT、调 BAPI 改数据、弹屏交互——都是高危动作（你可能正运行在标准流程的半途中）。增强代码的尺度：读数据、算标志、补输出，够了。

## 📖 延伸阅读

- [ABAP Keyword Documentation](https://help.sap.com/doc/abapdocu_752_index_htm/7.52/en-US/index.htm)——Enhancement Framework 章节；
- [SAP Help Portal](https://help.sap.com) 搜各业务模块的 "Customer Exit" 清单。

## 课后思考

> 把你的回答写在**页面底部评论区**，注明题号，一起讨论。

1. 为什么"直接修改标准代码"是绝对红线？说出至少三个后果。
2. BADI 的"接口 + 实现类"机制与第13课的哪个知识点完全同构？
3. 你的同事说"我在隐式增强点把标准内表 lt_data 里三行数据删了"——你对该改动的第一反应审查点是什么？
4. 查一查：SFLIGHT 相关程序里有没有官方公布的增强出口？（SE37/SE18 搜 Flight 相关 BADI，把发现贴出来）

---

下一课：[第16课：调用外部接口](16-external-api.md)
