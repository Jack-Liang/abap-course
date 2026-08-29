---
status: beta
---

# 第12课：Excel 导入导出

> 45分钟 | 阶段：核心篇 | 建议边读边做

## 前置依赖

- [第3课](03-data-dictionary.md)：已建好 `zac_flight_ext` 表并录入了几行数据；
- [第4课](04-internal-table.md)：内表操作；
- [第5课](05-open-sql.md)：写库与 LUW；
- [第8课](08-formatting.md)：SPLIT/字符串处理。

## 问题引入

业务每月发来一份几百行的 Excel 要录入 SAP；反过来，SAP 数据也要定期导给业务做透视。两头都绕不开"文件"。ABAP 与桌面文件打交道的主力是 `GUI_UPLOAD` / `GUI_DOWNLOAD`（前端服务器上的文件，走 SAP GUI 通道），进阶玩法是 ABAP2XLSX 开源库处理真正的 .xlsx。本课以第3课的补充信息表 `zac_flight_ext` 为主角，把"导出→加工→导入回写"整条链走通。

!!! warning "环境差异：GUI 文件操作需要 SAP GUI"

    `GUI_UPLOAD/DOWNLOAD` 操作的是**你电脑上的文件**，依赖 SAP GUI 前端——试用镜像 + SAP GUI 环境正常可用；若你在 ADT/WebGUI 等无前端环境运行会失败。第23课会看到服务器端文件的替代方案。

## 时间安排

| 时段 | 内容 | 时长 |
|------|------|------|
| 场景引入 | 文件进出的两个方向 | 3 分钟 |
| Demo 跟做 | 导出 CSV → 查看 → 导入回写（带校验） | 10 分钟 |
| 代码拆解 | 前端服务类 / 编码页 / 解析校验 / ABAP2XLSX | 24 分钟 |
| 知识总结 | 导入导出方案选型表 | 5 分钟 |
| 课后思考 | 练习 | 3 分钟 |

## 本课目标

完成本课你将能够：

- 用保存/打开对话框 + `GUI_DOWNLOAD` 把内表导出为 CSV；
- 用 `GUI_UPLOAD` 读文件进内表并逐行 SPLIT 解析；
- 实现带校验、错误统计、汇总报告的导入程序；
- 处理中文编码（codepage）与换行符等经典坑；
- 了解 ABAP2XLSX 处理真 .xlsx 的路线。

## Demo：导出→导入全链路（分步跟做）

SE38 运行 `zac_excel`（已随仓库下发）。**第一部分：导出**——

```abap
REPORT zac_excel.

START-OF-SELECTION.
  " === 第一部分：导出 zac_flight_ext 到 CSV（TAB 分隔） ===
  " 显式列清单不带 MANDT——客户端字段不该进文件
  SELECT carrid, connid, fldate, remark, priority
    FROM zac_flight_ext
    INTO TABLE @DATA(lt_ext).

  IF lines( lt_ext ) = 0.
    WRITE: / 'zac_flight_ext 无数据——先回第3课在 SE16 录入两三行，再回来导出'.
    RETURN.
  ENDIF.

  DATA(lv_default) = |flight_ext_{ sy-datum }.csv|.
  DATA lv_fullpath TYPE string.

  CALL FUNCTION 'GUI_FILE_SAVE_DIALOG'
    EXPORTING
      default_extension = 'csv'
      default_file_name = lv_default
    IMPORTING
      fullpath          = lv_fullpath.

  IF lv_fullpath IS NOT INITIAL.
    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        filename              = lv_fullpath
        filetype              = 'ASC'
        write_field_separator = 'X'      " 列间加 TAB 分隔符
        codepage              = '4110'   " UTF-8，中文必需
      TABLES
        data_tab              = lt_ext
      EXCEPTIONS
        file_write_error      = 1
        OTHERS                = 2.
    IF sy-subrc = 0.
      WRITE: / |导出成功: { lv_fullpath }|.
    ENDIF.
  ENDIF.
```

**跟做：** F8 → 弹保存对话框 → 存到桌面 → 用 Excel/文本编辑器打开看看（注意列间是 TAB 分隔、中文正常；表里没数据就先回第3课录入几行）。

**第二部分：导入回写**——用 Excel 改刚导出文件里的备注/优先级（或加几行），保存后再跑一次程序，这次在**打开对话框**里选中它：

```abap
  " === 第二部分：从 CSV 导回（打开对话框选文件 + 逐行校验 + 回写） ===
  " 不硬编码路径：让用户像导出时一样用对话框选文件
  DATA: lt_files TYPE filetable,
        lv_rc    TYPE i.

  cl_gui_frontend_services=>file_open_dialog(
    EXPORTING
      window_title            = '选择要导入的 CSV 文件'
    CHANGING
      file_table              = lt_files
      rc                      = lv_rc
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      OTHERS                  = 4 ).
  IF sy-subrc <> 0 OR lv_rc = 0.
    WRITE: / '未选择文件，导入取消'.
    RETURN.
  ENDIF.
  READ TABLE lt_files INTO DATA(ls_file) INDEX 1.

  DATA: lt_upload TYPE TABLE OF string.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename        = ls_file-filename
      filetype        = 'ASC'
      codepage        = '4110'
    TABLES
      data_tab        = lt_upload
    EXCEPTIONS
      file_open_error = 1
      OTHERS          = 2.

  IF sy-subrc = 0.
    DATA: lv_success TYPE i,
          lv_error   TYPE i,
          ls_ext     TYPE zac_flight_ext.
    LOOP AT lt_upload INTO DATA(lv_line).
      " 导出用的 TAB 分隔符，导入端必须用同一个字符拆
      SPLIT lv_line AT cl_abap_char_utilities=>horizontal_tab INTO
        DATA(lv_carrid) DATA(lv_connid) DATA(lv_fldate)
        DATA(lv_remark) DATA(lv_priority).

      IF lv_carrid IS INITIAL.
        lv_error = lv_error + 1.
        WRITE: / |第 { sy-tabix } 行数据不完整，跳过|.
        CONTINUE.
      ENDIF.

      " MODIFY = 存在即更新、不存在即新增；客户端字段 MANDT 由系统自动补当前 Client
      ls_ext = VALUE #( carrid   = lv_carrid
                        connid   = lv_connid
                        fldate   = lv_fldate
                        remark   = lv_remark
                        priority = lv_priority ).
      MODIFY zac_flight_ext FROM @ls_ext.
      IF sy-subrc = 0.
        lv_success = lv_success + 1.
      ENDIF.
    ENDLOOP.
    COMMIT WORK.
    WRITE: / |导入完成: 成功 { lv_success }, 失败 { lv_error }|.
  ENDIF.
```

**你会看到什么：** 每行 CSV 被拆成五段、逐行校验后写回 `zac_flight_ext`（MODIFY：存在即更新、不存在即新增），最后输出"成功 N，失败 M"汇总——一个最小但完整的批量导入程序。改过的备注在 SE16 里已经变样。

## 知识点

### 1. 前端文件操作家族

| 需求 | 工具 |
|------|------|
| 保存/打开对话框 | `GUI_FILE_SAVE_DIALOG` / `GUI_FILE_OPEN_DIALOG`（或类 `CL_GUI_FRONTEND_SERVICES`） |
| 下载（内表→文件） | `GUI_DOWNLOAD`：ASC（文本）/ DAT（带分隔符）/ BIN（二进制） |
| 上传（文件→内表） | `GUI_UPLOAD`：ASC/BIN；文本进 `TABLE OF string` |
| 二进制 | BIN 模式 + XSTRING（.xlsx 的基础） |

FM 与 `CL_GUI_FRONTEND_SERVICES` 静态方法（`gui_download`/`gui_upload`）是同一能力的两张皮，FM 写法短、类写法可 OO 组织——按团队口味选。

### 2. 三个经典坑

| 坑 | 症状 | 解法 |
|----|------|------|
| 中文乱码 | Excel 打开 CSV 是乱码 / 上传后中文变问号 | DOWNLOAD/UPLOAD 都显式指定 `codepage = '4110'`（UTF-8） |
| 首行不是表头 | 导出的 CSV 没列名，业务看不懂 | 先 APPEND 一行表头字符串，或手工构造文本内表再下载 |
| Excel 另存 CSV 的分号 | 德/中式区域设置下 Excel 用 `;` 分隔 | SPLIT 的分隔符与实际文件核对；稳妥做法是约定模板 + 打开前用文本编辑器抽查 |

### 3. 导入程序的标准结构（本课 Demo 的骨架）

```mermaid
flowchart LR
    A[GUI_UPLOAD<br/>读入文本行] --> B[LOOP + SPLIT<br/>逐行解析]
    B --> C{校验<br/>必填/格式/外键}
    C -->|OK| D[MODIFY / INSERT<br/>写库]
    C -->|NG| E[错误计数 + 行号日志]
    D --> F[COMMIT WORK<br/>汇总报告]
    E --> F
```

- **校验永在写库前**：必填非空、日期格式、外键存在性（第7课的 SCARR 校验模式复用）；
- **错误带行号**：`sy-tabix` 标注源文件行，业务能自己定位；
- **最后统一 COMMIT**：要么整批进，要么全回滚（第5课 LUW）；严格场景可加"预演模式"（只校验不写库）。

### 4. 真 .xlsx：ABAP2XLSX

CSV 满足不了多 Sheet、样式、公式时上 [ABAP2XLSX](https://abapgit.org)（开源，abapGit 一键装）：

```abap
DATA(lo_excel) = NEW zcl_excel( ).
DATA(lo_sheet) = lo_excel->get_active_worksheet( ).
lo_sheet->bind_table( ip_table = lt_ext ).         " 内表一键入 Sheet
" ... 写文件到服务器/AP 下载 ...
```

企业里还有 OLE2（`CREATE OBJECT excel 'EXCEL.APPLICATION'`）操纵本地 Excel——**了解即可**：慢、只适合桌面端交互，新项目别再引入。

### 5. 文件路径别硬编码：常量起步，配置收口

Demo 里 `lv_fullpath`、模板路径这类值直接写死在代码里，练手没问题，生产就是事故源：DEV/QAS/PRD 三套环境的共享盘目录、模板位置往往不同，而**代码是随传输请求三系统同步的**——环境差异改不了代码、也不该靠改代码解决。演进路线三步：

1. **起步：CONSTANTS 常量**——至少把路径收到程序顶部一处，改的时候不用全文搜；
2. **进阶：TVARVC 变式表**（STVARV 维护）——运维不改代码、不传请求就能调整取值，且按系统独立维护；
3. **复杂场景：自建定制表**（Z 表 + SM30 维护视图）——多路径、多参数、带开关时收口到一张表。

```abap
" 读 TVARVC 配置（STVARV 里维护的 Z_EXCEL_TEMPLATE 变量）
SELECT SINGLE low FROM tvarvc
  WHERE name = 'Z_EXCEL_TEMPLATE' AND type = 'P'
  INTO @DATA(lv_template).
```

!!! tip "原则：路径不同改配置，不改代码"

    判断标准很简单：这个值在 PRD 上线后有没有可能变？有可能，就别写死进代码。代码走传输、配置留在本系统——这是 DEV/QAS/PRD 三系统架构的底层默契。

## 💡 实战经验

!!! tip "导入模板是契约"

    给业务一个**固定模板**（表头+示例行+数据有效性下拉），比任何解析容错都有效。模板变了版本号+1，程序按版本解析——血泪换来的规范。

!!! tip "大文件走后台"

    `GUI_UPLOAD` 是前端同步操作，几十万行会把 SAP GUI 卡死。大数据量：文件放应用服务器（`OPEN DATASET`，第16课后深化）+ 后台作业处理。

!!! tip "导出前问一句"给谁看""

    给人看的（报表导出）用 CSV/ALV 导出即可；给系统吃的（接口文件）走 IDoc/OData/CPI（第16课），别把 Excel 当集成协议。

## 📖 延伸阅读

- [ABAP Keyword Documentation](https://help.sap.com/doc/abapdocu_752_index_htm/7.52/en-US/index.htm)——`GUI_DOWNLOAD` / `GUI_UPLOAD`；
- ABAP2XLSX 安装与文档见 [abapGit 官网](https://abapgit.org)（按第0课方式安装）。

## 课后思考

> 把你的回答写在**页面底部评论区**，注明题号，一起讨论。

1. `codepage = '4110'` 不传会发生什么？4110 是什么编码？
2. Demo 用 `MODIFY` 回写——如果业务需求是"只允许新增，不允许覆盖已有记录"，改用哪个语句？错误分支怎么处理？
3. 给导入加一道外键校验：carrid 必须存在于 SCARR——把你的校验代码贴出来（提示：第7课 `AT SELECTION-SCREEN` 里做过同样的事）。
4. 什么场景必须放弃 CSV 改用 ABAP2XLSX？

---

下一课：[第13课：ABAP 面向对象编程（基础）](13-oo-basic.md)
