" 飞行查询工具类（第13课封装版）
CLASS zcl_ac_flight_query DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: ty_sflight_tab TYPE STANDARD TABLE OF sflight WITH EMPTY KEY.

    METHODS:
      constructor IMPORTING iv_carrid TYPE s_carr_id OPTIONAL,
      get_flights   RETURNING VALUE(rt_sflight) TYPE ty_sflight_tab,
      get_detail    IMPORTING iv_connid        TYPE s_conn_id
                              iv_fldate        TYPE s_date
                    RETURNING VALUE(rs_detail) TYPE sflight.

    DATA: mv_carrid TYPE s_carr_id READ-ONLY.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_AC_FLIGHT_QUERY IMPLEMENTATION.


  METHOD constructor.
    mv_carrid = COND #( WHEN iv_carrid IS NOT INITIAL THEN iv_carrid ELSE 'AA' ).
  ENDMETHOD.


  METHOD get_flights.
    SELECT * FROM sflight WHERE carrid = @mv_carrid INTO TABLE @rt_sflight.
  ENDMETHOD.


  METHOD get_detail.
    SELECT SINGLE * FROM sflight
      WHERE carrid = @mv_carrid AND connid = @iv_connid AND fldate = @iv_fldate
      INTO @rs_detail.
  ENDMETHOD.
ENDCLASS.
