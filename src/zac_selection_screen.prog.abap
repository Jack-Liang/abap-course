*&---------------------------------------------------------------------*
*& Report ZAC_SELECTION_SCREEN
*&---------------------------------------------------------------------*
*& 第7课：选择屏幕
*& 演示 PARAMETERS/SELECT-OPTIONS、屏幕事件、输入校验
*&---------------------------------------------------------------------*
REPORT zac_selection_screen.

" 块标题必须是变量名或文本符号，不接受字面量
DATA title_b1 TYPE c LENGTH 40 VALUE '航班查询条件'.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE title_b1.
PARAMETERS: p_carrid TYPE sflight-carrid OBLIGATORY DEFAULT 'AA'.
SELECT-OPTIONS: s_connid FOR sflight-connid NO-EXTENSION,
                s_date   FOR sflight-fldate,
                s_seats  FOR sflight-seatsocc.
SELECTION-SCREEN END OF BLOCK b1.

AT SELECTION-SCREEN ON p_carrid.
  SELECT SINGLE carrid FROM scarr INTO @DATA(lv_check)
    WHERE carrid = @p_carrid.
  IF sy-subrc <> 0.
    MESSAGE e001(zac_flight_msg) WITH p_carrid.  " 航空公司代码 &1 不存在
  ENDIF.

START-OF-SELECTION.
  SELECT carrid, connid, fldate, seatsmax, seatsocc, price
    FROM sflight
    WHERE carrid = @p_carrid
      AND connid IN @s_connid
      AND fldate IN @s_date
      AND seatsocc IN @s_seats
    INTO TABLE @DATA(lt_sflight).

  IF lt_sflight IS INITIAL.
    WRITE: / '未找到符合条件的航班'.
  ELSE.
    LOOP AT lt_sflight INTO DATA(ls).
      WRITE: / |{ ls-carrid } { ls-connid } { ls-fldate } 座位 { ls-seatsocc }/{ ls-seatsmax }|.
    ENDLOOP.
    WRITE: / |共 { lines( lt_sflight ) } 条记录|.
  ENDIF.
