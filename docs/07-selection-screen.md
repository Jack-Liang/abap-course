---
status: draft
---

# 第7课：选择屏幕

> 45分钟 | 阶段：核心篇

## 前置依赖

- 第4课：会使用内表和基本 SQL 查询
- 第5课：了解 SFLIGHT / SCARR / SPFLI 表结构

## 问题引入

前几课的报表都是写死的查询条件——比如固定查"AA航空"的数据。但实际需求是让用户自己输入条件：航空公司、日期范围、航班号。怎么给报表加一个"输入界面"？输入的数据如何校验——用户输入了一个不存在的航空公司怎么办？

## 时间安排

| 时段 | 内容 | 时长 |
|------|------|------|
| 场景引入 | 为什么报表需要选择屏幕 / 真实报表的交互需求 | 3 分钟 |
| Demo 演示 | 运行带选择屏幕的航班查询报表 | 5 分钟 |
| 代码拆解 | PARAMETERS、SELECT-OPTIONS、事件块、校验逻辑 | 28 分钟 |
| 知识总结 | PARAMETERS vs SELECT-OPTIONS 对比表 | 6 分钟 |
| 课后思考 | 练习 | 3 分钟 |

## 本课目标

掌握 PARAMETERS 和 SELECT-OPTIONS 的用法，理解选择屏幕的事件处理，能编写带校验的查询报表。

## Demo

编写航班查询报表，支持按航空公司、航线编号、航班日期范围筛选，带输入校验。

## 知识点

### 1. PARAMETERS 语句
- 基本参数：PARAMETERS p_name TYPE c LENGTH 10.
- 引用 DDIC 类型：PARAMETERS p_carrid TYPE s_carrid.
- OBLIGATORY（必填）
- DEFAULT（默认值）
- AS CHECKBOX / RADIOBUTTON GROUP
- NO-DISPLAY（隐藏参数）
- MATCHCODE OBJECT（F4 搜索帮助）
- VALUE CHECK（值校验）

### 2. SELECT-OPTIONS 语句
- 低值/高值结构（SIGN / OPTION / LOW / HIGH）
- 选项类型：EQ / BT / NB / NE / GT / LE 等
- NO INTERVALS / NO-EXTENSION
- DEFAULT / MEMORY ID

### 3. SELECTION-SCREEN 事件
- INITIALIZATION（初始化默认值）
- AT SELECTION-SCREEN OUTPUT（PBO / 修改屏幕属性）
- AT SELECTION-SCREEN ON field（单个字段校验）
- AT SELECTION-SCREEN ON END OF（内表行校验）
- AT SELECTION-SCREEN（全局校验）

### 4. 选择屏幕分组
- SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
- SELECTION-SCREEN END OF BLOCK b1.

## Demo 代码

```abap
REPORT zac_selection_screen.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
PARAMETERS: p_carrid TYPE sflight-carrid OBLIGATORY DEFAULT 'AA',
            p_connid TYPE sflight-connid.
SELECT-OPTIONS: s_date  FOR sy-datum NO-EXTENSION,
                s_seats FOR sflight-seatsocc.
SELECTION-SCREEN END OF BLOCK b1.

INITIALIZATION.
  %_p_carrid%_text = '航空公司'.
  %_p_connid%_text = '航线编号'.
  %_s_date%_text   = '航班日期'.

AT SELECTION-SCREEN ON p_carrid.
  SELECT SINGLE carrid FROM scarr INTO @DATA(lv_check)
    WHERE carrid = @p_carrid.
  IF sy-subrc <> 0.
    MESSAGE e001(00) WITH p_carrid. " 航空公司代码不存在
  ENDIF.

START-OF-SELECTION.
  SELECT carrid, connid, fldate, seatsmax, seatsocc, price
    FROM sflight
    WHERE carrid = @p_carrid AND connid IN @s_connid AND fldate IN @s_date
    INTO TABLE @DATA(lt_sflight).

  IF lt_sflight IS INITIAL.
    WRITE: / '未找到符合条件的航班'.
  ELSE.
    LOOP AT lt_sflight INTO @DATA(ls).
      WRITE: / |{ ls-carrid } { ls-connid } { ls-fldate } { ls-seatsocc }|.
    ENDLOOP.
    WRITE: / |共 { lines( lt_sflight ) } 条记录|.
  ENDIF.
```

## 代码拆解要点

1. PARAMETERS vs SELECT-OPTIONS 的区别与适用场景
2. AT SELECTION-SCREEN ON 的校验触发时机
3. SELECT-OPTIONS 的 IN 操作符使用
4. INITIALIZATION 中修改标签文字

## 💡 实战经验

- **SELECT-OPTIONS 的 Low/High 是什么？** SELECT-OPTIONS 实际上创建了一个内表，有 SIGN、OPTION、LOW、HIGH 四个字段。`BETWEEN` 和 `IN` 底层就是操作这个内表
- **OBLIGATORY 的用户体验问题**：加了 OBLIGATORY 后用户不填就无法执行，但提示不够友好。更好的做法是不加 OBLIGATORY，在 AT SELECTION-SCREEN 事件中自己校验并输出 MESSAGE
- **INITIALIZATION 是设置默认值的地方**：在 INITIALIZATION 事件中给选择屏幕字段赋值，用户打开报表时就能看到预填的默认值——比每次手动输入方便得多
- **选择屏幕上的按钮**：用 SELECTION-SCREEN PUSHBUTTON 可以在选择屏幕上加自定义按钮，配合 USER-COMMAND 实现特殊功能（如一键导出、切换查询模式）

## 课后思考

1. PARAMETERS 和 SELECT-OPTIONS 各自适合什么场景？
2. AT SELECTION-SCREEN ON 和 AT SELECTION-SCREEN 有什么区别？
3. 尝试添加一个 RADIOBUTTON GROUP 让用户选择查询方式。
