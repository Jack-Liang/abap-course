---
status: draft
---

# 第14课：BAPI 调用 —— SAP 标准接口

> 45分钟 | 阶段：高级篇

## 前置依赖

- 第9课：了解 Function Module 的创建和调用
- 第5课：了解 Open SQL（理解事务提交）

## 问题引入

你需要让程序"自动创建一条航班预订"——但创建预订的复杂逻辑（检查座位、计算价格、锁定库存）不可能自己从头写。SAP 已经把这套逻辑封装好了，以 BAPI 的形式对外开放。怎么找到合适的 BAPI？怎么调用它？调用失败了怎么回滚？

## 时间安排

| 时段 | 内容 | 时长 |
|------|------|------|
| 场景引入 | "不要重复造轮子"——SAP 已有大量标准业务逻辑 | 3 分钟 |
| Demo 演示 | 通过 BAPI 创建和查询航班预订 | 5 分钟 |
| 代码拆解 | BAPI 查找方法、参数结构、RETURN 表处理、BAPI_TRANSACTION_COMMIT | 28 分钟 |
| 知识总结 | BAPI 调用模板、常见 BAPI 速查表 | 6 分钟 |
| 课后思考 | 练习 | 3 分钟 |

## 本课目标

掌握 BAPI 的查找和调用方法，理解 BAPI 的事务控制机制，能调用标准 BAPI 完成业务操作。

## Demo

通过 BAPI 创建一条 SBOOK 航班预订，查询预订状态，失败时回滚事务。

## 知识点

### 1. BAPI 概述
- 什么是 BAPI（Business Application Programming Interface）
- BAPI vs Function Module
- BAPI Explorer（BAPI 事务码）
- 命名规范：BAPI_* / BAPIFLBOOK*

### 2. BAPI 调用模式
- 通过 CALL FUNCTION 调用
- Import 参数传入业务数据
- Export 参数获取结果
- Tables 参数处理行项目

### 3. BAPI_RETURN_INFO 处理
- TYPE / ID / NUMBER / MESSAGE / LOG_NO / MESSAGE_V1~V4
- 判断成功/失败：TYPE = 'S' / 'E' / 'W'
- 消息拼接展示

### 4. BAPI 事务控制
- BAPI_TRANSACTION_COMMIT（提交）
- BAPI_TRANSACTION_ROLLBACK（回滚）
- WAIT 参数

### 5. 常用 BAPI 示例
- 创建/修改/查询航班预订
- BAPI 查询技巧（按业务对象搜索）

### 6. 封装为类的静态方法
- 新语法：将 BAPI 调用封装为类的静态方法

## Demo 代码

```abap
REPORT zac_bapi.

START-OF-SELECTION.
  " 1. 创建航班预订
  DATA: lt_booking TYPE TABLE OF bapisbook,
        ls_booking TYPE bapisbook,
        lt_return  TYPE TABLE OF bapiret2,
        ls_return  TYPE bapiret2.

  ls_booking-carrid   = 'AA'.
  ls_booking-connid   = '0017'.
  ls_booking-fldate   = '20260730'.
  ls_booking-bookid   = '00000001'.
  ls_booking-customid = '00000001'.
  ls_booking-class    = 'Y'.
  APPEND ls_booking TO lt_booking.

  CALL FUNCTION 'BAPI_SBOOK_CREATE'
    IMPORTING
      booking_number = DATA(lv_bookid)
    TABLES
      booking_data   = lt_booking
      return         = lt_return.

  " 2. 检查返回消息
  LOOP AT lt_return INTO ls_return WHERE type = 'E' OR type = 'A'.
    WRITE: / |错误: { ls_return-message }|.
  ENDLOOP.

  " 3. 提交事务
  IF lv_bookid IS NOT INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING wait = 'X'.
    WRITE: / |预订创建成功! 预订号: { lv_bookid }|.
  ELSE.
    WRITE: / '预订创建失败'.
  ENDIF.

  " 4. 查询预订详情
  CALL FUNCTION 'BAPI_SBOOK_GETDETAIL'
    EXPORTING
      booking_number    = lv_bookid
    IMPORTING
      return            = ls_return
    TABLES
      booking_detail    = lt_booking.

  LOOP AT lt_booking INTO ls_booking.
    WRITE: / |预订详情: { ls_booking-carrid }-{ ls_booking-connid }-{ ls_booking-fldate }|.
  ENDLOOP.
```

## 代码拆解要点

1. BAPI 的标准调用模式（填充参数 → 调用 → 检查返回 → 提交）
2. BAPI_RETURN_INFO 的字段含义
3. BAPI_TRANSACTION_COMMIT 的 WAIT 参数作用
4. 批量操作中的错误收集模式
5. 在 BAPI Explorer 中查找相关 BAPI

## 💡 实战经验

- **如何找到合适的 BAPI？** 在 SE37 中用 `BAPI_*` 模糊搜索，或在 SAP 的 BAPI Explorer（事务码 BAPI）中按业务对象浏览。也可以 Google “SAP BAPI + 业务场景”
- **RETURN 表比 RETURN 参数更重要**：很多 BAPI 的 RETURN 参数只返回一条消息，但 RETURN 表（BAPIRET2）会返回所有消息（成功/警告/错误）——务必检查 RETURN 表的 TYPE 字段
- **BAPI_TRANSACTION_COMMIT 必须单独调用**：BAPI 修改数据后不会自动提交。必须调用 `BAPI_TRANSACTION_COMMIT`（或 `BAPI_TRANSACTION_ROLLBACK`）来完成或回滚事务
- **BAPI 不能在 UPDATE TASK 中调用**：有些同学想在用户出口中调用 BAPI，但用户出口运行在 UPDATE TASK 中，BAPI 不支持——需要用 `CALL FUNCTION ... IN BACKGROUND TASK` 的方式处理

## 课后思考

1. BAPI 调用后忘记 COMMIT WORK 会怎样？
2. 如何在 BAPI Explorer 中找到”修改航班预订”的 BAPI？
3. 尝试将 BAPI 调用封装为类的静态方法（提示：CLASS-METHODS）。
