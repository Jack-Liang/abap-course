*&---------------------------------------------------------------------*
*& Report ZAC_OO_BASIC
*&---------------------------------------------------------------------*
*& 第13课：ABAP 面向对象编程（基础）
*& 演示 CLASS/INTERFACE/NEW/TRY-CATCH
*&---------------------------------------------------------------------*
REPORT zac_oo_basic.

INTERFACE lif_flight_query.
  METHODS:
    get_flights EXPORTING et_sflight TYPE sflight_tab,
    get_flight_detail IMPORTING iv_connid TYPE s_conn_id
                                iv_fldate TYPE s_date
                      RETURNING VALUE(rs_detail) TYPE sflight.
ENDINTERFACE.

CLASS lcl_flight_query DEFINITION.
  PUBLIC SECTION.
    INTERFACES: lif_flight_query.
    METHODS:
      constructor IMPORTING iv_carrid TYPE s_carr_id OPTIONAL.
    DATA: mv_carrid TYPE s_carr_id READ-ONLY.
  PRIVATE SECTION.
    DATA: mv_status TYPE string.
ENDCLASS.

CLASS lcl_flight_query IMPLEMENTATION.
  METHOD constructor.
    mv_carrid = COND #( WHEN iv_carrid IS NOT INITIAL THEN iv_carrid ELSE 'AA' ).
    mv_status = '已初始化'.
  ENDMETHOD.

  METHOD lif_flight_query~get_flights.
    SELECT * FROM sflight WHERE carrid = @mv_carrid INTO TABLE @et_sflight.
  ENDMETHOD.

  METHOD lif_flight_query~get_flight_detail.
    SELECT SINGLE * FROM sflight
      WHERE carrid = @mv_carrid AND connid = @iv_connid AND fldate = @iv_fldate
      INTO @rs_detail.
    IF rs_detail IS INITIAL.
      RAISE EXCEPTION TYPE cx_sy_open_sql_db.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.
  " NEW 创建对象
  DATA(lo_query) = NEW lcl_flight_query( 'AA' ).
  WRITE: / |当前航空公司: { lo_query->mv_carrid }|.

  " 调用接口方法
  DATA(lt_flights) = lo_query->lif_flight_query~get_flights( ).
  WRITE: / |共查询到 { lines( lt_flights ) } 条航班|.
  LOOP AT lt_flights INTO @DATA(ls).
    WRITE: / |  { ls-carrid } { ls-connid } { ls-fldate }|.
  ENDLOOP.

  " 异常处理
  TRY.
      DATA(ls_detail) = lo_query->lif_flight_query~get_flight_detail(
        iv_connid = '0017' iv_fldate = '20260730' ).
      WRITE: / |详情: 票价 { ls_detail-price }, 座位 { ls_detail-seatsocc }/{ ls_detail-seatsmax }|.
    CATCH cx_sy_open_sql_db INTO DATA(lx_error).
      WRITE: / |未找到航班: { lx_error->get_text( ) }|.
  ENDTRY.
