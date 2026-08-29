---
status: beta
---

# 第2课：Hello World 与基本数据类型

> 45分钟 | 阶段：基础篇 | 建议边读边做

## 前置依赖

- [第1课](01-sap-overview.md)：能登录系统、用 SE16 查表、知道 SE38 是什么。

## 问题引入

你已经会查表了，但"查"是手动操作——领导要的是每天早上自动生成的航班报表。怎么用代码读取 SCARR 并展示？写出的第一个程序能跑起来吗？本课跨过"从 0 到 1"：亲手写下、激活并运行你的第一个 ABAP 程序。

## 时间安排

| 时段 | 内容 | 时长 |
|------|------|------|
| 场景引入 | 为什么需要编程而不是手动操作 | 2 分钟 |
| Demo 跟做 | 创建、激活并运行第一个程序 | 8 分钟 |
| 代码拆解 | 程序结构、数据类型、DATA 声明、WRITE、@DATA | 27 分钟 |
| 知识总结 | 数据类型速查表、新旧语法对比 | 5 分钟 |
| 课后思考 | 练习 | 3 分钟 |

## 本课目标

完成本课你将能够：

- 在 SE38 中独立创建、激活、运行一个报表程序；
- 说出 ABAP 程序的基本骨架（REPORT → 声明 → 事件块 → 输出）；
- 声明变量时在 C/N/I/F/P/D/T/STRING 中选对类型；
- 用 `WRITE` 和字符串模板 `|{ }|` 输出数据；
- 用 `@DATA(...)` 内联声明简化代码。

## Demo：亲手运行第一个程序（分步跟做）

> 程序已随课程仓库下发（`zac_hello_world`），可以直接运行对照；更建议按下述步骤**自己从零敲一遍**。

### 步骤 1：创建程序

1. SE38，Name 字段输入 `zac_hello_world`（自己练习时可用 `zhello_自己的用户名` 避免撞名）；
2. 点 **Create**，弹窗中 Title 填 `Hello World 演示`，Type 保持默认 **Executable program**；
3. 系统要求选择 Package：课程用 `ZABAP_COURSE`（之后会提示关联传输请求，确认即可）；此时进入源代码编辑器。

### 步骤 2：敲入代码

把下面这段敲入编辑器（或粘贴，但建议敲一遍找手感）：

```abap
REPORT zac_hello_world.

START-OF-SELECTION.
  WRITE: / 'Hello ABAP!', / '---'.

  " 传统写法：先声明变量，再查询
  DATA: lv_carrid   TYPE scarr-carrid,
        lv_carrname TYPE scarr-carrname.
  SELECT SINGLE carrid, carrname
    FROM scarr INTO (lv_carrid, lv_carrname).
  WRITE: / |航空公司代码: { lv_carrid }|,
         / |名称: { lv_carrname }|.

  " 新语法写法：@DATA 内联声明
  SELECT SINGLE carrid, carrname
    FROM scarr INTO @DATA(ls_carr).
  WRITE: / |(新语法) 航空公司: { ls_carr-carrname }|.
```

### 步骤 3：保存、激活、运行

1. `Ctrl+S` 保存；
2. **激活（Ctrl+F3）**——ABAP 程序必须激活才能运行，这是和脚本语言最大的区别之一；
3. **运行（F8）**。

**你会看到什么：** 输出列表第一行 `Hello ABAP!`，随后是从 SCARR 读出的第一家航空公司的代码与名称——传统写法和新语法各输出一遍，结果相同。

!!! warning "常见报错"

    - **"Statement is not accessible"**：某条语句写在了事件块外或声明区外的非法位置；
    - **激活报 "Object ... does not exist"**：程序名敲错，或没保存就激活；
    - **输出空白**：SFLIGHT 数据没生成（回第0课第二节），或 SELECT 条件写错。

## 知识点

### 1. ABAP 程序基本结构

```abap
REPORT zac_hello_world.          " ① 程序头：声明程序类型与名称

" ② 全局声明区：DATA / TYPES / CONSTANTS / SELECT-OPTIONS ...

START-OF-SELECTION.              " ③ 事件块：主逻辑从这里开始
  " 业务代码

END-OF-SELECTION.                " ④ 可选：列表输出前的收尾逻辑
```

- **REPORT** 是可执行程序（报表）的标志，运行时通过选择屏幕触发；
- **事件块**（`START-OF-SELECTION` 等）决定了代码何时执行——不是从上到下顺序跑的普通脚本，这是 ABAP 与多数语言的第一处直觉差异；
- 简单程序只写 `START-OF-SELECTION` 就够；第7课会见到选择屏幕相关的更多事件。

### 2. 基本数据类型速查

| 类型 | 含义 | 长度/精度 | 典型用途 | 示例 |
|------|------|----------|---------|------|
| `C` | 字符 | 默认 1，可定长 | 代码、标志位 | `'AA'`、`'X'` |
| `N` | 数值文本 | 定长，前导零 | 单据号、编号 | `'0017'` |
| `I` | 整数 | 4 字节 | 计数、数量 | `42` |
| `F` | 浮点 | 8 字节 | 科学计算（**有精度坑**） | `3.14` |
| `P` | 打包数 | 1~16 字节 + DECIMALS | **金额**（课程主打） | `999.99` |
| `D` | 日期 | 8 位 `YYYYMMDD` | 日期字段 | `'20260730'` |
| `T` | 时间 | 6 位 `HHMMSS` | 时间字段 | `'103000'` |
| `STRING` | 变长字符串 | 按需增长 | 文本、JSON | `'你好 ABAP'` |
| `XSTRING` | 十进制字节串 | 变长 | 文件、二进制 | Excel 内容 |

**两个选型直觉：** 金额一律 `P`（配 `DECIMALS`，别用 F）；编号一律 `N`（保住前导零，别用 I 或 C）。

### 3. DATA 声明与 TYPE vs LIKE

```abap
DATA lv_carrid   TYPE scarr-carrid.       " 推荐：引用 DDIC 类型/表字段
DATA lv_count    TYPE i VALUE 0.
DATA lv_name     TYPE c LENGTH 20.        " 本地定义长度
CONSTANTS lc_aa  TYPE s_carr_id VALUE 'AA'. " 常量：激活时定值，运行期不可改

DATA lv_code     LIKE lv_carrid.          " 旧式：跟随另一变量
```

- **TYPE**：引用数据字典类型或已定义类型——**推荐**，语义清晰、重构友好；
- **LIKE**：照抄另一个对象的结构——旧代码常见，新代码少用（跟着变量走，变量变了它跟着变，有时是坑）；
- 命名规范（课程约定）：局部变量 `lv_`、全局 `gv_`、内表 `lt_`、工作区 `ls_`、常量 `lc_`。

### 4. WRITE 与字符串模板

```abap
WRITE: / '换行输出'.                      " / 表示换行
WRITE: '同行', '用逗号'.                   " 逗号链式

WRITE: / |航空公司: { lv_carrname }|.      " 字符串模板（第8课展开）
WRITE: / |日期: { sy-datum DATE = ISO }|. " 2026-07-30 而不是 20260730
```

传统 `WRITE` 是列表输出；**日常拼接优先字符串模板 `|{ }|`**，格式化能力更强（对齐、日期、货币格式都是它的主场，第8课细讲）。

### 5. WRITE 的 FORMAT 选项：看懂老代码即可

本课日常输出以字符串模板为主，但你打开任何一份十年前的 ABAP 程序，都会看到满屏下面这种写法——**目标是能读懂，新代码不必再写**：

```abap
" 标题行：居中输出 + 一条分隔线
WRITE: / '航班信息列表' CENTERED.
ULINE.                                    " 整行下划线分隔线（等价 WRITE / sy-uline）

" 颜色与强调（n 取 0~7 固定调色板，如 6 = 红）
WRITE: / '错误：未找到数据' COLOR 6 INTENSIFIED INVERSE.

" 对齐三兄弟：默认文本左对齐、数值右对齐
WRITE: / '名称'   LEFT-JUSTIFIED,
       / '标题'   CENTERED,
       / '金额列' RIGHT-JUSTIFIED.
```

- `COLOR n`：文字底色；`INTENSIFIED` 加亮、`INVERSE` 反白，常与 COLOR 连用；
- `ULINE`：输出整行分隔线，是老报表"标题 + 下划线"抬头的标配；
- `LEFT-JUSTIFIED / CENTERED / RIGHT-JUSTIFIED`：控制输出在列内的对齐方式。

!!! tip "格式化输出的现代分工"

    简单列表：字符串模板的格式化选项（第8课细讲）能干同样的事且更灵活；正经报表：直接上 ALV（第10课），颜色、对齐、列宽全是字段目录里的一项配置。`WRITE ... FORMAT` 家族基本只在读老代码和极少数纯文本输出场景出现。

### 6. 新语法：@DATA 内联声明

```abap
" 旧：两步走
DATA ls_carr TYPE scarr.
SELECT SINGLE carrid, carrname FROM scarr INTO CORRESPONDING FIELDS OF ls_carr.

" 新：一步到位
SELECT SINGLE carrid, carrname FROM scarr INTO @DATA(ls_carr).
```

- 变量在**使用处**声明并自动获得正确类型，删掉了"先声明后使用"的样板代码；
- 适用于 SELECT / LOOP AT / READ TABLE / FETCH 等语句的接收位置；
- **作用域规则**：内联变量作用于声明所在的**语句块**（如某个 LOOP 内部声明，出了循环就不可见）——这正是它和全局 DATA 的取舍点。

!!! tip "什么时候不用内联声明"

    变量需要**跨语句块使用**（如 LOOP 里查出值、循环外还要用）时，老实写全局 `DATA`。作用域拿不准就用全局声明，永远不会错。

## 💡 实战经验

!!! tip "sy-subrc 是 ABAP 最重要的系统变量"

    几乎每个语句执行后都会设置它：`0` 成功、`4` 未找到（SELECT 场景）、`8` 系统错误。每次 SELECT / READ / CALL FUNCTION 之后**先看 sy-subrc 再用结果**，是 ABAP 开发者的肌肉记忆。

!!! tip "WRITE 数值前的幽灵空格"

    直接 `WRITE lv_num` 输出数值时前面会自动补一个符号位空格。用字符串模板 `|{ lv_num }|` 输出更干净。

!!! tip "日期永远不是你想的样子"

    ABAP 内部日期是 `YYYYMMDD` 数字串，直接输出是 `20260730`。要人类可读格式用 `|{ lv_date DATE = ISO }|`。金额同理：`|{ lv_price CURRENCY = 'USD' }|`（第8课）。

## 📖 延伸阅读

- [ABAP Keyword Documentation](https://help.sap.com/doc/abapdocu_752_index_htm/7.52/en-US/index.htm)——查 `DATA`、`WRITE`、`SELECT SINGLE` 的权威定义；
- [参考资料库](references.md)——更多资料随课程扩充。

## 课后思考

> 不提供标准答案——**把你的回答写在页面底部评论区**，注明题号；我会参与讨论，你的答案也会帮到后来的同学。

1. 把本课程序改造成：输出 SCARR 表中**所有**航空公司的代码和名称（提示：`SELECT ... INTO TABLE @DATA(lt)` + `LOOP AT`）。
2. `@DATA(...)` 声明的变量作用域是什么？什么时候必须退回传统 `DATA`？
3. `TYPE` 和 `LIKE` 的区别？各举一个适用场景。
4. 存一个金额字段"票价 999.50 美元"，你会选什么类型？为什么不是 F（浮点）？

---

下一课：[第3课：数据字典——建一张自定义表](03-data-dictionary.md)
