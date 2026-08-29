*&---------------------------------------------------------------------*
*& Report ZAC_HELLO_WORLD
*&---------------------------------------------------------------------*
*& 第2课：Hello World 与基本数据类型
*& 演示 ABAP 程序基本结构、数据类型、@DATA 内联声明
*& 末段：课程环境自检——SFLIGHT 模型的表是否存在、是否有数据、各多少条
*&---------------------------------------------------------------------*
REPORT zac_hello_world.

" 环境自检用的全局变量：在 LOOP 里反复写入、跨语句使用，
" 用全局 DATA 声明（内联声明的作用域限制，见本课知识点）
DATA: gv_tabname TYPE string,
      gv_found   TYPE string,
      gv_count   TYPE i.

DATA g_tables TYPE STANDARD TABLE OF string WITH EMPTY KEY.

START-OF-SELECTION.
  WRITE: / 'Hello ABAP!', / '---'.

  " 传统写法：先声明变量，再查询
  DATA: lv_carrid TYPE scarr-carrid,
        lv_carrname TYPE scarr-carrname.
  SELECT SINGLE carrid, carrname
    FROM scarr INTO (@lv_carrid, @lv_carrname).
  WRITE: / |航空公司代码: { lv_carrid }|,
         / |名称: { lv_carrname }|.

  " 新语法写法：@DATA 内联声明
  SELECT SINGLE carrid, carrname
    FROM scarr INTO @DATA(ls_carr).
  WRITE: / |(新语法) 航空公司: { ls_carr-carrname }|.

  " ================= 课程环境自检 =================
  " 检查课程依赖的 SFLIGHT 模型表是否存在、是否有数据、各多少条
  g_tables = VALUE #( ( `SCARR` ) ( `SPFLI` ) ( `SFLIGHT` )
                      ( `SBOOK` ) ( `SCUSTOM` ) ( `STRAVELAG` ) ).
  SKIP.
  WRITE: / '课程环境自检（SFLIGHT 模型）',
         / '--------------------------------'.

  LOOP AT g_tables INTO gv_tabname.
    " 表是否存在：查数据字典的表目录 DD02L，AS4LOCAL = 'A' 表示激活版本。
    " 注意不能直接 SELECT 不存在的表——静态引用在激活（编译）期就报错，
    " 程序根本跑不起来，所以"运行期查表存在性"必须走数据字典
    SELECT SINGLE tabname FROM dd02l
      WHERE tabname = @gv_tabname AND as4local = 'A'
      INTO @gv_found.
    IF sy-subrc <> 0.
      WRITE: / |{ gv_tabname WIDTH = 10 }: 不存在——Flight 数据模型未安装（回第0课）|.
      CONTINUE.
    ENDIF.

    " 有多少条数据：FROM 后跟变量名做动态表名，一条 COUNT(*) 数完全表
    SELECT COUNT(*) FROM (gv_tabname) INTO @gv_count.
    IF gv_count = 0.
      WRITE: / |{ gv_tabname WIDTH = 10 }: 存在，暂无数据——运行 SAPBC_DATA_GENERATOR 生成（回第0课）|.
    ELSE.
      WRITE: / |{ gv_tabname WIDTH = 10 }: 存在，{ gv_count } 条数据|.
    ENDIF.
  ENDLOOP.
