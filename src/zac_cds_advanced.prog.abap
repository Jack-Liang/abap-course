*&---------------------------------------------------------------------*
*& Report ZAC_CDS_ADVANCED
*&---------------------------------------------------------------------*
*& 第21课：CDS View（进阶）
*& 演示参数化 CDS 视图的消费：zac_flight_stats( p_carrid = ... )
*&---------------------------------------------------------------------*
REPORT zac_cds_advanced.

START-OF-SELECTION.
  " 参数化 CDS：调用时传参，语法像函数
  SELECT * FROM zac_flight_stats( p_carrid = 'AA' )
    INTO TABLE @DATA(lt_stats).

  IF lines( lt_stats ) > 0.
    READ TABLE lt_stats INTO DATA(ls_stats) INDEX 1.
    WRITE: / |航空公司: { ls_stats-carrid }|.
    WRITE: / |航班数量: { ls_stats-flight_count }|.
    WRITE: / |平均票价: { ls_stats-avg_price }|.
    WRITE: / |总占座/总座位: { ls_stats-total_occupied }/{ ls_stats-total_seats }|.
  ELSE.
    WRITE: / '未找到统计数据'.
  ENDIF.
