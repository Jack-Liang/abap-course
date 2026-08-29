*&---------------------------------------------------------------------*
*& Report ZAC_FORMATTING
*&---------------------------------------------------------------------*
*& 第8课：数据格式化 —— 字符串、日期、货币
*& 演示字符串操作、字符串模板、日期函数、货币格式
*&---------------------------------------------------------------------*
REPORT zac_formatting.

START-OF-SELECTION.
  " 新语法 && 字符串拼接
  DATA(lv_name) = 'AA' && '-' && '0017'.
  WRITE: / |航线: { lv_name }|.

  " 字符串模板格式化
  SELECT SINGLE carrid, carrname, currcode
    FROM scarr INTO @DATA(ls_carr) WHERE carrid = 'AA'.
  WRITE: / |航空公司: { ls_carr-carrname } 货币: { ls_carr-currcode }|.

  " 日期格式化
  DATA(lv_date) = '20260730'.
  WRITE: / |原始: { lv_date }|.
  WRITE: / |ISO: { lv_date DATE = ISO }|.
  WRITE: / |用户格式: { lv_date DATE = USER }|.

  " 货币格式化——CURR 存的是内部格式，展示必须带币种语义
  DATA(lv_price) = 1500.
  WRITE: / |票价(USD): { lv_price CURRENCY = 'USD' }|.   " → 15.00
  WRITE: / |票价(JPY): { lv_price CURRENCY = 'JPY' }|.   " → 1,500

  " SPLIT
  SPLIT 'AA,0017,20260730' AT ',' INTO
    @DATA(lv_a) @DATA(lv_b) @DATA(lv_c).
  WRITE: / |拆分: { lv_a } / { lv_b } / { lv_c }|.

  " REPLACE 新语法
  DATA(lv_result) = replace(
    val = |Hello ABAP World|
    sub = 'World'
    with = 'SAP' ).
  WRITE: / lv_result.

  " COND 条件表达式
  DATA(lv_seatsocc) = 180.
  DATA(lv_seatsmax) = 200.
  DATA(lv_status) = COND string(
    WHEN lv_seatsocc >= lv_seatsmax THEN '已满'
    WHEN lv_seatsocc > lv_seatsmax * 8 / 10 THEN '紧张'
    ELSE '可订' ).
  WRITE: / |状态: { lv_status }|.
