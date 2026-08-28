# 第12课：Excel 导入导出

> 45分钟 | 阶段：核心篇

## 前置依赖

- 第4课：会使用内表
- 第8课：了解数据格式化
- 第10课：了解 ALV 报表展示

## 问题引入

业务部门每月发来一份 Excel 文件，里面有几百条航班数据需要录入 SAP——你不可能让业务人员一条一条在 SAP 里手工输入。反过来，SAP 里的数据也需要定期导出给业务部门。怎么让 ABAP 程序"读懂"和"写出"Excel 文件？

## 时间安排

| 时段 | 内容 | 时长 |
|------|------|------|
| 场景引入 | 业务部门的 Excel 数据如何进入 SAP / SAP 数据如何出去 | 3 分钟 |
| Demo 演示 | 演示 Excel 导出航班数据和 Excel 导入新航班 | 5 分钟 |
| 代码拆解 | GUI_DOWNLOAD、GUI_UPLOAD、ABAP2XLSX、文件路径处理 | 28 分钟 |
| 知识总结 | 导入导出流程对比图、错误处理清单 | 6 分钟 |
| 课后思考 | 练习 | 3 分钟 |

## 本课目标

掌握 ABAP 与 Excel 的数据交互方法，能实现常见的数据导入导出需求。

## Demo

将 SFLIGHT 数据导出为 Excel 文件，并从 Excel 模板导入一批新航班数据到自定义表 ZAC_FLIGHT_EXT。

## 知识点

### 1. CL_GUI_FRONTEND_SERVICES 概述
- GUI 提供的文件操作类、静态方法调用模式

### 2. 文件导出
- GUI_DOWNLOAD（FILETYPE / WRITE_FIELD_SEPARATOR / CODEPAGE）
- 文件保存对话框：FILE_SAVE_DIALOG

### 3. 文件导入
- GUI_UPLOAD（FILETYPE / CODEPAGE）
- 数据解析与转换

### 4. Excel 文件处理
- 简单方式：导出 CSV
- ABAP2XLSX 简介（开源库，处理 .xlsx，通过 abapGit 安装）
- OLE2 方式（了解即可，新项目不推荐）

### 5. 导入数据校验
- 循环读取、逐行校验、错误收集、批量 INSERT

## Demo 代码

```abap
REPORT zac_excel.

START-OF-SELECTION.
  " 导出 SFLIGHT 到 CSV
  SELECT * FROM sflight INTO TABLE @DATA(lt_sflight) UP TO 100 ROWS.
  DATA(lv_default) = |sflight_{ sy-datum }.csv|.
  DATA: lv_fullpath TYPE string.
  CALL FUNCTION 'GUI_FILE_SAVE_DIALOG'
    EXPORTING default_extension = 'csv' default_file_name = lv_default
    IMPORTING fullpath = lv_fullpath.

  IF lv_fullpath IS NOT INITIAL.
    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING filename = lv_fullpath filetype = 'ASC'
        write_field_separator = 'X' codepage = '4110'
      TABLES data_tab = lt_sflight.
    IF sy-subrc = 0.
      WRITE: / |导出成功: { lv_fullpath }|.
    ENDIF.
  ENDIF.

  " 从 CSV 导入航班数据
  DATA: lt_upload TYPE TABLE OF string.
  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING filename = 'import_flights.csv' filetype = 'ASC'
    TABLES data_tab = lt_upload.

  IF sy-subrc = 0.
    DATA: lv_success TYPE i, lv_error TYPE i.
    LOOP AT lt_upload INTO @DATA(lv_line).
      SPLIT lv_line AT ',' INTO @DATA(lv_carrid) @DATA(lv_connid)
                             @DATA(lv_fldate) @DATA(lv_price).
      IF lv_carrid IS INITIAL.
        lv_error = lv_error + 1. CONTINUE.
      ENDIF.
      DATA(ls_flight) = VALUE sflight(
        carrid = lv_carrid connid = lv_connid fldate = lv_fldate price = lv_price ).
      MODIFY sflight FROM @ls_flight.
      IF sy-subrc = 0. lv_success = lv_success + 1. ENDIF.
    ENDLOOP.
    COMMIT WORK.
    WRITE: / |导入完成: 成功 { lv_success }, 失败 { lv_error }|.
  ENDIF.
```

## 代码拆解要点

1. GUI_FILE_SAVE_DIALOG 获取保存路径
2. GUI_DOWNLOAD 的关键参数
3. GUI_UPLOAD 读取文件到内表
4. SPLIT 解析 CSV 行数据
5. 导入过程中的逐行校验与错误处理

## 💡 实战经验

- **GUI_DOWNLOAD 的编码问题**：如果导出的 Excel 打开是乱码，通常是编码不对。中文 Windows 系统下默认用 `4103`（UTF-8）编码，或者用 `8404`（简体中文 GBK）
- **大文件用 ABAP2XLSX**：如果数据量超过几万行，`CL_GUI_FRONTEND_SERVICES`（即 GUI_DOWNLOAD）会很慢甚至超时。大文件推荐使用 ABAP2XLSX 库（通过 abapGit 安装），性能好很多
- **导入校验至关重要**：永远不要直接把 Excel 数据 INSERT 到数据库！先读到内表，逐行校验格式和业务规则，记录错误行，最后展示校验结果让用户确认
- **文件路径在前端**：GUI_DOWNLOAD/GUI_UPLOAD 操作的是用户电脑上的文件（Presentation Server），不是 SAP 服务器上的文件。如果需要在服务器端读写文件，要用 OPEN DATASET

## 课后思考

1. CODEPAGE '4110' 和 '8400' 分别代表什么编码？
2. 如何处理导入数据中日期格式不统一的问题？
3. 如果要导出真正的 .xlsx 格式，需要怎么做？
