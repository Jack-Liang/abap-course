*&---------------------------------------------------------------------*
*& Report ZDEMO16_REST_API
*&---------------------------------------------------------------------*
*& 第16课：调用外部接口（REST/SOAP/PO/CPI）
*& 演示 CL_HTTP_CLIENT 调用 REST API、JSON 解析
*&---------------------------------------------------------------------*
REPORT zdemo16_rest_api.

START-OF-SELECTION.
  DATA: lo_http TYPE REF TO if_http_client,
        lv_json TYPE string.

  " 1. 创建 HTTP 连接
  cl_http_client=>create_by_url(
    EXPORTING
      url    = 'https://api.exchangerate-api.com/v4/latest/USD'
      ssl_id = 'ANONYMOUS'
    IMPORTING
      client = lo_http
    EXCEPTIONS OTHERS = 4 ).
  IF sy-subrc <> 0.
    WRITE: / 'HTTP 连接创建失败'. EXIT.
  ENDIF.

  " 2. 设置请求
  lo_http->request->set_method( 'GET' ).
  lo_http->request->set_header_field(
    name  = 'Content-Type'
    value = 'application/json' ).

  " 3. 发送与接收
  lo_http->send( EXCEPTIONS OTHERS = 1 ).
  IF sy-subrc <> 0.
    WRITE: / '请求发送失败'. lo_http->close( ). EXIT.
  ENDIF.

  lo_http->receive( EXCEPTIONS OTHERS = 1 ).
  IF sy-subrc <> 0.
    WRITE: / '响应接收失败'. lo_http->close( ). EXIT.
  ENDIF.

  lv_json = lo_http->response->get_cdata( ).
  lo_http->close( ).

  " 4. JSON 解析
  TYPES: BEGIN OF ty_result,
           base TYPE string,
         END OF ty_result.
  DATA(ls_result) = VALUE ty_result( ).
  /ui2/cl_json=>deserialize(
    EXPORTING json = lv_json
    CHANGING  data = ls_result ).

  " 5. 获取票价
  SELECT SINGLE price FROM sflight
    WHERE carrid = 'AA' AND connid = '0017'
    INTO @DATA(lv_price_usd).
  WRITE: / |原始票价: { lv_price_usd } USD|.
  WRITE: / |JSON 响应: { lv_json }|.