---
status: draft
---

# 第9课：Function Module（函数模块）

> 45分钟 | 阶段：核心篇

## 前置依赖

- 第5课：了解 Open SQL 查询
- 第4课：会使用内表和结构体

## 问题引入

你的"计算航班飞行时长"逻辑写在一个报表里，但现在另一个报表也需要这个功能——难道要复制粘贴代码吗？如果以后逻辑变了，两个地方都要改，极易遗漏。怎么把"可复用的逻辑"封装起来，让多个程序都能调用？

## 时间安排

| 时段 | 内容 | 时长 |
|------|------|------|
| 场景引入 | 代码复用的真实需求 / 复制粘贴的代价 | 3 分钟 |
| Demo 演示 | 创建并调用 Function Module | 5 分钟 |
| 代码拆解 | Function Group 概念、创建流程、参数设计、异常处理 | 28 分钟 |
| 知识总结 | Function Module vs 方法 对比表、SE37 操作速查 | 6 分钟 |
| 课后思考 | 练习 | 3 分钟 |

## 本课目标

理解 Function Group 和 Function Module 的概念，能创建和调用自定义函数，理解 RFC 的基础概念。

## Demo

创建一个 "计算航班飞行时长" 的 Function Module，从 SPFLI 获取起飞/到达时间，计算时长并返回结果，在报表程序中调用。

## 知识点

### 1. Function Group（函数组）
- 为什么需要函数组（全局数据共享）
- SE37 中创建 Function Group
- 全局数据区域的作用

### 2. Function Module 创建
- Import 参数（输入，Pass by Value / Reference）
- Export 参数（输出）
- Changing 参数（输入输出）
- Tables 参数（旧式，了解即可，推荐用 Changing + 内表）
- Exceptions（异常定义）

### 3. 源代码区域
- Global Data（全局数据）
- Function Main（主逻辑）
- Sub-Routines（子例程）

### 4. 调用方式
- CALL FUNCTION 'ZFM_...' 模式
- 按参数名传值
- EXCEPTIONS 处理

### 5. RFC 概念
- Remote Function Call
- RFC 调用模式（同步/异步）
- RFC Destination（SM59）

### 6. 测试
- SE37 测试环境（F8 单步执行）

## Demo 代码

Function Module 源代码：
```abap
FUNCTION zac_calc_flight_duration.
*"----------------------------------------------------------------------
*"* IMPORTING
*"   VALUE(IV_CARRID) TYPE S_CARR_ID
*"   VALUE(IV_CONNID) TYPE S_CONN_ID
*" EXPORTING
*"   VALUE(EV_DURATION) TYPE T_MSECHI
*"   VALUE(EV_DISTANCE) TYPE S_DISTID
*"   VALUE(EV_CITYFROM) TYPE S_FROM_CIT
*"   VALUE(EV_CITYTO)   TYPE S_TO_CIT
*"----------------------------------------------------------------------
  SELECT SINGLE depaturetime, arrivaltime, distance,
                cityfrom, cityto
    FROM spfli
    WHERE carrid = iv_carrid AND connid = iv_connid
    INTO @DATA(ls_spfli).

  IF sy-subrc = 0.
    ev_cityfrom = ls_spfli-cityfrom.
    ev_cityto   = ls_spfli-cityto.
    ev_distance = ls_spfli-distance.
    ev_duration = ls_spfli-arrivaltime - ls_spfli-depaturetime.
  ENDIF.
ENDFUNCTION.
```

调用方代码：
```abap
REPORT zac_call_function.

START-OF-SELECTION.
  CALL FUNCTION 'ZAC_CALC_FLIGHT_DURATION'
    EXPORTING
      iv_carrid  = 'AA'
      iv_connid  = '0017'
    IMPORTING
      ev_duration = @DATA(lv_duration)
      ev_distance = @DATA(lv_distance)
      ev_cityfrom = @DATA(lv_cityfrom)
      ev_cityto   = @DATA(lv_cityto).

  IF lv_duration IS NOT INITIAL.
    WRITE: / |{ lv_cityfrom } → { lv_cityto }|.
    WRITE: / |飞行时长: { lv_duration } 分钟, 距离: { lv_distance }|.
  ELSE.
    WRITE: / '未找到航线信息'.
  ENDIF.
```

## 代码拆解要点

1. Function Module 的参数传递方向（Import/Export/Changing）
2. CALL FUNCTION 的调用模式
3. @DATA 在 IMPORTING 中的使用
4. 异常处理的写法
5. RFC 的概念与 SM59 配置（简要）

## 💡 实战经验

- **全局内存 vs 局部数据**：Function Group 中的全局变量在同一个 Group 下的所有 Function Module 之间共享——这是功能，也是隐患。如果多个 FM 修改同一个全局变量，调用顺序不同结果就不同
- **RFC 调用的性能**：RFC（远程函数调用）比本地调用慢很多，因为要经过网络层。只在跨系统调用时使用 RFC，同一系统内用普通调用
- **SE37 中测试 FM**：开发完 FM 后，在 SE37 中直接按 F8 测试——输入参数后可以立即看到返回结果，比写报表测试快得多
- **BAPI 就是 RFC-enabled 的 FM**：很多同学觉得 BAPI 很神秘，其实 BAPI 本质上就是一个设置为 RFC-enabled 的 Function Module，只是遵循了 SAP 的命名和接口规范

## 课后思考

1. Function Module 和 Form（子例程）有什么区别？
2. Changing 参数和 Export 参数的区别是什么？
3. 尝试创建一个 Function Module，统计某航空公司的航班数量。