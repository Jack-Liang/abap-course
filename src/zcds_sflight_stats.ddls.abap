@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '航班统计视图'
define view ZCDS_SFLIGHT_STATS
  with parameters p_carrid : abap.char3
  as select from sflight
{
    key sflight.carrid,
    count(*)            as flight_count,
    sum(sflight.price)  as total_price,
    avg(sflight.price)  as avg_price,
    sflight.seatsmax    as total_seats,
    sum(sflight.seatsocc) as total_occupied
}
where sflight.carrid = $parameters.p_carrid
group by sflight.carrid, sflight.seatsmax
