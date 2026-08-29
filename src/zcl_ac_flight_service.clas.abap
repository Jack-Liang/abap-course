"! 航班业务逻辑服务类（第14课引入封装范式，第24课综合实战复用）
CLASS zcl_ac_flight_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    CLASS-METHODS:
      "! 调 BAPI 创建预订：内部完成 RET2 检查与 COMMIT/ROLLBACK。
      "! 成功返回系统分配的真实预订号；失败返回初值，原因放 ev_message。
      create_booking
        IMPORTING iv_carrid        TYPE s_carr_id
                  iv_connid        TYPE s_conn_id
                  iv_fldate        TYPE s_date
        EXPORTING ev_message       TYPE string
        RETURNING VALUE(rv_bookid) TYPE s_bookid,
      "! 教学占位（课后练习）：真实项目走后续单据流程，这里保持空实现
      cancel_booking
        IMPORTING iv_carrid TYPE s_carr_id
                  iv_connid TYPE s_conn_id
                  iv_fldate TYPE s_date
                  iv_bookid TYPE s_bookid,
      get_flight_info
        IMPORTING iv_carrid TYPE s_carr_id
                  iv_connid TYPE s_conn_id
                  iv_fldate TYPE s_date
        RETURNING VALUE(rs_info) TYPE sflight.

ENDCLASS.

CLASS zcl_ac_flight_service IMPLEMENTATION.

  METHOD create_booking.
    CLEAR: rv_bookid, ev_message.

    " BAPI 需要真实存在的客户与旅行社——各取一行演示数据
    SELECT SINGLE id FROM scustom INTO @DATA(lv_customerid).
    SELECT SINGLE agencynum FROM stravelag INTO @DATA(lv_agencynum).

    DATA(ls_bookdata) = VALUE bapisbonew(
      airlineid  = iv_carrid
      connectid  = iv_connid
      flightdate = iv_fldate
      customerid = lv_customerid
      agencynum  = lv_agencynum
      class      = 'Y'
      passname   = |ABAP Course { sy-uname }| ).

    DATA: lt_return TYPE STANDARD TABLE OF bapiret2 WITH EMPTY KEY,
          ls_return TYPE bapiret2.
    " 预订号显式声明——CALL FUNCTION 里的 DATA(...) 内联声明是 7.52+ 语法
    DATA lv_bookingnumber TYPE s_bookid.

    CALL FUNCTION 'BAPI_FLBOOKING_CREATEFROMDATA'
      EXPORTING
        booking_data  = ls_bookdata
      IMPORTING
        bookingnumber = lv_bookingnumber
      TABLES
        return        = lt_return.

    " BAPI 判据纪律：成败只看 RET2 的 TYPE（E/A 同罪），不看出参
    READ TABLE lt_return INTO ls_return WITH KEY type = 'E'.
    IF sy-subrc <> 0.
      READ TABLE lt_return INTO ls_return WITH KEY type = 'A'.
    ENDIF.

    IF sy-subrc = 0.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      ev_message = |{ ls_return-type }: { ls_return-message }|.
      RETURN.
    ENDIF.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
    rv_bookid = lv_bookingnumber.
  ENDMETHOD.

  METHOD cancel_booking.
    RETURN.
  ENDMETHOD.

  METHOD get_flight_info.
    SELECT SINGLE * FROM sflight
      WHERE carrid = @iv_carrid AND connid = @iv_connid AND fldate = @iv_fldate
      INTO @rs_info.
  ENDMETHOD.

ENDCLASS.
