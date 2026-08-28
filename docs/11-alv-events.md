# 第11课：ALV 交互事件

> 45分钟 | 阶段：核心篇

## 前置依赖

- 第10课：能创建基本的 ALV 报表

## 问题引入

ALV 报表展示航班列表已经不错了，但用户想"双击某条航班，查看该航班的旅客预订明细"——也就是从汇总数据钻取到明细数据。怎么实现这种"点击跳转"的交互？ALV 的事件机制是怎么工作的？

## 时间安排

| 时段 | 内容 | 时长 |
|------|------|------|
| 场景引入 | 从"查看数据"到"交互分析"的需求升级 | 3 分钟 |
| Demo 演示 | 双击航班行跳转到旅客预订明细 | 5 分钟 |
| 代码拆解 | 事件处理器注册、ON_DOUBLE_CLICK、数据传递、二级 ALV | 28 分钟 |
| 知识总结 | ALV 事件清单、Drill-Down 实现模式 | 6 分钟 |
| 课后思考 | 练习 | 3 分钟 |

## 本课目标

掌握 ALV 交互事件的处理机制，能实现点击跳转、明细展示等常见交互功能。

## Demo

在第10课 ALV 基础上，双击航班行查看该航班的旅客预订明细（SBOOK 表），实现 Drill-Down 效果。

## 知识点

### 1. ALV 交互事件机制
- I_CALLBACK_USER_COMMAND 参数
- Form 例程签名
- 参数 r_ucomm（功能码）和 rs_selfield（当前行信息）

### 2. rs_selfield 关键字段
- TABINDEX（行索引）、FIELDNAME（字段名）、VALUE（当前字段值）

### 3. 交互实现
- 双击事件处理（&IC1）
- Hotspot（热点链接）字段设置
- 基于当前行数据查询明细

### 4. Top-of-Page 事件
- I_CALLBACK_TOP_OF_PAGE
- REUSE_ALV_COMMENTARY_WRITE

### 5. 常见交互场景
- 跳转到其他事务码（CALL TRANSACTION）
- 弹出详细信息窗口
- 二次 ALV 显示明细

## Demo 代码

```abap
REPORT zac_alv_events.

TYPES: BEGIN OF ty_sflight,
         carrid TYPE sflight-carrid, connid TYPE sflight-connid,
         fldate TYPE sflight-fldate, price TYPE sflight-price,
         carrname TYPE scarr-carrname,
       END OF ty_sflight.

DATA: gt_sflight TYPE TABLE OF ty_sflight.

START-OF-SELECTION.
  SELECT f~*, c~carrname
    FROM sflight AS f INNER JOIN scarr AS c ON f~carrid = c~carrid
    INTO CORRESPONDING FIELDS OF TABLE @gt_sflight.
  PERFORM display_alv.

FORM display_alv.
  DATA(lt_fieldcat) = VALUE slis_t_fieldcat_alv(
    ( fieldname = 'CARRID'    seltext_l = '航空公司代码' hotspot = 'X' )
    ( fieldname = 'CONNID'    seltext_l = '航线编号'     hotspot = 'X' )
    ( fieldname = 'FLDATE'    seltext_l = '航班日期' )
    ( fieldname = 'CARRNAME'  seltext_l = '航空公司名称' )
    ( fieldname = 'PRICE'     seltext_l = '票价'         do_sum = 'X' ) ).
  DATA(ls_layout) = VALUE slis_layout_alv( zebra = 'X' colwidth_optimize = 'X' ).

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING i_callback_program = sy-repid
              i_callback_user_command = 'USER_COMMAND'
              i_callback_top_of_page = 'TOP_OF_PAGE'
              is_layout = ls_layout it_fieldcat = lt_fieldcat
    TABLES t_outtab = gt_sflight.
ENDFORM.

FORM user_command USING p_ucomm TYPE sy-ucomm p_selfield TYPE slis_selfield.
  CHECK p_ucomm = '&IC1'.
  READ TABLE gt_sflight INTO DATA(ls_sel) INDEX p_selfield-tabindex.
  IF sy-subrc = 0.
    PERFORM show_bookings USING ls_sel-carrid ls_sel-connid ls_sel-fldate.
  ENDIF.
ENDFORM.

FORM top_of_page.
  DATA(lt_list) = VALUE slis_t_listheader(
    ( typ = 'H' info = '航班信息列表' )
    ( typ = 'S' info = |日期: { sy-datum DATE = ISO }| ) ).
  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING it_list_commentary = lt_list.
ENDFORM.

FORM show_bookings USING p_carrid TYPE s_carr_id p_connid TYPE s_conn_id p_fldate TYPE s_date.
  SELECT bookid, customid, loccuram, luggweight
    FROM sbook WHERE carrid = @p_carrid AND connid = @p_connid AND fldate = @p_fldate
    INTO TABLE @DATA(lt_sbook).
  IF lt_sbook IS INITIAL.
    MESSAGE i000(oo) WITH '该航班暂无预订记录'. RETURN.
  ENDIF.
  DATA(lt_fc) = VALUE slis_t_fieldcat_alv(
    ( fieldname = 'BOOKID'      seltext_l = '预订号' )
    ( fieldname = 'CUSTOMID'    seltext_l = '客户号' )
    ( fieldname = 'LOCCURAM'    seltext_l = '本地金额' )
    ( fieldname = 'LUGGWEIGHT'   seltext_l = '行李重量' ) ).
  DATA(ls_layout) = VALUE slis_layout_alv(
    zebra = 'X' colwidth_optimize = 'X'
    window_titlebar = |旅客预订 - { p_carrid } { p_connid }| ).
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING is_layout = ls_layout it_fieldcat = lt_fc
    TABLES t_outtab = lt_sbook.
ENDFORM.
```

## 代码拆解要点

1. USER_COMMAND 回调的触发机制
2. rs_selfield-tabindex 读取当前行数据
3. Hotspot 设置与双击事件的关系
4. Top-of-Page 的回调机制
5. 二次 ALV 的调用方式

## 💡 实战经验

- **SET HANDLER 的顺序**：事件处理器的注册顺序决定了触发顺序。多个 handler 处理同一事件时，先注册的先执行——需要注意副作用
- **二级 ALV 的弹出方式**：用 cl_salv_table 的工厂方法创建第二个 ALV 实例时，传入不同的容器即可弹出独立窗口。不要在同一个容器上覆盖——会报错
- **传递数据的最佳实践**：通过事件参数（如 e_row → index）获取当前行号，再从内表中取数据——比通过屏幕字段传值更可靠
- **Toolbar 按钮自定义**：在 ALV 工具栏上添加自定义按钮，可以实现"导出 Excel"、"发送邮件"等功能，比在报表选择屏幕上放按钮更符合用户操作习惯

## 课后思考

1. 如何判断用户点击了哪个字段？
2. 如何在 ALV 中添加自定义按钮？
3. 二次 ALV 显示时，如何返回到主列表？
