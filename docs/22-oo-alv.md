# 第22课：OO ALV —— 面向对象的报表开发

> 45分钟 | 阶段：现代开发篇

## 前置依赖

- 第10课：了解 ALV 基础
- 第11课：了解 ALV 交互事件
- 第13课：了解 ABAP OO 基础（类、方法、事件）

## 问题引入

前面学的 CL_SALV_TABLE 是"快速方案"——几行代码就能展示数据，但定制性有限。如果需求是"自定义工具栏按钮、右键菜单、单元格编辑、动态列隐藏"等高级功能，就需要使用底层的 CL_GUI_ALV_GRID。这节课把 ALV 开发提升到"专业级"。

## 时间安排

| 时段 | 内容 | 时长 |
|------|------|------|
| 场景引入 | CL_SALV_TABLE 的局限性 / 什么时候需要 CL_GUI_ALV_GRID | 3 分钟 |
| Demo 演示 | 展示带自定义工具栏和单元格编辑的 ALV 报表 | 5 分钟 |
| 代码拆解 | CL_GUI_ALV_GRID、Screen Painter、容器、事件注册、布局管理 | 28 分钟 |
| 知识总结 | CL_SALV_TABLE vs CL_GUI_ALV_GRID 对比、开发流程图 | 6 分钟 |
| 课后思考 | 练习 | 3 分钟 |

## 本课目标

掌握 CL_GUI_ALV_GRID 的使用方法，能创建带自定义工具栏和交互功能的专业级 ALV 报表。

## Demo

用 CL_GUI_ALV_GRID 创建航班管理报表：自定义工具栏按钮（导出、刷新）、双击行查看明细、单元格可编辑修改航班价格。

## 知识点

### 1. OO ALV vs Function ALV 对比
- 灵活性（自定义事件、布局）
- 性能（大数据量）
- 扩展性（自定义 Toolbar、Cell Event）
- MVC 模式支持

### 2. 容器体系
- CL_GUI_CUSTOM_CONTAINER（自定义区域容器）
- CL_GUI_DOCKING_CONTAINER（停靠容器）
- CL_GUI_SPLITTER_CONTAINER（分割容器）
- Docking vs Custom Container 的选择

### 3. CL_GUI_ALV_GRID 核心
- 创建实例：NEW cl_gui_alv_grid( i_parent = mo_container )
- SET_TABLE_FOR_FIRST_DISPLAY
  - Field Catalog（LVC_T_FCAT）——比 SLIS 更强
  - Layout（LVC_S_LAYO）
- REFRESH_TABLE_DISPLAY（刷新数据）

### 4. 字段目录 LVC_T_FCAT
- LVC_S_FCAT 关键字段
  - FIELDNAME / REF_TABLE / REF_FIELD
  - EDIT / HOTSPOT / TECH / EMPHASIZE
- 自动生成：LVC_FIELDCATALOG_MERGE
- 新语法 VALUE 构造

### 5. 事件处理
- SET_HANDLER 注册事件处理方法
- 事件类型：
  - DOUBLE_CLICK
  - DATA_CHANGED
  - TOOLBAR
  - USER_COMMAND
- Event Handler Method 的签名

### 6. 自定义 Toolbar
- TOOLBAR 事件
- stb_button 结构
- APPEND / MODIFY 工具栏按钮

### 7. 完整开发流程（MVC 思路简要提及）

## Demo 代码

```abap
REPORT zac_oo_alv.

" 全局数据
TYPES: BEGIN OF ty_alv_data,
         carrid   TYPE sflight-carrid,
         connid   TYPE sflight-connid,
         fldate   TYPE sflight-fldate,
         price    TYPE sflight-price,
         seatsmax TYPE sflight-seatsmax,
         seatsocc TYPE sflight-seatsocc,
       END OF ty_alv_data.

CLASS lcl_app DEFINITION.
  PUBLIC SECTION.
    METHODS:
      constructor,
      display_data,
      refresh_data.
  PRIVATE SECTION.
    DATA: mo_container TYPE REF TO cl_gui_custom_container,
          mo_grid     TYPE REF TO cl_gui_alv_grid,
          mt_data     TYPE STANDARD TABLE OF ty_alv_data.
    METHODS:
      handle_double_click FOR EVENT double_click OF cl_gui_alv_grid
        IMPORTING e_row e_column,
      handle_toolbar FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING e_object,
      handle_user_command FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING e_ucomm,
      build_fieldcat RETURNING VALUE(rt_fcat) TYPE lvc_t_fcat.
ENDCLASS.

CLASS lcl_app IMPLEMENTATION.
  METHOD constructor.
    " 创建容器
    CREATE OBJECT mo_container
      EXPORTING container_name = 'CC_ALV'.
    " 创建 ALV Grid
    CREATE OBJECT mo_grid
      EXPORTING i_parent = mo_container.
    " 查询数据
    SELECT carrid, connid, fldate, price, seatsmax, seatsocc
      FROM sflight INTO TABLE @mt_data
      UP TO 50 ROWS.
    " 注册事件
    SET HANDLER: me->handle_double_click,
                 me->handle_toolbar,
                 me->handle_user_command
      FOR mo_grid.
  ENDMETHOD.

  METHOD display_data.
    DATA(ls_layout) = VALUE lvc_s_layo(
      zebra = abap_true
      cwidth_opt = abap_true
      sel_mode = 'A' ).
    mo_grid->set_table_for_first_display(
      EXPORTING
        is_layout       = ls_layout
      CHANGING
        it_outtab       = mt_data
        it_fieldcatalog = build_fieldcat( ) ).
  ENDMETHOD.

  METHOD build_fieldcat.
    rt_fcat = VALUE lvc_t_fcat(
      ( fieldname = 'CARRID'   ref_table = 'SFLIGHT' ref_field = 'CARRID' hotspot = 'X' )
      ( fieldname = 'CONNID'   ref_table = 'SFLIGHT' ref_field = 'CONNID' hotspot = 'X' )
      ( fieldname = 'FLDATE'   ref_table = 'SFLIGHT' ref_field = 'FLDATE' )
      ( fieldname = 'PRICE'    ref_table = 'SFLIGHT' ref_field = 'PRICE'  do_sum = 'X' )
      ( fieldname = 'SEATSMAX' ref_table = 'SFLIGHT' ref_field = 'SEATSMAX' do_sum = 'X' )
      ( fieldname = 'SEATSOCC' ref_table = 'SFLIGHT' ref_field = 'SEATSOCC' do_sum = 'X' )
    ).
  ENDMETHOD.

  METHOD handle_double_click.
    READ TABLE mt_data INTO DATA(ls_row) INDEX e_row-index.
    IF sy-subrc = 0.
      MESSAGE i000(oo) WITH |{ ls_row-carrid }-{ ls_row-connid }| |票价: { ls_row-price }|.
    ENDIF.
  ENDMETHOD.

  METHOD handle_toolbar.
    DATA(ls_btn) = VALUE stb_button(
      function  = 'EXPORT'
      icon      = '@16@'  " 导出图标
      quickinfo = '导出 Excel'
      text      = '导出' ).
    APPEND ls_btn TO e_object->mt_toolbar.
  ENDMETHOD.

  METHOD handle_user_command.
    CASE e_ucomm.
      WHEN 'EXPORT'.
        " 导出逻辑（调用 Function Module）
        PERFORM export_to_excel USING mt_data.
    ENDCASE.
  ENDMETHOD.

  METHOD refresh_data.
    SELECT carrid, connid, fldate, price, seatsmax, seatsocc
      FROM sflight INTO TABLE @mt_data.
    mo_grid->refresh_table_display( ).
  ENDMETHOD.
ENDCLASS.

" 全局引用
DATA: go_app TYPE REF TO lcl_app.

PARAMETERS: p_carrid TYPE sflight-carrid DEFAULT 'AA'.

START-OF-SELECTION.
  go_app = NEW lcl_app( ).
  go_app->display_data( ).
  CALL SCREEN 100.

" 导出 Form
FORM export_to_excel USING pt_data TYPE STANDARD TABLE.
  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filename = |flight_{ sy-datum }.csv|
      filetype = 'ASC'
    TABLES
      data_tab = pt_data.
  IF sy-subrc = 0.
    MESSAGE s000(oo) WITH '导出成功'.
  ENDIF.
ENDFORM.
```

## 代码拆解要点

1. CL_GUI_CUSTOM_CONTAINER 与 Screen 的关系
2. CL_GUI_ALV_GRID 的创建与首次显示
3. LVC_T_FCAT vs SLIS_T_FIELDCAT_ALV 的区别
4. SET_HANDLER 事件注册机制
5. TOOLBAR 事件中修改工具栏
6. Function ALV vs OO ALV 的完整对比

## 💡 实战经验

- **Screen Painter 是绕不过去的**：使用 CL_GUI_ALV_GRID 必须先在 Screen Painter（SE51）中画一个容器（Custom Control），然后代码中把 ALV Grid 放到容器里。Screen 操作是 SAP GUI 时代的产物，初次使用会觉得繁琐
- **PAI/PBO 事件**：Screen 的 PBO（Process Before Output）和 PAI（Process After Input）是两个关键事件。PBO 中准备数据，PAI 中处理用户操作——理解这两个事件是掌握 Screen 编程的关键
- **布局持久化**：CL_GUI_ALV_GRID 支持用户保存个性化布局（列顺序、宽度、排序等）。通过 `SET_TABLE_FOR_FIRST_DISPLAY` 的参数 `is_variant` 和 `i_save` 控制
- **性能提示**：数据量超过 10 万行时，考虑使用 ALV 的分页功能或改用 CL_SALV_TABLE 的分页模式——全量加载会导致界面卡顿

## 课后思考

1. OO ALV 必须在 Screen 中使用吗？能在 List 程序中用吗？
2. 如何让 OO ALV 中的字段变为可编辑状态？
3. 尝试在 TOOLBAR 中添加一个"刷新"按钮。
