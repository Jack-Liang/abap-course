*&---------------------------------------------------------------------*
*& Report ZAC_EXCEL
*&---------------------------------------------------------------------*
*& 第12课：Excel 导入导出
*& 演示 GUI_DOWNLOAD/GUI_UPLOAD、文件对话框、CSV 解析、导入校验
*&---------------------------------------------------------------------*
REPORT zac_excel.

START-OF-SELECTION.
  " === 第一部分：导出 zac_flight_ext 到 CSV（TAB 分隔） ===
  " 显式列清单不带 MANDT——客户端字段不该进文件
  SELECT carrid, connid, fldate, remark, priority
    FROM zac_flight_ext
    INTO TABLE @DATA(lt_ext).

  IF lines( lt_ext ) = 0.
    WRITE: / 'zac_flight_ext 无数据——先回第3课在 SE16 录入两三行，再回来导出'.
    RETURN.
  ENDIF.

  DATA(lv_default) = |flight_ext_{ sy-datum }.csv|.
  DATA lv_fullpath TYPE string.

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
        write_field_separator = 'X'      " 列间加 TAB 分隔符
        codepage              = '4110'   " UTF-8，中文必需
      TABLES
        data_tab              = lt_ext
      EXCEPTIONS
        file_write_error      = 1
        OTHERS                = 2.
    IF sy-subrc = 0.
      WRITE: / |导出成功: { lv_fullpath }|.
    ENDIF.
  ENDIF.

  " === 第二部分：从 CSV 导回（打开对话框选文件 + 逐行校验 + 回写） ===
  " 不硬编码路径：让用户像导出时一样用对话框选文件
  DATA: lt_files TYPE filetable,
        lv_rc    TYPE i.

  cl_gui_frontend_services=>file_open_dialog(
    EXPORTING
      window_title            = '选择要导入的 CSV 文件'
    CHANGING
      file_table              = lt_files
      rc                      = lv_rc
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      OTHERS                  = 4 ).
  IF sy-subrc <> 0 OR lv_rc = 0.
    WRITE: / '未选择文件，导入取消'.
    RETURN.
  ENDIF.
  READ TABLE lt_files INTO DATA(ls_file) INDEX 1.

  DATA: lt_upload TYPE TABLE OF string.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename        = ls_file-filename
      filetype        = 'ASC'
      codepage        = '4110'
    TABLES
      data_tab        = lt_upload
    EXCEPTIONS
      file_open_error = 1
      OTHERS          = 2.

  IF sy-subrc = 0.
    DATA: lv_success TYPE i,
          lv_error   TYPE i,
          ls_ext     TYPE zac_flight_ext.
    LOOP AT lt_upload INTO DATA(lv_line).
      " 导出用的 TAB 分隔符，导入端必须用同一个字符拆
      SPLIT lv_line AT cl_abap_char_utilities=>horizontal_tab INTO
        DATA(lv_carrid) DATA(lv_connid) DATA(lv_fldate)
        DATA(lv_remark) DATA(lv_priority).

      IF lv_carrid IS INITIAL.
        lv_error = lv_error + 1.
        WRITE: / |第 { sy-tabix } 行数据不完整，跳过|.
        CONTINUE.
      ENDIF.

      " MODIFY = 存在即更新、不存在即新增；客户端字段 MANDT 由系统自动补当前 Client
      ls_ext = VALUE #( carrid   = lv_carrid
                        connid   = lv_connid
                        fldate   = lv_fldate
                        remark   = lv_remark
                        priority = lv_priority ).
      MODIFY zac_flight_ext FROM @ls_ext.
      IF sy-subrc = 0.
        lv_success = lv_success + 1.
      ENDIF.
    ENDLOOP.
    COMMIT WORK.
    WRITE: / |导入完成: 成功 { lv_success }, 失败 { lv_error }|.
  ENDIF.
