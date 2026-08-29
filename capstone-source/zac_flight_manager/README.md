# ZAC_FLIGHT_MANAGER —— 第24课综合实战参考源码包

## 这个目录是什么

第24课"综合实战 —— SFLIGHT 航班管理系统"主程序 `ZAC_FLIGHT_MANAGER`（含 5 个 INCLUDE + Screen 100）的**可粘贴级完整参考实现**，与 `docs/24-capstone.md` 的设计走读一一对应。

**本目录是过渡产物**：请作者把下列源码逐个粘贴进 SAP 系统、画好 Screen 100、全部激活并自测通过后，用 **abapGit pull** 让系统生成正式的 `src/zac_flight_manager.prog.abap` / `.prog.xml` / `.prog.screen_0100.abap`（新版 abapGit 支持序列化 Dynpro：流逻辑单列一个文件，元素清单在 `.prog.xml` 的 `DYNPROS` 段）入库文件。元素清单仍保留在本目录，供画屏对照与旧版 abapGit 环境兜底。

## 文件清单

| 文件 | 对应对象 | 内容 |
|------|----------|------|
| `zac_flight_manager.prog.abap` | ZAC_FLIGHT_MANAGER | 主程序：INCLUDE 框架 + START-OF-SELECTION |
| `zac_flight_top.abap` | ZAC_FLIGHT_TOP | 全局声明：TABLES / 类型 / 两个本地类 DEFINITION / go_app、ok_code |
| `zac_flight_sel.abap` | ZAC_FLIGHT_SEL | 选择屏幕（b1 / p_carrid / s_date）+ 公司代码校验 |
| `zac_flight_pbo.abap` | ZAC_FLIGHT_PBO | Screen 100 PBO：MODULE status_0100 |
| `zac_flight_pai.abap` | ZAC_FLIGHT_PAI | Screen 100 PAI：MODULE user_command_0100 |
| `zac_flight_forms.abap` | ZAC_FLIGHT_FORMS | lcl_alv_display / lcl_flight_app 两个类的 IMPLEMENTATION |

## 建对象顺序

1. **先建 5 个 INCLUDE**：SE38 或 ADT 新建程序 `ZAC_FLIGHT_TOP` / `ZAC_FLIGHT_SEL` / `ZAC_FLIGHT_PBO` / `ZAC_FLIGHT_PAI` / `ZAC_FLIGHT_FORMS`，**程序类型 = I（包含程序）**，分别粘贴对应 `.abap` 文件内容并激活（`ZAC_FLIGHT_TOP` 引用了 `lcl_flight_app` 与 `lcl_alv_display`，自身声明完整，可独立激活）。
2. **建主程序**：新建 `ZAC_FLIGHT_MANAGER`，**程序类型 = 1（可执行程序）**，粘贴 `zac_flight_manager.prog.abap` 内容。
3. **画 Screen 100**：在主程序上右键 → 创建屏幕，元素按下表配置。
4. **文本符号**：主程序的文本符号中设 `b01 = 查询条件`（SELECTION TEXTS 里也给 p_carrid / s_date 配上选择文本，如"航空公司"/"航班日期"）。
5. **全部激活**（SE80 / ADT 整体激活），然后运行 `ZAC_FLIGHT_MANAGER` 自测。

## Screen 100 元素清单

| 元素 | 配置 |
|------|------|
| 屏幕类型 | Normal（普通屏幕） |
| Custom Control | 名称 `CUST_FLIGHT`，拖满整个屏幕，勾选"可调整大小"（Resizing 垂直 + 水平） |
| OK 码字段 | 字段名 `OK_CODE`（元素清单中分配，类型 OK） |
| 流逻辑 PBO | `PROCESS BEFORE OUTPUT.` → `MODULE status_0100.` |
| 流逻辑 PAI | `PROCESS AFTER INPUT.` → `MODULE user_command_0100.` |
| GUI 状态 `STATUS_100` | 含 `BACK`（F3）、`EXIT`（Shift+F3，功能类型 E）、`CANC`（F12，功能类型 E） |
| 标题 `TITLE_100` | `SFLIGHT 航班管理` |

## 运行前提

以下对象必须已在系统中激活（即已通过 abapGit 从本仓库 `src/` 导入）：

- `ZAC_FLIGHT_DETAIL` —— CDS 视图实体（数据层，第20课）
- `ZCL_AC_FLIGHT_SERVICE` —— 业务服务类（BAPI 封装，第14课）
- `ZAC_FLIGHT_MSG` —— 消息类（第18课，001–005 号消息）

另需 SFLIGHT 示例数据（`SAPBC_DATA_GENERATOR` 生成）。

## 已知限制

- **服务类为真实 BAPI 实现**：`zcl_ac_flight_service=>create_booking` 内部调用 `BAPI_FLBOOKING_CREATEFROMDATA` 并完成 RET2 检查与 COMMIT/ROLLBACK（成功返回真实预订号，失败返回初值并把原因放进 `ev_message`，`zac_flight_forms.abap` 里对应有失败分支）。需要系统带 SAP_BASIS 演示 Flight BAPI，且 `SCUSTOM` / `STRAVELAG` 有演示数据。`cancel_booking` 仍是教学占位（课后练习）。
- **满员判断基于内存快照**：`create_booking` 里的满员校验读的是展示内表 `mt_data` 的当前行，真实项目应在服务类内对 `sflight` 加锁重查。
- **导出为 TAB 分隔 CSV**：`GUI_DOWNLOAD` 用 `filetype = 'ASC'` + `write_field_separator = 'X'`，字段以制表符分隔，Excel 可直接打开；`STATUS`（string）列在不同 GUI 版本下可能被截断，如需精确宽度可改用 `filetype = 'DAT'` 方案。
