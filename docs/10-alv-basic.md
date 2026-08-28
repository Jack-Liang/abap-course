---
status: draft
---

# 第10课：ALV 报表（基础）

> 45分钟 | 阶段：核心篇

## 前置依赖

- 第4课：会使用内表
- 第7课：了解选择屏幕（非必须但推荐）
- 第13课：了解 ABAP 面向对象基础（理解类和方法的调用方式）

## 问题引入

用 WRITE 输出的数据是"纯文本"——没有列对齐、没有排序、没有合计。用户拿到这样的报表会觉得不够专业。SAP 有没有一种"标准的报表展示方式"——自动生成表格、排序、筛选、合计？ALV 就是 SAP 的标准答案。

## 时间安排

| 时段 | 内容 | 时长 |
|------|------|------|
| 场景引入 | WRITE 输出 vs ALV 展示的对比 | 3 分钟 |
| Demo 演示 | 展示 SFLIGHT 的 ALV 报表，演示排序/合计/筛选 | 5 分钟 |
| 代码拆解 | CL_SALV_TABLE 使用流程、Field Catalog、布局设置 | 28 分钟 |
| 知识总结 | CL_SALV_TABLE vs REUSE_ALV_GRID 对比、常用方法速查 | 6 分钟 |
| 课后思考 | 练习 | 3 分钟 |

## 本课目标

掌握 ALV 报表的基本用法，能快速将内表数据以标准 ALV Grid 形式展示。

## Demo

用 ALV Grid 展示 SFLIGHT 航班列表，支持排序、合计、筛选，通过 Field Catalog 自定义列标题和格式。

## 知识点

### 1. ALV 概述
- 什么是 ALV（ABAP List Viewer）
- ALV 分类：Function ALV / OO ALV / SALV

### 2. REUSE_ALV_GRID_DISPLAY
- I_CALLBACK_PROGRAM 参数
- I_CALLBACK_PF_STATUS_SET（自定义工具栏）
- I_CALLBACK_USER_COMMAND（交互事件——第11课重点）
- IT_FIELDCAT（字段目录）
- IS_LAYOUT（布局）
- I_SAVE / IS_VARIANT（变式保存）

### 3. Field Catalog 构建
- 手动构建 SLIS_T_FIELDCAT_ALV
  - FIELDNAME / REF_FIELDNAME / REF_TABNAME
  - SELTEXT_L / M / S（列标题）
  - HOTSPOT / DO_SUM / NO_ZERO / EDIT
- 自动生成：REUSE_ALV_FIELDCATALOG_MERGE
- 新语法：VALUE 构造 Field Catalog

### 4. Layout 常用选项
- ZEBRA（斑马纹）
- COLWIDTH_OPTIMIZE（列宽优化）
- NO_COLHEAD（隐藏列头）
- GET_SELINFO（显示选择条件）
- TOTALS_TEXT（合计标签）

### 5. ALV 标准 Toolbar
- 导出 Excel / 打印 / 筛选 / 排序 / 小计

## Demo 代码

```abap
REPORT zac_alv_basic.

START-OF-SELECTION.
  " 查询数据
  SELECT f~carrid, f~connid, f~fldate, f~seatsmax, f~seatsocc, f~price,
         c~carrname
    FROM sflight AS f
    INNER JOIN scarr AS c ON f~carrid = c~carrid
    INTO TABLE @DATA(lt_sflight).

  " 构造 Field Catalog（新语法 VALUE）
  DATA(lt_fieldcat) = VALUE slis_t_fieldcat_alv(
    ( fieldname = 'CARRID'    seltext_l = '航空公司代码' outputlen = 10 )
    ( fieldname = 'CONNID'    seltext_l = '航线编号'     outputlen = 10 )
    ( fieldname = 'FLDATE'    seltext_l = '航班日期'     outputlen = 12 )
    ( fieldname = 'CARRNAME' seltext_l = '航空公司名称' outputlen = 20 )
    ( fieldname = 'SEATSMAX'  seltext_l = '最大座位'     outputlen = 12 do_sum = 'X' )
    ( fieldname = 'SEATSOCC'  seltext_l = '已占座位'     outputlen = 12 do_sum = 'X' )
    ( fieldname = 'PRICE'     seltext_l = '票价'         outputlen = 15 do_sum = 'X' )
  ).

  " 布局
  DATA(ls_layout) = VALUE slis_layout_alv(
    zebra = 'X'
    colwidth_optimize = 'X'
    totals_text = '合计'
  ).

  " 输出 ALV
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid
      is_layout          = ls_layout
      it_fieldcat        = lt_fieldcat
    TABLES
      t_outtab           = lt_sflight
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
```

## 代码拆解要点

1. REUSE_ALV_GRID_DISPLAY 的关键参数
2. Field Catalog 手动 vs 自动生成
3. VALUE #() 构造内表的新语法
4. Layout 选项对展示效果的影响
5. sy-subrc 的错误处理

## 💡 实战经验

- **CL_SALV_TABLE 是首选**：新项目推荐使用 OO ALV（CL_SALV_TABLE），而不是老式的 Function Module 方式（REUSE_ALV_*）。OO ALV 代码更简洁，且 SAP 官方已不再维护老式 ALV
- **Field Catalog 自动生成**：如果内表结构与数据库表一致，用 `cl_salv_table=>factory` 自动生成 Field Catalog 即可。只有需要自定义列标题/格式时才手动设置
- **ALV 报表不用 WRITE**：ALV 自己管理屏幕输出，程序中不需要 WRITE 语句。如果有 WRITE 输出，会和 ALV 界面冲突
- **调试 ALV 的技巧**：如果 ALV 显示不出来，最常见原因是内表为空或数据结构有问题。在调用 ALV 前加一个断点检查内表内容

## 课后思考

1. Field Catalog 的 REF_FIELDNAME 和 SELTEXT_L 有什么区别？
2. 如何让 ALV 默认按某个字段排序？
3. VALUE 构造 Field Catalog 时，没有列出的字段会怎样？