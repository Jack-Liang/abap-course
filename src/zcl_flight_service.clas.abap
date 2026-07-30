" 航班业务逻辑服务类（第24课综合实战）
CLASS zcl_flight_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    CLASS-METHODS:
      create_booking
        IMPORTING iv_carrid TYPE s_carr_id
                  iv_connid TYPE s_conn_id
                  iv_fldate TYPE s_date
        RETURNING VALUE(rv_bookid) TYPE s_bookid,
      cancel_booking
        IMPORTING iv_carrid  TYPE s_carr_id
                  iv_connid  TYPE s_conn_id
                  iv_fldate  TYPE s_date
                  iv_bookid  TYPE s_bookid,
      get_flight_info
        IMPORTING iv_carrid TYPE s_carr_id
                  iv_connid TYPE s_conn_id
                  iv_fldate TYPE s_date
        RETURNING VALUE(rs_info) TYPE sflight.

ENDCLASS.

CLASS zcl_flight_service IMPLEMENTATION.

  METHOD create_booking.
    " 调用 BAPI 创建预订（实际实现请根据系统 BAPI 调整）
    rv_bookid = '00000001'.
    WRITE: / |BAPI 创建预订: { iv_carrid }-{ iv_connid }-{ iv_fldate }|.
  ENDMETHOD.

  METHOD cancel_booking.
    WRITE: / |取消预订: { iv_carrid }-{ iv_connid }-{ iv_fldate }-{ iv_bookid }|.
  ENDMETHOD.

  METHOD get_flight_info.
    SELECT SINGLE * FROM sflight
      WHERE carrid = @iv_carrid AND connid = @iv_connid AND fldate = @iv_fldate
      INTO @rs_info.
  ENDMETHOD.

ENDCLASS.
