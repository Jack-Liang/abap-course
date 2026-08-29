*&---------------------------------------------------------------------*
*& Report ZAC_CALL_FUNCTION
*&---------------------------------------------------------------------*
*& 第9课：Function Module（函数模块）
*& 演示 CALL FUNCTION 调用 ZAC_CALC_FLIGHT_DURATION
*& 前置：先按课文步骤（或 ref-source/zac_flight_utils/）创建函数组与 FM
*&---------------------------------------------------------------------*
REPORT zac_call_function.

START-OF-SELECTION.
  " 出参显式声明接收——CALL FUNCTION 里的 DATA(...) 内联声明是 7.52+ 语法，
  " 7.40/7.50 环境会报 "inline declaration not possible in this position"
  DATA: lv_found      TYPE abap_bool,
        lv_minutes    TYPE i,
        lv_distance   TYPE s_distance,
        lv_cityfrom   TYPE s_from_cit,
        lv_cityto     TYPE s_to_city.

  CALL FUNCTION 'ZAC_CALC_FLIGHT_DURATION'
    EXPORTING
      iv_carrid       = 'AA'
      iv_connid       = '0017'
    IMPORTING
      ev_found        = lv_found
      ev_duration_min = lv_minutes
      ev_distance     = lv_distance
      ev_cityfrom     = lv_cityfrom
      ev_cityto       = lv_cityto
    EXCEPTIONS
      not_found       = 1
      OTHERS          = 2.

  IF sy-subrc <> 0.
    WRITE: / '未找到航线信息'.
  ELSE.
    WRITE: / |{ lv_cityfrom } → { lv_cityto }|.
    WRITE: / |飞行时长: { lv_minutes } 分钟, 距离: { lv_distance }|.
  ENDIF.
