@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '航班统计视图'
define view entity ZAC_FLIGHT_STATS
  with parameters p_carrid : abap.char(3)
  as select from sflight
    inner join scarr on sflight.carrid = scarr.carrid
{
    key sflight.carrid,
    count(*)              as flight_count,
    @Semantics.amount.currencyCode: 'currcode'
    sum(sflight.price)    as total_price,
    avg(sflight.price)    as avg_price,
    sum(sflight.seatsmax) as total_seats,
    sum(sflight.seatsocc) as total_occupied,
    scarr.currcode
}
where sflight.carrid = $parameters.p_carrid
group by sflight.carrid, scarr.currcode
