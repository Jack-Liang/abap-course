FUNCTION zac_calc_flight_duration.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_CARRID) TYPE  S_CARR_ID
*"     VALUE(IV_CONNID) TYPE  S_CONN_ID
*"  EXPORTING
*"     VALUE(EV_FOUND) TYPE  ABAP_BOOL
*"     VALUE(EV_DURATION_MIN) TYPE  I
*"     VALUE(EV_DISTANCE) TYPE  S_DISTANCE
*"     VALUE(EV_CITYFROM) TYPE  S_FROM_CIT
*"     VALUE(EV_CITYTO) TYPE  S_TO_CITY
*"  EXCEPTIONS
*"      NOT_FOUND
*"----------------------------------------------------------------------

  SELECT SINGLE deptime, arrtime, distance, cityfrom, cityto
    FROM spfli
    WHERE carrid = @iv_carrid AND connid = @iv_connid
    INTO @DATA(ls_spfli).

  IF sy-subrc = 0.
    ev_cityfrom     = ls_spfli-cityfrom.
    ev_cityto       = ls_spfli-cityto.
    ev_distance     = ls_spfli-distance.
    " TIMS 是 HHMMSS 数字串，直接相减会错位——先拆出时分各自换算成分钟
    ev_duration_min = ( ls_spfli-arrtime(2) * 60 + ls_spfli-arrtime+2(2) )
                    - ( ls_spfli-deptime(2) * 60 + ls_spfli-deptime+2(2) ).
    ev_found        = abap_true.
  ELSE.
    RAISE not_found.
  ENDIF.


ENDFUNCTION.
