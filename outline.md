# ABAP 开发课程 · 24课时详细提纲

> **历史文档（2026-07 初版提纲）：** 本文件是课程立项时的设计蓝图，**不再随课文同步更新**——课文的权威版本在 [`docs/`](docs/) （[在线阅读](https://abap.jack-liang.com/)），对象命名以[第0课命名规范](docs/00-getting-started.md#四命名规范与对象对照)为准（本文部分示例代码使用旧对象名）。保留本文用于追溯课程设计思路。

> 目标学员：有计算机编程基础，零 SAP/ABAP 经验
> 每课时：45 分钟
> 教学方式：Demo 演示 → 代码拆解 → 知识点提炼
> 贯穿数据：SFLIGHT 航班模型（SFLIGHT / SCARR / SPFLI / SBOOK）
> 语言：中文授课，代码中文注释

---

## 第一阶段：基础篇（第1-6课）

### 第1课：SAP 系统入门与开发环境

**Demo：** 登录 SAP，用 SE16 浏览 SFLIGHT / SCARR / SPFLI / SBOOK 表数据

**课程目标：** 学员首次接触 SAP，能独立导航到常用事务码，浏览数据，建立对 SAP 体系的基本认知。

**知识点清单：**
- SAP 系统架构概述（三层架构：表示层 → 应用层 → 数据库层）
- SAP GUI 布局与操作（菜单栏、标准工具栏、状态栏、命令栏输入事务码）
- 常用事务码：SE38（ABAP Editor）、SE80（Object Navigator）、SE16（数据浏览器；试用镜像只有 SE16，公司系统另有 SE16N）、SE11（数据字典）、SU01（用户管理）
- F1 帮助的使用方法
- 查表技巧：SE16 基本操作、SE16N vs SE16 的区别（公司环境）、通配符使用、最大命中数设置
- SE11 中查看表结构、字段说明、索引
- SAP Easy Access 与用户菜单
- SAP 开发对象层级（Development Class / Package 的概念）

**代码要点：** 无代码，纯系统操作

---

### 第2课：Hello World 与基本数据类型

**Demo：** 编写第一个 ABAP 程序，输出 "Hello ABAP!" 并从 SCARR 表读取第一条航空公司的名称和代码展示

**课程目标：** 理解 ABAP 程序基本结构，掌握数据类型与变量声明，能编写简单输出程序。

**知识点清单：**
- ABAP 程序基本结构（REPORT → DATA → START-OF-SELECTION → WRITE）
- 基本数据类型详解：C（字符）、N（数值文本）、I（整数）、F（浮点）、D（日期 YYYYMMDD）、T（时间 HHMMSS）、P（打包数/金额）、XSTRING（十六进制）、STRING（变长字符串）
- DATA 语句声明变量
- TYPE vs LIKE 的区别
- WRITE 语句及 FORMAT 选项（颜色、对齐、换行）
- **新语法：`@DATA` 内联声明**——在 SELECT / LOOP / CALL FUNCTION 等语句中直接声明变量
- 新旧写法对比：传统 DATA 声明 vs 内联声明

**代码要点：**
```abap
REPORT zac_hello_world.

START-OF-SELECTION.
  WRITE: / 'Hello ABAP!', / '---'.

  " 传统写法
  DATA: lv_carrid TYPE scarr-carrid,
        lv_carrname TYPE scarr-carrname.
  SELECT SINGLE carrid, carrname
    FROM scarr INTO (lv_carrid, lv_carrname).
  WRITE: / |航空公司代码: { lv_carrid }|, / |名称: { lv_carrname }|.

  " 新语法写法
  SELECT SINGLE carrid, carrname
    FROM scarr INTO @DATA(ls_carr).
  WRITE: / |(新语法) 航空公司: { ls_carr-carrname }|.
```

---

### 第3课：数据字典 —— 建一张自定义表

**Demo：** 在 SE11 中创建一张航班补充信息表（ZAC_FLIGHT_EXT），包含航班号、备注、优先级等字段，并在 SE16 中录入测试数据

**课程目标：** 掌握数据字典核心对象（Domain / Data Element / Table）的创建流程，理解 SAP 数据模型的分层设计思想。

**知识点清单：**
- 数据字典三层结构：Domain → Data Element → Table/Structure
- Domain 创建（值范围、固定值、转换例程）
- Data Element 创建（关联 Domain、字段标签、F1/F4 帮助）
- 透明表（Transparent Table）创建
  - 字段类型选择
  - Delivery & Maintenance 设置
  - 技术设置（数据类、大小类、缓冲）
- 主键与索引
- 外键关系定义（Cardinality、Check Field）
- Structure（结构体）创建——不可持久化，仅作为数据容器
- 激活与检查，修复激活错误
- 数据浏览器中直接维护表数据
- Append Structure（追加结构）的概念

**代码要点：** 无代码（纯 SE11 操作），附 SQL 语句在课件中展示建表结果

---

### 第4课：内表与结构体操作

**Demo：** 将 SFLIGHT 数据读入内表，按航空公司分组排序，筛选出指定航空公司的航班，查找某条航线信息并输出

**课程目标：** 掌握内表的声明与操作方法，理解不同内表类型的适用场景，熟练使用内表常用操作。

**知识点清单：**
- 结构体声明（TYPES BEGIN OF / TYPES END OF）
- 内表声明方式（TYPE TABLE OF / TYPE STANDARD TABLE / SORTED TABLE / HASHED TABLE）
- 带表头行（WITH HEADER LINE）vs 不带——推荐不带的现代写法
- 内表操作：
  - APPEND / INSERT / COLLECT
  - SORT BY（升序/降序、多重排序）
  - LOOP AT ... WHERE / LOOP AT ... INTO
  - READ TABLE ... WITH KEY / BINARY SEARCH
  - MODIFY ... TRANSPORTING
  - DELETE ... WHERE
  - DESCRIBE TABLE
- 内表赋值：MOVE-CORRESPONDING
- **新语法：`FOR ... IN` 循环表达式**
- **新语法：`CORRESPONDING #( ... )` 赋值操作符**
- **新语法：LOOP AT ... INTO @DATA(ls) / LOOP AT ... GROUP BY**
- **新语法：REDUCE 简单介绍（累加示例）**

**代码要点：**
```abap
REPORT zac_internal_table.

START-OF-SELECTION.
  " 读取航班数据
  SELECT * FROM sflight INTO TABLE @DATA(lt_sflight).

  " 新语法 FOR 循环
  DATA(lt_carrids) = VALUE sortd_t_scarrid(
    FOR ls IN lt_sflight
    WHERE carrid = 'AA'
    ( ls-carrid )
  ).

  " CORRESPONDING 赋值
  DATA(lt_result) = CORRESPONDING spfli_tab( lt_sflight ).

  " LOOP + INTO @DATA
  LOOP AT lt_sflight INTO @DATA(ls_f) WHERE carrid = 'AA'.
    WRITE: / |航班: { ls_f-carrid } { ls_f-connid } { ls_f-fldate }|.
  ENDLOOP.

  " REDUCE 累加
  DATA(lv_total) = REDUCE i(
    INIT sum = 0
    FOR ls IN lt_sflight
    NEXT sum = sum + ls-seatsocc
  ).
  WRITE: / |总已占座位: { lv_total }|.
```

---

### 第5课：Open SQL —— 增删改查

**Demo：** 对 SFLIGHT 执行多种查询（单行、多行、JOIN），新增一条航班记录，修改已占座位数，删除一条记录

**课程目标：** 全面掌握 Open SQL 的 SELECT / INSERT / UPDATE / DELETE 操作，理解不同查询方式的区别和适用场景。

**知识点清单：**
- SELECT 语句详解
  - SELECT SINGLE ... INTO vs SELECT ... INTO TABLE
  - SELECT ... UP TO n ROWS
  - WHERE 条件、LIKE、IN、BETWEEN、IS NULL/NOT NULL
  - ORDER BY
  - DISTINCT
- JOIN 查询
  - INNER JOIN / LEFT OUTER JOIN
  - 多表 JOIN 的注意事项（性能、数据量）
- 聚合函数：COUNT / SUM / AVG / MIN / MAX / GROUP BY / HAVING
- **新语法：`@` 占位符在 WHERE 条件中的使用**
- **新语法：`%_HINTS` 性能提示（简要提及）**
- INSERT 语句（单行 / 内表批量）
- UPDATE 语句（SET ... WHERE / 内表批量）
- MODIFY 语句（新增或修改，自动判断）
- DELETE 语句
- **数据库事务与 LUW 概念**：COMMIT WORK / ROLLBACK WORK（简要介绍，第14课深化）
- **新语法：内联声明结果（INTO @DATA / INTO TABLE @DATA(lt)）**

**代码要点：**
```abap
REPORT zac_sql_crud.

START-OF-SELECTION.
  " 1. 单行查询
  SELECT SINGLE * FROM sflight
    WHERE carrid = 'AA' AND connid = '0017' AND fldate = '20260101'
    INTO @DATA(ls_sflight).

  " 2. 多行查询 + @ 占位符
  SELECT * FROM sflight
    WHERE carrid = @sy-mandt " 演示变量参数
      AND fldate >= '20260101'
    INTO TABLE @DATA(lt_sflight)
    UP TO @DATA(lv_rows) ROWS.

  " 3. JOIN 查询
  SELECT f~carrid, f~connid, f~fldate, c~carrname, p~cityfrom, p~cityto
    FROM sflight AS f
    INNER JOIN scarr AS c ON f~carrid = c~carrid
    INNER JOIN spfli AS p ON f~carrid = p~carrid AND f~connid = p~connid
    WHERE f~carrid = 'AA'
    INTO TABLE @DATA(lt_join).

  " 4. 聚合
  SELECT carrid, connid, COUNT(*) AS cnt, SUM( seatsocc ) AS total
    FROM sflight
    WHERE carrid = 'AA'
    GROUP BY carrid, connid
    INTO TABLE @DATA(lt_stats).

  " 5. INSERT
  DATA(ls_new) = VALUE sflight(
    carrid = 'AA' connid = '0017' fldate = '20260730'
    seatsmax = 200 seatsocc = 0
  ).
  INSERT sflight FROM @ls_new.
  IF sy-subrc = 0.
    WRITE: / '插入成功'.
  ENDIF.

  " 6. UPDATE
  UPDATE sflight SET seatsocc = seatsocc + 1
    WHERE carrid = 'AA' AND connid = '0017' AND fldate = '20260730'.

  " 7. DELETE
  DELETE FROM sflight
    WHERE carrid = 'AA' AND connid = '0017' AND fldate = '20260730'.

  COMMIT WORK.
```

---

### 第6课：ABAP 调试器

**Demo：** 对第5课报表设置断点，逐步调试 SQL 查询和内表操作过程，使用 Watchpoint 监控变量变化

**课程目标：** 掌握 ABAP 调试器的核心操作，能独立定位程序逻辑错误和数据异常。

**知识点清单：**
- 断点类型
  - 静态断点（在代码中写 BREAK-POINT / BREAK 用户名）
  - 动态断点（断点界面设置）
  - 外部断点（外部系统调用时触发）
- 调试器界面布局
  - 代码窗口、变量窗口、结构体窗口、调用栈(Call Stack)、断点Tab
- 常用操作
  - F5 (Step Into) —— 进入 Function / Method
  - F6 (Step Over) —— 执行当前行不进入子程序
  - F7 (Step Return) —— 返回上一层
  - F8 (Continue) —— 运行到下一个断点
- 变量查看
  - 双击变量查看值
  - 查看内表内容（Table 内容展示）
  - 查看结构体字段
- Watchpoint（观察点）
  - 设置条件：当某个字段变为指定值时暂停
  - 实际应用场景：调试 LOOP 内的条件判断
- Fields 工具栏按钮：查看系统变量（SY-SUBRC / SY-DBCNT 等）
- 断点在 Function / Method 中的使用
- 调试时修改变量值（Field Contents → Change）

**代码要点：** 使用第5课代码，增加 BREAK-POINT 断点

---

## 第二阶段：核心篇（第7-13课）

### 第7课：选择屏幕

**Demo：** 编写航班查询报表，支持按航空公司、航线编号、航班日期范围筛选，带输入校验

**课程目标：** 掌握 PARAMETERS 和 SELECT-OPTIONS 的用法，理解选择屏幕的事件处理，能编写带校验的查询报表。

**知识点清单：**
- PARAMETERS 语句
  - 基本参数（TYPE / LIKE）
  - OBLIGATORY（必填）
  - DEFAULT（默认值）
  - AS CHECKBOX / RADIOBUTTON GROUP
  - NO-DISPLAY（隐藏参数）
  - MATCHCODE OBJECT（F4 搜索帮助）
  - VALUE CHECK（值校验）
- SELECT-OPTIONS 语句
  - 低值/高值结构（SIGN / OPTION / LOW / HIGH）
  - 选项类型：EQ / BT / NB / NE / GT / LE 等
  - NO INTERVALS（只显示低值）
  - DEFAULT
  - MEMORY ID（SAP 内存）
- SELECTION-SCREEN 事件
  - INITIALIZATION（初始化默认值）
  - AT SELECTION-SCREEN OUTPUT（PBO / 修改屏幕属性）
  - AT SELECTION-SCREEN ON field（单个字段校验）
  - AT SELECTION-SCREEN ON END OF（内表行校验）
  - AT SELECTION-SCREEN（全局校验）
- 选择屏幕分组与块：SELECTION-SCREEN BEGIN OF BLOCK / END OF BLOCK
- **新语法：%_OPTIONS 属性（简要）**

**代码要点：**
```abap
REPORT zac_selection_screen.

PARAMETERS: p_carrid TYPE sflight-carrid OBLIGATORY DEFAULT 'AA',
            p_connid TYPE sflight-connid.

SELECT-OPTIONS: s_date FOR sy-datum NO-EXTENSION NO INTERVALS,
                s_seats FOR sflight-seatsocc.

AT SELECTION-SCREEN ON p_carrid.
  SELECT SINGLE carrid FROM scarr INTO @DATA(lv_check)
    WHERE carrid = @p_carrid.
  IF sy-subrc <> 0.
    MESSAGE e000(zac_flight_msg) WITH p_carrid. " 航空公司代码不存在
  ENDIF.

START-OF-SELECTION.
  SELECT * FROM sflight
    WHERE carrid = @p_carrid
      AND connid IN @s_date  " 演示 SELECT-OPTIONS 直接在 SQL 中使用
      AND fldate IN @s_date
    INTO TABLE @DATA(lt_sflight).

  LOOP AT lt_sflight INTO @DATA(ls).
    WRITE: / |{ ls-carrid } { ls-connid } { ls-fldate } { ls-seatsocc }|.
  ENDLOOP.
```

---

### 第8课：数据格式化 —— 字符串、日期、货币

**Demo：** 将航班数据进行格式化输出：日期转为 YYYY-MM-DD 格式、金额带千分位、字符串拼接航班路线信息、替换特殊字符

**课程目标：** 掌握 ABAP 中常用数据格式化方法，能灵活处理字符串、日期和数值的展示需求。

**知识点清单：**
- 字符串操作
  - CONCATENATE → **新语法：`&&` 运算符**
  - SPLIT 按分隔符拆分
  - SHIFT 左移/右移（按字符/按字符串）
  - REPLACE 旧语法 → **新语法 REPLACE 子串**
  - FIND / COUNT / LENGTH / STRLEN
  - CONDENSE（去空格）
  - TRANSLATE（大小写转换）
  - OVERLAY（按模式替换）
- **字符串模板 `` `|{ val format}|` ``**
  - 基本插值：`|{ lv_name }|` 
  - 日期格式：`|{ lv_date DATE = ISO }|`
  - 数值格式：`|{ lv_amount CURRENCY = 'USD' }|`
  - 对齐与宽度：`|{ lv_text WIDTH = 20 }|`
  - 条件输出：`|{ COND #( WHEN lv_flag = 'X' THEN '是' ELSE '否' ) }|`
- 日期函数
  - 计算两日期间隔天数
  - 日期加减（+ / -）
  - 系统变量 SY-DATUM / SY-UZEIT / SY-TCODE
- 货币与数量格式
  - WRITE ... CURRENCY / WRITE ... UNIT
  - 千分位、小数位控制

**代码要点：**
```abap
REPORT zac_formatting.

START-OF-SELECTION.
  DATA(lv_carrid) = 'AA' && ' ' && '0017'.  " 新语法 &&
  DATA(lv_route) = |{ 'AA' } 航线 { '0017' }|.  " 字符串模板

  " 传统字符串拼接
  CONCATENATE '航班' 'AA' '0017' INTO DATA(lv_old_way) SEPARATED BY space.

  " 字符串模板格式化
  SELECT SINGLE * FROM sflight INTO @DATA(ls_f)
    WHERE carrid = 'AA' AND connid = '0017'.
  IF ls_f IS ASSIGNED.
    WRITE: / |航班日期: { ls_f-fldate DATE = ISO }|.
    WRITE: / |已占/最大: { ls_f-seatsocc }/{ ls_f-seatsmax }|.
    WRITE: / |占比: { ls_f-seatsocc * 100 / ls_f-seatsmax }%|.
  ENDIF.

  " REPLACE 新语法
  DATA(lv_text) = |Hello ABAP World|.
  DATA(lv_result) = replace( val = lv_text sub = 'World' with = 'SAP' ).
  WRITE: / lv_result.

  " SPLIT
  SPLIT 'AA,0017,20260730' AT ',' INTO @DATA(lv_a) @DATA(lv_b) @DATA(lv_c).
  WRITE: / |拆分结果: { lv_a } { lv_b } { lv_c }|.
```

---

### 第9课：Function Module（函数模块）

**Demo：** 创建一个 "计算航班飞行时长" 的 Function Module，从 SPFLI 获取起飞/到达城市和机场，计算时长并返回结果，在报表程序中调用

**课程目标：** 理解 Function Group 和 Function Module 的概念，能创建和调用自定义函数，理解 RFC 的基础概念。

**知识点清单：**
- Function Group（函数组）概念与创建
  - 为什么需要函数组（全局数据共享）
  - SE37 中创建 Function Group
- Function Module 创建
  - Import / Export 参数（Pass by Value / Reference）
  - Changing 参数
  - Tables 参数（旧式，了解即可，推荐用 Changing + 内表）
  - Exceptions（异常定义）
- 源代码区域（Global Data / Function Main / Sub-Routines）
- 调用方式
  - `CALL FUNCTION 'ZFM_...'` 模式
  - 按参数名传值
  - 异常处理（EXCEPTIONS）
- RFC 概念（Remote Function Call）
  - 什么是 RFC / RFC 调用模式（同步/异步）
  - RFC Destination（SM59）
  - 轻量提及，第16课深化
- Function Module 测试（SE37 测试环境）
- **新语法：调用时的简洁传参写法**

**代码要点：**
```abap
" Function Module: ZAC_CALC_FLIGHT_DURATION
FUNCTION zac_calc_flight_duration.
  *"----------------------------------------------------------------------
  *" IMPORTING
  *"   VALUE(IV_CARRID) TYPE S_CARR_ID
  *"   VALUE(IV_CONNID) TYPE S_CONN_ID
  *" EXPORTING
  *"   VALUE(EV_DURATION) TYPE T_MSECHI " 时长
  *"   VALUE(EV_DISTANCE) TYPE S_DISTID
  *"   VALUE(EV_CITYFROM) TYPE S_FROM_CIT
  *"   VALUE(EV_CITYTO) TYPE S_TO_CIT
  *"----------------------------------------------------------------------
  SELECT SINGLE depaturetime, arrivaltime, distance, cityfrom, cityto
    FROM spfli
    WHERE carrid = iv_carrid AND connid = iv_connid
    INTO @DATA(ls_spfli).

  IF sy-subrc = 0.
    ev_cityfrom = ls_spfli-cityfrom.
    ev_cityto   = ls_spfli-cityto.
    ev_distance = ls_spfli-distance.
    ev_duration = ls_spfli-arrivaltime - ls_spfli-depaturetime.
  ENDIF.
ENDFUNCTION.

" 调用方
REPORT zac_call_function.

START-OF-SELECTION.
  CALL FUNCTION 'ZAC_CALC_FLIGHT_DURATION'
    EXPORTING
      iv_carrid = 'AA'
      iv_connid = '0017'
    IMPORTING
      ev_duration = @DATA(lv_duration)
      ev_distance = @DATA(lv_distance)
      ev_cityfrom = @DATA(lv_cityfrom)
      ev_cityto   = @DATA(lv_cityto).
  WRITE: / |{ lv_cityfrom } → { lv_cityto }|.
  WRITE: / |飞行时长: { lv_duration } 分钟, 距离: { lv_distance }|.
```

---

### 第10课：ALV 报表（基础）

**Demo：** 用 ALV Grid 展示 SFLIGHT 航班列表，支持排序、合计、筛选，通过 Field Catalog 自定义列标题和格式

**课程目标：** 掌握 ALV 报表的基本用法，能快速将内表数据以标准 ALV Grid 形式展示。

**知识点清单：**
- ALV 概述
  - 什么是 ALV（ABAP List Viewer）
  - ALV 分类：Function ALV / OO ALV / SALV（后续课程分别涉及）
- `REUSE_ALV_GRID_DISPLAY` 基本调用
  - I_CALLBACK_PROGRAM 参数
  - I_CALLBACK_PF_STATUS_SET（自定义工具栏——简要提及）
  - I_CALLBACK_USER_COMMAND（交互事件——第11课重点）
  - IT_FIELDCAT（字段目录）
  - IS_LAYOUT（布局）
  - I_SAVE / IS_VARIANT（变式保存）
- Field Catalog 构建
  - 手动构建 SLIS_T_FIELDCAT_ALV
    - FIELDNAME / REF_FIELDNAME / REF_TABNAME
    - SELTEXT_L / M / S（列标题）
    - HOTSPOT（热点链接）
    - DO_SUM（合计）
    - NO_ZERO（隐藏零值）
    - EDIT（可编辑——简要提及）
  - **自动生成 Field Catalog（`REUSE_ALV_FIELDCATALOG_MERGE`）**
  - **新语法：用 VALUE 构造 Field Catalog**
- Layout 常用选项
  - ZEBRA（斑马纹）
  - COLWIDTH_OPTIMIZE（列宽优化）
  - NO_COLHEAD（隐藏列头）
  - GET_SELINFO（显示选择条件）
- ALV 标准 Toolbar 功能（导出 Excel / 打印 / 筛选 / 排序）
- **新语法：VALUE #() 构造内表的用法**

**代码要点：**
```abap
REPORT zac_alv_basic.

START-OF-SELECTION.
  " 查询数据
  SELECT f~carrid, f~connid, f~fldate, f~seatsmax, f~seatsocc, f~price,
         c~carrname
    FROM sflight AS f
    INNER JOIN scarr AS c ON f~carrid = c~carrid
    INTO TABLE @DATA(lt_sflight).

  " 构造 Field Catalog（新语法 VALUE）
  DATA(lt_fieldcat) = VALUE slis_t_fieldcat_alv(
    ( fieldname = 'CARRID'   seltext_l = '航空公司代码' outputlen = 10 )
    ( fieldname = 'CONNID'   seltext_l = '航线编号'     outputlen = 10 )
    ( fieldname = 'FLDATE'   seltext_l = '航班日期'     outputlen = 12 )
    ( fieldname = 'CARRNAME' seltext_l = '航空公司名称' outputlen = 20 )
    ( fieldname = 'SEATSMAX' seltext_l = '最大座位'     outputlen = 12 do_sum = 'X' )
    ( fieldname = 'SEATSOCC' seltext_l = '已占座位'     outputlen = 12 do_sum = 'X' )
    ( fieldname = 'PRICE'    seltext_l = '票价'         outputlen = 15 do_sum = 'X' )
  ).

  " 布局
  DATA(ls_layout) = VALUE slis_layout_alv(
    zebra = 'X'
    colwidth_optimize = 'X'
    totals_text = '合计'
  ).

  " 输出 ALV
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid
      is_layout          = ls_layout
      it_fieldcat        = lt_fieldcat
    TABLES
      t_outtab           = lt_sflight
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.
```

---

### 第11课：ALV 交互事件

**Demo：** 在第10课 ALV 基础上，双击航班行查看该航班的旅客预订明细（SBOOK 表），实现 Drill-Down 效果

**课程目标：** 掌握 ALV 交互事件的处理机制，能实现点击跳转、明细展示等常见交互功能。

**知识点清单：**
- ALV 交互事件机制
  - `I_CALLBACK_USER_COMMAND` 参数
  - Form 例程签名：`FORM user_command USING r_ucomm LIKE sy-ucomm rs_selfield TYPE slis_selfield`
  - 参数 r_ucomm（功能码）和 rs_selfield（当前行信息）
- rs_selfield 关键字段
  - TABINDEX（行索引）
  - FIELDNAME（字段名）
  - VALUE（当前字段值）
  - TAB_NAME（内表名）
- 交互实现
  - 双击事件处理
  - Hotspot（热点链接）字段设置
  - 基于当前行数据查询明细
- Top-of-Page 事件
  - `I_CALLBACK_TOP_OF_PAGE`
  - `REUSE_ALV_COMMENTARY_WRITE`
  - 报表标题、选择条件回显
- 常见交互场景
  - 跳转到其他事务码（CALL TRANSACTION）
  - 弹出详细信息窗口（POPUP）
  - 二次 ALV 显示明细
- 状态栏消息：MESSAGE 位置与类型

**代码要点：**
```abap
" 在第10课基础上增加交互
FORM user_command USING p_ucomm    TYPE sy-ucomm
                       p_selfield TYPE slis_selfield.
  CASE p_ucomm.
    WHEN '&IC1'.  " 双击
      IF p_selfield-fieldname = 'CARRID' OR p_selfield-fieldname = 'CONNID'.
        " 读取当前行数据
        READ TABLE lt_sflight INTO DATA(ls_sel) INDEX p_selfield-tabindex.
        IF sy-subrc = 0.
          PERFORM show_bookings USING ls_sel-carrid ls_sel-connid ls_sel-fldate.
        ENDIF.
      ENDIF.
  ENDCASE.
ENDFORM.

FORM show_bookings USING p_carrid TYPE s_carr_id
                         p_connid TYPE s_conn_id
                         p_fldate TYPE s_date.
  " 查询预订明细
  SELECT * FROM sbook
    WHERE carrid = @p_carrid AND connid = @p_connid AND fldate = @p_fldate
    INTO TABLE @DATA(lt_sbook).

  " 用 Field Catalog 展示
  DATA(lt_fc) = VALUE slis_t_fieldcat_alv(
    ( fieldname = 'BOOKID'  seltext_l = '预订号' )
    ( fieldname = 'CUSTOMID' seltext_l = '客户号' )
    ( fieldname = 'LOCCURAM' seltext_l = '本地金额' )
    ( fieldname = 'LUGGWEIGHT' seltext_l = '行李重量' )
  ).

  DATA(ls_layout) = VALUE slis_layout_alv(
    zebra = 'X' colwidth_optimize = 'X'
    window_titlebar = |旅客预订 - { p_carrid } { p_connid }|
  ).

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      is_layout  = ls_layout
      it_fieldcat = lt_fc
    TABLES
      t_outtab  = lt_sbook.
ENDFORM.
```

---

### 第12课：Excel 导入导出

**Demo：** 将 SFLIGHT 数据导出为 Excel 文件，并从 Excel 模板导入一批新航班数据到自定义表 ZAC_FLIGHT_EXT（第3课创建的）

**课程目标：** 掌握 ABAP 与 Excel 的数据交互方法，能实现常见的数据导入导出需求。

**知识点清单：**
- `CL_GUI_FRONTEND_SERVICES` 概述
  - GUI 提供的文件操作类
  - 方法调用模式（静态方法）
- 文件导出
  - `CL_GUI_FRONTEND_SERVICES=>GUI_DOWNLOAD`
    - BIN_FILESIZE / FILETYPE 参数（DAT / ASC / BIN / XLS）
    - WRITE_FIELD_SEPARATOR（CSV 分隔符）
  - 文件保存对话框：`CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG`
  - 文件名和路径处理
- 文件导入
  - `CL_GUI_FRONTEND_SERVICES=>GUI_UPLOAD`
  - FILETYPE / CODEPAGE 参数
  - 数据解析与转换
- Excel 文件处理
  - 简单方式：导出为 CSV（分隔符格式）直接用 Excel 打开
  - **ABAP2XLSX 简介**（开源库，处理 .xlsx 格式）
    - 安装方式（通过 abapGit）
    - ZCL_EXCEL 基本用法（创建工作簿、Sheet、单元格赋值）
  - OLE2 方式（简要提及，了解即可，新项目不推荐）
- 导入数据校验
  - 循环读取、逐行校验
  - 错误收集与日志输出
  - 批量 INSERT
- 文件路径常量与配置管理

**代码要点：**
```abap
REPORT zac_excel.

START-OF-SELECTION.
  " 查询数据
  SELECT * FROM sflight INTO TABLE @DATA(lt_sflight).

  " 导出 CSV
  DATA(lv_filename) = |sflight_{ sy-datum }.csv|.
  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filename                = lv_filename
      filetype                = 'ASC'
      write_field_separator   = 'X'
    TABLES
      data_tab                = lt_sflight
    EXCEPTIONS
      file_write_error        = 1.

  " 导入 Excel/CSV
  DATA: lt_upload TYPE TABLE OF string.
  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                = 'zflight_import.csv'
      filetype                = 'ASC'
    TABLES
      data_tab                = lt_upload.

  " 解析并校验导入数据
  LOOP AT lt_upload INTO @DATA(lv_line).
    SPLIT lv_line AT ',' INTO @DATA(lv_carrid) @DATA(lv_connid) @DATA(lv_fldate) ...
    " 校验与写入
    ...
  ENDLOOP.
```

---

### 第13课：ABAP 面向对象编程（基础）

**Demo：** 用 ABAP Objects 封装一个 "航班查询工具类"，包含方法：按航空公司查航线、按日期查航班、获取航班详情，在报表中实例化使用

**课程目标：** 理解 ABAP OO 的基本概念，能创建类和方法，理解封装思想，为后续 OO ALV 和设计模式打基础。

**知识点清单：**
- 面向对象编程概念
  - 类（Class）与对象（Object）
  - 封装（Encapsulation）
  - SE24（Class Builder）界面
- CLASS 定义
  - CLASS ... DEFINITION / PUBLIC SECTION / PRIVATE SECTION
  - 方法定义：METHODS
  - 属性定义：DATA
  - 构造函数：METHODS CONSTRUCTOR
- CLASS 实现
  - CLASS ... IMPLEMENTATION
  - METHOD 实现
- 对象创建与使用
  - **新语法：`NEW` 操作符创建对象**
  - 方法调用：`lo_obj->method( )`
  - `DATA(lo_obj) = NEW lcl_flight_query( ).`
- Interface（接口）概念
  - INTERFACE ... DEFINITION
  - 类实现接口
  - 接口 vs 类的区别与使用场景
- 异常处理
  - TRY / CATCH / ENDTRY
  - RAISE EXCEPTION TYPE
  - CX_ROOT 异常体系（简要介绍）
- **新语法：`NEW` / `CAST` / `CASTING`**
- OO 程序结构：CREATE OBJECT vs NEW 对比

**代码要点：**
```abap
" 本地类定义
REPORT zac_oo_basic.

CLASS lcl_flight_query DEFINITION.
  PUBLIC SECTION.
    METHODS:
      constructor IMPORTING iv_carrid TYPE s_carr_id OPTIONAL,
      get_flights   EXPORTING et_sflight TYPE sflight_tab,
      get_flight_detail IMPORTING iv_connid TYPE s_conn_id
                                   iv_fldate TYPE s_date
                         RETURNING VALUE(rs_detail) TYPE sflight.
  PRIVATE SECTION.
    DATA: mv_carrid TYPE s_carr_id.
ENDCLASS.

CLASS lcl_flight_query IMPLEMENTATION.
  METHOD constructor.
    mv_carrid = iv_carrid.
  ENDMETHOD.

  METHOD get_flights.
    SELECT * FROM sflight
      WHERE carrid = @mv_carrid
      INTO TABLE @et_sflight.
  ENDMETHOD.

  METHOD get_flight_detail.
    SELECT SINGLE * FROM sflight
      WHERE carrid = @mv_carrid
        AND connid = @iv_connid
        AND fldate = @iv_fldate
      INTO @rs_detail.
  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.
  " 新语法 NEW 创建对象
  DATA(lo_query) = NEW lcl_flight_query( 'AA' ).

  " 调用方法
  DATA(lt_flights) = lo_query->get_flights( ).

  LOOP AT lt_flights INTO @DATA(ls).
    WRITE: / |{ ls-carrid } { ls-connid } { ls-fldate }|.
  ENDLOOP.

  " 链式调用
  DATA(ls_detail) = lo_query->get_flight_detail(
    iv_connid = '0017' iv_fldate = '20260730' ).
```

---

## 第三阶段：高级篇（第14-19课）

### 第14课：BAPI 调用

**Demo：** 调用 BAPI 创建一条 SBOOK 航班预订记录，处理返回消息，并演示 BAPI 修改和查询操作

**课程目标：** 理解 BAPI 的概念和调用模式，能使用 BAPI 完成常见的业务操作（创建/修改/查询）。

**知识点清单：**
- BAPI 概述
  - 什么是 BAPI（Business Application Programming Interface）
  - BAPI vs Function Module
  - BAPI Explorer（BAPI 事务码）
- BAPI 调用模式
  - 通过 `CALL FUNCTION` 调用 BAPI
  - Import 参数传入业务数据
  - Export 参数获取结果
  - Tables 参数处理行项目
- BAPI_RETURN_INFO 处理
  - TYPE / ID / NUMBER / MESSAGE / LOG_NO / LOG_MSG_NO / MESSAGE_V1~V4
  - 判断成功/失败：TYPE = 'S' / 'E' / 'W'
  - 消息拼接展示
- BAPI 事务控制
  - `BAPI_TRANSACTION_COMMIT`（提交）
  - `BAPI_TRANSACTION_ROLLBACK`（回滚）
  - WAIT 参数
- 常用 BAPI 示例
  - 创建/修改/查询航班预订
  - BAPI 查询技巧（按业务对象搜索）
- **新语法：封装 BAPI 调用为类的静态方法**
- 错误处理最佳实践（批量操作中的错误收集）

**代码要点：**
```abap
REPORT zac_bapi.

START-OF-SELECTION.
  DATA: ls_booking TYPE bapisbook,
        lt_booking TYPE TABLE OF bapisbook,
        ls_return  TYPE bapiret2.

  ls_booking-carrid  = 'AA'.
  ls_booking-connid  = '0017'.
  ls_booking-fldate  = '20260730'.
  ls_booking-bookid  = '00000001'.
  ls_booking-customid = '00000001'.

  CALL FUNCTION 'BAPI_SBOOK_CREATE'
    IMPORTING
      booking_number = DATA(lv_bookid)
    TABLES
      booking_data   = lt_booking
    EXCEPTIONS
      others         = 1.

  " 处理返回
  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      wait = 'X'.

  IF lv_bookid IS NOT INITIAL.
    WRITE: / |预订创建成功: { lv_bookid }|.
  ELSE.
    WRITE: / '预订创建失败'.
  ENDIF.
```

---

### 第15课：增强（Enhancement）

**Demo：** 给 SAP 标准的航班程序或屏幕增加一个自定义字段（如 ZAC_FLIGHT_EXT 中的备注字段），通过增强实现数据的读写联动

**课程目标：** 理解 SAP 增强的概念和分类，掌握查找增强、实现增强的基本方法，能完成常见增强开发。

**知识点清单：**
- 增强概述
  - 为什么需要增强（不修改标准代码的原则）
  - SAP 增强技术发展史：User Exit → BADI → Enhancement Spot → New Enhancement Framework
- User Exit（用户出口）
  - EXIT / CALL CUSTOMER-FUNCTION
  - 查找方法：SMOD / CMOD（Find → Global Search）
  - Project 分配与组件管理
  - CMOD 操作流程
- BADI（Business Add-In）
  - 什么是 BADI（面向接口的增强点）
  - SE18 查找 BADI 定义
  - SE19 创建 BADI 实现
  - 方法重写
- Enhancement Spot（增强点）
  - 显式增强点 vs 隐式增强点
  - SE80 / SE19 查找增强点
  - 在 Include 程序中插入隐式增强代码
  - Pre-Exit / Post-Exit / Overwrite 的区别
- 增强查找技巧
  - WHERE-USED list 方法
  - 断点调试定位（在标准程序中设断点，查看调用栈找增强入口）
  - 通过出口程序名搜索（命名规范：EXIT_saplname_nnn）
- Demo：实际操作一个 SFLIGHT 相关的增强场景

**代码要点：** 增强代码示例（在增强点中插入的代码）

```abap
" 在隐式增强点中读取自定义扩展数据
ENHANCEMENT 1  Z_SFLIGHT_EXT.  " 实际版本号由系统生成
  SPOTS z_sflight_ext.

  DATA: lv_remark TYPE zac_flight_ext-remark.

  SELECT SINGLE remark FROM zac_flight_ext
    WHERE carrid = @ls_sflight-carrid
      AND connid = @ls_sflight-connid
      AND fldate = @ls_sflight-fldate
    INTO @lv_remark.

  IF sy-subrc = 0.
    " 将备注信息追加到屏幕输出
    WRITE: / |备注: { lv_remark }|.
  ENDIF.

ENDENHANCEMENT.
```

---

### 第16课：调用外部接口（REST / SOAP / PO / CPI）

**Demo：** 调用外部 REST API（如获取实时汇率），将 SFLIGHT 票价从 USD 换算为 CNY，并以 SOAP / PO / CPI 为补充概览

**课程目标：** 掌握 ABAP 调用 REST API 的方法，理解 SAP 与外部系统集成的基本模式，了解 PO 和 CPI 架构。

**知识点清单：**
- SAP 外部集成概述
  - REST API / SOAP WebService / SAP PO / SAP CPI 各自定位
- **REST API 调用（重点）**
  - `CL_HTTP_CLIENT` 类
  - 创建连接：`CREATE_BY_URL`
  - 设置 HTTP Header：Content-Type / Authorization
  - 发送请求：`SEND` / `RECEIVE`
  - 获取响应：`GET_CDATA` / `GET_DATA`
  - 关闭连接：`CLOSE`
  - GET vs POST 请求区别
- JSON 解析
  - `/UI2/CL_JSON` 工具类
  - `DESERIALIZE` / `SERIALIZE`
  - 结构体映射（JSON → ABAP Structure）
- **SOAP WebService 概览**
  - SOAMANAGER 创建与发布
  - WSDL 概念
  - 消费外部 WebService（简要）
- **SAP PO 概览**（截图演示）
  - Process Orchestration 架构
  - Integration Engine / AEX / BPM
  - IDoc 消息收发流程
- **SAP CPI 概览**
  - Cloud Platform Integration
  - iFlow 概念
  - 与传统 PO 的对比
- 异常处理
  - HTTP 错误码处理
  - CX_HTTP_WEB_PROXY / CX_ROOT 异常体系

**代码要点：**
```abap
REPORT zac_rest_api.

START-OF-SELECTION.
  DATA: lo_http TYPE REF TO if_http_client,
        lv_url  TYPE string.

  " 调用汇率 API
  lv_url = 'https://api.exchangerate-api.com/v4/latest/USD'.

  cl_http_client=>create_by_url(
    EXPORTING
      url                = lv_url
    IMPORTING
      client             = lo_http
    EXCEPTIONS
      argument_not_found = 1
      plugin_not_active  = 2
      internal_error     = 3
      OTHERS             = 4 ).

  lo_http->send( EXCEPTIONS OTHERS = 1 ).
  lo_http->receive( EXCEPTIONS OTHERS = 1 ).

  DATA(lv_response) = lo_http->get_cdata( ).
  lo_http->close( ).

  " JSON 解析
  DATA: BEGIN OF ls_rate,
          rates TYPE SORTED TABLE OF f WITH UNIQUE KEY table_line,
        END OF ls_rate.
  DATA: BEGIN OF ls_result,
          base   TYPE string,
          rates  TYPE SORTED TABLE OF f WITH UNIQUE KEY table_line,
        END OF ls_result.

  /ui2/cl_json=>deserialize(
    EXPORTING json = lv_response
    CHANGING  data = ls_result ).

  " 获取 CNY 汇率
  DATA(lv_cny_rate) = ls_result-rates[ 'CNY' ].
  WRITE: / |USD → CNY 汇率: { lv_cny_rate }|.

  " 换算 SFLIGHT 票价
  SELECT SINGLE price FROM sflight
    WHERE carrid = 'AA' AND connid = '0017'
    INTO @DATA(lv_price_usd).

  DATA(lv_price_cny) = lv_price_usd * lv_cny_rate.
  WRITE: / |票价: { lv_price_usd } USD = { lv_price_cny } CNY|.
```

---

### 第17课：Transport Request（请求与传输）

**Demo：** 将前面开发的所有对象（报表程序、Function Module、数据字典、增强等）打包到一个 Transport Request，释放并传输到测试系统

**课程目标：** 理解 SAP Transport 体系的工作原理，能规范地管理开发对象在不同系统间的传输。

**知识点清单：**
- Transport Request 概述
  - 为什么要传输请求（开发 → 质量 → 生产）
  - 请求 vs 任务（Task）
  - 请求类型（Workbench Transport / Customizing Transport）
- 请求管理事务码
  - SE09 / SE01（Transport Organizer）
  - 请求列表、释放、导入
- 创建请求
  - 首次保存对象时自动弹出创建请求
  - 手动创建请求并分配对象
  - 请求命名规范建议（如 ZFLT_D01 / ZFLT_C01）
- 任务管理
  - 修复任务（Repair Task）
  - 开发任务（Development Task）
- 请求释放
  - 单任务释放 vs 整包释放
  - 释放前检查（依赖关系）
- 传输导入
  - STMS 事务码概览（简要介绍管理员操作）
  - 导入后验证
  - 传输日志查看
- 请求锁定与冲突处理
- 最佳实践
  - 一个功能模块一个请求
  - 请求文档记录
  - 跨请求对象依赖检查
- 自定义表数据传输（通过 Table Maintenance + Transport）

**代码要点：** 纯系统操作，附请求截图

---

### 第18课：消息处理（Message Class）

**Demo：** 创建一个航班相关的消息类 ZAC_FLIGHT_MSG，包含常用消息（航空公司不存在、航班已满、预订成功等），在报表和 Function 中使用消息提示操作结果

**课程目标：** 掌握 SAP 消息体系的使用方法，能创建和管理消息类，实现多语言友好的用户提示。

**知识点清单：**
- SAP 消息体系概述
  - 消息类型：S（Success） / E（Error） / W（Warning） / I（Information） / A（Abend / 中断）
  - 消息 ID 与消息编号
- 消息类（Message Class）
  - SE91 创建消息类
  - 消息编号（3位数字）
  - 消息文本（最长 80 字符）
  - 占位符 `&1 &2 &3 &4`
  - 多语言维护
- 消息使用方式
  - `MESSAGE id msgid TYPE msgty NUMBER msgnr WITH var1 var2 ...`
  - 简写：`MESSAGE e000(zac_flight_msg)`
  - `MESSAGE i... WITH`（带变量）
  - RAISING 消息（在 Function Module 中）
- **新语法：`MESSAGE INTO @DATA(lv_msg)` 内联接收**
- 消息在 Function Module 中的使用
  - Exception 与消息的配合
  - RAISING 模式 vs 内联模式
- 消息在 BADI / 增强中的使用
- 实际场景演示
  - 输入校验时发出错误消息
  - 操作成功后提示成功消息
  - 批量处理中收集消息

**代码要点：**
```abap
" 消息类 ZAC_FLIGHT_MSG 示例消息：
" 001 航空公司代码 &1 不存在
" 002 航班已满，无法预订
" 003 预订成功：&1-&2-&3 座位 &4
" 004 查询完成，共 &1 条记录

REPORT zac_message.

PARAMETERS: p_carrid TYPE s_carr_id OBLIGATORY.

AT SELECTION-SCREEN ON p_carrid.
  SELECT SINGLE carrid FROM scarr INTO @DATA(lv_check)
    WHERE carrid = @p_carrid.
  IF sy-subrc <> 0.
    MESSAGE e001(zac_flight_msg) WITH p_carrid. " 航空公司代码 XXX 不存在
  ENDIF.

START-OF-SELECTION.
  SELECT COUNT(*) FROM sflight
    WHERE carrid = @p_carrid
    INTO @DATA(lv_count).

  MESSAGE s004(zac_flight_msg) WITH lv_count. " 查询完成，共 N 条记录

  " 新语法：消息内联接收
  SELECT SINGLE * FROM sflight INTO @DATA(ls_f)
    WHERE carrid = @p_carrid AND connid = '0017'.
  IF sy-subrc <> 0.
    " 消息文本存入变量
    MESSAGE e002(zac_flight_msg) INTO @DATA(lv_msg).
    WRITE: / lv_msg.
  ENDIF.
```

---

### 第19课：新语法专题

**Demo：** 将前面课程中的老代码全部用新语法重写，系统对比新旧写法，展示新语法的性能优势和可读性提升

**课程目标：** 系统掌握 ABAP 7.4+ 新语法特性，能在实际开发中自觉使用现代写法。

**知识点清单：**
- 内联声明
  - `@DATA` / `@FINAL`
  - `FIELD-SYMBOLS <fs> TYPE ...` 的旧写法对比
- 构造操作符
  - `VALUE #()` —— 内表构造
  - `CORRESPONDING #()` —— 结构体/内表映射
  - `NEW` —— 创建对象
  - `CONV` —— 类型转换
  - `CAST` —— 运行时类型转换
- 条件与转换操作符
  - `COND #( WHEN ... THEN ... ELSE ... )`
  - `SWITCH #( ... )`
  - `EXACT #( )` —— 精确转换（避免数据丢失）
- 字符串模板（回顾 + 进阶）
  - `|{ val format}|` 进阶格式化
  - 算术表达式：`|{ lv_a + lv_b }|`
  - 嵌套 COND/SWITCH
  - `|{ ... WIDTH = 20 ALIGN = LEFT }|`
- 循环表达式
  - `FOR ... IN` —— 遍历内表
  - `FOR i = 1 THEN i + 1 UNTIL ...` —— 数值循环
  - `FOR GROUPS ... OF ... IN ...` —— 分组循环
  - `LET` 表达式 —— 局部变量
- REDUCE
  - 累加 / 字符串拼接 / 条件计数
  - INIT / NEXT 结构
- FILTER
  - 按条件过滤内表
  - `EXCEPT` / `IN` 补集
- Mesh Path
  - 结构化数据关联路径
  - `_flight->\_spfli->cityfrom`
- CLEANUP
  - 资源清理机制
- 性能优势
  - 新语法生成的代码与旧语法的 OpenSQL 优化对比
  - SAP 官方推荐的新语法使用场景

**代码要点：** 新旧对比代码（多段）

```abap
" 对比1：内表声明
" 旧
DATA: lt_sflight TYPE STANDARD TABLE OF sflight.
DATA: ls_sflight TYPE sflight.
" 新
SELECT * FROM sflight INTO TABLE @DATA(lt_sflight).

" 对比2：内表构造
" 旧
DATA: lt_tab TYPE TABLE OF sflight.
APPEND: VALUE #( carrid = 'AA' connid = '0017' ) TO lt_tab.
" 新
DATA(lt_tab) = VALUE sflight_tab(
  ( carrid = 'AA' connid = '0017' fldate = '20260730' )
  ( carrid = 'DL' connid = '0100' fldate = '20260730' )
).

" 对比3：条件表达式
" 旧
IF lv_seatsocc >= lv_seatsmax.
  lv_status = '已满'.
ELSE.
  lv_status = '可订'.
ENDIF.
" 新
DATA(lv_status) = COND string(
  WHEN lv_seatsocc >= lv_seatsmax THEN '已满'
  ELSE '可订' ).

" 对比4：REDUCE
DATA(lv_total) = REDUCE i(
  INIT sum = 0
  FOR ls IN lt_sflight
  NEXT sum = sum + ls-seatsocc
).

" 对比5：FILTER
DATA(lt_aa) = FILTER #( lt_sflight USING KEY carrid
  WHERE carrid = 'AA' ).

" 对比6：FOR + LET
DATA(lt_summary) = VALUE sflight_tab(
  FOR GROUPS grp OF ls IN lt_sflight
    GROUP BY ( carrid = ls-carrid )
    LET cnt = COUNT( * ) IN
    ( carrid = grp-carrid seatsocc = cnt )
).
```

---

## 第四阶段：现代开发篇（第20-24课）

### 第20课：CDS View（基础）

**Demo：** 在 ADT（ABAP Development Tools）中创建 CDS View，将 SFLIGHT + SCARR + SPFLI 三表关联定义为一个航班详情视图，在 ABAP 程序中通过 `SELECT * FROM zcds_flight INTO TABLE @DATA(lt)` 使用

**课程目标：** 理解 CDS 的概念和语法，能创建基本 CDS View 替代 ABAP 中的复杂 JOIN。

**知识点清单：**
- CDS 概述
  - Core Data Services
  - CDS vs ABAP DDIC View
  - 为什么用 CDS（性能、可复用、注解驱动、Fiori 基础）
- ADT（ABAP Development Tools）概览
  - Eclipse 安装 ABAP 插件
  - 连接 SAP 系统
  - ADT vs SE80
- CDS DDL 语法
  - `DEFINE VIEW zcds_xxx AS SELECT FROM ... { ... }`
  - 字段选择与别名
  - 多表 JOIN（内连接）
  - WHERE 条件
  - GROUP BY / HAVING / 聚合
  - 参数化 View：`WITH PARAMETERS p_carrid : abap.char3`
- Association（关联）
  - `[INNER] JOIN` vs Association 的区别
  - Association 语法：`ASSOCIATION spfli TO spfli ON ...`
  - `$projection` 投影
  - 路径表达式：`_spfli.cityfrom`
- @Annotation（注解）
  - `@AbapCatalog.sqlViewName`
  - `@AbapCatalog.compiler.compareFilter`
  - `@ObjectModel.readOnly`
  - `@UI` 系列注解（简要介绍）
- 在 ABAP 程序中使用 CDS View
  - `SELECT * FROM zcds_xxx INTO TABLE @DATA(lt)`
  - `SELECT * FROM zcds_xxx( p_carrid = 'AA' ) INTO TABLE @DATA(lt)` —— 参数传递

**代码要点：**
```sql
@AbapCatalog.sqlViewName: 'ZV_SFLIGHT_DETAIL'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '航班详情视图'
define view ZAC_FLIGHT_DETAIL as select from sflight
  inner join scarr on sflight.carrid = scarr.carrid
  inner join spfli on sflight.carrid = spfli.carrid
                    and sflight.connid = spfli.connid
{
    key sflight.carrid,
    key sflight.connid,
    key sflight.fldate,
    sflight.price,
    sflight.seatsmax,
    sflight.seatsocc,
    scarr.carrname,
    spfli.cityfrom,
    spfli.cityto,
    spfli.distance,
    spfli.deptime,
    spfli.arrtime
}
```

---

### 第21课：CDS View（进阶）

**Demo：** 创建参数化 CDS View，按航空公司统计航班数量和平均票价；使用 DCL 定义访问控制；体验 View Entity 新语法

**课程目标：** 掌握 CDS 的高级特性（函数、Session 变量、访问控制），了解 View Entity 新语法。

**知识点清单：**
- CDS 函数
  - 聚合函数：COUNT / SUM / AVG / MIN / MAX
  - 标量函数：COALESCE / CAST / DIVISION / CONCAT / UPPER / LOWER / SUBSTRING / LENGTH
  - 日期函数：DATS_DAYS_BETWEEN / DATS_ADD_DAYS
- Session 变量
  - `$session.user`
  - `$session.system_date`
  - 在 WHERE 条件中使用
- 访问控制（DCL —— Data Control Language）
  - `@AccessControl.authorizationCheck: #CHECK`
  - `DEFINE ROLE` / `DEFINE ROLE WITH CONDITION`
  - CDS Role 分配
- View Entity（ABAP 7.55+ 新语法）
  - `DEFINE VIEW ENTITY zve_xxx AS SELECT FROM ... { ... }`
  - View Entity vs CDS View 的区别
  - 更简洁的语法、更多函数支持
  - `$self` 关键字
- CDS 在报表中的使用模式
  - CDS 做数据源，ABAP 做展示
  - 与 ALV 结合
- CDS 性能考量
  - 下推到数据库执行 vs ABAP 层处理

**代码要点：**
```sql
" 参数化 CDS View
@AbapCatalog.sqlViewName: 'ZV_SFLIGHT_STATS'
@EndUserText.label: '航班统计视图'
define view ZAC_FLIGHT_STATS
  with parameters p_carrid : abap.char3
  as select from sflight
{
    key sflight.carrid,
    count(*)            as flight_count,
    sum(sflight.price)  as total_price,
    avg(sflight.price)  as avg_price,
    max(sflight.price)  as max_price
}
where sflight.carrid = $parameters.p_carrid
group by sflight.carrid

" DCL 访问控制
@MappingRole: true
define role zr_flight_data {
  grant select on ZAC_FLIGHT_DETAIL
    where carrid = aspect zcds_flight_auth.carrid;
}
```

---

### 第22课：OO ALV（面向对象 ALV）

**Demo：** 用 CL_GUI_ALV_GRID 重写第10课的 ALV 报表，展示 OO ALV 的布局容器、事件注册等机制，对比 Function ALV 与 OO ALV 的区别

**课程目标：** 掌握 OO ALV 的使用方法，理解其与 Function ALV 的区别与优势，能独立开发 OO ALV 报表。

**知识点清单：**
- OO ALV vs Function ALV 对比
  - 灵活性（自定义事件、布局）
  - 性能（大数据量时）
  - 扩展性（自定义 Toolbar、Cell Event）
  - MVC 模式支持
- 容器体系
  - `CL_GUI_CUSTOM_CONTAINER` —— 自定义区域容器
  - `CL_GUI_DOCKING_CONTAINER` —— 停靠容器
  - `CL_GUI_SPLITTER_CONTAINER` —— 分割容器
  - Docking vs Custom Container 的选择
- CL_GUI_ALV_GRID 核心
  - 创建实例：`NEW cl_gui_alv_grid( cl_gui_custom_container )`
  - `SET_TABLE_FOR_FIRST_DISPLAY` —— 首次显示
    - Field Catalog（LVC_T_FCAT）——比 SLIS 字段目录功能更强
    - Layout（LVC_S_LAYO）
  - `REFRESH_TABLE_DISPLAY` —— 刷新数据
- 字段目录（LVC_T_FCAT）
  - `LVC_S_FCAT` 关键字段：FIELDNAME / REF_TABLE / REF_FIELD / EDIT / HOTSPOT / TECH 等
  - 自动生成：`LVC_FIELDCATALOG_MERGE`
  - **新语法 VALUE 构造**
- 事件处理
  - `SET_HANDLER` 注册事件处理方法
  - 事件类型：CLICK / DOUBLE_CLICK / DATA_CHANGED / TOOLBAR / USER_COMMAND
  - Event Handler Method 的签名
  - 注册多个 Handler
- 自定义 Toolbar
  - TOOLBAR 事件
  - `SE_TOOLBAR` 修改工具栏
- 状态栏消息
  - `SET_TOOLBAR_BUTTON` / `APPEND_TOOLBAR_BUTTON`
- 完整开发流程（MVC 思路简要提及）

**代码要点：**
```abap
REPORT zac_oo_alv.

CLASS lcl_app DEFINITION.
  PUBLIC SECTION.
    METHODS:
      constructor,
      display_data.
  PRIVATE SECTION.
    DATA: mo_container TYPE REF TO cl_gui_custom_container,
          mo_grid     TYPE REF TO cl_gui_alv_grid,
          lt_sflight  TYPE STANDARD TABLE OF sflight.
    METHODS:
      handle_double_click FOR EVENT double_click OF cl_gui_alv_grid
        IMPORTING e_row e_column.
ENDCLASS.

CLASS lcl_app IMPLEMENTATION.
  METHOD constructor.
    " 创建容器
    mo_container = NEW cl_gui_custom_container(
      container_name = 'CC_ALV' ).
    " 创建 ALV Grid
    mo_grid = NEW cl_gui_alv_grid( i_parent = mo_container ).
    " 注册事件
    SET HANDLER me->handle_double_click FOR mo_grid.
    " 查询数据
    SELECT * FROM sflight INTO TABLE @lt_sflight.
  ENDMETHOD.

  METHOD display_data.
    " Field Catalog
    DATA(lt_fcat) = VALUE lvc_t_fcat(
      ( fieldname = 'CARRID'   ref_table = 'SFLIGHT' ref_field = 'CARRID' )
      ( fieldname = 'CONNID'   ref_table = 'SFLIGHT' ref_field = 'CONNID' )
      ( fieldname = 'FLDATE'   ref_table = 'SFLIGHT' ref_field = 'FLDATE' )
      ( fieldname = 'PRICE'    hotspot = 'X' )
      ( fieldname = 'SEATSOCC' )
    ).
    DATA(ls_layout) = VALUE lvc_s_layo(
      zebra = 'X' cwidth_opt = 'X' ).
    " 显示
    mo_grid->set_table_for_first_display(
      EXPORTING
        is_layout       = ls_layout
      CHANGING
        it_outtab       = lt_sflight
        it_fieldcatalog = lt_fcat ).
  ENDMETHOD.

  METHOD handle_double_click.
    READ TABLE lt_sflight INTO DATA(ls_row) INDEX e_row-index.
    IF sy-subrc = 0 AND e_column-fieldname = 'PRICE'.
      MESSAGE i000(oo) WITH |票价: { ls_row-price }|.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

SELECTION-SCREEN BEGIN OF BLOCK b1.
PARAMETERS p_carrid TYPE sflight-carrid DEFAULT 'AA'.
SELECTION-SCREEN END OF BLOCK b1.

AT SELECTION-SCREEN OUTPUT.
  %_p_carrid%_text = '航空公司'.

START-OF-SELECTION.
  DATA(go_app) = NEW lcl_app( ).
  go_app->display_data( ).

  " 需要在 Screen Painter 中定义 Screen 100 包含 Custom Control CC_ALV
  CALL SCREEN 100.
```

---

### 第23课：BTP 概览 + abapGit 代码管理

**Demo：** 前半部分展示 BTP 环境和 Business Application Studio；后半部分使用 abapGit 克隆一个仓库，推送课程代码

**课程目标：** 了解 SAP BTP 云平台架构，掌握 abapGit 的安装和使用方法，能通过 Git 管理 ABAP 代码。

**知识点清单：**
- SAP BTP 概览（前半）
  - BTP（Business Technology Platform）架构
  - ABAP Environment（Steampunk / BTP ABAP）vs On-Premise ABAP
  - Business Application Studio（BAS）
  - SAP Fiori Tools 简介
  - Cloud 与传统 ABAP 开发对比
  - RAP（ABAP RESTful Application Programming Model）简要提及
- abapGit（后半）
  - 什么是 abapGit（ABAP 的 Git 客户端）
  - 安装方法（通过 abapGit 在线安装 / SAP Note / CTS）
  - 创建仓库
  - Clone 远程仓库到 SAP
  - Pull / Push 操作
  - 分支管理（切换分支 / 创建分支）
  - `.abapgit.xml` 文件作用
  - 代码冲突处理
  - 与团队协作工作流
  - abapGit vs CTS（请求传输）的配合策略
  - 日常开发流程：Git clone → 开发 → Commit → Push → PR → 传输

**代码要点：** abapGit 操作截图 + BTP 界面截图

---

### 第24课：综合实战 —— SFLIGHT 航班管理系统

**Demo：** 整合前面所有知识点，开发一个完整的"航班管理系统"：选择屏幕筛选 → CDS 取数 → OO ALV 展示 → 点击预订 → BAPI 创建 → 消息提示 → Excel 导出 → 请求传输 → abapGit 推送

**课程目标：** 综合运用全部课程知识，完成一个完整的开发项目，理解 SAP 开发的端到端流程。

**知识点清单：**
- 全流程串联回顾
  - 需求分析 → 数据设计 → 编码开发 → 调试 → 增强 → 请求传输 → Git 管理
- 项目架构设计
  - 程序结构（Include 拆分：TOP / PBO / PAI / FORMS）
  - 类组织（MVC：Model / View / Controller）
  - CDS 作为数据层
  - OO ALV 作为展示层
  - Function Module 作为业务逻辑层
- 功能模块拆解
  - 选择屏幕（PARAMETERS / SELECT-OPTIONS + 校验）
  - CDS View 取数（参数化 + 关联）
  - OO ALV Grid 展示（容器 / Field Catalog / 事件）
  - ALV 双击 → BAPI 创建 SBOOK 预订
  - 消息类提示操作结果
  - Excel 导出报表数据
  - Transport Request 打包传输
  - abapGit 推送到远程仓库
- 课程总结
  - 24课知识点回顾地图
  - 后续学习路线建议
  - 推荐资源（SAP Community / SAP Help Portal / 开源项目）

**代码要点：** 完整项目代码结构

```
ZAC_FLIGHT_MANAGER（主程序）
├── ZAC_FLIGHT_TOP    → 数据声明、CDS View 使用
├── ZAC_FLIGHT_SEL    → 选择屏幕 PBO/PAI
├── ZAC_FLIGHT_PBO    → ALV 初始化
├── ZAC_FLIGHT_PAI    → ALV 事件处理
├── ZAC_FLIGHT_FORMS  → 辅助逻辑（BAPI调用、Excel导出、消息处理）
├── ZAC_FLIGHT_DETAIL → CDS View
├── ZCL_FLIGHT_MANAGER → 全局类（MVC Controller）
├── ZCL_ALV_DISPLAY      → ALV 展示类
└── ZCL_AC_FLIGHT_SERVICE   → 业务逻辑类（BAPI封装）
```

```abap
" ZAC_FLIGHT_MANAGER 主程序
REPORT zac_flight_manager.

INCLUDE zac_flight_top.
INCLUDE zac_flight_sel.
INCLUDE zac_flight_pbo.
INCLUDE zac_flight_pai.
INCLUDE zac_flight_forms.

INITIALIZATION.
  " 初始化默认值

START-OF-SELECTION.
  " 1. 通过 CDS View 取数
  SELECT * FROM zac_flight_detail( p_carrid = @p_carrid )
    INTO TABLE @DATA(lt_flights).

  " 2. 创建 OO ALV 展示
  DATA(go_alv) = NEW zcl_alv_display( ).
  go_alv->display( it_data = lt_flights ).

  " 3. 事件处理（双击创建预订）
  " → 由 ALV Event Handler 处理

  " 4. Excel 导出
  " → 用户点击自定义 Toolbar 按钮触发

  " 5. 请求传输 + abapGit 推送
  " → 开发完成后在 SE09 和 abapGit 中操作
```

---

## 附录：课程资源清单

### SAP 标准数据表（SFLIGHT 模型）
| 表名 | 描述 | 关键字段 |
|------|------|---------|
| SCARR | 航空公司 | CARRID, CARRNAME, CURRCODE, URL |
| SPFLI | 航线规划 | CARRID, CONNID, CITYFROM, CITYTO, DISTANCE, DEPTIME, ARRTIME |
| SFLIGHT | 航班 | CARRID, CONNID, FLDATE, PRICE, SEATSMAX, SEATSOCC, PLANETYPE |
| SBOOK | 航班预订 | CARRID, CONNID, FLDATE, BOOKID, CUSTOMID, LOCCURAM, LUGGWEIGHT |

### 常用事务码速查
| 事务码 | 功能 | 首次出现 |
|--------|------|---------|
| SE38 | ABAP Editor | 第1课 |
| SE80 | Object Navigator | 第1课 |
| SE11 | Data Dictionary | 第1课 |
| SE16 / SE16N | Data Browser（试用镜像只有 SE16） | 第1课 |
| SE37 | Function Builder | 第9课 |
| SE24 | Class Builder | 第13课 |
| SE19 | BADI Implementation | 第15课 |
| SE09/SE01 | Transport Organizer | 第17课 |
| SE91 | Message Maintenance | 第18课 |
| STMS | Transport Management | 第17课 |
| SOAMANAGER | Web Service 管理 | 第16课 |
| CMOD | Enhancement Projects | 第15课 |
| BAPI | BAPI Explorer | 第14课 |

### 推荐学习资源
- SAP Help Portal: https://help.sap.com
- SAP Community: https://community.sap.com
- ABAP RESTful Application Programming Model (RAP): https://community.sap.com/topics/abap
- abapGit: https://abapGit.org
- ABAP7.4+ 新语法官方文档
