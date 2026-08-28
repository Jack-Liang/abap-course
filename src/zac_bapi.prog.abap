*&---------------------------------------------------------------------*
*& Report ZAC_BAPI
*&---------------------------------------------------------------------*
*& 第14课：BAPI 调用
*& 演示 BAPI 创建/查询预订、RETURN_INFO 处理、事务控制
*&---------------------------------------------------------------------*
REPORT zac_bapi.

START-OF-SELECTION.
  DATA: lt_booking TYPE TABLE OF bapisbook,
        ls_booking TYPE bapisbook,
        lt_return  TYPE TABLE OF bapiret2.

  ls_booking-carrid   = 'AA'.
  ls_booking-connid   = '0017'.
  ls_booking-fldate   = '20260730'.
  ls_booking-bookid   = '00000001'.
  ls_booking-customid = '00000001'.
  ls_booking-class    = 'Y'.
  APPEND ls_booking TO lt_booking.

  CALL FUNCTION 'BAPI_SBOOK_CREATE'
    IMPORTING
      booking_number = DATA(lv_bookid)
    TABLES
      booking_data   = lt_booking
      return         = lt_return.

  " 检查返回消息
  LOOP AT lt_return INTO DATA(ls_return) WHERE type = 'E' OR type = 'A'.
    WRITE: / |错误: { ls_return-message }|.
  ENDLOOP.

  " 提交事务
  IF lv_bookid IS NOT INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT' EXPORTING wait = 'X'.
    WRITE: / |预订创建成功! 预订号: { lv_bookid }|.
  ELSE.
    WRITE: / '预订创建失败'.
  ENDIF.

  " 查询预订详情
  CALL FUNCTION 'BAPI_SBOOK_GETDETAIL'
    EXPORTING
      booking_number = lv_bookid
    TABLES
      booking_detail = lt_booking.

  LOOP AT lt_booking INTO ls_booking.
    WRITE: / |预订: { ls_booking-carrid }-{ ls_booking-connid }-{ ls_booking-fldate }|.
  ENDLOOP.