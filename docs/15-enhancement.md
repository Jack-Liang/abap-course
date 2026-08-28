---
status: draft
---

# 第15课：增强（Enhancement）—— 不改标准代码扩展功能

> 45分钟 | 阶段：高级篇

## 前置依赖

- 第9课：了解 Function Module 概念
- 第13课：了解 ABAP OO 基础

## 问题引入

你发现 SFLIGHT 标准程序在创建航班时没有做"日期校验"——用户可以输入过去日期。但 SFLIGHT 是 SAP 标准程序，你不能直接改它的代码（修改后会丢失、升级后覆盖）。怎么办？SAP 提供了"增强"机制——在不改标准代码的前提下，注入自定义逻辑。

## 时间安排

| 时段 | 内容 | 时长 |
|------|------|------|
| 场景引入 | 不能改标准代码但需要加功能——真实困境 | 3 分钟 |
| Demo 演示 | 通过 BADI 给 SAP 程序增加日期校验逻辑 | 8 分钟 |
| 代码拆解 | User Exit / BADI / Enhancement Spot 概念和操作 | 26 分钟 |
| 知识总结 | 三种增强方式对比表、查找增强的方法 | 5 分钟 |
| 课后思考 | 练习 | 3 分钟 |

## 本课目标

掌握 SAP 增强的核心概念，能找到和使用 BADI 给标准程序添加自定义逻辑。

## Demo

通过 Enhancement Spot 给 SAP 标准程序的航班创建功能增加"日期不能早于今天"的校验逻辑。

## 知识点

### 1. 增强概述
- 为什么需要增强（不修改标准代码的原则）
- SAP 增强技术发展史：
  - User Exit → BADI → Enhancement Spot → New Enhancement Framework

### 2. User Exit（用户出口）
- EXIT / CALL CUSTOMER-FUNCTION 语法
- SMOD / CMOD
  - 查找 User Exit（Find → Global Search）
  - 创建 Project
  - 分配组件（Components）
  - 激活退出函数

### 3. BADI（Business Add-In）
- 面向接口的增强点
- SE18：查找 BADI 定义
- SE19：创建 BADI 实现
- 方法重写

### 4. Enhancement Spot（增强点）
- 显式增强点 vs 隐式增强点
- SE80 / SE19 查找增强点
- 隐式增强操作：
  - 在 Include 程序中右键 → Enhancement → Create
  - Pre-Exit（增强前） / Post-Exit（增强后） / Overwrite（覆盖）

### 5. 增强查找技巧
- WHERE-USED list 方法
- 断点调试定位（在标准程序中设断点）
- 通过出口程序名搜索（命名规范 EXIT_saplname_nnn）

## Demo 代码

在隐式增强点中插入的代码：
```abap
ENHANCEMENT 1  Z_SFLIGHT_EXT.
  SPOTS z_sflight_ext.

  " 在标准 ALV 展示前追加自定义字段
  DATA: lv_remark TYPE zac_flight_ext-remark.

  SELECT SINGLE remark FROM zac_flight_ext
    WHERE carrid = @ls_sflight-carrid
      AND connid = @ls_sflight-connid
      AND fldate = @ls_sflight-fldate
    INTO @lv_remark.

  IF sy-subrc = 0.
    " 将备注追加到输出结构
    ls_output-zz_remark = lv_remark.
  ENDIF.

ENDENHANCEMENT.
```

## 代码拆解要点

1. ENHANCEMENT ... ENDENHANCEMENT 的语法
2. SPOTS 声明增强点的位置
3. Pre-Exit / Post-Exit / Overwrite 的区别
4. 增强代码中如何访问标准程序的数据
5. 增强的查找与定位方法

## 💡 实战经验

- **找 BADI 的最快方法**：在目标程序中执行 → 在调试器中点菜单"Breakpoints → Breakpoint at → Enhancement"，系统会列出该程序中所有可用的增强点——比手动搜索快得多
- **User Exit vs BADI**：User Exit 是第一代增强（需要找出口程序），BADI 是第二代（面向对象）。新项目优先使用 BADI——接口更清晰、不需要修改 Include
- **增强代码的命名**：增强实现在 Z 开头的 Include 或 Class 中。给增强 Include 起一个有意义的名字（如 `ZZ_SFLIGHT_DATE_CHECK`），方便后续维护
- **增强可能不存在**：不是所有标准程序都有增强点。如果找不到合适的增强点，可能需要考虑其他方案（如替代 BADI、屏幕增强、或与 Basis 团队沟通）

## 课后思考

1. User Exit 和 BADI 的区别是什么？什么场景下用哪个？
2. 如何判断一个标准程序有哪些可用的增强点？
3. 增强代码会影响其他客户吗？为什么？