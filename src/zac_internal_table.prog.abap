*&---------------------------------------------------------------------*
*& Report ZAC_INTERNAL_TABLE
*&---------------------------------------------------------------------*
*& 第4课：内表与结构体操作
*& 演示内表声明、FOR/CORRESPONDING/REDUCE 新语法
*&---------------------------------------------------------------------*
REPORT zac_internal_table.

TYPES: ty_carrid_tab TYPE SORTED TABLE OF s_carr_id
                       WITH UNIQUE KEY table_line,
       BEGIN OF ty_count,
         carrid TYPE s_carr_id,
         cnt    TYPE i,
       END OF ty_count,
       ty_count_tab TYPE SORTED TABLE OF ty_count
                       WITH UNIQUE KEY carrid.

START-OF-SELECTION.
  " 读取航班数据
  SELECT * FROM sflight INTO TABLE @DATA(lt_sflight).

  " FOR 表推导式 —— 提取不重复的航空公司
  " （UNIQUE KEY 是去重的关键：缺了它只排序、不去重）
  DATA(lt_carrids) = VALUE ty_carrid_tab(
    FOR ls IN lt_sflight
    ( ls-carrid )
  ).
  WRITE: / |航空公司数量: { lines( lt_carrids ) }|.

  " FOR GROUPS —— 按航空公司分组统计航班数
  DATA(lt_summary) = VALUE ty_count_tab(
    FOR GROUPS grp OF ls IN lt_sflight
      GROUP BY ( carrid = ls-carrid cnt = GROUP SIZE )
    ( carrid = grp-carrid cnt = grp-cnt )
  ).
  LOOP AT lt_summary INTO DATA(ls_grp).
    WRITE: / |{ ls_grp-carrid }: { ls_grp-cnt } 条航班|.
  ENDLOOP.

  " REDUCE 累加 —— 总已占座位
  DATA(lv_total) = REDUCE i(
    INIT sum = 0
    FOR ls IN lt_sflight
    NEXT sum = sum + ls-seatsocc
  ).
  WRITE: / |总已占座位: { lv_total }|.
