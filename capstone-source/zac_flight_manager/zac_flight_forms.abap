*&---------------------------------------------------------------------*
*& Include ZAC_FLIGHT_FORMS
*&---------------------------------------------------------------------*
*& 第24课：综合实战 —— 两个本地类的实现（视图层 + 控制器层）
*&---------------------------------------------------------------------*

CLASS lcl_alv_display IMPLEMENTATION.

  METHOD constructor.
    mo_app = io_app.     " 视图持有控制器引用，事件只做"翻译"
  ENDMETHOD.

  METHOD set_data.
    mt_data = it_data.
  ENDMETHOD.

  METHOD display.
    CALL SCREEN 100.     " 触发 PBO → status_0100 → 回调本类 pbo
  ENDMETHOD.

  METHOD pbo.
    " 首次 PBO 时创建容器与 Grid（第22课）；此后每次 PBO 不再重建
    IF mo_grid IS NOT BOUND.
      mo_container = NEW cl_gui_custom_container( container_name = 'CUST_FLIGHT' ).
      mo_grid = NEW cl_gui_alv_grid( i_parent = mo_container ).

      SET HANDLER: me->handle_double_click,
                   me->handle_toolbar,
                   me->handle_user_command FOR mo_grid.

      DATA(ls_layout) = VALUE lvc_s_layo(
        zebra = abap_true cwidth_opt = abap_true ).
      mo_grid->set_table_for_first_display(
        EXPORTING is_layout       = ls_layout
        CHANGING  it_outtab       = mt_data
                  it_fieldcatalog = build_fieldcat( ) ).
    ENDIF.
  ENDMETHOD.

  METHOD build_fieldcat.
    " 字段目录：前 9 列引用 DDIC 字段自动取列头与格式，
    " 后 2 列为计算列，无 ref_table，手工给中文列头
    rt_fcat = VALUE lvc_t_fcat(
      ( fieldname = 'CARRID'      ref_table = 'SFLIGHT' ref_field = 'CARRID'   hotspot = 'X' )
      ( fieldname = 'CONNID'      ref_table = 'SFLIGHT' ref_field = 'CONNID'   hotspot = 'X' )
      ( fieldname = 'FLDATE'      ref_table = 'SFLIGHT' ref_field = 'FLDATE' )
      ( fieldname = 'CARRNAME'    ref_table = 'SCARR'   ref_field = 'CARRNAME' )
      ( fieldname = 'CITYFROM'    ref_table = 'SPFLI'   ref_field = 'CITYFROM' )
      ( fieldname = 'CITYTO'      ref_table = 'SPFLI'   ref_field = 'CITYTO' )
      ( fieldname = 'PRICE'       ref_table = 'SFLIGHT' ref_field = 'PRICE'    do_sum = 'X' )
      ( fieldname = 'SEATSMAX'    ref_table = 'SFLIGHT' ref_field = 'SEATSMAX' do_sum = 'X' )
      ( fieldname = 'SEATSOCC'    ref_table = 'SFLIGHT' ref_field = 'SEATSOCC' do_sum = 'X' )
      ( fieldname = 'LOAD_FACTOR' scrtext_m = '上座率' coltext = '上座率' )
      ( fieldname = 'STATUS'      scrtext_m = '状态'   coltext = '状态' ) ).
  ENDMETHOD.

  METHOD handle_double_click.
    " 事件只做"翻译"：读当前行 → 交控制器处理，业务不在视图层
    READ TABLE mt_data INTO DATA(ls_row) INDEX e_row-index.
    CHECK sy-subrc = 0.
    mo_app->create_booking( iv_carrid = ls_row-carrid
                            iv_connid = ls_row-connid
                            iv_fldate = ls_row-fldate ).
  ENDMETHOD.

  METHOD handle_toolbar.
    " 自定义工具栏：追加导出按钮（第22课写法）
    DATA(ls_btn) = VALUE stb_button(
      function = 'ZEXPORT' icon = '@16@' quickinfo = '导出 CSV' text = '导出' ).
    APPEND ls_btn TO e_object->mt_toolbar.
  ENDMETHOD.

  METHOD handle_user_command.
    CASE e_ucomm.
      WHEN 'ZEXPORT'.
        mo_app->export_to_csv( ).
    ENDCASE.
  ENDMETHOD.

  METHOD refresh.
    " 数据变了 → 视图跟着刷；保持光标/滚动位置
    mt_data = it_data.
    IF mo_grid IS BOUND.
      mo_grid->refresh_table_display(
        is_stable = VALUE lvc_s_stbl( row = 'X' col = 'X' ) ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.

CLASS lcl_flight_app IMPLEMENTATION.

  METHOD get_data.
    " 数据层：CDS 视图 + 选择屏幕条件（第5/7/20课合体）
    SELECT * FROM zac_flight_detail
      WHERE carrid = @p_carrid AND fldate IN @s_date
      INTO CORRESPONDING FIELDS OF TABLE @mt_data.

    " 加工层：表达式计算上座率与状态（第19课 COND）
    LOOP AT mt_data ASSIGNING FIELD-SYMBOL(<fs>).
      <fs>-load_factor = COND #( WHEN <fs>-seatsmax > 0
                                 THEN <fs>-seatsocc * 100 / <fs>-seatsmax
                                 ELSE 0 ).
      <fs>-status = COND string(
        WHEN <fs>-seatsocc >= <fs>-seatsmax THEN '已满'
        WHEN <fs>-load_factor > 80          THEN '紧张'
        ELSE '可订' ).
    ENDLOOP.

    " WITH 后传字符串模板最稳妥（内建函数在某些版本的操作数位上有类型限制）
    MESSAGE ID 'ZAC_FLIGHT_MSG' TYPE 'S' NUMBER 004 WITH |{ lines( mt_data ) }|.
  ENDMETHOD.

  METHOD display.
    mo_alv = NEW lcl_alv_display( me ).
    mo_alv->set_data( mt_data ).
    mo_alv->display( ).            " CALL SCREEN 100 → PBO 起容器
  ENDMETHOD.

  METHOD pbo.
    IF mo_alv IS BOUND.
      mo_alv->pbo( ).
    ENDIF.
  ENDMETHOD.

  METHOD create_booking.
    " 满员校验：先查内存表当前行（第18课消息类）
    READ TABLE mt_data INTO DATA(ls_flight)
      WITH KEY carrid = iv_carrid
               connid = iv_connid
               fldate = iv_fldate.
    IF sy-subrc = 0 AND ls_flight-seatsocc >= ls_flight-seatsmax.
      " TYPE 'S' 在 PAI 后显示在屏幕状态栏，不打断流程
      MESSAGE ID 'ZAC_FLIGHT_MSG' TYPE 'S' NUMBER 002.
      RETURN.
    ENDIF.

    " 业务层：复用第14课封装好的服务类（BAPI + RET2 + COMMIT 全在里面）
    DATA lv_msg TYPE string.
    DATA(lv_bookid) = zcl_ac_flight_service=>create_booking(
      EXPORTING
        iv_carrid  = iv_carrid
        iv_connid  = iv_connid
        iv_fldate  = iv_fldate
      IMPORTING
        ev_message = lv_msg ).             " 失败原因（成功为空）
    IF lv_bookid IS INITIAL.
      MESSAGE lv_msg TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.                              " 失败：不刷数据，用户重试
    ENDIF.
    MESSAGE ID 'ZAC_FLIGHT_MSG' TYPE 'S' NUMBER 003
      WITH iv_carrid iv_connid lv_bookid.

    " 数据变了 → 重新取数 → 视图跟着刷
    get_data( ).
    mo_alv->refresh( mt_data ).
  ENDMETHOD.

  METHOD export_to_csv.
    " 文件名带 ISO 日期：flight_YYYYMMDD.csv
    DATA(lv_filename) = |flight_{ sy-datum DATE = ISO }.csv|.

    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        filename              = lv_filename
        filetype              = 'ASC'
        write_field_separator = 'X'
      TABLES
        data_tab              = mt_data
      EXCEPTIONS
        OTHERS                = 1.

    IF sy-subrc = 0.
      MESSAGE ID 'ZAC_FLIGHT_MSG' TYPE 'S' NUMBER 005 WITH lv_filename.
    ELSE.
      MESSAGE |导出失败：{ lv_filename }| TYPE 'E'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
