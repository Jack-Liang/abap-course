*&---------------------------------------------------------------------*
*& Include ZAC_FLIGHT_SEL
*&---------------------------------------------------------------------*
*& 第24课：综合实战 —— 选择屏幕（第7课）
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-b01.
PARAMETERS p_carrid TYPE s_carr_id OBLIGATORY DEFAULT 'AA'.
SELECT-OPTIONS s_date FOR sflight-fldate.
SELECTION-SCREEN END OF BLOCK b1.

" 航空公司代码存在性校验（第18课：消息类）
AT SELECTION-SCREEN ON p_carrid.
  SELECT SINGLE carrid FROM scarr
    WHERE carrid = @p_carrid
    INTO @DATA(lv_carrid).
  IF sy-subrc <> 0.
    MESSAGE ID 'ZAC_FLIGHT_MSG' TYPE 'E' NUMBER 001 WITH p_carrid.
  ENDIF.
