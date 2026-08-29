---
status: beta
---

# 第19课：新语法专题

> 45分钟 | 阶段：高级篇 | 建议边读边做

## 前置依赖

- [第4课](04-internal-table.md)：内表操作（FOR/GROUP BY 已见过）；
- [第8课](08-formatting.md)：COND/SWITCH 初见；
- 前面各课零散出现过的新语法，本课一次收齐。

## 问题引入

前面 18 课里，新语法像"零花钱"一样撒在各处：`@DATA` 在第2课、字符串模板在第8课、FOR/GROUP BY 在第4课。本课把整套 **ABAP 7.4+ 表达式体系**摆上操作台系统过一遍——目标不是"背语法"，而是建立**表达式思维**：老写法是一行行"命令"，新写法是一层层"表达式"，后者能组合、能嵌套、能一句说完一件事。

## 时间安排

| 时段 | 内容 | 时长 |
|------|------|------|
| 场景引入 | 命令式 → 表达式式的思维转换 | 3 分钟 |
| Demo 跟做 | 七组新旧对照一口气跑完 | 10 分钟 |
| 代码拆解 | 构造/条件/转换/循环/折叠/过滤/映射 + Mesh 与 CLEANUP | 24 分钟 |
| 知识总结 | 新语法速查矩阵 | 5 分钟 |
| 课后思考 | 练习 | 3 分钟 |

## 本课目标

完成本课你将能够：

- 用 VALUE 构造任意结构/内表字面量；
- 用 COND/SWITCH 替代多分支 IF，并嵌套进模板；
- 用 FOR（含 FOR GROUPS）在表达式里遍历与分组；
- 用 REDUCE 折叠单值、FILTER 按键过滤、CORRESPONDING 映射字段；
- 说出 @FINAL、EXACT、Mesh Path、CLEANUP 这四个"边角"特性各自解决什么问题；
- 判断"这段老代码值得重写吗"的取舍标准。

## Demo：七组对照（分步跟做）

SE38 运行 `zac_new_syntax`（已随仓库下发），七段输出对应七个特性：

```abap
REPORT zac_new_syntax.

START-OF-SELECTION.
  " 对比1：内联声明
  SELECT * FROM sflight INTO TABLE @DATA(lt_sflight).

  " 对比2：VALUE 构造（SORTED 表类型，为对比5 FILTER 铺垫）
  TYPES ty_flight_tab TYPE SORTED TABLE OF sflight
                          WITH NON-UNIQUE KEY carrid.
  DATA(lt_tab) = VALUE ty_flight_tab(
    ( carrid = 'AA' connid = '0017' fldate = '20260730' seatsmax = 200 )
    ( carrid = 'DL' connid = '0100' fldate = '20260730' seatsmax = 180 )
    ( carrid = 'UA' connid = '0941' fldate = '20260730' seatsmax = 350 ) ).

  " 对比3：COND
  LOOP AT lt_tab INTO DATA(ls).
    DATA(lv_status) = COND string(
      WHEN ls-seatsocc >= ls-seatsmax THEN '已满'
      WHEN ls-seatsocc > ls-seatsmax * 8 / 10 THEN '紧张'
      ELSE '可订' ).
    WRITE: / |{ ls-carrid }-{ ls-connid } { lv_status }|.
  ENDLOOP.

  " 对比4：REDUCE
  DATA(lv_total) = REDUCE i(
    INIT sum = 0
    FOR ls IN lt_tab
    NEXT sum = sum + ls-seatsmax ).
  WRITE: / |总座位: { lv_total }|.

  " 对比5：FILTER（要求表带合适键，走主键 carrid）
  DATA(lt_aa) = FILTER #( lt_tab WHERE carrid = 'AA' ).
  WRITE: / |AA 航班: { lines( lt_aa ) }|.

  " 对比6：SWITCH
  DATA(lv_name) = SWITCH string(
    'AA' WHEN 'AA' THEN 'American Airlines'
                WHEN 'DL' THEN 'Delta Air Lines'
                WHEN 'UA' THEN 'United Airlines'
                ELSE '未知' ).
  WRITE: / lv_name.

  " 对比7：FOR 构造 + CORRESPONDING
  TYPES: BEGIN OF ty_short,
           carrid TYPE s_carr_id,
           connid TYPE s_conn_id,
           price  TYPE s_price,
         END OF ty_short,
         ty_short_tab TYPE STANDARD TABLE OF ty_short WITH EMPTY KEY.
  DATA(lt_short) = VALUE ty_short_tab(
    FOR ls IN lt_sflight
    ( CORRESPONDING #( ls ) ) ).
  WRITE: / |短表行数: { lines( lt_short ) }|.
```

**你会看到什么：** 三行"状态"输出（AA/DL/UA 的满座判断）、总座位合计、AA 航班数、全名映射、以及与 SFLIGHT 等行的"短表"行数——七个特性各有产出。

## 知识点

### 1. 内联声明与构造

```abap
" 内联：声明即使用处（第2课）
SELECT ... INTO TABLE @DATA(lt).

" VALUE：结构/内表的"字面量"
DATA(ls)  = VALUE sflight( carrid = 'AA' connid = '0017' ).
DATA(lt2) = VALUE ty_flight_tab( ( ... ) ( ... ) ).   " 每对括号一行
```

### 2. @FINAL：内联声明的"只读版"

```abap
" 与 @DATA 出现在同样位置，但声明后不可再赋值
SELECT SINGLE price FROM sflight
  WHERE carrid = 'AA' AND connid = '0017'
  INTO @FINAL(lv_price).

" lv_price = lv_price + 100.   " ← 编译期直接报错，根本激活不了
```

普通声明也有对应写法：`FINAL(lv_threshold) = 100.`。**"算一次、用到底"的量**（汇率、阈值、查出来的配置）用 `@FINAL`，后面任何试图改它的代码连激活都过不了——把"不该变"交给编译器看守，比靠自觉和代码评审靠谱得多。这与第13课"约束能编译期挡住就别留到运行时"是同一个思路。

### 3. 条件表达式：COND vs SWITCH

```abap
COND string( WHEN 条件 THEN a WHEN 条件2 THEN b ELSE c )   " 区间/复杂条件
SWITCH string( lv_code WHEN 'AA' THEN x WHEN 'DL' THEN y ELSE z )  " 单值映射
```

表达式化后它们能进字符串模板、方法参数、VALUE 内部——IF/ELSE 做不到。选用规则一句话：**条件看大小用 COND，条件看等于用 SWITCH**。

### 4. EXACT：精确转换，宁可报错不可错数

```abap
" CONV：转不过去就"凑活"——静默舍入
DATA(lv_conv) = CONV i( '3.7' ).        " 得到 4，没人告诉你丢了 0.3

" EXACT：丢精度就直接抛异常
DATA(lv_exact) = EXACT i( '3.7' ).      " 运行时抛 CX_SY_CONVERSION_NO_NUMBER
```

两者是"宽容"与"严格"的取舍：纯展示类字段用 CONV 无妨；**金额、数量、税率**这类"错一分钱都是事故"的字段，用 EXACT 让错误当场爆炸，而不是悄悄进账。EXACT 抛出的异常是可以 CATCH 的——接住后走对账/告警流程（完整写法见第 10 节的 CLEANUP 示例）。

### 5. 循环表达式：FOR 家族

```abap
" FOR ... IN：逐行投喂（第4课）
VALUE t( FOR ls IN lt ( ls-carrid ) )

" FOR GROUPS：分组（第4课已详）
" FOR i = 1 THEN i + 1 WHILE i <= 10：数值循环（见下方示例）
```

数值循环示例（生成序列的场景）：

```abap
TYPES ty_ints TYPE STANDARD TABLE OF i WITH EMPTY KEY.
DATA(lt_1to5) = VALUE ty_ints(
  FOR i = 1 THEN i + 1 WHILE i <= 5 ( i ) ).   " ( 1 2 3 4 5 )
```

配合 `LET` 可在表达式内声明临时量（第4课 FOR GROUPS 见过）。

### 6. REDUCE：折叠

```abap
DATA(lv_total) = REDUCE i(
  INIT sum = 0            " 起始值
  FOR ls IN lt_tab        " 数据源
  NEXT sum = sum + ls-seatsmax ).   " 每步怎么折
```

折叠目标不止数字：`INIT text = ` `` `` ` `` 之后 `NEXT text = text && ...` 拼字符串；条件计数 `NEXT cnt = cnt + COND i( WHEN ... THEN 1 ELSE 0 )`——REDUCE 的 NEXT 里还能嵌 COND/LET，表达式的组合性就在这里体现。

### 7. FILTER：按键过滤整表

```abap
DATA(lt_aa) = FILTER #( lt_tab WHERE carrid = 'AA' ).            " 主键
DATA(lt_non_aa) = FILTER #( lt_tab EXCEPT WHERE carrid = 'AA' ). " 补集
```

**前提：表类型必须有匹配 WHERE 字段的键**（SORTED/HASHED 或标准表的主键）——所以 Demo 的 `lt_tab` 声明成 `SORTED TABLE ... KEY carrid`。这呼应第4课的选型：**类型系统不只是声明，是算法承诺**（第4课复杂度差异的语法体现）。

### 8. CORRESPONDING：同名映射

```abap
ls_short = CORRESPONDING #( ls_flight ).                    " 同名字段自动搬
ls_full  = CORRESPONDING #( BASE ( ls_short ) ls_flight ).   " 以 ls_short 为底、ls_flight 覆盖同名字段
```

进阶参数 `MAPPING`/`EXCEPT` 处理异名字段与排除项。第4课已见基础形态，综合实战（第24课）用它做 CDS 行到输出结构的转换。

### 9. Mesh Path：结构化数据的关联路径（看得懂即可）

ABAP 7.50 引入的实验性特性：**MESH 类型**把几张内表 + 表间关联声明成一个"网状结构"，之后用 **Mesh Path** 沿关联路径直接取值，省去手工再查一次表：

```abap
TYPES:
  BEGIN OF ty_flight,
    carrid TYPE sflight-carrid,
    connid TYPE sflight-connid,
    fldate TYPE sflight-fldate,
  END OF ty_flight,
  ty_flights TYPE SORTED TABLE OF ty_flight
             WITH UNIQUE KEY carrid connid fldate,
  BEGIN OF ty_spfli,
    carrid   TYPE spfli-carrid,
    connid   TYPE spfli-connid,
    cityfrom TYPE spfli-cityfrom,
  END OF ty_spfli,
  ty_spflis TYPE SORTED TABLE OF ty_spfli
            WITH UNIQUE KEY carrid connid.

" ① MESH 类型：两个节点表 + 一条关联 _spfli
TYPES:
  BEGIN OF MESH ty_route_mesh,
    flight TYPE ty_flights
      ASSOCIATION _spfli TO spfli
        ON carrid = carrid AND connid = connid,
    spfli  TYPE ty_spflis,
  END OF MESH ty_route_mesh.

" ② 填充网状结构
DATA(lo_mesh) = VALUE ty_route_mesh(
  flight = VALUE #( ( carrid = 'AA' connid = '0017' fldate = '20260730' ) )
  spfli  = VALUE #( ( carrid = 'AA' connid = '0017' cityfrom = 'NEW YORK' ) ) ).

" ③ Mesh Path：从航班行沿 _spfli 关联走到航线，取 cityfrom
DATA(lv_cityfrom) = lo_mesh-flight[ 1 ]\_spfli[ 1 ]-cityfrom.   " 'NEW YORK'
```

`_flight->\_spfli->cityfrom` 这类路径的本质：把"按外键再 READ 一次表"压缩成一个表达式。**实话**：实际项目里几乎没人用——Open SQL JOIN 和第4课的内表读已经够用，Mesh 概念重、可读性争议大，属 7.50 的实验性探索。遇到它认得即可，新代码不必主动引入。

### 10. CLEANUP：异常外传前的清理段

TRY 块除了 CATCH 还有第三段（呼应第13课的异常类）。**执行时机最容易讲错，先记住规则：CLEANUP 只在 TRY 里抛了异常、且没有被本层任何 CATCH 接住（异常要继续向外传）时执行**——正常跑完不执行、被本层 CATCH 接住也不执行：

```abap
TRY.
    TRY.
        DATA(lv_exact) = EXACT i( '3.7' ).       " 第 4 节的例子：这里抛异常
      CLEANUP.
        " 走到这里 = 异常没被内层接住、即将外传——先还原状态再放行
        " 典型动作：关连接、释放锁、还原全局变量
        WRITE: / '内层清理：还原状态，异常继续外传'.
    ENDTRY.
  CATCH cx_sy_conversion_no_number INTO DATA(lx).
    WRITE: / |外层接住: { lx->get_text( ) }|.
ENDTRY.
```

分工一句话：**CATCH 管"出错了怎么办"，CLEANUP 管"异常逃出去之前必须还原什么"**。申请锁/打开连接之后立刻套上带 CLEANUP 的 TRY，保证异常外传时资源不跟着泄漏。清理时需要异常对象记日志的话，写 `CLEANUP INTO DATA(lx)`（与 CATCH 的 INTO 同款）。

### 11. 重写取舍：什么时候动老代码

| 场景 | 建议 |
|------|------|
| 新写的代码 | 无脑新语法 |
| 改动中的老代码（顺手范围） | 改到哪重写到哪 |
| 运行良好的老代码（无人触碰） | **不动**——重写引入回归风险，收益只是好看 |

新语法的编译产物与等价老写法**无性能差异**（Open SQL 层面甚至更优），收益在**可读性与组合性**——这决定了它是"写代码的方式"而不是"优化手段"。

## 💡 实战经验

!!! tip "表达式嵌套别超过三层"

    `REDUCE( FOR ... LET ... COND ... )` 一条龙很爽，三层以上没人读得懂。嵌套失控 = 提中间变量或拆方法，可读性优先于炫技。

!!! tip "FILTER 前先看表类型"

    FILTER 报"键不存在"时，先回声明处给表配上键——而不是退回 LOOP。类型声明处解决问题，算法处就干净。

!!! tip "团队统一一个时代"

    半新半旧的代码库最难维护。团队约定"新代码一律新语法（Open SQL 强制 @）"，评审时一句话能说清。

## 📖 延伸阅读

- [ABAP Keyword Documentation](https://help.sap.com/doc/abapdocu_752_index_htm/7.52/en-US/index.htm)——ABAP Expressesions 章节（本课全部操作符的官方定义与更多示例）。

## 课后思考

> 把你的回答写在**页面底部评论区**，注明题号，一起讨论。

1. 用 `FOR i = ... WHILE` + REDUCE 算 1~100 的和——一条表达式写出来贴评论区。
2. FILTER 的"表必须带键"限制，背后是第4课哪个知识点？EXCEPT 版语义是什么？
3. 把第5课 Demo 里"传统写法"的 SELECT 段（若有旧式变量声明）整体新语法化，贴出你的版本。
4. 你在维护一段 800 行的 2010 年老报表，领导让你"顺手升级新语法"——你的专业建议是什么？
5. EXACT 与 CONV 你各会在什么字段上用？CATCH 与 CLEANUP 的分工，用一句话说清。

---

下一课：[第20课：CDS View（基础）](20-cds-basic.md)——高级篇收官，进入现代开发篇。
