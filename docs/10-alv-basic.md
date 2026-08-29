---
status: beta
---

# 第10课：ALV 报表（基础）

> 45分钟 | 阶段：核心篇 | 建议边读边做

## 前置依赖

- [第4课](04-internal-table.md)：内表；
- [第5课](05-open-sql.md)：JOIN 查询。

## 问题引入

WRITE 输出的"纯文本列表"没有排序、没有合计、没有导出——用户第一眼就会问"能不能像 Excel 那样玩？"。**ALV（ABAP List Viewer）**就是 SAP 的标准答案：把内表扔给它，它给出一个自带排序/筛选/合计/导出/布局定制的专业表格。本课用最经典的 Function ALV 起步，第22课再进化到 OO ALV。

## 时间安排

| 时段 | 内容 | 时长 |
|------|------|------|
| 场景引入 | WRITE vs ALV 的直观对比 | 3 分钟 |
| Demo 跟做 | 运行报表 + 体验工具栏五件套 | 8 分钟 |
| 代码拆解 | REUSE 调用 / Field Catalog / Layout | 26 分钟 |
| 知识总结 | ALV 三代技术对比、Field Catalog 速查 | 5 分钟 |
| 课后思考 | 练习 | 3 分钟 |

## 本课目标

完成本课你将能够：

- 用 `REUSE_ALV_GRID_DISPLAY` 把任意内表渲染成 ALV Grid；
- 手工/自动两种方式构建 Field Catalog，定制列标题、列宽、合计；
- 用 Layout 开启斑马纹、列宽优化、合计文本；
- 熟练使用 ALV 标准工具栏（排序/筛选/合计/导出/布局变式）。

## Demo：第一个 ALV 报表（分步跟做）

SE38 运行 `zac_alv_basic`（已随仓库下发）：

```abap
REPORT zac_alv_basic.

START-OF-SELECTION.
  SELECT f~carrid, f~connid, f~fldate, f~seatsmax,
         f~seatsocc, f~price, c~carrname
    FROM sflight AS f
    INNER JOIN scarr AS c ON f~carrid = c~carrid
    INTO TABLE @DATA(lt_sflight).

  " VALUE 构造 Field Catalog
  DATA(lt_fieldcat) = VALUE slis_t_fieldcat_alv(
    ( fieldname = 'CARRID'    seltext_l = '航空公司代码' outputlen = 10 )
    ( fieldname = 'CONNID'    seltext_l = '航线编号'     outputlen = 10 )
    ( fieldname = 'FLDATE'    seltext_l = '航班日期'     outputlen = 12 )
    ( fieldname = 'CARRNAME' seltext_l = '航空公司名称' outputlen = 20 )
    ( fieldname = 'SEATSMAX'  seltext_l = '最大座位'     outputlen = 12 do_sum = 'X' )
    ( fieldname = 'SEATSOCC'  seltext_l = '已占座位'     outputlen = 12 do_sum = 'X' )
    ( fieldname = 'PRICE'     seltext_l = '票价'         outputlen = 15 )  " 多币种混列，合计没有意义
  ).

  DATA(ls_layout) = VALUE slis_layout_alv(
    zebra = 'X'
    colwidth_optimize = 'X'
    totals_text = '合计' ).

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid
      is_layout          = ls_layout
      it_fieldcat        = lt_fieldcat
    TABLES
      t_outtab           = lt_sflight
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
```

**你会看到什么：** 全屏 ALV 表格——斑马纹、中文列标题、两个座位数值列底部自动合计（票价是多币种混列，不做合计——见字段目录注释）。然后体验**工具栏五件套**（用户视角的 ALV 价值全在这）：

1. **排序**：点列头再点升/降序按钮；
2. **筛选**：选中某行某列的值 → Filter → 按此值过滤；
3. **小计**：先把 CARRID 拖进左侧排序区（或设为排序字段）→ Subtotals——每家航空公司一段小计；
4. **导出**：本地文件（Spreadsheet/CSV）一键落 Excel；
5. **布局**：调整列序/隐藏列后保存**变式**（Layout），下次直接选。

<!-- 配图（待截图后启用）：![ALV 报表全屏效果](https://cdn.jsdelivr.net/gh/jack-liang/abap-course-assets@main/10-alv-basic/alv-grid.png) -->

## 知识点

### 1. ALV 三代技术

| 代 | 入口 | 本课地位 |
|----|------|---------|
| Function ALV | `REUSE_ALV_GRID_DISPLAY`（FM） | ✅ 本课：语法最短、上手最快，海量存量代码在用 |
| SALV（OO 简化版） | `CL_SALV_TABLE` | 更现代的"简单模式"，工厂方法 + 方法调用 |
| OO ALV | `CL_GUI_ALV_GRID` + 容器 | 第22课：可编辑单元格、自定义工具栏、事件全掌控 |

三代共存是现实：**读得懂 REUSE（存量）、新报表可上 SALV、复杂交互上 OO ALV**。

### 2. REUSE_ALV_GRID_DISPLAY 的骨架

```abap
CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
  EXPORTING
    i_callback_program = sy-repid   " 回调定位用（交互事件要找到你的 FORM）
    is_layout          = ls_layout  " 布局
    it_fieldcat        = lt_fieldcat" 字段目录：列怎么显示
    i_save             = 'A'        " 允许保存布局变式（'A'=用户+全局）
  TABLES
    t_outtab           = lt_sflight " 数据源：任意结构内表
  EXCEPTIONS ...
```

**心法：ALV = 内表 + 字段目录 + 布局。**数据丢进去，怎么显示全靠后两样。

### 3. Field Catalog：列的说明书

每一列一条记录，常用字段：

| 字段 | 作用 |
|------|------|
| `FIELDNAME` | 对应内表字段名（必填） |
| `REF_TABLE` / `REF_FIELD` | 引用 DDIC——列标题、转换例程、单位全继承（**能引用就不手填**） |
| `SELTEXT_L/M/S` | 长/中/短列标题（无 REF 时手工指定） |
| `OUTPUTLEN` | 列宽 |
| `DO_SUM` | 该列合计 |
| `NO_ZERO` | 零值显示为空（数值列观感神器） |
| `HOTSPOT` | 列变热点链接（第11课） |
| `CURRENCY` / `CFIELDNAME` | 金额列的币种引用（第8课的货币语义落地处） |
| `EMPHASIZE` | 列底色（如 'C300'） |

**自动生成**：内表结构源自 DDIC 时用 `REUSE_ALV_FIELDCATALOG_MERGE` 让系统按结构生成，再逐项覆盖需要定制的列——比全手写省事且不会漏字段。

**JOIN 内表的坑**：本课数据来自 JOIN（carrname 不在任何单表结构里），自动生成对不上，所以全手写——这正是 SELTEXT_L 的用武之地。

### 4. Layout：表格的皮肤

| 选项 | 效果 |
|------|------|
| `zebra = 'X'` | 斑马纹 |
| `colwidth_optimize = 'X'` | 按内容自动列宽 |
| `totals_text` | 合计行标签 |
| `no_colhead` | 隐藏列头（拼接到别的输出时用） |
| `info_fieldname` | 指定一个 'X'/颜色的字段控制整行底色（行级高亮） |
| `window_titlebar` | 窗口标题 |

### 5. 变式（Layout Variant）

用户调好的列序/隐藏/合计方案可保存为**变式**；`i_save = 'A'` + `is_variant` 报表名让用户"存自己的布局、下次直接选"。报表加 `i_save` 一行，用户满意度+1——性价比极高。

### 6. 两个加分项：可编辑列与页头回显选择条件

**可编辑列（简要提及）**：字段目录里给某列加 `edit = 'X'`，该列就变成可输入框。但先清醒认识两件事：

- 编辑改的只是**屏幕上那份内表副本**——改屏幕 ≠ 改数据库，把值回写 SFLIGHT 是你自己的责任；
- 想在用户敲键时实时校验，要注册 DATA_CHANGED 事件（REUSE 版：`i_events` 传一行 `name = slis_ev_data_changed` + 对应处理 FORM），复杂度明显上升。

真正的可编辑 ALV 项目通常直接上第22课的 OO ALV——此处点到为止，面试和被追问时知道有这回事即可。

**把选择条件显示到页头**：报表的选择条件（`p_carrid`、`s_date` 之类）在结果屏幕上默认是看不见的，但用户截图、打印时最想带上的恰恰是它。经典 LIST 型 ALV（`REUSE_ALV_LIST_DISPLAY`）的 Layout 里有 `get_selinfos` 选项，可让系统把选择屏幕信息自动带进清单抬头；GRID 型没有这项自动能力，标准做法是自己回调页头画出来：

```abap
CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
  EXPORTING
    i_callback_program     = sy-repid
    i_callback_top_of_page = 'TOP_OF_PAGE'   " 页头回调
    is_layout              = ls_layout
    it_fieldcat            = lt_fieldcat
  TABLES
    t_outtab               = lt_sflight.

FORM top_of_page.
  DATA(lt_list) = VALUE slis_t_listheader(
    ( typ = 'H' info = '航班信息列表' )
    ( typ = 'S' key = '航空公司' info = p_carrid )
    ( typ = 'S' key = '日期区间' info = |{ s_date-low } ~ { s_date-high }| ) ).
  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING it_list_commentary = lt_list.
ENDFORM.
```

第11课的 Demo 会完整走一遍这个回调——此处先知道"页头画布就是干这个的"即可。

## 💡 实战经验

!!! tip "ALV 程序里不要 WRITE"

    ALV 接管整个列表输出；混入 WRITE 会产生两段拼接的"丑列表"。提示信息用 MESSAGE（S 型状态栏），别用 WRITE。

!!! tip "显示不出来先断点看内表"

    ALV 空白的九成原因是内表为空（SELECT 条件错）。调 REUSE 前设断点翻内表（第6课技能），30 秒定位。

!!! tip "列标题优先走 DDIC"

    手写 SELTEXT_L 的列，业务改名时代码要跟着改；REF_TABLE/REF_FIELD 引用 DDIC 的列，改 DDIC 数据元素标签（第3课）即可全局生效。能引用，不手填。

## 📖 延伸阅读

- [ABAP Keyword Documentation](https://help.sap.com/doc/abapdocu_752_index_htm/7.52/en-US/index.htm)——REUSE_ALV_* / SALV 类族文档；
- 第22课 OO ALV 对比章节（学完本课再看，对比更清晰）。

## 课后思考

> 把你的回答写在**页面底部评论区**，注明题号，一起讨论。

1. `REF_FIELDNAME/REF_TABLE` 与 `SELTEXT_L` 各解决什么问题？优先用哪个，为什么？
2. 给报表加"允许用户保存布局变式"要改哪两个参数？
3. 动手：把 PRICE 列设为 NO_ZERO 并给 SEATSOCC/SEATSMAX 算"上座率"列（提示：改 SELECT 加计算列，或查完后 LOOP 加工）——把你的列定义贴出来。
4. Function ALV / SALV / OO ALV 各适合什么场景？

---

下一课：[第11课：ALV 交互事件](11-alv-events.md)
