*&---------------------------------------------------------------------*
*& Report ZDEMO04_INTERNAL_TABLE
*&---------------------------------------------------------------------*
*& 第4课：内表与结构体操作
*& 演示内表声明、FOR/CORRESPONDING/REDUCE 新语法
*&---------------------------------------------------------------------*
REPORT zdemo04_internal_table.

START-OF-SELECTION.
  " 读取航班数据
  SELECT * FROM sflight INTO TABLE @DATA(lt_sflight).

  " FOR 循环表达式 —— 提取不重复的航空公司
  DATA(lt_carrids) = VALUE SORTED TABLE OF s_carr_id(
    FOR ls IN lt_sflight
    NEXT ( ls-carrid )
  ).
  WRITE: / |航空公司数量: { lines( lt_carrids ) }|.

  " FOR GROUPS —— 按航空公司分组统计
  DATA(lt_summary) = VALUE SORTED TABLE OF sflight(
    FOR GROUPS grp OF ls IN lt_sflight
    GROUP BY ( carrid = ls-carrid )
    LET cnt = COUNT( * ) IN
    ( carrid = grp-carrid seatsocc = cnt )
  ).
  LOOP AT lt_summary INTO @DATA(ls_grp).
    WRITE: / |{ ls_grp-carrid }: { ls_grp-seatsocc } 条航班|.
  ENDLOOP.

  " REDUCE 累加 —— 总已占座位
  DATA(lv_total) = REDUCE i(
    INIT sum = 0
    FOR ls IN lt_sflight
    NEXT sum = sum + ls-seatsocc
  ).
  WRITE: / |总已占座位: { lv_total }|.
