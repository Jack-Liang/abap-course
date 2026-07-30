*&---------------------------------------------------------------------*
*& Report ZDEMO07_SELECTION_SCREEN
*&---------------------------------------------------------------------*
*& 第7课：选择屏幕
*& 演示 PARAMETERS/SELECT-OPTIONS、屏幕事件、输入校验
*&---------------------------------------------------------------------*
REPORT zdemo07_selection_screen.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
PARAMETERS: p_carrid TYPE sflight-carrid OBLIGATORY DEFAULT 'AA',
            p_connid TYPE sflight-connid.
SELECT-OPTIONS: s_date  FOR sy-datum NO-EXTENSION,
                s_seats FOR sflight-seatsocc.
SELECTION-SCREEN END OF BLOCK b1.

INITIALIZATION.
  %_p_carrid%_text = '航空公司'.
  %_p_connid%_text = '航线编号'.
  %_s_date%_text   = '航班日期'.

AT SELECTION-SCREEN ON p_carrid.
  SELECT SINGLE carrid FROM scarr INTO @DATA(lv_check)
    WHERE carrid = @p_carrid.
  IF sy-subrc <> 0.
    MESSAGE e001(00) WITH p_carrid.
  ENDIF.

START-OF-SELECTION.
  SELECT carrid, connid, fldate, seatsmax, seatsocc, price
    FROM sflight
    WHERE carrid = @p_carrid
      AND connid IN @s_connid
      AND fldate IN @s_date
    INTO TABLE @DATA(lt_sflight).

  IF lt_sflight IS INITIAL.
    WRITE: / '未找到符合条件的航班'.
  ELSE.
    LOOP AT lt_sflight INTO @DATA(ls).
      WRITE: / |{ ls-carrid } { ls-connid } { ls-fldate } 座位 { ls-seatsocc }/{ ls-seatsmax }|.
    ENDLOOP.
    WRITE: / |共 { lines( lt_sflight ) } 条记录|.
  ENDIF.
