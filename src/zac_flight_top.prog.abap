*&---------------------------------------------------------------------*
*& Include ZAC_FLIGHT_TOP
*&---------------------------------------------------------------------*
*& 第24课：综合实战 —— 全局声明（顶层 INCLUDE）
*&---------------------------------------------------------------------*

TABLES: sflight.

" 视图类要引用控制器，先延迟声明（第13课）
CLASS lcl_flight_app DEFINITION DEFERRED.

" 输出行结构：CDS 行 + 两个计算列
TYPES: BEGIN OF ty_flight_detail.
        INCLUDE TYPE zac_flight_detail.        " CDS 字段整建制引入（第20课）
TYPES:  status      TYPE string,             " 状态：已满/紧张/可订
        load_factor TYPE p LENGTH 5 DECIMALS 2, " 上座率（%）
       END OF ty_flight_detail.
TYPES ty_t_flight_detail TYPE STANDARD TABLE OF ty_flight_detail WITH EMPTY KEY.

*&---------------------------------------------------------------------*
*& 视图层：Screen 100 + Custom Container 方案（第22课）
*&---------------------------------------------------------------------*
CLASS lcl_alv_display DEFINITION.
  PUBLIC SECTION.
    METHODS:
      constructor IMPORTING io_app TYPE REF TO lcl_flight_app,
      set_data    IMPORTING it_data TYPE ty_t_flight_detail,
      display,                                     " CALL SCREEN 100
      refresh     IMPORTING it_data TYPE ty_t_flight_detail,
      pbo.                                         " PBO 回调：首次建容器与 Grid
  PRIVATE SECTION.
    DATA: mo_app       TYPE REF TO lcl_flight_app,
          mo_container TYPE REF TO cl_gui_custom_container,
          mo_grid      TYPE REF TO cl_gui_alv_grid,
          mt_data      TYPE ty_t_flight_detail.
    METHODS:
      build_fieldcat RETURNING VALUE(rt_fcat) TYPE lvc_t_fcat,
      handle_double_click FOR EVENT double_click OF cl_gui_alv_grid
        IMPORTING e_row e_column,
      handle_toolbar FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING e_object,
      handle_user_command FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING e_ucomm.
ENDCLASS.

*&---------------------------------------------------------------------*
*& 控制器层：取数 / 编排 / 预订 / 导出
*&---------------------------------------------------------------------*
CLASS lcl_flight_app DEFINITION.
  PUBLIC SECTION.
    METHODS:
      get_data,                                    " CDS 取数 + 计算列
      display,                                     " 建视图并展示
      pbo,                                         " 转调视图的 pbo
      create_booking IMPORTING iv_carrid TYPE s_carr_id
                               iv_connid TYPE s_conn_id
                               iv_fldate TYPE s_date,
      export_to_csv.
  PRIVATE SECTION.
    DATA: mt_data TYPE ty_t_flight_detail,
          mo_alv  TYPE REF TO lcl_alv_display.
ENDCLASS.

" 全局对象与 OK 码
DATA: go_app  TYPE REF TO lcl_flight_app,
      ok_code TYPE sy-ucomm.
