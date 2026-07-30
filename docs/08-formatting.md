# 第8课：数据格式化 —— 字符串、日期、货币

> 45分钟 | 阶段：核心篇

## 前置依赖

- 第2课：了解 ABAP 基本数据类型
- 第5课：会从数据库读取数据到内表

## 问题引入

从 SFLIGHT 表查出的日期是 `20260730`，货币金额没有千分位——用户看到的数据完全不像"产品级"的。怎么把这些"原始数据"格式化成用户友好的形式？比如 `2026-07-30`、`1,234,567.89 CNY`？

## 时间安排

| 时段 | 内容 | 时长 |
|------|------|------|
| 场景引入 | 原始数据 vs 用户友好数据的对比 | 3 分钟 |
| Demo 演示 | 格式化前后的航班数据对比展示 | 5 分钟 |
| 代码拆解 | 字符串模板、日期格式化、货币转换、CONDENSE/SPLIT/REPLACE | 28 分钟 |
| 知识总结 | 格式化函数速查表 | 6 分钟 |
| 课后思考 | 练习 | 3 分钟 |

## 本课目标

掌握 ABAP 中常用数据格式化方法，能灵活处理字符串、日期和数值的展示需求。

## Demo

将航班数据进行格式化输出：日期转为 YYYY-MM-DD 格式、金额带千分位、字符串拼接航班路线信息、替换特殊字符。

## 知识点

### 1. 字符串操作
- CONCATENATE → 新语法：`&&` 运算符
- SPLIT 按分隔符拆分
- SHIFT 左移/右移
- REPLACE 旧语法 → 新语法 REPLACE
- FIND / COUNT / LENGTH / STRLEN
- CONDENSE（去空格）
- TRANSLATE（大小写转换）

### 2. 字符串模板
- 基本插值：`|{ lv_name }|`
- 日期格式：`|{ lv_date DATE = ISO }|`
- 数值格式：`|{ lv_amount CURRENCY = 'USD' }|`
- 对齐与宽度：`|{ lv_text WIDTH = 20 }|`
- 条件输出：`|{ COND #( WHEN ... THEN ... ELSE ... ) }|`

### 3. 日期函数
- 系统变量：SY-DATUM / SY-UZEIT
- 日期加减
- 计算两日期间隔天数

### 4. 货币与数量格式
- WRITE ... CURRENCY / WRITE ... UNIT
- 千分位、小数位控制

## Demo 代码

```abap
REPORT zdemo08_formatting.

START-OF-SELECTION.
  " 字符串拼接 —— 新语法 &&
  DATA(lv_name) = 'AA' && '-' && '0017'.
  WRITE: / |航线: { lv_name }|.

  " 字符串模板格式化
  SELECT SINGLE carrid, carrname, currcode
    FROM scarr INTO @DATA(ls_carr) WHERE carrid = 'AA'.
  WRITE: / |航空公司: { ls_carr-carrname }|.
  WRITE: / |货币代码: { ls_carr-currcode }|.

  " 日期格式化
  DATA(lv_date) = '20260730'.
  WRITE: / |原始日期: { lv_date }|.
  WRITE: / |ISO格式: { lv_date DATE = ISO }|.
  WRITE: / |用户格式: { lv_date DATE = USER }|.

  " 数值格式化
  DATA(lv_price) = 1500.
  WRITE: / |票价: { lv_price CURRENCY = 'USD' }|.

  " SPLIT 拆分
  SPLIT 'AA,0017,20260730' AT ',' INTO
    @DATA(lv_carrid) @DATA(lv_connid) @DATA(lv_fldate).
  WRITE: / |拆分: { lv_carrid } / { lv_connid } / { lv_fldate }|.

  " REPLACE
  DATA(lv_text) = |Hello ABAP World|.
  DATA(lv_result) = replace( val = lv_text sub = 'World' with = 'SAP' ).
  WRITE: / lv_result.

  " COND 条件表达式
  DATA(lv_seatsocc) = 180.
  DATA(lv_seatsmax) = 200.
  DATA(lv_status) = COND string(
    WHEN lv_seatsocc >= lv_seatsmax THEN '已满'
    WHEN lv_seatsocc > lv_seatsmax * 8 / 10 THEN '紧张'
    ELSE '可订' ).
  WRITE: / |状态: { lv_status }|.
```

## 代码拆解要点

1. && 运算符 vs CONCATENATE
2. 字符串模板的灵活用法
3. DATE = ISO / USER 的区别
4. CURRENCY 参数影响千分位和小数
5. COND vs IF/ELSE 的可读性对比

## 💡 实战经验

- **字符串模板是首选**：`|{ lv_var }|` 语法比 CONCATENATE 更简洁，且支持方向、对齐、日期/货币格式化等——新项目一律用字符串模板
- **CONVERT_TO_LOCAL_CURRENCY 的坑**：这个函数需要传入"汇率类型"和"日期"参数，如果传错，金额会大错特错。建议先在 SE37 中单独测试，确认结果正确后再嵌入代码
- **日期计算的常见场景**：`lv_date + 30` 可以直接加天数，但跨月/跨年时 ABAP 会自动处理。如果要用工作日计算，需要用 `DATE_COMPUTE_DAY` 或 FM `HR_99S_DATE_MINUS_DAYS`
- **SPLIT 的用法注意**：`SPLIT lv_str AT ',' INTO lt_table` 在较新版本的 ABAP 中，结果表可以用 `TABLE OF string` 接收——比声明多个变量更灵活

## 课后思考

1. 字符串模板和 CONCATENATE 各有什么优势？
2. COND / SWITCH 能嵌套吗？
3. 如何将日期 '20260730' 转换为 '30.07.2026' 格式？
