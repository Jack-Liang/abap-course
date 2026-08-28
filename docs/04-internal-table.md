---
status: draft
---

# 第4课：内表与结构体操作

> 45分钟 | 阶段：基础篇

## 前置依赖

- 第2课：了解 ABAP 基本数据类型和 DATA 声明
- 第3课：了解 SFLIGHT 表结构（知道有哪些字段）

## 问题引入

SFLIGHT 有几千条数据，你用 `SELECT SINGLE` 一次只能取一条——怎么把所有数据一次性"装起来"，然后按航空公司分组、排序、查找特定航线？手动数显然不现实。内表就是 ABAP 的"容器"，专门用来批量处理数据。

## 时间安排

| 时段 | 内容 | 时长 |
|------|------|------|
| 场景引入 | 一条一条查数据 vs 批量处理的效率对比 | 3 分钟 |
| Demo 演示 | 批量查询航班数据，分组排序查找 | 5 分钟 |
| 代码拆解 | 内表声明/操作/新语法 FOR/CORRESPONDING/REDUCE | 30 分钟 |
| 知识总结 | 三种内表类型对比表、常用操作速查 | 5 分钟 |
| 课后思考 | 练习 | 2 分钟 |

## 本课目标

掌握内表的声明与操作方法，理解不同内表类型的适用场景，熟练使用内表常用操作。

## Demo

将 SFLIGHT 数据读入内表，按航空公司分组排序，筛选出指定航空公司的航班，查找某条航线信息并输出。

## 知识点

### 1. 结构体声明
- TYPES BEGIN OF ty_structure.
- TYPES: field1 TYPE c, field2 TYPE i.
- TYPES END OF ty_structure.
- DATA ls_struct TYPE ty_structure.

### 2. 内表声明方式
- TYPE TABLE OF（标准写法）
- TYPE STANDARD TABLE（标准表，无排序）
- TYPE SORTED TABLE（排序表，定义唯一键，自动排序）
- TYPE HASHED TABLE（哈希表，定义唯一键，查找最快）
- 带表头行（WITH HEADER LINE）vs 不带——推荐不带的现代写法

### 3. 内表操作
- APPEND：追加到末尾
- INSERT：插入到指定位置
- COLLECT：按汇总字段累加（旧语法，了解即可）
- SORT BY：排序（升序 ASCENDING / 降序 DESCENDING）
- LOOP AT ... WHERE：条件循环
- READ TABLE ... WITH KEY：按字段值查找
- READ TABLE ... WITH TABLE KEY：按表键查找
- READ TABLE ... INDEX：按索引查找
- BINARY SEARCH：二分查找（需先 SORT）
- MODIFY ... TRANSPORTING：只更新指定字段
- DELETE ... WHERE：条件删除
- DESCRIBE TABLE：获取行数

### 4. 新语法
- FOR ... IN 循环表达式
- CORRESPONDING #( ... ) 赋值操作符
- LOOP AT ... INTO @DATA(ls)
- LOOP AT ... GROUP BY 分组循环
- REDUCE 累加（简单介绍）

## Demo 代码

```abap
REPORT zac_internal_table.

START-OF-SELECTION.
  " 读取航班数据
  SELECT * FROM sflight INTO TABLE @DATA(lt_sflight).

  " 新语法 FOR 循环 —— 提取不重复的航空公司代码
  DATA(lt_carrids) = VALUE SORTED TABLE OF s_carr_id(
    FOR ls IN lt_sflight
    NEXT ( ls-carrid )
  ).

  " CORRESPONDING 赋值 —— 将结构转换为另一种结构
  TYPES: BEGIN OF ty_summary,
           carrid TYPE s_carr_id,
           count  TYPE i,
         END OF ty_summary.
  DATA(lt_result) = VALUE ty_summary_tab(
    FOR GROUPS grp OF ls IN lt_sflight
    GROUP BY ( carrid = ls-carrid )
    ( carrid = grp-carrid count = COUNT( * ) )
  ).

  " LOOP + INTO @DATA
  LOOP AT lt_sflight INTO @DATA(ls_f) WHERE carrid = 'AA'.
    WRITE: / |航班: { ls_f-carrid } { ls_f-connid } { ls_f-fldate }|.
  ENDLOOP.

  " REDUCE 累加 —— 统计总已占座位
  DATA(lv_total) = REDUCE i(
    INIT sum = 0
    FOR ls IN lt_sflight
    NEXT sum = sum + ls-seatsocc
  ).
  WRITE: / |总已占座位: { lv_total }|.
```

## 💡 实战经验

- **带表头行 vs 不带表头行**：`WITH HEADER LINE` 是老语法，SAP 官方已不推荐。新项目统一使用不带表头行的内表，用 `FIELD-SYMBOLS` 或 `@DATA` 访问当前行
- **READ TABLE 加 BINARY SEARCH 的前提**：内表必须先按查找字段 SORT 排序！不排序直接用 BINARY SEARCH 结果会错，且 ABAP 不报警告
- **LOOP 中修改内表**：用 `LOOP AT lt INTO ls WHERE ...` 只能读取，要修改用 `LOOP AT lt ASSIGNING FIELD-SYMBOL(<fs>) WHERE ...`，直接改 `<fs>-field = xxx`，不需要再 MODIFY
- **REDUCE 的性能**：对于大数据量内表，REDUCE 和 LOOP + 累加变量性能差异不大，但 REDUCE 的代码可读性更好——推荐使用

## 代码拆解要点

1. 内表的三种类型及适用场景
2. @DATA 在 LOOP 中的作用域
3. FOR ... IN 表达式的语法结构
4. GROUP BY 在 ABAP 层的分组方式
5. REDUCE 的 INIT / NEXT 结构

## 课后思考

1. STANDARD TABLE / SORTED TABLE / HASHED TABLE 三种内表分别适合什么场景？
2. READ TABLE 加 BINARY SEARCH 的前提条件是什么？
3. 用新语法重构一个你熟悉的内表操作。
