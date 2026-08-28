*&---------------------------------------------------------------------*
*& Report ZAC_HELLO_WORLD
*&---------------------------------------------------------------------*
*& 第2课：Hello World 与基本数据类型
*& 演示 ABAP 程序基本结构、数据类型、@DATA 内联声明
*&---------------------------------------------------------------------*
REPORT zac_hello_world.

START-OF-SELECTION.
  WRITE: / 'Hello ABAP!', / '---'.

  " 传统写法：先声明变量，再查询
  DATA: lv_carrid TYPE scarr-carrid,
        lv_carrname TYPE scarr-carrname.
  SELECT SINGLE carrid, carrname
    FROM scarr INTO (lv_carrid, lv_carrname).
  WRITE: / |航空公司代码: { lv_carrid }|,
         / |名称: { lv_carrname }|.

  " 新语法写法：@DATA 内联声明
  SELECT SINGLE carrid, carrname
    FROM scarr INTO @DATA(ls_carr).
  WRITE: / |(新语法) 航空公司: { ls_carr-carrname }|.
