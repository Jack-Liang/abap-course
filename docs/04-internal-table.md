---
status: beta
---

# 第4课：内表与结构体操作

> 45分钟 | 阶段：基础篇 | 建议边读边做

## 前置依赖

- [第2课](02-hello-world.md)：会创建/激活/运行程序，了解基本类型；
- [第3课](03-data-dictionary.md)：了解 SFLIGHT 表结构。

## 问题引入

SFLIGHT 有几千行，`SELECT SINGLE` 一次取一条显然不现实。怎么把数据一次性"装起来"，再分组、排序、查找？答案就是**内表（Internal Table）**——ABAP 的内存容器，也是这门语言几十年来的核心数据结构。本课同时引入一批现代写法（`FOR` / `GROUP BY` / `REDUCE`），它们会让你的内表代码从"过程式循环"进化为"表达式"。

## 时间安排

| 时段 | 内容 | 时长 |
|------|------|------|
| 场景引入 | 逐条查 vs 批量处理 | 3 分钟 |
| Demo 跟做 | 运行 zac_internal_table，看四段输出 | 5 分钟 |
| 代码拆解 | 结构体/内表类型/常用操作/新语法 | 29 分钟 |
| 知识总结 | 三种内表选型表、操作速查 | 6 分钟 |
| 课后思考 | 练习 | 2 分钟 |

## 本课目标

完成本课你将能够：

- 用 `TYPES ... BEGIN OF` 定义自己的结构体和表类型；
- 说出 STANDARD / SORTED / HASHED 三种内表的差异并正确选型；
- 熟练使用 APPEND / SORT / LOOP / READ / MODIFY / DELETE；
- 用 `FOR`、`FOR GROUPS`、`REDUCE`、`CORRESPONDING` 写现代内表代码。

## Demo：批量处理航班数据（分步跟做）

程序 `zac_internal_table` 已随仓库下发，SE38 直接运行。它做四件事，输出对照着看：

```abap
REPORT zac_internal_table.

TYPES: ty_carrid_tab TYPE SORTED TABLE OF s_carr_id
                       WITH UNIQUE KEY table_line,
       BEGIN OF ty_count,
         carrid TYPE s_carr_id,
         cnt    TYPE i,
       END OF ty_count,
       ty_count_tab TYPE SORTED TABLE OF ty_count
                       WITH UNIQUE KEY carrid.

START-OF-SELECTION.
  " ① 批量读取：一次 SELECT 把 SFLIGHT 全部装进内存
  SELECT * FROM sflight INTO TABLE @DATA(lt_sflight).

  " ② FOR 表推导式——提取不重复的航空公司
  "    （UNIQUE KEY 是去重的关键：缺了它只排序、不去重）
  DATA(lt_carrids) = VALUE ty_carrid_tab(
    FOR ls IN lt_sflight
    ( ls-carrid )
  ).
  WRITE: / |航空公司数量: { lines( lt_carrids ) }|.

  " ③ FOR GROUPS——按航空公司分组统计航班数
  DATA(lt_summary) = VALUE ty_count_tab(
    FOR GROUPS grp OF ls IN lt_sflight
      GROUP BY ( carrid = ls-carrid cnt = GROUP SIZE )
    ( carrid = grp-carrid cnt = grp-cnt )
  ).
  LOOP AT lt_summary INTO DATA(ls_grp).
    WRITE: / |{ ls_grp-carrid }: { ls_grp-cnt } 条航班|.
  ENDLOOP.

  " ④ REDUCE——全表累加总已占座位
  DATA(lv_total) = REDUCE i(
    INIT sum = 0
    FOR ls IN lt_sflight
    NEXT sum = sum + ls-seatsocc
  ).
  WRITE: / |总已占座位: { lv_total }|.
```

**你会看到什么：** 第一行是**去重后**的航空公司数量（演示数据通常十几家，取决于你的 SFLIGHT 数据）；随后每家航空公司一行"xx: N 条航班"；最后一行是全表座位占用总数。第⑤节逐段拆解。

## 知识点

### 1. 结构体：内表里的"一行"

```abap
TYPES: BEGIN OF ty_summary,
         carrid TYPE s_carr_id,
         count  TYPE i,
       END OF ty_summary.

DATA ls_summary TYPE ty_summary.                     " 一行
DATA lt_summary TYPE STANDARD TABLE OF ty_summary    " 一容器行
                   WITH EMPTY KEY.
```

- 结构体 = 若干字段的组合；内表 = 结构体的可重复集合；
- **现代写法别忘了 `WITH EMPTY KEY`**——不带键的标准表在严格语法检查下要求显式声明键，`EMPTY KEY` 表示"这表没键，随便排"；
- DDIC 表也可以直接当结构体/表类型用：`TYPE sflight`、`TYPE STANDARD TABLE OF sflight`。

### 2. 三种内表类型：选型是本课的灵魂

| 类型 | 排序 | 键 | READ 性能 | 适用场景 |
|------|------|----|----------|---------|
| `STANDARD TABLE` | 保持插入序 | 可无键 | 线性 O(n) | 顺序遍历、临时收集、结果集 |
| `SORTED TABLE` | 自动按键排序 | 唯一/非唯一 | 二分 O(log n) | 需要**有序**或按键频繁查 |
| `HASHED TABLE` | 无序 | 仅唯一键 | 哈希 O(1) | 大表按键精确查找 |

```abap
DATA lt_std    TYPE STANDARD TABLE OF sflight WITH EMPTY KEY.
DATA lt_srt    TYPE SORTED TABLE OF sflight WITH NON-UNIQUE KEY carrid.
DATA lt_hash   TYPE HASHED TABLE OF sflight  WITH UNIQUE KEY carrid connid fldate.
```

**选型直觉：** 拿来就遍历 → STANDARD；边插边要求有序/按键二分 → SORTED；几万行按键随机查 → HASHED。（查找复杂度背后的数据结构原理，感兴趣的同学可延伸阅读资料库里 Hello 算法——数组/有序表/哈希表三连。）

!!! warning "WITH HEADER LINE 已死"

    `DATA lt TYPE ... WITH HEADER LINE`（表名既是表又是工作区）是上个时代的写法，官方已不推荐且在 OO 上下文中不可用。新代码一律：表 + 显式工作区（`ls_`）或 `FIELD-SYMBOLS`。

### 3. 常用操作速查

```abap
" 装载与追加
APPEND ls TO lt.                    " 标准表尾部追加
INSERT ls INTO TABLE lt.            " 通用（排序/哈希表按键定位）
COLLECT ls INTO lt.                 " 数值字段按键累加（旧式汇总）

" 排序与统计
SORT lt BY carrid ASCENDING seatsocc DESCENDING.
DATA(lv_lines) = lines( lt ).       " 行数（现代写法，替代 DESCRIBE TABLE）

" 循环
LOOP AT lt INTO DATA(ls) WHERE carrid = 'AA'.      " 只读遍历
LOOP AT lt ASSIGNING FIELD-SYMBOL(<fs>).            " 就地修改（见下）
ENDLOOP.

" 查找
READ TABLE lt INTO ls INDEX 1.                    " 按行号
READ TABLE lt INTO ls WITH KEY carrid = 'AA'.     " 按内容（线性）
READ TABLE lt INTO ls WITH TABLE KEY carrid = 'AA'. " 按表键（SORTED/HASHED 走算法）
IF sy-subrc = 0. ... ENDIF.

" 修改与删除
MODIFY lt FROM ls INDEX 5 TRANSPORTING seatsocc.  " 只搬指定字段
DELETE lt WHERE carrid = 'AA'.
CLEAR lt.                                          " 清空（保留内存）
FREE lt.                                           " 清空并释放内存
```

!!! warning "BINARY SEARCH 的隐形炸弹"

    `READ TABLE ... BINARY SEARCH` 要求表**已按查找字段排序**。不排序它照样"认真"二分——返回**随机错误行且无任何警告**。要么先 SORT，要么直接用 SORTED/HASHED 表 + `WITH TABLE KEY`，把正确性交给类型系统。

### 4. 循环中改数据：ASSIGNING vs INTO

```abap
" INTO：拷贝一行到 ls，改 ls 不影响原表，需要 MODIFY 回写
LOOP AT lt INTO ls.
  ls-seatsocc = ls-seatsocc + 1.
  MODIFY lt FROM ls TRANSPORTING seatsocc.   " 又一步，啰嗦
ENDLOOP.

" ASSIGNING：FIELD-SYMBOL 直接指向原表行，改了就是改了
LOOP AT lt ASSIGNING FIELD-SYMBOL(<fs>).
  <fs>-seatsocc = <fs>-seatsocc + 1.
ENDLOOP.
```

大数据量表循环修改，`ASSIGNING` 少一次行拷贝，是默认选择。

### 5. 新语法四件套（Demo 逐段拆解）

**① `FOR ... IN`：把循环变成表达式**

```abap
DATA(lt_carrids) = VALUE ty_carrid_tab(
  FOR ls IN lt_sflight
  ( ls-carrid ) ).
```

左边是 `VALUE 目标类型( 内容 )`，内容由 FOR 逐行投喂——一个表达式完成"遍历+投影+装载"。**去重靠的是键声明，不是 SORTED 本身**：`ty_carrid_tab` 定义为 `WITH UNIQUE KEY table_line`，重复值在插入时被丢弃；键写成 NON-UNIQUE 就只排序、不去重。

**② `FOR GROUPS`：ABAP 层的分组统计**

```abap
FOR GROUPS grp OF ls IN lt_sflight
  GROUP BY ( carrid = ls-carrid cnt = GROUP SIZE )
  ( carrid = grp-carrid cnt = grp-cnt )
```

- `GROUP BY` 定义分组键，`grp` 代表组键、组内成员可再 `FOR IN GROUP grp` 展开；
- 组键里可以用两个特殊值附加组件：`GROUP SIZE`（组内行数）和 `GROUP INDEX`（组序号）——统计类需求直接挂在键上，不必再数一遍；
- 对应 SQL 的 `GROUP BY`——数据已在内存时用它，别再倒回数据库。

**③ `REDUCE`：折叠成单值**

```abap
DATA(lv_total) = REDUCE i(
  INIT sum = 0                 " 折叠起点
  FOR ls IN lt_sflight         " 逐行
  NEXT sum = sum + ls-seatsocc ).  " 折叠动作
```

**④ `CORRESPONDING`：同名字段自动搬运**

```abap
DATA ls_flight TYPE sflight.
DATA ls_sum    TYPE ty_summary.
ls_sum = CORRESPONDING #( ls_flight ).   " 只搬两边同名的字段（carrid）
```

结构不同但有公共字段时免掉逐字段赋值；进阶参数 `MAPPING`/`EXCEPT` 第19课专题展开。

## 💡 实战经验

!!! tip "大数据量表先想键，再想循环"

    几万行内表要在循环里按键查另一张内表？把被查表建成 `HASHED TABLE WITH UNIQUE KEY`，O(1) 命中——嵌套双层 STANDARD 循环是性能杀手排行榜第一名。

!!! tip "lines( ) 替代 DESCRIBE TABLE"

    取行数用内置函数 `lines( lt )`，可内联进表达式：`IF lines( lt ) > 0.`，比 `DESCRIBE TABLE lt LINES lv_n` 干净得多。

!!! tip "REDUCE vs LOOP 累加：性能等价，选可读性"

    两者编译后差别可忽略；REDUCE 让"折叠意图"一目了然。团队规范二选一统一即可。

## 📖 延伸阅读

- [ABAP Keyword Documentation](https://help.sap.com/doc/abapdocu_752_index_htm/7.52/en-US/index.htm)——`VALUE / FOR / REDUCE / CORRESPONDING` 各条目；
- 标准表/排序表/哈希表的查找复杂度差异，本质是数据结构问题，延伸理解见参考资料库背景资料区。

## 课后思考

> 把你的回答写在**页面底部评论区**，注明题号，一起讨论。

1. 三种内表各适合什么场景？给 SFLIGHT 做"按 carrid+connid+fldate 查一个航班"的内存缓存，你选哪种？
2. `READ TABLE ... BINARY SEARCH` 的前提是什么？违反了会发生什么（为什么说它是"隐形炸弹"）？
3. 用 `FOR GROUPS` 改写：统计每家航空公司的**平均**票价（提示：组内再 REDUCE 或两次分组）。
4. `LOOP AT ... ASSIGNING` 相比 `INTO` 的优势在哪？什么情况下必须小心 `<fs>` 的生命周期？

---

下一课：[第5课：Open SQL——增删改查](05-open-sql.md)
