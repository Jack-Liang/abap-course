*&---------------------------------------------------------------------*
*& Report ZAC_ENV_CHECK
*&---------------------------------------------------------------------*
*& 第0课：课程环境自检
*& 一键检查：① 课程对象是否已随 abapGit 入库（查对象目录 TADIR）
*&           ② SFLIGHT 演示数据是否就绪（表存在性 + 数据条数）
*& 用法：abapGit 导入课程仓库后运行（F8），全部"就绪"即可开始上课
*&---------------------------------------------------------------------*
REPORT zac_env_check.

" 待检查的课程对象（TADIR 是系统的对象目录：R3TR + 对象类型 + 对象名）
TYPES: BEGIN OF ty_obj,
         pgmid    TYPE tadir-pgmid,
         object   TYPE tadir-object,
         obj_name TYPE tadir-obj_name,
         desc     TYPE string,
       END OF ty_obj,
       ty_obj_tab TYPE STANDARD TABLE OF ty_obj WITH EMPTY KEY.

" 演示数据表名清单
TYPES: BEGIN OF ty_tab,
         name TYPE string,
       END OF ty_tab,
       ty_tab_tab TYPE STANDARD TABLE OF ty_tab WITH EMPTY KEY.

DATA: gt_objs  TYPE ty_obj_tab,
      gt_tabs  TYPE ty_tab_tab,
      gv_found TYPE string,
      gv_count TYPE i,
      gv_miss  TYPE i.

START-OF-SELECTION.
  WRITE: / '课程环境自检（ZAC_ENV_CHECK）',
         / '=================================='.

  " ① 课程对象：abapGit 导入后应全部就绪
  gt_objs = VALUE #(
    ( pgmid = 'R3TR' object = 'TABL' obj_name = 'ZAC_FLIGHT_EXT'           desc = '自定义表：航班扩展（第3课）' )
    ( pgmid = 'R3TR' object = 'MSAG' obj_name = 'ZAC_FLIGHT_MSG'           desc = '消息类：航班消息（第18课）' )
    ( pgmid = 'R3TR' object = 'FUGR' obj_name = 'ZAC_FLIGHT_UTILS'         desc = '函数组：航班工具（第9课）' )
    ( pgmid = 'R3TR' object = 'FUNC' obj_name = 'ZAC_CALC_FLIGHT_DURATION' desc = '函数模块：计算飞行时长（第9课）' )
    ( pgmid = 'R3TR' object = 'CLAS' obj_name = 'ZCL_AC_FLIGHT_QUERY'      desc = '类：航班查询（第13课）' )
    ( pgmid = 'R3TR' object = 'CLAS' obj_name = 'ZCL_AC_FLIGHT_SERVICE'    desc = '类：航班服务 / BAPI（第14课）' )
    ( pgmid = 'R3TR' object = 'DDLS' obj_name = 'ZAC_FLIGHT_DETAIL'        desc = 'CDS 视图：航班详情（第20课）' )
    ( pgmid = 'R3TR' object = 'DDLS' obj_name = 'ZAC_FLIGHT_STATS'         desc = 'CDS 视图：航班统计（第21课）' )
    ( pgmid = 'R3TR' object = 'PROG' obj_name = 'ZAC_FLIGHT_MANAGER'       desc = '综合实战：航班管理系统（第24课）' ) ).

  SKIP.
  WRITE: / '① 课程对象（9 项）',
         / '----------------------------------'.
  LOOP AT gt_objs INTO DATA(ls_obj).
    CLEAR gv_found.
    SELECT SINGLE obj_name FROM tadir
      WHERE pgmid = @ls_obj-pgmid AND object = @ls_obj-object AND obj_name = @ls_obj-obj_name
      INTO @gv_found.
    IF sy-subrc = 0.
      WRITE: / |[已入库] { ls_obj-desc }|.
    ELSE.
      WRITE: / |[缺 失] { ls_obj-desc }|.
      gv_miss = gv_miss + 1.
    ENDIF.
  ENDLOOP.

  " ② SFLIGHT 演示数据（官方镜像预置；为空时运行 SAPBC_DATA_GENERATOR）
  gt_tabs = VALUE #( ( name = 'SCARR' ) ( name = 'SPFLI' ) ( name = 'SFLIGHT' )
                     ( name = 'SBOOK' ) ( name = 'SCUSTOM' ) ( name = 'STRAVELAG' ) ).
  SKIP.
  WRITE: / '② SFLIGHT 演示数据（6 张表）',
         / '----------------------------------'.
  LOOP AT gt_tabs INTO DATA(ls_tab).
    " 表是否存在：查数据字典表目录 DD02L（AS4LOCAL = 'A' 即激活版本）
    SELECT SINGLE tabname FROM dd02l
      WHERE tabname = @ls_tab-name AND as4local = 'A'
      INTO @gv_found.
    IF sy-subrc <> 0.
      WRITE: / |{ ls_tab-name WIDTH = 10 }: 表不存在——Flight 数据模型未安装|.
      gv_miss = gv_miss + 1.
      CONTINUE.
    ENDIF.
    " 有多少条数据：FROM 后跟变量名做动态表名，一条 COUNT(*) 数完全表
    SELECT COUNT(*) FROM (ls_tab-name) INTO @gv_count.
    IF gv_count = 0.
      WRITE: / |{ ls_tab-name WIDTH = 10 }: 存在，暂无数据——运行 SAPBC_DATA_GENERATOR 生成|.
      gv_miss = gv_miss + 1.
    ELSE.
      WRITE: / |{ ls_tab-name WIDTH = 10 }: 存在，{ gv_count } 条数据|.
    ENDIF.
  ENDLOOP.

  " ③ 结论
  SKIP.
  IF gv_miss = 0.
    WRITE: / '>>> 全部就绪，可以开始上课！',
           / '>>> 下一站：第1课（SAP 系统入门与开发环境）。'.
  ELSE.
    WRITE: / |>>> 有 { gv_miss } 项未就绪——按上方提示回第0课逐项处理。|.
  ENDIF.
