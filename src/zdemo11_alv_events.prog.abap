*&---------------------------------------------------------------------*
*& Report ZDEMO11_ALV_EVENTS
*&---------------------------------------------------------------------*
*& 第11课：ALV 交互事件
*& 演示 USER_COMMAND、Hotspot、Top-of-Page、Drill-Down
*&---------------------------------------------------------------------*
REPORT zdemo11_alv_events.

TYPES: BEGIN OF ty_sflight,
         carrid   TYPE sflight-carrid,
         connid   TYPE sflight-connid,
         fldate   TYPE sflight-fldate,
         price    TYPE sflight-price,
         carrname TYPE scarr-carrname,
       END OF ty_sflight.

DATA: gt_sflight TYPE TABLE OF ty_sflight.

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

FORM user_command USING p_ucomm    TYPE sy-ucomm
                       p_selfield TYPE slis_selfield.
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

FORM show_bookings USING p_carrid TYPE s_carr_id
                         p_connid TYPE s_conn_id
                         p_fldate TYPE s_date.
  SELECT bookid, customid, loccuram, luggweight
    FROM sbook
    WHERE carrid = @p_carrid AND connid = @p_connid AND fldate = @p_fldate
    INTO TABLE @DATA(lt_sbook).
  IF lt_sbook IS INITIAL.
    MESSAGE i000(oo) WITH '该航班暂无预订记录'. RETURN.
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
