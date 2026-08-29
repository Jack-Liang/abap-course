*&---------------------------------------------------------------------*
*& Include ZAC_FLIGHT_PAI
*&---------------------------------------------------------------------*
*& 第24课：综合实战 —— Screen 100 PAI
*&---------------------------------------------------------------------*

MODULE user_command_0100 INPUT.
  " 经典两段式：先保存 OK 码再清空，避免与屏幕字段 OK_CODE 串值
  DATA(lv_ok) = ok_code.
  CLEAR ok_code.
  CASE lv_ok.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT' OR 'CANC'.
      LEAVE PROGRAM.
  ENDCASE.
ENDMODULE.
