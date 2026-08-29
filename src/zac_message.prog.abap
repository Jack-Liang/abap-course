*&---------------------------------------------------------------------*
*& Report ZAC_MESSAGE
*&---------------------------------------------------------------------*
*& 第18课：消息处理（Message Class）
*& 演示消息类创建与使用、MESSAGE 语句、MESSAGE INTO 内联
*&---------------------------------------------------------------------*
REPORT zac_message.

" 消息类 ZAC_FLIGHT_MSG：
" 001 航空公司代码 &1 不存在
" 002 航班已满，无法预订
" 003 预订成功：&1-&2-&3
" 004 查询完成，共 &1 条记录
" 005 数据已导出至 &1

PARAMETERS: p_carrid TYPE s_carr_id OBLIGATORY.

AT SELECTION-SCREEN ON p_carrid.
  SELECT SINGLE carrid FROM scarr INTO @DATA(lv_check)
    WHERE carrid = @p_carrid.
  IF sy-subrc <> 0.
    MESSAGE e001(zac_flight_msg) WITH p_carrid.
  ENDIF.

START-OF-SELECTION.
  SELECT COUNT(*) FROM sflight
    WHERE carrid = @p_carrid
    INTO @DATA(lv_count).
  MESSAGE s004(zac_flight_msg) WITH lv_count.

  SELECT SINGLE * FROM sflight INTO @DATA(ls_f)
    WHERE carrid = @p_carrid AND connid = '0017'.
  IF sy-subrc <> 0.
    MESSAGE e002(zac_flight_msg) INTO DATA(lv_msg).
    WRITE: / lv_msg.
  ELSE.
    WRITE: / |航班 { ls_f-carrid }-{ ls_f-connid }|.
    WRITE: / |已占/最大: { ls_f-seatsocc }/{ ls_f-seatsmax }|.
    WRITE: / |票价: { ls_f-price }|.
  ENDIF.
