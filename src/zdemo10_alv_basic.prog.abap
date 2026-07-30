*&---------------------------------------------------------------------*
*& Report ZDEMO10_ALV_BASIC
*&---------------------------------------------------------------------*
*& 第10课：ALV 报表（基础）
*& 演示 REUSE_ALV_GRID_DISPLAY、Field Catalog、Layout
*&---------------------------------------------------------------------*
REPORT zdemo10_alv_basic.

START-OF-SELECTION.
  SELECT f~carrid, f~connid, f~fldate, f~seatsmax,
         f~seatsocc, f~price, c~carrname
    FROM sflight AS f
    INNER JOIN scarr AS c ON f~carrid = c~carrid
    INTO TABLE @DATA(lt_sflight).

  " VALUE 构造 Field Catalog
  DATA(lt_fieldcat) = VALUE slis_t_fieldcat_alv(
    ( fieldname = 'CARRID'    seltext_l = '航空公司代码' outputlen = 10 )
    ( fieldname = 'CONNID'    seltext_l = '航线编号'     outputlen = 10 )
    ( fieldname = 'FLDATE'    seltext_l = '航班日期'     outputlen = 12 )
    ( fieldname = 'CARRNAME' seltext_l = '航空公司名称' outputlen = 20 )
    ( fieldname = 'SEATSMAX'  seltext_l = '最大座位'     outputlen = 12 do_sum = 'X' )
    ( fieldname = 'SEATSOCC'  seltext_l = '已占座位'     outputlen = 12 do_sum = 'X' )
    ( fieldname = 'PRICE'     seltext_l = '票价'         outputlen = 15 do_sum = 'X' )
  ).

  DATA(ls_layout) = VALUE slis_layout_alv(
    zebra = 'X'
    colwidth_optimize = 'X'
    totals_text = '合计' ).

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
