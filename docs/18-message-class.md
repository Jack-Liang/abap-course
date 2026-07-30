# 第18课：消息类（Message Class）与用户提示

> 45分钟 | 阶段：高级篇

## 前置依赖

- 第7课：了解选择屏幕事件（在 AT SELECTION-SCREEN 中使用过 MESSAGE）
- 第5课：了解 sy-subrc 检查

## 问题引入

你的报表用 WRITE 输出提示信息，但这些信息是"硬编码"在代码里的——"请输入航空公司代码"直接写在程序中。如果客户要求把所有提示改成英文呢？要改多少个地方？消息类就是把提示文本"集中管理"的机制——修改一处，全局生效，还支持多语言。

## 时间安排

| 时段 | 内容 | 时长 |
|------|------|------|
| 场景引入 | 硬编码提示 vs 消息类的维护成本对比 | 3 分钟 |
| Demo 演示 | 创建消息类，在程序中使用多语言消息 | 5 分钟 |
| 代码拆解 | SE91 创建消息类、MESSAGE 语句、消息类型（E/W/I/S/A/X） | 28 分钟 |
| 知识总结 | 消息类型速查表、多语言处理要点 | 6 分钟 |
| 课后思考 | 练习 | 3 分钟 |

## 本课目标

掌握消息类的创建和使用方法，理解不同消息类型的行为差异，能在程序中使用消息进行用户提示和错误处理。

## Demo

创建航班系统消息类 ZFLIGHT_MSG，定义常用消息（如"航班不存在"、"座位已满"等），在报表中选择屏幕校验、SQL 操作等场景中使用这些消息。

## 知识点

### 1. SAP 消息体系概述
- 消息类型：S（Success）/ E（Error）/ W（Warning）/ I（Information）/ A（Abend）
- 消息 ID 与消息编号
- 消息在 SAP 体系中的作用

### 2. 消息类（Message Class）
- SE91 创建消息类
- 消息编号（3位数字：000-999）
- 消息文本（最长 80 字符）
- 占位符 &1 &2 &3 &4
- 多语言维护

### 3. 消息使用方式
- MESSAGE id msgid TYPE msgty NUMBER msgnr WITH var1 var2 ...
- 简写：MESSAGE e000(zflight)
- MESSAGE i... WITH（带变量）
- RAISING 消息（在 Function Module 中）
- MESSAGE INTO @DATA(lv_msg)（新语法：内联接收）

### 4. 消息在 Function Module 中的使用
- Exception 与消息的配合
- RAISING 模式 vs 内联模式

### 5. 消息在 BADI / 增强中的使用

### 6. 实际场景
- 输入校验时发出错误消息
- 操作成功后提示成功消息
- 批量处理中收集消息并汇总展示

## Demo 代码

```abap
REPORT zdemo18_message.

" 消息类 ZFLIGHT_MSG 示例消息：
" 001 航空公司代码 &1 不存在
" 002 航班已满，无法预订
" 003 预订成功：&1-&2-&3 座位 &4
" 004 查询完成，共 &1 条记录
" 005 数据已导出至 &1

PARAMETERS: p_carrid TYPE s_carr_id OBLIGATORY,
            p_connid TYPE sflight-connid.

AT SELECTION-SCREEN ON p_carrid.
  SELECT SINGLE carrid FROM scarr INTO @DATA(lv_check)
    WHERE carrid = @p_carrid.
  IF sy-subrc <> 0.
    MESSAGE e001(zflight) WITH p_carrid.
  ENDIF.

START-OF-SELECTION.
  SELECT COUNT(*) FROM sflight
    WHERE carrid = @p_carrid
    INTO @DATA(lv_count).

  " 成功消息
  MESSAGE s004(zflight) WITH lv_count.

  " 获取单条详情
  SELECT SINGLE * FROM sflight INTO @DATA(ls_f)
    WHERE carrid = @p_carrid AND connid = @p_connid.

  IF sy-subrc <> 0.
    " 新语法：消息内联接收
    MESSAGE e002(zflight) INTO @DATA(lv_msg).
    WRITE: / lv_msg.
  ELSE.
    " 判断是否已满
    IF ls_f-seatsocc >= ls_f-seatsmax.
      MESSAGE w002(zflight).
    ELSE.
      WRITE: / |航班 { ls_f-carrid }-{ ls_f-connid }|.
      WRITE: / |已占/最大: { ls_f-seatsocc }/{ ls_f-seatsmax }|.
      WRITE: / |票价: { ls_f-price }|.
    ENDIF.
  ENDIF.
```

## 代码拆解要点

1. SE91 中创建消息类的操作步骤
2. 消息占位符 &1 ~ &4 的使用
3. MESSAGE ... WITH 的参数传递
4. 消息类型（E/W/S/I/A）的区别
5. MESSAGE INTO @DATA 的新语法用法
6. 消息在输入校验中的使用

## 💡 实战经验

- **消息号从 001 开始**：SAP 建议消息号从 001 开始连续编号，中间不要留空——方便后续查找和维护
- **& 占位符的妙用**：消息文本中最多可以有 4 个 `&` 占位符，调用时用 `MESSAGE msgid TYPE 'E' WITH lv_var1 lv_var2` 替换。比字符串拼接更规范
- **TYPE 'E' 会中断程序**：消息类型 E（Error）会弹出错误对话框并中断当前处理流程。在 INITIALIZATION 中不要用 TYPE 'E'——会导致选择屏幕无法加载
- **消息类支持多语言**：登录 SAP 时选择的语言不同，同一条消息可以显示不同文本。在 SE91 中可以维护多语言版本的翻译
- **WITH TITLE 的用法**：`MESSAGE ... WITH ... DISPLAY LIKE 'W'` 可以改变消息的显示方式——比如用 E 类型存储但以 W 类型展示，给用户"警告"而不是"阻断"

## 课后思考

1. 消息类型 E 和 A 有什么区别？在什么场景用哪个？
2. 如何在 Function Module 中将消息传递给调用方？
3. 试着在消息文本中使用所有 4 个占位符。