*&---------------------------------------------------------------------*
*& Report ZAC_CDS_BASIC
*&---------------------------------------------------------------------*
*& 第20课：CDS View（基础）
*& 演示 CDS 视图的消费：zac_flight_detail 当表查
*&---------------------------------------------------------------------*
REPORT zac_cds_basic.

START-OF-SELECTION.
  " CDS 视图当"表"用——JOIN 已经住在视图里
  SELECT * FROM zac_flight_detail
    INTO TABLE @DATA(lt_flights)
    UP TO 20 ROWS.

  LOOP AT lt_flights INTO DATA(ls).
    WRITE: / |{ ls-carrname } { ls-cityfrom } → { ls-cityto } { ls-price } { ls-currcode }|.
  ENDLOOP.

  WRITE: / |共 { lines( lt_flights ) } 条|.
