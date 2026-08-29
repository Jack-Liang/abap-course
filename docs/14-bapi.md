---
status: beta
---

# 第14课：BAPI 调用 —— SAP 标准业务接口

> 45分钟 | 阶段：高级篇 | 建议边读边做

## 前置依赖

- [第9课](09-function-module.md)：CALL FUNCTION 与 RFC 概念（BAPI 的谜底）；
- [第5课](05-open-sql.md)：COMMIT WORK 与 LUW。

## 问题引入

程序要"自动创建一条航班预订"——座位检查、价格计算、库存锁定这套逻辑自己写？SAP 早已封装好，以 **BAPI**（Business Application Programming Interface）对外开放：它是 RFC-enabled 的 FM + 严格的接口规范（RET2 返回表、独立事务控制）。掌握 BAPI，你就能安全地驱动 SAP 的全部标准业务，而不是绕过它直接捅表。

!!! warning "环境差异：Flight BAPI 的齐备度"

    课程 Demo 用的 `BAPI_FLBOOKING_CREATEFROMDATA` 属 SAP_BASIS 自带的演示 Flight 模型（SAP 官方注明"仅供培训/演示"），试用镜像通常都有。不同镜像包含的 Flight BAPI 不完全一致，跑 Demo 前先 SE37 搜索 `BAPI_FLBOOKING*` / `BAPI_FLIGHT*` 确认；如果你的镜像缺某个，跟着课文学调用模式即可——**RETURN 检查 + COMMIT/ROLLBACK 的范式适用于所有 BAPI**，第24课综合实战还会用课程自建的 `zcl_ac_flight_service` 复用同样的模式。

## 时间安排

| 时段 | 内容 | 时长 |
|------|------|------|
| 场景引入 | 为什么绝不直接 UPDATE 标准表 | 3 分钟 |
| Demo 跟做 | BAPI 创建预订 → 查 RETURN → COMMIT | 10 分钟 |
| 代码拆解 | 查找 BAPI / RET2 / 事务控制 / 封装 | 24 分钟 |
| 知识总结 | BAPI 调用模板 | 5 分钟 |
| 课后思考 | 练习 | 3 分钟 |

## 本课目标

完成本课你将能够：

- 用 BAPI Explorer（事务码 `BAPI`）和 SE37 搜索定位业务 BAPI；
- 按标准范式调用 BAPI：填参数 → 调用 → 查 BAPIRET2 → COMMIT/ROLLBACK；
- 读懂 RET2 的 TYPE/ID/NUMBER/MESSAGE 四件套；
- 解释 WAIT 参数、批量调用的错误收集模式。

## Demo：创建一条航班预订（分步跟做）

SE38 运行 `zac_bapi`（已随仓库下发）：

```abap
REPORT zac_bapi.

START-OF-SELECTION.
  " 1. 取一条真实航班作预订目标——写死的日期在演示数据里未必存在
  SELECT SINGLE carrid, connid, fldate
    FROM sflight
    WHERE carrid = 'AA'
    INTO @DATA(ls_flight).

  IF sy-subrc <> 0.
    WRITE: / 'SFLIGHT 里没有 AA 的航班，先回第0课生成演示数据'.
    RETURN.
  ENDIF.

  " 2. 组装预订数据（BAPISBONEW 是该 BAPI 自带的入参结构）
  "    客户与旅行社也取真实存在的行，外键校验才过得去
  SELECT SINGLE id FROM scustom INTO @DATA(lv_customerid).
  SELECT SINGLE agencynum FROM stravelag INTO @DATA(lv_agencynum).

  DATA ls_bookdata TYPE bapisbonew.
  ls_bookdata-airlineid  = ls_flight-carrid.
  ls_bookdata-connectid  = ls_flight-connid.
  ls_bookdata-flightdate = ls_flight-fldate.
  ls_bookdata-customerid = lv_customerid.
  ls_bookdata-agencynum  = lv_agencynum.
  ls_bookdata-class      = 'Y'.
  ls_bookdata-passname   = |课程学员 { sy-uname }|.

  " 3. 调用 BAPI：结构化入参 + RET2 返回表 + 出参预订号
  DATA lt_return TYPE STANDARD TABLE OF bapiret2 WITH EMPTY KEY.

  CALL FUNCTION 'BAPI_FLBOOKING_CREATEFROMDATA'
    EXPORTING
      booking_data  = ls_bookdata
    IMPORTING
      bookingnumber = DATA(lv_bookid)
    TABLES
      return        = lt_return.

  " 4. 成败只看 RET2 的 TYPE（E/A 同罪）——不是只看出参！
  DATA(lv_ok) = abap_true.
  LOOP AT lt_return INTO DATA(ls_return).
    WRITE: / |RET2[{ ls_return-type }] { ls_return-message }|.
    IF ls_return-type CA 'EA'.
      lv_ok = abap_false.
    ENDIF.
  ENDLOOP.

  " 5. 成功才提交，失败即回滚——BAPI 的事务铁律
  IF lv_ok = abap_true.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING wait = 'X'.
    WRITE: / |预订创建成功! 预订号: { lv_bookid }|.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    WRITE: / '预订创建失败，已回滚'.
  ENDIF.
```

**你会看到什么：** 成功路径先打出 RET2 里 TYPE 为 S/W 的消息，再打出预订号；把 `customerid` 换成不存在的客户号（如 `'99999999'`）再跑，RET2 出 E 消息、走回滚分支——**两条路径都要亲手跑一遍**，体感"提交/回滚的分水岭"。预订真正落库后，可去 SE16 查 SBOOK 看刚生成的行。

<!-- 配图（待截图后启用）：![BAPI Explorer 按层级浏览](https://cdn.jsdelivr.net/gh/jack-liang/abap-course-assets@main/14-bapi/bapi-explorer.png) -->

## 知识点

### 1. BAPI 是什么：规范化的 FM

| 维度 | 普通 FM | BAPI |
|------|---------|------|
| 本质 | Function Module | RFC-enabled 的 FM |
| 命名 | 任意 | `BAPI_<对象>_<动作>` |
| 返回 | 各式各样 | 统一 **BAPIRET2** |
| 事务 | 内部不定 | **从不自行 COMMIT**，由调用方决定 |
| 发布 | 随意 | SAP 官方保证跨版本兼容 |

一句话：**BAPI 是 SAP 承诺"按这个合同调用，升级不坑你"的标准接口**。改标准业务数据的唯一正道。

### 2. 找 BAPI 的三条路

1. **事务码 BAPI**（BAPI Explorer）：按业务对象层级浏览（Flight→Booking→Create）——最系统；
2. **SE37 模糊搜索**：`BAPI_SBOOK*`、`BAPI_FLIGHT*`；
3. **Where-Used 反查**：在标准程序里看 SAP 自己怎么调（第1课 Where-Used 技能复用）。

### 3. BAPIRET2：唯一可信的结果来源

| 字段 | 含义 |
|------|------|
| TYPE | **S** 成功 / **W** 警告 / **E** 错误 / **A** 中断 |
| ID / NUMBER | 消息类与编号（第18课消息体系） |
| MESSAGE | 拼好的消息文本（V1~V4 是占位变量） |
| ROW / FIELD | 出错的行/字段（批量场景定位用） |

**判据纪律：成功与否看 RET2 的 TYPE，不要拿"出参非空"当成功**——有的 BAPI 失败也回填出参。批量调用时收集全部 E/A 再统一决定提交或回滚。

### 4. 事务控制：COMMIT 与 WAIT

```abap
CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
  EXPORTING wait = 'X'.        " 同步等待落库再返回
CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
```

- BAPI 是"SAP LUW"的一环：**调用后数据处于待提交状态**，COMMIT 生效、ROLLBACK 全撤（第5课 LUW 概念的高层封装）；
- `WAIT = 'X'`：等数据库更新线程完成再返回——**提交后立刻查询/后续 BAPI 依赖刚写的数据时必须加**，否则可能读到旧状态；
- 忘 COMMIT 的后果：程序看着成功了，对话结束数据被回滚——"幽灵数据"事故第一名。

### 5. 封装：把 BAPI 藏进类里

课程仓库的全局类 `zcl_ac_flight_service`（本课引入的全局服务类）就是范例：`create_booking( )` 内部完成"取演示数据 → 调 BAPI → 查 RET2 → 决定 COMMIT/ROLLBACK"，成功返回真实预订号、失败返回初值并带出原因——第24课综合实战直接复用它。**范式写一次，业务处只表达意图。**

## 💡 实战经验

!!! warning "直接 UPDATE 标准表是死罪"

    `UPDATE sbook SET ...` 绕过了全部业务检查（座位、价格、凭证流），数据一致性当场崩坏，且升级必出问题。改标准业务数据的路径只有一条：BAPI/BDC。这条红线在任何项目规范里都排第一。

!!! tip "批量 BAPI 的两种姿势"

    有 xxxMULTI 版本的 BAPI 优先（一次传内表）；没有就循环调用——但**只 COMMIT 一次**：循环里逐条 COMMIT 既慢又破坏"整批原子性"。

!!! tip "A 类型消息要当异常处理"

    RET2 的 TYPE = 'A'（Abort）意味着调用半途被终止，后续状态不可预期——见到 A 与 E 同罪，立即回滚。

## 📖 延伸阅读

- [ABAP Keyword Documentation](https://help.sap.com/doc/abapdocu_752_index_htm/7.52/en-US/index.htm)——BAPI 与 `BAPI_TRANSACTION_COMMIT` 条目；
- [SAP Help Portal](https://help.sap.com) 搜 "BAPI"——各业务模块的 BAPI 清单。

## 课后思考

> 把你的回答写在**页面底部评论区**，注明题号，一起讨论。

1. 调 BAPI 后忘 COMMIT，程序内看数据"在"、换个会话看"不在"——用 LUW 概念解释这个现象（第5课埋的线）。
2. `WAIT = 'X'` 解决什么问题？不加的典型翻车场景是什么？
3. 批量创建 100 条预订，其中第 37 条 RET2 报 E——你的处理流程是什么？（整批回滚 vs 跳过错行提交其余，两种策略各适合什么业务？）
4. 动手：把 Demo 改成"失败也输出完整 RET2 明细（含 W 警告）"——把你的 LOOP 写出来。

---

下一课：[第15课：增强（Enhancement）](15-enhancement.md)
