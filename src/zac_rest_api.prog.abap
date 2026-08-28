*&---------------------------------------------------------------------*
*& Report ZAC_REST_API
*&---------------------------------------------------------------------*
*& 第16课：调用外部接口（REST/SOAP/PO/CPI）
*& 演示 CL_HTTP_CLIENT 调用 REST API、JSON 解析、票价换算
*&---------------------------------------------------------------------*
REPORT zac_rest_api.

START-OF-SELECTION.
  DATA: lo_http TYPE REF TO if_http_client,
        lv_json TYPE string.

  " 1. 创建 HTTP 客户端
  cl_http_client=>create_by_url(
    EXPORTING
      url    = 'https://open.er-api.com/v6/latest/USD'
      ssl_id = 'ANONYMOUS'
    IMPORTING
      client = lo_http
    EXCEPTIONS OTHERS = 4 ).
  IF sy-subrc <> 0.
    WRITE: / 'HTTP 连接创建失败（检查网络/SM59/SSL）'. EXIT.
  ENDIF.

  " 2. 组装 GET 请求
  lo_http->request->set_method( 'GET' ).
  lo_http->request->set_header_field(
    name  = 'Accept' value = 'application/json' ).

  " 3. 发送与接收
  lo_http->send( EXCEPTIONS OTHERS = 1 ).
  IF sy-subrc <> 0.
    WRITE: / '请求发送失败'. lo_http->close( ). EXIT.
  ENDIF.
  lo_http->receive( EXCEPTIONS OTHERS = 1 ).
  IF sy-subrc <> 0.
    WRITE: / '响应接收失败（外网/防火墙/SSL 证书，见课文环境提示）'.
    lo_http->close( ). EXIT.
  ENDIF.

  lv_json = lo_http->response->get_cdata( ).
  lo_http->close( ).

  WRITE: / |响应前 200 字: {
    COND string( WHEN strlen( lv_json ) > 200
                 THEN substring( val = lv_json len = 200 )
                 ELSE lv_json ) }|.

  " 4. JSON 解析：按需声明字段，工具类按名自动映射
  TYPES: BEGIN OF ty_rates,
           cny TYPE string,
           jpy TYPE string,
         END OF ty_rates.
  TYPES: BEGIN OF ty_result,
           result    TYPE string,
           base_code TYPE string,
           rates     TYPE ty_rates,
         END OF ty_result.

  DATA(ls_result) = VALUE ty_result( ).
  /ui2/cl_json=>deserialize(
    EXPORTING
      json        = lv_json
      pretty_name = /ui2/cl_json=>pretty_mode-none
    CHANGING
      data        = ls_result ).

  " 5. 查票价并换算
  SELECT SINGLE price FROM sflight
    WHERE carrid = 'AA' AND connid = '0017'
    INTO @DATA(lv_price_usd).

  IF ls_result-rates-cny IS NOT INITIAL.
    DATA(lv_rate) = CONV f( ls_result-rates-cny ).
    WRITE: / |原始票价: { lv_price_usd } USD|.
    WRITE: / |实时汇率: 1 USD = { lv_rate } CNY|.
    WRITE: / |换算票价: { lv_price_usd * lv_rate NUMBER = USER } CNY|.
  ELSE.
    WRITE: / '未能解析到 CNY 汇率（检查网络与 JSON 结构）'.
  ENDIF.
