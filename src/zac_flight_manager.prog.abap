*&---------------------------------------------------------------------*
*& Report ZAC_FLIGHT_MANAGER
*&---------------------------------------------------------------------*
*& 第24课：综合实战 —— SFLIGHT 航班管理系统（主程序）
*& 架构：CDS（数据）→ 本地视图类（展示）→ 本地应用类（编排）
*&---------------------------------------------------------------------*
REPORT ZAC_FLIGHT_MANAGER.

INCLUDE ZAC_FLIGHT_TOP.
INCLUDE ZAC_FLIGHT_SEL.
INCLUDE ZAC_FLIGHT_PBO.
INCLUDE ZAC_FLIGHT_PAI.
INCLUDE ZAC_FLIGHT_FORMS.

START-OF-SELECTION.
  GO_APP = NEW LCL_FLIGHT_APP( ).
  GO_APP->GET_DATA( ).
  GO_APP->DISPLAY( ).
