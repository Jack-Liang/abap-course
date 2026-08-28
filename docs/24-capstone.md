---
status: draft
---

# 第24课：综合实战 —— SFLIGHT 航班管理系统

> 45分钟 | 阶段：现代开发篇

## 前置依赖

- 全部前23课内容

## 问题引入

23节课学完了——知识点分散在各个 Demo 中。现在要把它们整合起来，做一个"像样的"完整系统。不是简单的功能堆砌，而是用面向对象的设计思想，把航班管理、数据展示、外部接口、数据导入导出等功能组织成一个可维护的系统。

## 时间安排

| 时段 | 内容 | 时长 |
|------|------|------|
| 场景引入 | 从"知识点"到"产品"的思维转换 | 3 分钟 |
| Demo 演示 | 展示完整航班管理系统的功能全貌 | 5 分钟 |
| 代码拆解 | 系统设计思路、OO 架构、核心模块代码走读 | 28 分钟 |
| 知识总结 | 课程知识图谱、ABAP 学习路线建议 | 6 分钟 |
| 课后思考 | 课程总结 | 3 分钟 |

## 本课目标

综合运用课程所学知识，设计并实现一个航班管理系统，理解 ABAP 项目的完整架构和开发流程。

## Demo

整合前面所有知识点，开发一个完整的"航班管理系统"：选择屏幕筛选 → CDS 取数 → OO ALV 展示 → 点击预订 → BAPI 创建 → 消息提示 → Excel 导出 → 请求传输 → abapGit 推送。

## 知识点（全部回顾）

### 1. 项目架构设计
- 程序结构（Include 拆分：TOP / SEL / PBO / PAI / FORMS）
- 类组织（MVC：Model / View / Controller）
- CDS 作为数据层
- OO ALV 作为展示层
- Function Module 作为业务逻辑层

### 2. 功能模块拆解
- 选择屏幕（PARAMETERS / SELECT-OPTIONS + 校验）
- CDS View 取数（参数化 + 关联）
- OO ALV Grid 展示（容器 / Field Catalog / 事件）
- ALV 双击 → BAPI 创建 SBOOK 预订
- 消息类提示操作结果
- Excel 导出报表数据
- Transport Request 打包传输
- abapGit 推送到远程仓库

### 3. 课程总结
- 24课知识点回顾地图
- 知识体系架构图
- 后续学习路线建议
  - BTP / RAP 深入
  - Fiori Elements
  - S/4HANA Migration
  - SAP Certification
- 推荐资源
  - SAP Community
  - SAP Help Portal
  - abapGit 开源项目
  - ABAP 技术博客

## 项目代码结构

```
ZAC_FLIGHT_MANAGER（主程序）
├── ZAC_FLIGHT_TOP      → 全局数据声明、CDS View 类型引用
├── ZAC_FLIGHT_SEL      → 选择屏幕 PBO / PAI 事件
├── ZAC_FLIGHT_PBO      → ALV 初始化、Screen 处理
├── ZAC_FLIGHT_PAI      → ALV 事件处理（双击 / Toolbar）
├── ZAC_FLIGHT_FORMS    → 辅助逻辑（BAPI 调用、Excel 导出、消息）
├── ZAC_FLIGHT_DETAIL    → CDS View（航班详情）
├── ZAC_FLIGHT_STATS     → CDS View（统计）
├── ZCL_FLIGHT_MANAGER     → 全局类（MVC Controller）
├── ZCL_ALV_DISPLAY        → ALV 展示类
└── ZCL_AC_FLIGHT_SERVICE     → 业务逻辑类（BAPI 封装）
```

## Demo 代码

主程序：
```abap
REPORT zac_flight_manager.

INCLUDE zac_flight_top.
INCLUDE zac_flight_sel.
INCLUDE zac_flight_pbo.
INCLUDE zac_flight_pai.
INCLUDE zac_flight_forms.

INITIALIZATION.
  PERFORM init_default.

START-OF-SELECTION.
  PERFORM get_data.
  PERFORM display_alv.
```

TOP Include：
```abap
* ZAC_FLIGHT_TOP
TABLES: sflight.

DATA: go_app TYPE REF TO lcl_flight_app.

PARAMETERS: p_carrid TYPE sflight-carrid OBLIGATORY DEFAULT 'AA'.

SELECT-OPTIONS: s_date FOR sflight-fldate.

* CDS 类型声明
TYPES: BEGIN OF ty_flight_detail.
        INCLUDE TYPE zac_flight_detail.
TYPES:   status TYPE string,
TYPES:   load_factor TYPE p DECIMALS 2,
TYPES: END OF ty_flight_detail.
```

Controller 类：
```abap
CLASS lcl_flight_app DEFINITION.
  PUBLIC SECTION.
    METHODS:
      constructor IMPORTING iv_carrid TYPE s_carr_id,
      get_data,
      display,
      create_booking IMPORTING iv_connid TYPE s_conn_id
                               iv_fldate TYPE s_date,
      export_to_excel.
  PRIVATE SECTION.
    DATA: mv_carrid TYPE s_carr_id,
          mt_data   TYPE STANDARD TABLE OF ty_flight_detail,
          mo_alv    TYPE REF TO lcl_alv_display.
ENDCLASS.

CLASS lcl_flight_app IMPLEMENTATION.
  METHOD constructor.
    mv_carrid = iv_carrid.
    mo_alv = NEW lcl_alv_display( ).
  ENDMETHOD.

  METHOD get_data.
    " 通过 CDS View 取数
    SELECT * FROM zac_flight_detail( p_carrid = @mv_carrid )
      WHERE fldate IN @s_date
      INTO CORRESPONDING FIELDS OF TABLE @mt_data.

    " 计算状态和上座率
    LOOP AT mt_data ASSIGNING FIELD-SYMBOL(<fs>).
      <fs>-load_factor = COND p(
        WHEN <fs>-seatsmax > 0 THEN <fs>-seatsocc * 100 / <fs>-seatsmax
        ELSE 0 ).
      <fs>-status = COND string(
        WHEN <fs>-seatsocc >= <fs>-seatsmax THEN '已满'
        WHEN <fs>-load_factor > 80 THEN '紧张'
        ELSE '可订' ).
    ENDLOOP.
  ENDMETHOD.

  METHOD display.
    mo_alv->display( it_data = mt_data ).
  ENDMETHOD.

  METHOD create_booking.
    " 调用 BAPI 创建预订
    zcl_ac_flight_service=>create_booking(
      iv_carrid  = mv_carrid
      iv_connid  = iv_connid
      iv_fldate  = iv_fldate ).
    " 刷新数据
    get_data( ).
    mo_alv->refresh( mt_data ).
  ENDMETHOD.

  METHOD export_to_excel.
    " 导出 Excel
    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        filename = |flight_{ sy-datum }.csv|
        filetype = 'ASC'
        write_field_separator = 'X'
      TABLES
        data_tab = mt_data.
    MESSAGE s000(oo) WITH '导出成功'.
  ENDMETHOD.
ENDCLASS.
```

## 代码拆解要点

1. Include 拆分的最佳实践
2. CDS View 作为数据层的优势
3. MVC 模式在 ABAP 中的应用
4. BAPI 调用封装为类的静态方法
5. 事件处理与业务逻辑的解耦
6. 全流程串联：从用户输入到数据展示

## 课程总结

### 知识体系回顾
- **基础篇（1-6）**：SAP 入门 → 数据类型 → 数据字典 → 内表 → SQL → 调试
- **核心篇（7-13）**：选择屏幕 → 格式化 → Function → ALV → Excel → OO
- **高级篇（14-19）**：BAPI → 增强 → 外部接口 → 传输 → 消息 → 新语法
- **现代篇（20-24）**：CDS → OO ALV → BTP → abapGit → 综合实战

### 后续学习建议
1. 实际项目中练习（找一个真实的开发需求）
2. 学习 SAP Fiori Elements + RAP 模型
3. 关注 SAP BTP 和 S/4HANA 新特性
4. 考虑 SAP 认证（C_TAW12_750 等）
5. 持续关注 SAP Community 和技术博客

## 💡 实战经验

- **先设计再编码**：综合项目最忌"边写边想"。先画出类图和流程图，明确每个类的职责和接口，再开始编码——可以避免大量返工
- **不要追求完美**：综合实战的目的是"串联知识点"，不是做出生产级产品。功能完整 > 代码完美。有时间的同学可以在课后持续优化
- **代码复用之前的成果**：第1-23课的代码都是这次实战的"积木"。不需要从头写——把之前的类、Function Module、CDS View 直接复用过来
- **课程只是起点**：24节课覆盖了 ABAP 开发的核心知识，但 ABAP 的世界远不止这些。后续可以深入学习：Web Dynpro / SAPUI5（UI开发）、IDoc/ALE（接口）、Workflow（工作流）、HANA Native SQL（数据库开发）

## 课后思考

1. 回顾24课，你觉得自己掌握最好的是哪些部分？
2. 哪些知识点还需要额外练习？
3. 尝试为航班管理系统增加一个新功能（如按月份统计票价趋势）。
