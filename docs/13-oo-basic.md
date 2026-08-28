# 第13课：ABAP 面向对象编程（基础）

> 45分钟 | 阶段：核心篇

## 前置依赖

- 第9课：了解 Function Module 的封装思想
- 第5课：了解 Open SQL 查询

## 问题引入

你已经会用 Function Module 封装逻辑了，但 FM 有一个缺点——它的数据是"全局共享"的，多个 FM 之间可能互相干扰。有没有更严格的"封装"方式——数据和方法绑定在一起，外部只能通过规定好的接口访问？面向对象（OO）就是解决这个问题的。

## 时间安排

| 时段 | 内容 | 时长 |
|------|------|------|
| 场景引入 | 过程式编程 vs 面向对象的思维转换 | 3 分钟 |
| Demo 演示 | 创建航班查询工具类，在报表中调用 | 5 分钟 |
| 代码拆解 | 类/对象/方法/属性/构造函数/接口/异常 | 28 分钟 |
| 知识总结 | OO 核心概念速查、SE24/SE80 操作要点 | 6 分钟 |
| 课后思考 | 练习 | 3 分钟 |

## 本课目标

理解 ABAP OO 的基本概念，能创建类和方法，理解封装思想，为后续 OO ALV 和设计模式打基础。

## Demo

用 ABAP Objects 封装一个 "航班查询工具类"，包含方法：按航空公司查航线、按日期查航班、获取航班详情，在报表中实例化使用。

## 知识点

### 1. 面向对象编程概念
- 类（Class）与对象（Object）
- 封装（Encapsulation）
- SE24（Class Builder）界面

### 2. CLASS 定义
- CLASS ... DEFINITION
- PUBLIC SECTION / PRIVATE SECTION / PROTECTED SECTION
- METHODS（方法定义）
- DATA（属性定义）
- CONSTRUCTOR（构造函数）

### 3. CLASS 实现
- CLASS ... IMPLEMENTATION
- METHOD ... ENDMETHOD

### 4. 对象创建与使用
- 新语法：NEW 操作符创建对象
- 方法调用：lo_obj->method( )
- DATA(lo_obj) = NEW lcl_flight_query( ).

### 5. Interface（接口）
- INTERFACE ... DEFINITION
- 类实现接口
- 接口 vs 类的区别与使用场景

### 6. 异常处理
- TRY / CATCH / ENDTRY
- RAISE EXCEPTION TYPE
- CX_ROOT 异常体系

### 7. 新语法
- NEW 创建对象
- CAST 类型转换

## Demo 代码

```abap
REPORT zac_oo_basic.

" 工具接口定义
INTERFACE lif_flight_query.
  METHODS:
    get_flights EXPORTING et_sflight TYPE sflight_tab,
    get_flight_detail IMPORTING iv_connid TYPE s_conn_id
                                iv_fldate TYPE s_date
                      RETURNING VALUE(rs_detail) TYPE sflight.
ENDINTERFACE.

" 航班查询类
CLASS lcl_flight_query DEFINITION.
  PUBLIC SECTION.
    INTERFACES: lif_flight_query.
    METHODS:
      constructor IMPORTING iv_carrid TYPE s_carr_id OPTIONAL.
    DATA: mv_carrid TYPE s_carr_id READ-ONLY.
  PRIVATE SECTION.
    DATA: mv_status TYPE string.
ENDCLASS.

CLASS lcl_flight_query IMPLEMENTATION.
  METHOD constructor.
    mv_carrid = COND #( WHEN iv_carrid IS NOT INITIAL THEN iv_carrid ELSE 'AA' ).
    mv_status = '已初始化'.
  ENDMETHOD.

  METHOD lif_flight_query~get_flights.
    SELECT * FROM sflight
      WHERE carrid = @mv_carrid
      INTO TABLE @et_sflight.
  ENDMETHOD.

  METHOD lif_flight_query~get_flight_detail.
    SELECT SINGLE * FROM sflight
      WHERE carrid = @mv_carrid
        AND connid = @iv_connid
        AND fldate = @iv_fldate
      INTO @rs_detail.
    IF rs_detail IS INITIAL.
      RAISE EXCEPTION TYPE cx_sy_open_sql_db.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.
  " 创建对象（新语法 NEW）
  DATA(lo_query) = NEW lcl_flight_query( 'AA' ).

  WRITE: / |当前航空公司: { lo_query->mv_carrid }|.

  " 调用接口方法
  DATA(lt_flights) = lo_query->lif_flight_query~get_flights( ).
  WRITE: / |共查询到 { lines( lt_flights ) } 条航班|.

  LOOP AT lt_flights INTO @DATA(ls).
    WRITE: / |  { ls-carrid } { ls-connid } { ls-fldate }|.
  ENDLOOP.

  " 获取单条详情（含异常处理）
  TRY.
      DATA(ls_detail) = lo_query->lif_flight_query~get_flight_detail(
        iv_connid = '0017' iv_fldate = '20260730' ).
      WRITE: / |详情: 票价 { ls_detail-price }, 座位 { ls_detail-seatsocc }/{ ls_detail-seatsmax }|.
    CATCH cx_sy_open_sql_db INTO DATA(lx_error).
      WRITE: / |未找到航班: { lx_error->get_text( ) }|.
  ENDTRY.
```

## 代码拆解要点

1. INTERFACE 定义与实现
2. CLASS DEFINITION / IMPLEMENTATION 的结构
3. CONSTRUCTOR 构造函数的作用
4. NEW 创建对象 vs CREATE OBJECT 的区别
5. TRY/CATCH 异常处理模式
6. READ-ONLY 属性的使用

## 💡 实战经验

- **全局类 vs 局部类**：在 SE24 中创建的类是"全局类"，整个系统都能调用。在程序内部用 `CLASS lcl_xxx DEFINITION` 定义的是局部类——只在当前程序有效。新项目推荐全局类
- **属性的可见性**：PRIVATE 是默认也是最安全的。公开属性（PUBLIC）意味着任何程序都能修改——破坏封装。推荐所有属性设为 PRIVATE，通过 GETTER/SETTER 方法访问
- **异常处理不要吞掉错误**：`TRY ... CATCH cx_root` 捕获所有异常但不做处理，会让 Bug 隐藏得更深。至少要在 CATCH 中记录日志或提示用户
- **OO 的性能**：ABAP OO 和过程式编程的性能差异微乎其微（<1%），不要因为"性能"而拒绝使用 OO。代码的可维护性更重要

## 课后思考

1. 类和接口的区别是什么？什么场景下用接口？
2. 如果一个方法可能抛异常，调用方有几种处理方式？
3. 尝试为 lcl_flight_query 增加一个"计算平均票价"的方法。