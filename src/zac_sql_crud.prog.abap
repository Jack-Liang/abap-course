*&---------------------------------------------------------------------*
*& Report ZAC_SQL_CRUD
*&---------------------------------------------------------------------*
*& 第5课：Open SQL —— 增删改查
*& 演示 SELECT/INSERT/UPDATE/DELETE、JOIN、聚合、@占位符
*&---------------------------------------------------------------------*
REPORT zac_sql_crud.

START-OF-SELECTION.
  " 1. 单行查询
  SELECT SINGLE * FROM sflight
    WHERE carrid = 'AA' AND connid = '0017'
    INTO @DATA(ls_sflight).
  IF sy-subrc = 0.
    WRITE: / |找到航班: { ls_sflight-carrid }-{ ls_sflight-connid }|.
  ENDIF.

  " 2. 多行查询 + @占位符
  DATA(lv_rows) = 10.
  SELECT * FROM sflight
    WHERE fldate >= '20260101'
    INTO TABLE @DATA(lt_sflight)
    UP TO @lv_rows ROWS.
  WRITE: / |查询到 { lines( lt_sflight ) } 条记录|.

  " 3. JOIN 查询
  SELECT f~carrid, f~connid, f~fldate, c~carrname,
         p~cityfrom, p~cityto
    FROM sflight AS f
    INNER JOIN scarr AS c ON f~carrid = c~carrid
    INNER JOIN spfli AS p ON f~carrid = p~carrid
                         AND f~connid = p~connid
    WHERE f~carrid = 'AA'
    INTO TABLE @DATA(lt_join).
  LOOP AT lt_join INTO @DATA(ls_j).
    WRITE: / |{ ls_j-carrname } { ls_j-cityfrom } → { ls_j-cityto }|.
  ENDLOOP.

  " 4. 聚合
  SELECT carrid, COUNT(*) AS cnt, SUM( seatsocc ) AS total
    FROM sflight WHERE carrid = 'AA'
    GROUP BY carrid
    INTO TABLE @DATA(lt_stats).
  READ TABLE lt_stats INTO @DATA(ls_st) INDEX 1.
  IF sy-subrc = 0.
    WRITE: / |AA 航班共 { ls_st-cnt } 条, 总座位 { ls_st-total }|.
  ENDIF.

  " 5. INSERT
  DATA(ls_new) = VALUE sflight(
    carrid = 'AA' connid = '0017' fldate = '20260730'
    seatsmax = 200 seatsocc = 0 ).
  INSERT sflight FROM @ls_new.

  " 6. UPDATE
  UPDATE sflight SET seatsocc = seatsocc + 1
    WHERE carrid = 'AA' AND connid = '0017' AND fldate = '20260730'.

  " 7. DELETE
  DELETE FROM sflight
    WHERE carrid = 'AA' AND connid = '0017' AND fldate = '20260730'.

  COMMIT WORK.
  WRITE: / |操作已完成|.
