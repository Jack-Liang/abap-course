# 第2课：Hello World 与基本数据类型

> 45分钟 | 阶段：基础篇

## 前置依赖

- 第1课：能登录 SAP 系统，会用 SE16N 浏览数据

## 问题引入

你已经会查表了，但"查"是手动操作。怎么用代码自动读取 SCARR 表中的航空公司信息并展示出来？写出的第一个程序能运行吗？本课带你跨过"从0到1"的门槛。

## 时间安排

| 时段 | 内容 | 时长 |
|------|------|------|
| 场景引入 | 为什么需要编程而不是手动操作 | 2 分钟 |
| Demo 演示 | 运行 Hello World 程序，看输出效果 | 3 分钟 |
| 代码拆解 | 程序结构、数据类型、DATA 声明、WRITE、@DATA | 30 分钟 |
| 知识总结 | 8 种数据类型速查表、新旧语法对比 | 7 分钟 |
| 课后思考 | 练习 | 3 分钟 |

## 本课目标

理解 ABAP 程序基本结构，掌握数据类型与变量声明，能编写简单输出程序。

## Demo

编写第一个 ABAP 程序，输出 "Hello ABAP!" 并从 SCARR 表读取第一条航空公司的名称和代码展示。

## 知识点

### 1. ABAP 程序基本结构
- REPORT 语句
- DATA 声明区域
- START-OF-SELECTION 事件
- END-OF-SELECTION 事件
- WRITE 输出语句

### 2. 基本数据类型
- C：字符型（默认长度1）
- N：数值文本（用于编号）
- I：整数（4字节）
- F：浮点数（8字节，注意精度问题）
- P：打包数（金额常用，DECIMALS）
- D：日期（YYYYMMDD 格式）
- T：时间（HHMMSS 格式）
- XSTRING：十六进制字符串
- STRING：变长字符串

### 3. DATA 语句声明变量
- 基本语法：DATA lv_name TYPE c LENGTH 10.
- 常量声明：CONSTANTS lc_value TYPE i VALUE 100.
- TYPE vs LIKE 的区别
- TYPE 的使用：引用 DDIC 类型

### 4. WRITE 语句
- WRITE / '文本' （换行输出）
- WRITE: / '行1', '行2' （同行输出）
- FORMAT COLOR / INTENSIFIED / HOTSPOT
- NO-GAP（去空格）

### 5. 新语法：@DATA 内联声明
- 在 SELECT 语句中直接声明变量
- 在 LOOP / READ TABLE 中使用
- 在 CALL FUNCTION 中使用
- 新旧写法对比

## Demo 代码

```abap
REPORT zdemo02_hello_world.

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

## 💡 实战经验

- **@DATA 不是万能的**：@DATA 声明的变量只在当前语句块内有效（如 LOOP / IF 内），出了作用域就没了——不确定时还是用传统 DATA 声明更安全
- **WRITE 输出的坑**：直接 WRITE 一个数值时，前面会自动补空格。用 `WRITE: / |{ lv_num }|` 字符串模板可以去掉多余空格
- **sy-subrc 是 ABAP 中最重要的系统变量**：几乎每个操作都会设置它。`0` 表示成功，`4` 表示没找到数据，`8` 表示系统错误——养成每次操作后检查 sy-subrc 的习惯
- **日期类型的坑**：ABAP 日期格式是 `YYYYMMDD`（如 `20260730`），不是 `YYYY-MM-DD`。直接 WRITE 日期只会显示 `20260730`，需要用 `|{ lv_date DATE = ISO }|` 才能变成 `2026-07-30`

## 代码拆解要点

1. REPORT 定义程序名
2. DATA 分组声明 vs @DATA 内联声明
3. SELECT SINGLE 语法（只取一条）
4. INTO 工作区 vs INTO CORRESPONDING
5. WRITE 格式化输出与字符串模板

## 课后思考

1. 尝试输出 SCARR 表中所有航空公司的列表（提示：用 SELECT ... INTO TABLE + LOOP）
2. @DATA 声明的变量作用域是什么？
3. TYPE 和 LIKE 有什么区别？什么场景用哪个？
