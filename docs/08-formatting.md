---
status: beta
---

# 第8课：数据格式化 —— 字符串、日期、货币

> 45分钟 | 阶段：核心篇 | 建议边读边做

## 前置依赖

- [第2课](02-hello-world.md)：基本数据类型；
- [第5课](05-open-sql.md)：会查表取数。

## 问题引入

查出来的日期是 `20260730`，金额是 `1500.00`——用户要的是 `2026-07-30` 和 `$1,500.00`。"原始数据"与"用户友好"之间的距离，就是本课的内容：**字符串模板**是主角，外加字符串操作全家桶、日期运算和货币格式。这些零碎知识在真实项目里的出镜率极高。

## 时间安排

| 时段 | 内容 | 时长 |
|------|------|------|
| 场景引入 | 原始数据 vs 产品级输出的对比 | 3 分钟 |
| Demo 跟做 | 运行 zac_formatting 对照八段输出 | 7 分钟 |
| 代码拆解 | 字符串模板 / 字符串操作 / 日期 / 货币 / COND | 27 分钟 |
| 知识总结 | 格式化速查表 | 5 分钟 |
| 课后思考 | 练习 | 3 分钟 |

## 本课目标

完成本课你将能够：

- 用字符串模板 `|{ }|` 完成插值、对齐、日期/货币格式化；
- 熟练使用 `&&`、SPLIT、REPLACE、CONDENSE、TRANSLATE、FIND 处理字符串；
- 做日期加减与间隔计算，用对 SY-DATUM / SY-UZEIT；
- 正确格式化 CURR/QUAN 字段（CURRENCY/UNIT 语义）；
- 用 `COND`/`SWITCH` 把多分支 IF 变成表达式。

## Demo：格式化前后对比（分步跟做）

SE38 运行 `zac_formatting`（已随仓库下发），八段输出对照下面源码看：

```abap
REPORT zac_formatting.

START-OF-SELECTION.
  " ① 新语法 && 字符串拼接
  DATA(lv_name) = 'AA' && '-' && '0017'.
  WRITE: / |航线: { lv_name }|.

  " ② 字符串模板插值
  SELECT SINGLE carrid, carrname, currcode
    FROM scarr INTO @DATA(ls_carr) WHERE carrid = 'AA'.
  WRITE: / |航空公司: { ls_carr-carrname } 货币: { ls_carr-currcode }|.

  " ③ 日期格式化（DATE 格式项只作用于类型 d，字符型会语法报错，CONV 转一下）
  DATA(lv_date) = CONV d( '20260730' ).
  WRITE: / |原始: { lv_date }|.
  WRITE: / |ISO: { lv_date DATE = ISO }|.
  WRITE: / |用户格式: { lv_date DATE = USER }|.

  " ④ 货币格式化——CURR 存的是内部格式，展示必须带币种语义
  DATA(lv_price) = 1500.
  WRITE: / |票价(USD): { lv_price CURRENCY = 'USD' }|.   " → 15.00
  WRITE: / |票价(JPY): { lv_price CURRENCY = 'JPY' }|.   " → 1,500

  " ⑤ SPLIT 拆分
  SPLIT 'AA,0017,20260730' AT ',' INTO
    @DATA(lv_a) @DATA(lv_b) @DATA(lv_c).
  WRITE: / |拆分: { lv_a } / { lv_b } / { lv_c }|.

  " ⑥ REPLACE 函数式写法
  DATA(lv_result) = replace(
    val = |Hello ABAP World|
    sub = 'World'
    with = 'SAP' ).
  WRITE: / lv_result.

  " ⑦ COND 条件表达式
  DATA(lv_seatsocc) = 180.
  DATA(lv_seatsmax) = 200.
  DATA(lv_status) = COND string(
    WHEN lv_seatsocc >= lv_seatsmax THEN '已满'
    WHEN lv_seatsocc > lv_seatsmax * 8 / 10 THEN '紧张'
    ELSE '可订' ).
  WRITE: / |状态: { lv_status }|.
```

**你会看到什么：** `2026-07-30` 与 `20260730` 同屏对比、带货币语义的票价、拆分与替换结果、`180/200 → 紧张` 的状态判断——一条数据从"生"到"熟"的全过程。

## 知识点

### 1. 字符串模板：格式化的瑞士军刀

```abap
|航班 { ls_carr-carrname }|                       " 基本插值
|{ lv_date DATE = ISO }|                          " 2026-07-30
|{ lv_date DATE = USER }|                         " 按用户主数据格式（如 07/30/2026）
|{ lv_price CURRENCY = 'USD' }|                   " 按货币的小数位
|{ lv_qty UNIT = 'KG' }|                          " 按单位的数量
|{ lv_text WIDTH = 20 ALIGN = RIGHT PAD = '.' }|  " 定宽右对齐补点
|{ COND #( WHEN lv_flag = 'X' THEN '是' ELSE '否' ) }|  " 表达式直接进模板
|下一站 \| { lv_city }|                          " 转义：\| 输出字面量竖线
```

**为什么它是首选**：一个表达式完成"拼接 + 格式化 + 对齐"，可直接嵌进 WRITE / 方法参数 / 内表构造。CONCATENATE 没死，但新代码没有理由不先想字符串模板。

!!! tip "CURRENCY 不只是加个符号"

    `CURRENCY = 'USD'` 的真正作用是按币种决定**小数位**（JPY 0 位、USD 2 位、BHD 3 位）——CURR 字段存的是内部格式，展示必须带货币语义，否则日元会多出两个零。

### 2. 字符串操作速查

| 任务 | 现代写法 | 备注 |
|------|---------|------|
| 拼接 | `'a' && 'b'` | 替代 CONCATENATE 的日常场景 |
| 拆分 | `SPLIT str AT ',' INTO a b c.` / `INTO TABLE lt` | 结果数未知时拆进内表 |
| 替换 | `replace( val = … sub = … with = … )` | 函数式；旧式 REPLACE … WITH … 仍在老代码里 |
| 查找 | `find( val = … sub = … )` 返回位置；`contains( val = … sub = … )` 返回布尔 | 替代 SEARCH/FIND 语句 |
| 长度 | `strlen( str )`、`numofchar( str )` | 后者忽略尾部空格（定长 CHAR 友好） |
| 去空格 | `condense( val = … )` | 首尾 + 压缩中间连续空格 |
| 大小写 | `to_upper( )` / `to_lower( )` | 替代 TRANSLATE … UPPER/LOWER |
| 分段 | `substring( val = … off = … len = … )` | 替代 str+off(len) 老写法 |
| 逐字符 | `segment( val = … index = … sep = … )` | 取第 N 段 |

（`shift` / `overlay` / `translate` 语句族仍在维护老代码时常见，能读懂即可。）

### 3. 日期与时间

```abap
DATA(lv_today) = sy-datum.            " 今天
DATA(lv_due)   = sy-datum + 30.       " 直接加 30 天（跨月跨年自动进位）
DATA(lv_gap)   = lv_due - sy-datum.   " 两日期相减 = 间隔天数
DATA(lv_now)   = sy-uzeit.            " 当前时间 HHMMSS
DATA(lv_hh)    = sy-uzeit(2).         " 取小时（偏移 0 长 2）
```

- 日期本质是 `YYYYMMDD` 的数字语义对象，加减乘除（天数）都是原生操作；
- 想要"格式化的今天"：`|{ sy-datum DATE = ISO }|`；
- 工作日历计算（跳过周末/节假日）要靠工厂日历 FM（如 `DATE_CONVERT_TO_FACTORYDATE`），知道方向即可。

### 4. 货币金额的正确姿势

```abap
" 存：内部格式（DEC 15,2 为多）——始终伴随币种字段
DATA: lv_price TYPE sflight-price,
      lv_curr  TYPE scarr-currcode.

" 显：三种场景
WRITE: / |显示: { lv_price CURRENCY = lv_curr }|.   " ① 字符串模板
WRITE lv_price CURRENCY lv_curr.                     " ② WRITE 附加（老代码常见）
" ③ ALV：Field Catalog 设 CFIELDNAME = 'CURRENCY'，列自动按币种格式化（第10课）
```

数量（QUAN）同理，用 `UNIT`。**金额永远和币种成对出现**——只展示金额不带币种语义，是业务系统的不诚实行为。

### 5. COND / SWITCH：分支即表达式

```abap
DATA(lv_status) = COND string(
  WHEN lv_occ >= lv_max  THEN '已满'
  WHEN lv_occ > lv_max * 8 / 10 THEN '紧张'
  ELSE '可订' ).                                   " 连续区间判断

DATA(lv_class) = SWITCH string( lv_grade           " 按单值分发
  WHEN 'A' THEN '优'
  WHEN 'B' THEN '良'
  ELSE '中' ).
```

- COND 适合**区间/条件**判断，SWITCH 适合**单值映射**；
- 能用作表达式意味着可以直接塞进模板、方法参数、VALUE 构造——IF 做不到这一点；
- 第19课新语法专题会把它们和 FOR/REDUCE 组合成完全体。

## 💡 实战经验

!!! tip "汇率换算不是乘法题"

    本课只做了"按币种展示"。真要跨币种换算，用 `CONVERT_TO_LOCAL_CURRENCY`（或 BAPI_EXCHANGERATE_*），它按汇率类型+日期取官方汇率——自己拿个硬编码汇率乘一下，审计时是要出事的。

!!! tip "SPLIT 结果未知就拆进内表"

    `SPLIT lv_csv AT ',' INTO TABLE DATA(lt_parts).` 比声明一堆变量稳——CSV 每行字段数经常不齐，拆进表再按索引取。

!!! tip "调试字符串问题先看"隐形字符""

    比较不相等但肉眼一样？多半是尾部空格或不可见字符：`|len={ strlen( lv_s ) } val=[{ lv_s }]|` 打出来看，condense 或 `= numofchar` 对症下药。

## 📖 延伸阅读

- [ABAP Keyword Documentation](https://help.sap.com/doc/abapdocu_752_index_htm/7.52/en-US/index.htm)——String Templates / String Functions 章节，内置函数全表。

## 课后思考

> 把你的回答写在**页面底部评论区**，注明题号，一起讨论。

1. `DATE = ISO` 与 `DATE = USER` 的输出差异由什么决定？
2. 为什么 `|{ lv_price CURRENCY = 'JPY' }|` 不会显示小数？内部存储值变了吗？
3. 把 Demo ⑦ 改成 SWITCH 实现——SWITCH 在这里顺手吗？为什么？
4. 写一个表达式：取 `sy-datum` 与 `'20261231'` 的间隔天数并输出"距年底还有 N 天"。

---

下一课：[第9课：Function Module（函数模块）](09-function-module.md)
