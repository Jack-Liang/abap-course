*&---------------------------------------------------------------------*
*& Report ZAC_BAPI
*&---------------------------------------------------------------------*
*& 第14课：BAPI 调用
*& 演示标准 Flight BAPI 创建预订、RET2 判据、事务控制
*&---------------------------------------------------------------------*
REPORT zac_bapi.

START-OF-SELECTION.
  " 1. 取一条真实航班作预订目标——写死的日期在演示数据里未必存在
  SELECT SINGLE carrid, connid, fldate
    FROM sflight
    WHERE carrid = 'AA'
    INTO @DATA(ls_flight).

  IF sy-subrc <> 0.
    WRITE: / 'SFLIGHT 里没有 AA 的航班，先回第0课生成演示数据'.
    RETURN.
  ENDIF.

  " 2. 组装预订数据（BAPISBONEW 是该 BAPI 自带的入参结构）
  "    客户与旅行社也取真实存在的行，外键校验才过得去
  SELECT SINGLE id FROM scustom INTO @DATA(lv_customerid).
  SELECT SINGLE agencynum FROM stravelag INTO @DATA(lv_agencynum).

  DATA ls_bookdata TYPE bapisbonew.
  ls_bookdata-airlineid  = ls_flight-carrid.
  ls_bookdata-connectid  = ls_flight-connid.
  ls_bookdata-flightdate = ls_flight-fldate.
  ls_bookdata-customerid = lv_customerid.
  ls_bookdata-agencynum  = lv_agencynum.
  ls_bookdata-class      = 'Y'.
  ls_bookdata-passname   = |课程学员 { sy-uname }|.

  " 3. 调用 BAPI：结构化入参 + RET2 返回表 + 出参预订号
  DATA lt_return TYPE STANDARD TABLE OF bapiret2 WITH EMPTY KEY.
  " 预订号显式声明——CALL FUNCTION 里的 DATA(...) 内联声明是 7.52+ 语法
  DATA lv_bookid TYPE s_book_id.

  CALL FUNCTION 'BAPI_FLBOOKING_CREATEFROMDATA'
    EXPORTING
      booking_data  = ls_bookdata
    IMPORTING
      bookingnumber = lv_bookid
    TABLES
      return        = lt_return.

  " 4. 成败只看 RET2 的 TYPE（E/A 同罪）——不是只看出参！
  DATA(lv_ok) = abap_true.
  LOOP AT lt_return INTO DATA(ls_return).
    WRITE: / |RET2[{ ls_return-type }] { ls_return-message }|.
    IF ls_return-type CA 'EA'.
      lv_ok = abap_false.
    ENDIF.
  ENDLOOP.

  " 5. 成功才提交，失败即回滚——BAPI 的事务铁律
  IF lv_ok = abap_true.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING wait = 'X'.
    WRITE: / |预订创建成功! 预订号: { lv_bookid }|.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    WRITE: / '预订创建失败，已回滚'.
  ENDIF.
