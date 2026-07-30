# 第19课：新语法全面应用

> 45分钟 | 阶段：高级篇

## 前置依赖

- 第4课：了解内表操作
- 第13课：了解 ABAP OO 基础
- 本课程前半部分：已有足够的传统语法基础

## 问题引入

你用传统语法写了这么多代码，其实 ABAP 新语法可以让代码量减少一半以上——同样的功能，新语法写出来更短、更可读、更不容易出错。但新语法不是"语法糖"那么简单，它改变了你思考数据的方式。这节课用 SFLIGHT 场景集中演示所有核心新语法。

## 时间安排

| 时段 | 内容 | 时长 |
|------|------|------|
| 场景引入 | 传统语法 vs 新语法——同一个功能的代码量对比 | 3 分钟 |
| Demo 演示 | 用新语法重写一个航班统计报表 | 5 分钟 |
| 代码拆解 | VALUE / COND / SWITCH / REDUCE / FILTER / CORRESPONDING / FOR / inline declaration | 28 分钟 |
| 知识总结 | 新语法速查表、性能对比要点 | 6 分钟 |
| 课后思考 | 练习 | 3 分钟 |

## 本课目标

系统掌握 ABAP 7.40+ 核心新语法，能用新语法简化传统代码，理解新语法的适用场景和注意事项。

## Demo

用新语法重写航班统计报表：VALUE 构建内表、FILTER 筛选数据、REDUCE 计算汇总、COND 条件表达式，对比新旧语法的代码量和可读性。

## 知识点

### 1. 内联声明
- @DATA / @FINAL
- FIELD-SYMBOLS 旧写法对比
- 作用域说明

### 2. 构造操作符
- VALUE #() —— 内表构造
- CORRESPONDING #() —— 结构体/内表映射
- NEW —— 创建对象
- CONV —— 类型转换
- CAST —— 运行时类型转换

### 3. 条件与转换操作符
- COND #( WHEN ... THEN ... ELSE ... )
- SWITCH #( ... )
- EXACT #( ) —— 精确转换

### 4. 字符串模板进阶
- |{ val format}| 进阶格式化
- 算术表达式
- 嵌套 COND/SWITCH
- WIDTH / ALIGN 选项

### 5. 循环表达式
- FOR ... IN —— 遍历内表
- FOR i = 1 THEN i + 1 UNTIL ... —— 数值循环
- FOR GROUPS ... OF ... IN ... —— 分组循环
- LET 表达式 —— 局部变量

### 6. REDUCE
- 累加 / 字符串拼接 / 条件计数
- INIT / NEXT 结构

### 7. FILTER
- 按条件过滤内表
- EXCEPT / IN 补集

### 8. Mesh Path
- 结构化数据关联路径
- 用途与限制

### 9. CLEANUP
- 资源清理机制

### 10. 性能优势
- 新语法的 OpenSQL 优化
- SAP 官方推荐

## Demo 代码

```abap
REPORT zdemo19_new_syntax.

START-OF-SELECTION.
  " ========================
  " 对比1：内联声明
  " ========================
  " 旧
  DATA: lt_sflight TYPE STANDARD TABLE OF sflight.
  SELECT * FROM sflight INTO TABLE lt_sflight.
  " 新
  SELECT * FROM sflight INTO TABLE @DATA(lt_sflight_new).

  " ========================
  " 对比2：内表构造 VALUE
  " ========================
  DATA(lt_tab) = VALUE sflight_tab(
    ( carrid = 'AA' connid = '0017' fldate = '20260730' seatsmax = 200 )
    ( carrid = 'DL' connid = '0100' fldate = '20260730' seatsmax = 180 )
    ( carrid = 'UA' connid = '0941' fldate = '20260730' seatsmax = 350 )
  ).

  " ========================
  " 对比3：条件表达式 COND
  " ========================
  LOOP AT lt_tab INTO @DATA(ls).
    DATA(lv_status) = COND string(
      WHEN ls-seatsocc >= ls-seatsmax THEN |已满|
      WHEN ls-seatsocc > ls-seatsmax * 8 / 10 THEN |紧张|
      ELSE |可订| ).
    WRITE: / |{ ls-carrid }-{ ls-connid } | { lv_status }|.
  ENDLOOP.

  " ========================
  " 对比4：REDUCE 累加
  " ========================
  DATA(lv_total_seats) = REDUCE i(
    INIT sum = 0
    FOR ls IN lt_tab
    NEXT sum = sum + ls-seatsmax ).
  WRITE: / |总座位数: { lv_total_seats }|.

  " ========================
  " 对比5：FILTER 过滤
  " ========================
  DATA(lt_aa) = FILTER #( lt_tab USING KEY carrid
    WHERE carrid = 'AA' ).
  WRITE: / |AA 航班数: { lines( lt_aa ) }|.

  " ========================
  " 对比6：FOR + LET 分组
  " ========================
  SELECT * FROM sflight INTO TABLE @DATA(lt_full).
  DATA(lt_summary) = VALUE SORTED TABLE OF sflight(
    FOR GROUPS grp OF ls IN lt_full
    GROUP BY ( carrid = ls-carrid connid = ls-connid )
    LET cnt = COUNT( * ) IN
    ( carrid = grp-carrid connid = grp-connid
      seatsocc = cnt seatsmax = cnt )
  ).

  " ========================
  " 对比7：SWITCH 映射
  " ========================
  DATA(lv_code) = 'AA'.
  DATA(lv_name) = SWITCH string(
    lv_code
    WHEN 'AA' THEN 'American Airlines'
    WHEN 'DL' THEN 'Delta Air Lines'
    WHEN 'UA' THEN 'United Airlines'
    ELSE |未知: { lv_code }| ).
  WRITE: / |{ lv_code } → { lv_name }|.

  " ========================
  " 对比8：CORRESPONDING 映射
  " ========================
  TYPES: BEGIN OF ty_short,
           carrid TYPE s_carr_id,
           connid TYPE s_conn_id,
           price  TYPE s_price,
         END OF ty_short.
  DATA(lt_short) = VALUE ty_short_tab(
    FOR ls IN lt_sflight_new
    ( carrid = ls-carrid connid = ls-connid price = ls-price )
  ).
```

## 代码拆解要点

1. 每个新语法特性的正确语法结构
2. 新旧写法的可读性和代码量对比
3. VALUE / CORRESPONDING / COND / SWITCH / REDUCE / FILTER 各自适用场景
4. FOR ... IN / FOR GROUPS 的循环表达式
5. 内联声明的作用域理解

## 💡 实战经验

- **新语法不是必须用**：SAP 系统版本 ≥ 7.40 支持大部分新语法，但 ≤ 7.02 的老系统不支持。写代码前先确认目标系统的版本
- **VALUE 构建大数据量的性能**：VALUE 操作会在内存中构建全新内表，如果数据量很大（10万+行），会有明显的内存和性能开销。大数据量场景仍用 SELECT ... INTO TABLE
- **COND vs IF**：COND 表达式适合简单的"赋值选择"，逻辑复杂时还是用 IF ... ELSEIF 更清晰。不要为了炫技把简单逻辑写成复杂的三元表达式
- **内联声明 @DATA 的调试**：用 @DATA 声明的变量在调试器中有时显示不了类型信息。调试时如果需要看类型，可以临时改为传统 DATA 声明

## 课后思考

1. 新语法有哪些限制？（提示：某些旧系统版本不支持）
2. REDUCE 和 LOOP AT + 累加变量，哪个性能更好？
3. 用新语法重构你在之前课程中写过的任何一段代码。
