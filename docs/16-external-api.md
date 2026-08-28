---
status: draft
---

# 第16课：调用外部接口 —— REST / SOAP

> 45分钟 | 阶段：高级篇

## 前置依赖

- 第9课：了解 Function Module 和 RFC 概念
- 第13课：了解 ABAP OO 基础（理解类的调用方式）

## 问题引入

你的 SAP 系统需要"查一下外部航空公司的实时航班信息"——但这个信息在另一个公司的系统里，通过 REST API 提供。SAP 怎么调用外部 HTTP 接口？返回的 JSON 数据怎么解析？如果调用失败了怎么处理重试？

## 时间安排

| 时段 | 内容 | 时长 |
|------|------|------|
| 场景引入 | SAP 不是孤岛——需要与外部系统交互 | 3 分钟 |
| Demo 演示 | 调用模拟的航班信息 REST API | 5 分钟 |
| 代码拆解 | CL_HTTP_CLIENT、JSON 解析（/UI2/CL_JSON）、错误处理、超时设置 | 28 分钟 |
| 知识总结 | REST 调用流程图、JSON 解析方法、常见错误处理 | 6 分钟 |
| 课后思考 | 练习 | 3 分钟 |

## 本课目标

掌握 SAP 调用外部 REST API 的方法，能处理 JSON 响应，理解异常处理和超时机制。

## Demo

通过 ABAP 程序调用一个模拟的航班信息 REST API，解析 JSON 响应并将结果展示在 ALV 报表中。

## 知识点

### 1. SAP 外部集成概述
- REST API / SOAP WebService / SAP PO / SAP CPI 各自定位
- 选型建议

### 2. REST API 调用（重点，约 25 分钟）
- CL_HTTP_CLIENT 类
  - CREATE_BY_URL 创建连接
  - SET_HEADER 设置 HTTP Header
  - SEND / RECEIVE 发送接收
  - GET_CDATA 获取响应
  - CLOSE 关闭连接
- HTTP Header 设置（Content-Type / Authorization）
- GET vs POST 请求

### 3. JSON 解析
- /UI2/CL_JSON 工具类
  - DESERIALIZE（反序列化：JSON → ABAP）
  - SERIALIZE（序列化：ABAP → JSON）
- 结构体映射

### 4. SOAP WebService 概览（约 5 分钟）
- SOAMANAGER 创建与发布
- WSDL 概念
- 消费外部 WebService（简要）

### 5. SAP PO 概览（约 5 分钟）
- Process Orchestration 架构
- Integration Engine / AEX / BPM
- IDoc 消息收发流程
- WE05/WE07 监控

### 6. SAP CPI 概览（约 5 分钟）
- Cloud Platform Integration
- iFlow 概念
- 与传统 PO 的对比

### 7. 异常处理
- HTTP 错误码处理
- CX_HTTP_WEB_PROXY / CX_ROOT

## Demo 代码

```abap
REPORT zac_rest_api.

START-OF-SELECTION.
  DATA: lo_http TYPE REF TO if_http_client,
        lv_url  TYPE string,
        lv_json TYPE string.

  " 1. 创建 HTTP 连接
  lv_url = 'https://api.exchangerate-api.com/v4/latest/USD'.

  cl_http_client=>create_by_url(
    EXPORTING
      url                = lv_url
      ssl_id             = 'ANONYMOUS'
    IMPORTING
      client             = lo_http
    EXCEPTIONS
      argument_not_found = 1
      plugin_not_active  = 2
      internal_error     = 3
      OTHERS             = 4 ).

  IF sy-subrc <> 0.
    WRITE: / 'HTTP 连接创建失败'.
    EXIT.
  ENDIF.

  " 2. 设置请求
  lo_http->request->set_method( 'GET' ).
  lo_http->request->set_header_field(
    name  = 'Content-Type'
    value = 'application/json' ).

  " 3. 发送与接收
  lo_http->send( EXCEPTIONS OTHERS = 1 ).
  IF sy-subrc <> 0.
    WRITE: / '请求发送失败'.
    lo_http->close( ).
    EXIT.
  ENDIF.

  lo_http->receive( EXCEPTIONS OTHERS = 1 ).
  IF sy-subrc <> 0.
    WRITE: / '响应接收失败'.
    lo_http->close( ).
    EXIT.
  ENDIF.

  lv_json = lo_http->response->get_cdata( ).
  lo_http->close( ).

  " 4. JSON 解析
  TYPES: BEGIN OF ty_rates,
           rates TYPE SORTED TABLE OF string WITH UNIQUE KEY table_line,
         END OF ty_rates.
  TYPES: BEGIN OF ty_result,
           base  TYPE string,
           rates TYPE SORTED TABLE OF string WITH UNIQUE KEY table_line,
         END OF ty_result.

  DATA(ls_result) = VALUE ty_result( ).

  /ui2/cl_json=>deserialize(
    EXPORTING
      json = lv_json
      pretty_name = /ui2/cl_json=>pretty_mode-camel_case
    CHANGING
      data = ls_result ).

  " 5. 获取汇率并换算
  DATA(lv_cny_rate) = 0.0.
  READ TABLE ls_result-rates INTO DATA(lv_rate_line)
    WITH KEY table_line = 'CNY'.
  " 实际需根据 JSON 结构映射解析

  SELECT SINGLE price FROM sflight
    WHERE carrid = 'AA' AND connid = '0017'
    INTO @DATA(lv_price_usd).

  IF lv_price_usd > 0 AND lv_cny_rate > 0.
    DATA(lv_price_cny) = lv_price_usd * lv_cny_rate.
    WRITE: / |原始票价: { lv_price_usd } USD|.
    WRITE: / |汇率: 1 USD = { lv_cny_rate } CNY|.
    WRITE: / |换算票价: { lv_price_cny } CNY|.
  ENDIF.
```

## 代码拆解要点

1. CL_HTTP_CLIENT 的完整调用流程
2. HTTP Header 的设置方法
3. /UI2/CL_JSON 反序列化的用法
4. SSL / TLS 的配置注意
5. 异常处理和连接关闭的重要性

## 💡 实战经验

- **SM59 先配置好**：调用外部 API 前必须在 SM59 中配置 RFC 目标（Destination）。这是 Basis 团队的工作，但开发人员需要知道配置的参数名和类型
- **JSON 解析用 /UI2/CL_JSON**：这是 SAP 官方的 JSON 工具类，比手动 SPLIT/REPLACE 解析可靠得多。传入 ABAP 结构体，JSON 字段自动映射到对应字段名
- **超时设置很重要**：默认 HTTP 超时可能太长（60秒），建议设为 10-30 秒。外部接口挂了不能让你的程序一直等
- **HTTPS 证书问题**：调用 HTTPS 接口时，如果 SAP 服务器没有导入对方的 SSL 证书，会报证书错误。需要 Basis 团队用 STRUST 导入证书
- **生产环境用 PO/CPI**：直接在 ABAP 中调用外部接口适合开发和测试。生产环境建议通过 SAP PO（Process Orchestration）或 SAP CPI（Cloud Platform Integration）做中间层——更好的监控、重试和错误处理

## 课后思考

1. 如果外部 API 返回 HTTP 500 错误，如何排查？
2. 如何发送带认证的 HTTP 请求（如 Bearer Token）？
3. REST 和 SOAP 各自的优缺点是什么？