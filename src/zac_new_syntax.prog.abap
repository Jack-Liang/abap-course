*&---------------------------------------------------------------------*
*& Report ZAC_NEW_SYNTAX
*&---------------------------------------------------------------------*
*& 第19课：新语法专题
*& 系统对比新旧写法：VALUE/CORRESPONDING/COND/SWITCH/FOR/REDUCE/FILTER
*&---------------------------------------------------------------------*
REPORT zac_new_syntax.

START-OF-SELECTION.
  " 对比1：内联声明
  SELECT * FROM sflight INTO TABLE @DATA(lt_sflight).

  " 对比2：VALUE 构造（SORTED 表类型，为对比5 FILTER 铺垫）
  TYPES ty_flight_tab TYPE SORTED TABLE OF sflight
                          WITH NON-UNIQUE KEY carrid.
  DATA(lt_tab) = VALUE ty_flight_tab(
    ( carrid = 'AA' connid = '0017' fldate = '20260730' seatsmax = 200 )
    ( carrid = 'DL' connid = '0100' fldate = '20260730' seatsmax = 180 )
    ( carrid = 'UA' connid = '0941' fldate = '20260730' seatsmax = 350 ) ).

  " 对比3：COND
  LOOP AT lt_tab INTO DATA(ls).
    DATA(lv_status) = COND string(
      WHEN ls-seatsocc >= ls-seatsmax THEN '已满'
      WHEN ls-seatsocc > ls-seatsmax * 8 / 10 THEN '紧张'
      ELSE '可订' ).
    WRITE: / |{ ls-carrid }-{ ls-connid } { lv_status }|.
  ENDLOOP.

  " 对比4：REDUCE
  DATA(lv_total) = REDUCE i(
    INIT sum = 0
    FOR ls IN lt_tab
    NEXT sum = sum + ls-seatsmax ).
  WRITE: / |总座位: { lv_total }|.

  " 对比5：FILTER（要求表带合适键，走主键 carrid）
  DATA(lt_aa) = FILTER #( lt_tab WHERE carrid = 'AA' ).
  WRITE: / |AA 航班: { lines( lt_aa ) }|.

  " 对比6：SWITCH
  DATA(lv_name) = SWITCH string(
    'AA' WHEN 'AA' THEN 'American Airlines'
                WHEN 'DL' THEN 'Delta Air Lines'
                WHEN 'UA' THEN 'United Airlines'
                ELSE '未知' ).
  WRITE: / lv_name.

  " 对比7：FOR 构造 + CORRESPONDING
  TYPES: BEGIN OF ty_short,
           carrid TYPE s_carr_id,
           connid TYPE s_conn_id,
           price  TYPE s_price,
         END OF ty_short,
         ty_short_tab TYPE STANDARD TABLE OF ty_short WITH EMPTY KEY.
  DATA(lt_short) = VALUE ty_short_tab(
    FOR ls IN lt_sflight
    ( CORRESPONDING #( ls ) ) ).
  WRITE: / |短表行数: { lines( lt_short ) }|.
