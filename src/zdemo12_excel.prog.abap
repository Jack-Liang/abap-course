*&---------------------------------------------------------------------*
*& Report ZDEMO12_EXCEL
*&---------------------------------------------------------------------*
*& 第12课：Excel 导入导出
*& 演示 GUI_DOWNLOAD/GUI_UPLOAD、CSV 解析、导入校验
*&---------------------------------------------------------------------*
REPORT zdemo12_excel.

START-OF-SELECTION.
  " === 第一部分：导出 SFLIGHT 到 CSV ===
  SELECT * FROM sflight INTO TABLE @DATA(lt_sflight) UP TO 100 ROWS.

  DATA(lv_default) = |sflight_{ sy-datum }.csv|.
  DATA: lv_fullpath TYPE string.

  CALL FUNCTION 'GUI_FILE_SAVE_DIALOG'
    EXPORTING
      default_extension = 'csv'
      default_file_name = lv_default
    IMPORTING
      fullpath          = lv_fullpath.

  IF lv_fullpath IS NOT INITIAL.
    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        filename              = lv_fullpath
        filetype              = 'ASC'
        write_field_separator = 'X'
        codepage              = '4110'
      TABLES
        data_tab              = lt_sflight
      EXCEPTIONS
        file_write_error      = 1.
    IF sy-subrc = 0.
      WRITE: / |导出成功: { lv_fullpath }|.
    ENDIF.
  ENDIF.

  " === 第二部分：从 CSV 导入航班数据 ===
  DATA: lt_upload TYPE TABLE OF string.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename  = 'import_flights.csv'
      filetype  = 'ASC'
    TABLES
      data_tab  = lt_upload
    EXCEPTIONS
      file_open_error = 1.

  IF sy-subrc = 0.
    DATA: lv_success TYPE i, lv_error TYPE i.
    LOOP AT lt_upload INTO @DATA(lv_line).
      SPLIT lv_line AT ',' INTO
        @DATA(lv_carrid) @DATA(lv_connid)
        @DATA(lv_fldate)  @DATA(lv_price).

      IF lv_carrid IS INITIAL.
        lv_error = lv_error + 1.
        WRITE: / |第 { sy-tabix } 行数据不完整，跳过|.
        CONTINUE.
      ENDIF.

      DATA(ls_flight) = VALUE sflight(
        carrid = lv_carrid connid = lv_connid
        fldate = lv_fldate price  = lv_price ).
      MODIFY sflight FROM @ls_flight.
      IF sy-subrc = 0.
        lv_success = lv_success + 1.
      ENDIF.
    ENDLOOP.
    COMMIT WORK.
    WRITE: / |导入完成: 成功 { lv_success }, 失败 { lv_error }|.
  ENDIF.