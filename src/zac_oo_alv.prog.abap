*&---------------------------------------------------------------------*
*& Report ZAC_OO_ALV
*&---------------------------------------------------------------------*
*& 第22课：OO ALV（面向对象 ALV）
*& 演示 CL_GUI_ALV_GRID、Docking Container、事件注册、自定义工具栏
*&---------------------------------------------------------------------*
REPORT zac_oo_alv.

CLASS lcl_app DEFINITION.
  PUBLIC SECTION.
    METHODS: constructor, display_data.
  PRIVATE SECTION.
    DATA: mo_container TYPE REF TO cl_gui_docking_container,
          mo_grid      TYPE REF TO cl_gui_alv_grid,
          mt_data      TYPE STANDARD TABLE OF sflight.
    METHODS:
      handle_double_click FOR EVENT double_click OF cl_gui_alv_grid
        IMPORTING e_row e_column,
      handle_toolbar FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING e_object,
      handle_user_command FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING e_ucomm.
ENDCLASS.

CLASS lcl_app IMPLEMENTATION.
  METHOD constructor.
    " 停靠容器：直接挂在选择屏幕上，无需 Screen Painter 画屏
    mo_container = NEW cl_gui_docking_container(
                      repid     = sy-repid
                      dynnr     = sy-dynnr
                      side      = cl_gui_docking_container=>dock_at_bottom
                      extension = 200 ).
    mo_grid = NEW cl_gui_alv_grid( i_parent = mo_container ).
    SELECT * FROM sflight INTO TABLE @mt_data UP TO 50 ROWS.
    SET HANDLER:
      me->handle_double_click,
      me->handle_toolbar,
      me->handle_user_command FOR mo_grid.
  ENDMETHOD.

  METHOD display_data.
    DATA(ls_layout) = VALUE lvc_s_layo(
      zebra = abap_true cwidth_opt = abap_true ).
    DATA(lt_fcat) = VALUE lvc_t_fcat(
      ( fieldname = 'CARRID'    ref_table = 'SFLIGHT' ref_field = 'CARRID' hotspot = 'X' )
      ( fieldname = 'CONNID'    ref_table = 'SFLIGHT' ref_field = 'CONNID' hotspot = 'X' )
      ( fieldname = 'FLDATE'    ref_table = 'SFLIGHT' ref_field = 'FLDATE' )
      ( fieldname = 'PRICE'     ref_table = 'SFLIGHT' ref_field = 'PRICE' do_sum = 'X' )
      ( fieldname = 'SEATSMAX'  ref_table = 'SFLIGHT' ref_field = 'SEATSMAX' do_sum = 'X' )
      ( fieldname = 'SEATSOCC'  ref_table = 'SFLIGHT' ref_field = 'SEATSOCC' do_sum = 'X' ) ).
    mo_grid->set_table_for_first_display(
      EXPORTING is_layout = ls_layout
      CHANGING  it_outtab = mt_data it_fieldcatalog = lt_fcat ).
  ENDMETHOD.

  METHOD handle_double_click.
    READ TABLE mt_data INTO DATA(ls_row) INDEX e_row-index.
    IF sy-subrc = 0.
      MESSAGE |{ ls_row-carrid }-{ ls_row-connid } 票价 { ls_row-price }| TYPE 'I'.
    ENDIF.
  ENDMETHOD.

  METHOD handle_toolbar.
    DATA(ls_btn) = VALUE stb_button(
      function = 'ZEXPORT' icon = '@16@' quickinfo = '导出 CSV' text = '导出' ).
    APPEND ls_btn TO e_object->mt_toolbar.
  ENDMETHOD.

  METHOD handle_user_command.
    CASE e_ucomm.
      WHEN 'ZEXPORT'.
        CALL FUNCTION 'GUI_DOWNLOAD'
          EXPORTING filename = |flight_{ sy-datum }.csv| filetype = 'ASC'
          TABLES data_tab = mt_data.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.

INITIALIZATION.
  " 在选择屏幕阶段挂载 ALV：屏幕出现即见表格，事件即时可交互
  DATA(go_app) = NEW lcl_app( ).
  go_app->display_data( ).
