*&---------------------------------------------------------------------*
*& Report ZAC_FLIGHT_MANAGER
*&---------------------------------------------------------------------*
*& 第24课：综合实战 —— SFLIGHT 航班管理系统（主程序）
*& 架构：CDS（数据）→ 本地视图类（展示）→ 本地应用类（编排）
*&---------------------------------------------------------------------*
REPORT zac_flight_manager.

INCLUDE zac_flight_top.
INCLUDE zac_flight_sel.
INCLUDE zac_flight_pbo.
INCLUDE zac_flight_pai.
INCLUDE zac_flight_forms.

START-OF-SELECTION.
  go_app = NEW lcl_flight_app( ).
  go_app->get_data( ).
  go_app->display( ).
