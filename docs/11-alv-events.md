---
status: draft
---

# 第11课：ALV 交互事件

> 45分钟 | 阶段：核心篇 | 建议边读边做

## 前置依赖

- [第10课](10-alv-basic.md)：能跑起 REUSE ALV。

## 问题引入

静态报表只能"看"，用户要的是"点"：双击一行航班，钻到该航班的旅客预订明细；点一下热点列，跳转主数据。这叫 **Drill-Down（钻取）**——报表从"纸"进化成"入口"。本课给 ALV 装上交互：`USER_COMMAND` 回调、Hotspot 热点列、Top-of-Page 页头。

## 时间安排

| 时段 | 内容 | 时长 |
|------|------|------|
| 场景引入 | 从"看"到"点"：钻取需求 | 3 分钟 |
| Demo 跟做 | 双击航班 → 预订明细二级 ALV | 8 分钟 |
| 代码拆解 | 回调机制 / rs_selfield / Top-of-Page / 交互模式 | 26 分钟 |
| 知识总结 | 常用功能码与交互模式速查 | 5 分钟 |
| 课后思考 | 练习 | 3 分钟 |

## 本课目标

完成本课你将能够：

- 用 `i_callback_user_command` 接管 ALV 的用户动作；
- 读懂 `slis_selfield`（点了哪行哪列）并实现双击钻取；
- 把列配成 Hotspot（单击即触发）；
- 用 `REUSE_ALV_COMMENTARY_WRITE` 画出带标题/条件的页头；
- 说出三种常见交互模式（二级 ALV / 跳事务码 / 弹窗）。

## Demo：双击钻取预订明细（分步跟做）

SE38 运行 `zac_alv_events`（已随仓库下发）：

```abap
REPORT zac_alv_events.

TYPES: BEGIN OF ty_sflight,
         carrid   TYPE sflight-carrid,
         connid   TYPE sflight-connid,
         fldate   TYPE sflight-fldate,
         price    TYPE sflight-price,
         carrname TYPE scarr-carrname,
       END OF ty_sflight.

DATA: gt_sflight TYPE TABLE OF ty_sflight.   " 全局：回调 FORM 要访问

START-OF-SELECTION.
  SELECT f~carrid, f~connid, f~fldate, f~price, c~carrname
    FROM sflight AS f
    INNER JOIN scarr AS c ON f~carrid = c~carrid
    INTO CORRESPONDING FIELDS OF TABLE @gt_sflight.
  PERFORM display_alv.

FORM display_alv.
  DATA(lt_fieldcat) = VALUE slis_t_fieldcat_alv(
    ( fieldname = 'CARRID'   seltext_l = '航空公司代码' hotspot = 'X' )
    ( fieldname = 'CONNID'   seltext_l = '航线编号'     hotspot = 'X' )
    ( fieldname = 'FLDATE'   seltext_l = '航班日期' )
    ( fieldname = 'CARRNAME' seltext_l = '航空公司名称' )
    ( fieldname = 'PRICE'    seltext_l = '票价'         do_sum = 'X' ) ).

  DATA(ls_layout) = VALUE slis_layout_alv(
    zebra = 'X' colwidth_optimize = 'X' ).

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = sy-repid
      i_callback_user_command  = 'USER_COMMAND'
      i_callback_top_of_page   = 'TOP_OF_PAGE'
      is_layout                = ls_layout
      it_fieldcat              = lt_fieldcat
    TABLES
      t_outtab                 = gt_sflight.
ENDFORM.

" ① 交互回调：系统在用户操作后调这个 FORM
FORM user_command USING p_ucomm    TYPE sy-ucomm
                       p_selfield TYPE slis_selfield.
  CHECK p_ucomm = '&IC1'.                      " &IC1 = 双击/热点
  READ TABLE gt_sflight INTO DATA(ls_sel) INDEX p_selfield-tabindex.
  IF sy-subrc = 0.
    PERFORM show_bookings USING ls_sel-carrid ls_sel-connid ls_sel-fldate.
  ENDIF.
ENDFORM.

" ② 页头
FORM top_of_page.
  DATA(lt_list) = VALUE slis_t_listheader(
    ( typ = 'H' info = '航班信息列表' )
    ( typ = 'S' info = |日期: { sy-datum DATE = ISO }| ) ).
  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING it_list_commentary = lt_list.
ENDFORM.

" ③ 二级 ALV：按主键行查 SBOOK 明细
FORM show_bookings USING p_carrid TYPE s_carr_id
                         p_connid TYPE s_conn_id
                         p_fldate TYPE s_date.
  SELECT bookid, customid, loccuram, luggweight
    FROM sbook
    WHERE carrid = @p_carrid AND connid = @p_connid AND fldate = @p_fldate
    INTO TABLE @DATA(lt_sbook).
  IF lt_sbook IS INITIAL.
    MESSAGE '该航班暂无预订记录' TYPE 'I'. RETURN.
  ENDIF.
  DATA(lt_fc) = VALUE slis_t_fieldcat_alv(
    ( fieldname = 'BOOKID'     seltext_l = '预订号' )
    ( fieldname = 'CUSTOMID'   seltext_l = '客户号' )
    ( fieldname = 'LOCCURAM'   seltext_l = '本地金额' )
    ( fieldname = 'LUGGWEIGHT' seltext_l = '行李重量' ) ).
  DATA(ls_layout) = VALUE slis_layout_alv(
    zebra = 'X' colwidth_optimize = 'X'
    window_titlebar = |旅客预订 - { p_carrid } { p_connid }| ).
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING is_layout = ls_layout it_fieldcat = lt_fc
    TABLES t_outtab = lt_sbook.
ENDFORM.
```

**跟做两步：**

1. F8 → 列表带页头（标题 + 日期）；**双击任意航班行** → 弹出该航班的旅客预订二级列表（窗口标题带公司/航线）；
2. **单击** CARRID 列的值（热点列，鼠标变手型）→ 同样触发钻取——热点是"单击即发"，双击是标准交互。

<!-- 配图（待截图后启用）：![双击钻取预订明细](https://cdn.jsdelivr.net/gh/jack-liang/abap-course-assets@main/11-alv-events/drilldown-sbook.png) -->

## 知识点

### 1. 回调机制：ALV 怎么找到你的 FORM

```abap
i_callback_program      = sy-repid        " 你的程序
i_callback_user_command = 'USER_COMMAND'  " FORM 名（字符串）
i_callback_top_of_page  = 'TOP_OF_PAGE'
```

ALV（通用控件）在用户操作时**反向调用你程序里的 FORM**——这就是回调：你把"处理函数的名字"告诉它，它在合适的时机调用。`i_callback_program` 就是让它知道去哪个程序里找。这是"控制反转"的 FM 风格实现（第13课 OO 版叫 SET HANDLER，思想相同）。

### 2. USER_COMMAND 的两个参数

```abap
FORM user_command USING p_ucomm    TYPE sy-ucomm
                       p_selfield TYPE slis_selfield.
```

- **p_ucomm 功能码**：`&IC1` = 双击或热点点击（最常用）；自定义工具栏按钮的功能码（第22课自定义）也走这里；
- **p_selfield 现场信息**：

| 字段 | 含义 |
|------|------|
| `TABINDEX` | 点击的行号（内表索引） |
| `FIELDNAME` | 点击的列 |
| `VALUE` | 该单元格值 |
| `REFRESH` | 置 'X' 让 ALV 刷新显示（改完内表后用） |

**标准动作**：`READ TABLE gt_sflight INDEX p_selfield-tabindex` 拿到整行数据——这就是"从点击定位到数据"的完整链条。

### 3. Hotspot：让单元格变按钮

Field Catalog 里 `hotspot = 'X'` 的列：文字带下划线、鼠标手型、**单击即触发 `&IC1`**（不用双击）。适合"编号类"字段做钻取入口；别满屏热点——交互要有节制。

### 4. Top-of-Page：ALV 的页头画布

```abap
( typ = 'H' info = '大标题' )      " H 标题（大字）
( typ = 'S' info = '选择: ...' )   " S 键值行（小字）
```

`REUSE_ALV_COMMENTARY_WRITE` 把这个内表渲染成 ALV 顶部的页头。**好习惯**：把选择屏幕的条件回显在页头（第7课的选择参数），用户打印/截图时条件一目了然。

### 5. 三种常见交互模式

```abap
" A. 二级 ALV（本课 Demo）：明细列表再铺一层
PERFORM show_bookings USING ...

" B. 跳转事务码并带上当前行（"带着数据去别的界面"类需求）
" 前提：目标事务码的首屏幕字段挂了对应的记忆 ID——F1 帮助 → Technical
" info 里的 "Parameter ID" 就是它（'CAR' 是航空公司代码的记忆 ID）
SET PARAMETER ID 'CAR' FIELD ls_sel-carrid.
CALL TRANSACTION '<目标事务码>' AND SKIP FIRST SCREEN.  " 填实际存在的目标

" C. 弹窗确认（删除/提交前确认）
CALL FUNCTION 'POPUP_TO_CONFIRM' ...
```

## 💡 实战经验

!!! tip "数据表必须全局（或至少回调可见）"

    回调 FORM 由 ALV 调起，访问的是程序全局数据——所以 `gt_sflight` 声明在 START-OF-SELECTION 之外。把内表声明进事件块里，回调读不到，是新手高频翻车点。

!!! tip "改了内表记得 p_selfield-refresh"

    回调里改数据（如更新行状态）后置 `p_selfield-refresh = 'X'`，ALV 才会重画；不设的话数据变了显示还是旧的。

!!! tip "钻取链别超过三层"

    一级→二级→三级是用户耐心极限；更深的层次应重新设计导航（或者想想是不是该做事务码/ Fiori 页面了）。

## 📖 延伸阅读

- [ABAP Keyword Documentation](https://help.sap.com/doc/abapdocu_752_index_htm/7.52/en-US/index.htm)——`slis_selfield` 结构与 REUSE 回调文档。

## 课后思考

> 把你的回答写在**页面底部评论区**，注明题号，一起讨论。

1. `&IC1` 是什么？除了它你还猜有哪些功能码会进 USER_COMMAND？
2. Hotspot 列和普通列双击的触发差异是什么？各自适合什么场景？
3. 动手：给二级 ALV 的 CUSTOMID 列加热点，双击客户号再钻一层（SCUSTOM 客户主数据，含姓名/城市）——把你的 FORM 贴出来。
4. 回调里为什么要 `READ TABLE ... INDEX p_selfield-tabindex` 而不是直接用 `p_selfield-value`？（提示：value 是"点击的那个格子"，你要的是什么？）

---

下一课：[第12课：Excel 导入导出](12-excel.md)
