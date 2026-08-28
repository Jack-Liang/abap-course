@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '航班详情视图'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZAC_FLIGHT_DETAIL
  as select from sflight
    inner join scarr on sflight.carrid = scarr.carrid
    inner join spfli on sflight.carrid = spfli.carrid
                      and sflight.connid = spfli.connid
{
    key sflight.carrid,
    key sflight.connid,
    key sflight.fldate,
    sflight.price,
    sflight.seatsmax,
    sflight.seatsocc,
    sflight.planetype,
    scarr.carrname,
    scarr.currcode,
    spfli.cityfrom,
    spfli.cityto,
    spfli.distance,
    spfli.deptime,
    spfli.arrtime
}
