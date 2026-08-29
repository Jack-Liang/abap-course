---
status: beta
---

# 第13课：ABAP 面向对象编程（基础）

> 45分钟 | 阶段：核心篇 | 建议边读边做

## 前置依赖

- [第9课](09-function-module.md)：封装思想与 FM 的局限；
- [第5课](05-open-sql.md)：SELECT。

## 问题引入

FM 封装了逻辑，但函数组的全局数据是"裸奔"的——同组 FM 互相踩内存的隐患第9课刚警告过。**面向对象（OO）**把数据和操作数据的方法绑成一个整体，外部只能走公开的接口访问：这是更严格的封装，也是现代 ABAP 的地基——后面的 OO ALV（22课）、CDS 消费、BTP 开发全是类与方法的 世界。本课写出你的第一个类。

## 时间安排

| 时段 | 内容 | 时长 |
|------|------|------|
| 场景引入 | 从 FM 的全局数据之痛到 OO 封装 | 3 分钟 |
| Demo 跟做 | 运行 zac_oo_basic，过一遍对象的一生 | 8 分钟 |
| 代码拆解 | 类定义/实现/实例化/接口/异常 | 27 分钟 |
| 知识总结 | FM vs 方法、SE24 速查 | 4 分钟 |
| 课后思考 | 练习 | 3 分钟 |

## 本课目标

完成本课你将能够：

- 读懂并写出"本地类"的 DEFINITION / IMPLEMENTATION 结构；
- 用 `NEW` 创建对象、`->` 调用方法、访问 READ-ONLY 属性；
- 用构造函数做初始化，理解 PUBLIC/PRIVATE 分区；
- 定义与实现接口（INTERFACE），说出"面向接口"的好处；
- 用自定义异常类 + TRY/CATCH 处理错误。

## Demo：航班查询工具类（分步跟做）

SE38 运行 `zac_oo_basic`（已随仓库下发）：

```abap
REPORT zac_oo_basic.

" 接口：只声明"能做什么"，不管"谁来做"
INTERFACE lif_flight_query.
  METHODS:
    get_flights EXPORTING et_sflight TYPE sflight_tab,
    get_flight_detail IMPORTING iv_connid TYPE s_conn_id
                                iv_fldate TYPE s_date
                      RETURNING VALUE(rs_detail) TYPE sflight.
ENDINTERFACE.

" 自定义异常：找不着数据不是数据库错误
CLASS lcx_not_found DEFINITION INHERITING FROM cx_static_check.
ENDCLASS.

CLASS lcl_flight_query DEFINITION.
  PUBLIC SECTION.
    INTERFACES: lif_flight_query.                  " 实现接口
    METHODS:
      constructor IMPORTING iv_carrid TYPE s_carr_id OPTIONAL.
    DATA: mv_carrid TYPE s_carr_id READ-ONLY.      " 外部只读
  PRIVATE SECTION.
    DATA: mv_status TYPE string.                    " 外部不可见
ENDCLASS.

CLASS lcl_flight_query IMPLEMENTATION.
  METHOD constructor.
    mv_carrid = COND #( WHEN iv_carrid IS NOT INITIAL THEN iv_carrid ELSE 'AA' ).
    mv_status = '已初始化'.
  ENDMETHOD.

  METHOD lif_flight_query~get_flights.
    SELECT * FROM sflight WHERE carrid = @mv_carrid INTO TABLE @et_sflight.
  ENDMETHOD.

  METHOD lif_flight_query~get_flight_detail.
    SELECT SINGLE * FROM sflight
      WHERE carrid = @mv_carrid AND connid = @iv_connid AND fldate = @iv_fldate
      INTO @rs_detail.
    IF rs_detail IS INITIAL.
      RAISE EXCEPTION TYPE lcx_not_found.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.
  " NEW 创建对象（构造参数直接塞括号）
  DATA(lo_query) = NEW lcl_flight_query( 'AA' ).
  WRITE: / |当前航空公司: { lo_query->mv_carrid }|.

  " 调用接口方法（实现接口的方法带 接口名~ 前缀）
  " get_flights 是 EXPORTING 方法——用 IMPORTING 接结果，不能函数式赋值
  lo_query->lif_flight_query~get_flights( IMPORTING et_sflight = DATA(lt_flights) ).
  WRITE: / |共查询到 { lines( lt_flights ) } 条航班|.
  LOOP AT lt_flights INTO @DATA(ls).
    WRITE: / |  { ls-carrid } { ls-connid } { ls-fldate }|.
  ENDLOOP.

  " 异常处理：查一个不存在的日期
  TRY.
      DATA(ls_detail) = lo_query->lif_flight_query~get_flight_detail(
        iv_connid = '0017' iv_fldate = '20260730' ).
      WRITE: / |详情: 票价 { ls_detail-price }, 座位 { ls_detail-seatsocc }/{ ls_detail-seatsmax }|.
    CATCH lcx_not_found INTO DATA(lx_error).
      WRITE: / |未找到航班: { lx_error->get_text( ) }|.
  ENDTRY.
```

**你会看到什么：** AA 的航班列表 + 一条详情（或"未找到航班"——取决于 2026-07-30 有没有数据）。一个对象从创建、调用到异常处理的完整生命周期。

**跟做改造：** 把 `NEW lcl_flight_query( 'AA' )` 换成 `'LH'` 再跑；把详情日期换成 `'20991231'`，看异常分支输出——两条路都亲手触发一遍。

## 知识点

### 1. 类的解剖图

```abap
CLASS lcl_x DEFINITION.          " 声明：长什么样（对外合同）
  PUBLIC SECTION.                " 公开：外部可用
  PROTECTED SECTION.             " 保护：本类+子类（第22课后你会遇到）
  PRIVATE SECTION.               " 私有：仅本类
ENDCLASS.

CLASS lcl_x IMPLEMENTATION.      " 实现：怎么做（内部细节）
ENDCLASS.
```

- **DEFINITION 与 IMPLEMENTATION 分离**：声明是合同，实现是履约——调用方只看合同，重构实现不影响调用方（SE24 里对应两个编辑页）；
- **三个可见区分区**：默认一切放 PRIVATE，需要暴露的才上 PUBLIC——封装的纪律是"最小暴露"；
- **本地类 vs 全局类**：写在报表里的叫本地类（`lcl_` 前缀，随程序生灭）；SE24 建的是全局类（课程仓库的 `zcl_ac_flight_query`，跨程序复用）。语法一致，先本地练手。

### 2. 对象的创建与使用

```abap
DATA(lo_query) = NEW lcl_flight_query( 'AA' ).   " 现代写法
" 等价旧写法：CREATE OBJECT lo_query EXPORTING iv_carrid = 'AA'.

lo_query->mv_carrid.                             " -> 访问成员
lo_query->lif_flight_query~get_flights( ).       " 调方法
```

- **类是图纸，对象是实例**：`NEW` 一次造一个，各实例属性互不干扰；
- 构造函数 `constructor` 在 NEW 时自动执行——参数直接写进括号；
- **`NEW` + 内联声明**是现代三连：声明、创建、类型推导一步完成。

### 3. CAST #( )：向下转型

`NEW` 造出对象后，引用之间还有一个方向问题。把上例的对象赋给**接口引用**试试：

```abap
DATA lo_if TYPE REF TO lif_flight_query.
lo_if = NEW lcl_flight_query( 'AA' ).                " 向上转型：自动、安全
lo_if->get_flights( IMPORTING et_sflight = DATA(lt2) ). " OK：接口声明过的方法

DATA(lo_class) = CAST lcl_flight_query( lo_if ).      " 向下转型：必须显式 CAST
WRITE: / lo_class->mv_carrid.                         " mv_carrid 不在接口里，只有类引用能访问
```

- **向上转型**（实现类 → 接口、子类 → 父类）永远安全，普通赋值即完成，不用写任何东西；
- **向下转型**（接口/父类引用 → 具体类引用）必须 `CAST #( )`——系统在**运行时**检查引用背后对象的真实类型，对不上就抛 `CX_SY_MOVE_CAST_ERROR`（可 TRY/CATCH 的动态检查异常；不 catch 就是短dump）；
- 旧写法是 `lo_class ?= lo_if`，与 `CAST #( )` 等价——CAST 能进表达式，是新旧之分而非能力之分；
- 同族还有 `EXACT #( )`（严格无损转换，第19课细讲）——`NEW / CAST / EXACT` 三个"构造表达式"是同一代语法，写法风格一脉相承。

!!! tip "什么时候真的需要 CAST"

    良好的设计面向接口编程，大多数时候不需要向下转型。典型必须 CAST 的场景：事件回调的 `sender` 参数（通用父类引用，要转回具体类才知道"谁触发的"，第22课 OO ALV 会遇到）、异构内表混存多种子类对象后的分拣。

### 4. 接口：面向"能做什么"编程

```abap
INTERFACE lif_flight_query.
  METHODS get_flights ...
ENDCLASS.

CLASS lcl_flight_query DEFINITION.
  PUBLIC SECTION.
    INTERFACES: lif_flight_query.     " 签合同：这些方法我实现
```

- 接口只有声明没有实现；类通过 `INTERFACES` 接入并逐个实现（方法名带 `接口名~` 前缀）；
- **价值**：调用方面向 `lif_flight_query` 编程，今天是 `lcl_flight_query`、明天换成查缓存的实现类，调用代码一行不改——这就是第24课 MVC 分层的地基。

### 5. 异常：对象化的错误

```abap
CLASS lcx_not_found DEFINITION INHERITING FROM cx_static_check.
ENDCLASS.

RAISE EXCEPTION TYPE lcx_not_found.       " 抛出
CATCH lcx_not_found INTO DATA(lx_error).  " 捕获 → lx_error 是异常对象
  lx_error->get_text( )                    " 人类可读的描述
```

- 自定义异常 = 继承 `cx_static_check` 的类（可加属性携带上下文，如"哪个航班没找到"）；
- 对比 FM 的经典 EXCEPTIONS（一个 sy-subrc 数字）：异常对象能**分类**（继承体系）、**携带信息**（get_text/属性）、**强制处理**（可检查异常不 catch 会语法警告）；
- 第9课埋的伏笔在此兑现：`RAISING` 声明 + TRY/CATCH 是 FM 与类的共通语言。

### 6. 方法参数的三种出参

| 形式 | 写法 | 用途 |
|------|------|------|
| IMPORTING | `METHODS m IMPORTING iv_x TYPE ...` | 入参 |
| RETURNING | `RETURNING VALUE(rv_x) TYPE ...` | **函数式**：可内联 `DATA(x) = obj->m( )` |
| EXPORTING | `EXPORTING et_x TYPE ...` | 多返回值或大数据量（避免 RETURNING 拷贝） |

新方法优先 RETURNING（可链式、可表达式）；大数据内表用 EXPORTING 少拷贝。

## 💡 实战经验

!!! tip "全局类建 SE24，本地类练手用"

    需要跨程序复用/单测/被别类引用的类，放 SE24 全局类（仓库里的 `zcl_ac_flight_query` 就是）；只在单个报表内部用的，本地类即可，省对象编号。

!!! tip "READ-ONLY 是好东西"

    `DATA mv_carrid READ-ONLY` 让外部能读不能改——比全 PRIVATE 再写 getter 省事，比全 PUBLIC 安全。属性暴露的默认选择。

!!! warning "cx_sy_open_sql_db 不是业务异常"

    系统 DB 异常类表示"数据库层面出错"，"业务上没查到"要抛自己的异常类（本课 `lcx_not_found`）。catch 一堆系统异常当业务逻辑用，是可读性灾难。

## 📖 延伸阅读

- [ABAP Keyword Documentation](https://help.sap.com/doc/abapdocu_752_index_htm/7.52/en-US/index.htm)——ABAP Objects 章节（CLASS / INTERFACE / RAISE）；
- 全局类范例：仓库 `zcl_ac_flight_query`（第13课配套，命名见[第0课矩阵](00-getting-started.md#四命名规范与对象对照)）。

## 课后思考

> 把你的回答写在**页面底部评论区**，注明题号，一起讨论。

1. DEFINITION/IMPLEMENTATION 分离的价值是什么？和"接口与实现分离"是一回事吗？
2. 给 `lcx_not_found` 加一个属性 `mv_flight_key`（存"公司-航线-日期"），抛出时赋值、捕获后输出——把代码贴出来。
3. RETURNING 和 EXPORTING 各适合什么场景？大数据内表为什么倾向 EXPORTING？
4. 对比第9课 FM：把 `zac_calc_flight_duration` 改写成静态方法（`CLASS-METHODS`）的类，各有什么优劣？

---

下一课：[第14课：BAPI 调用](14-bapi.md)——核心篇收官，进入高级篇。
