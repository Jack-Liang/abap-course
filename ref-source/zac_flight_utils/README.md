# 第9课参考源码：函数组 ZAC_FLIGHT_UTILS

[第9课](../../docs/09-function-module.md)的 Function Group 与 Function Module **参考源码**。函数组对象建议按课文步骤在 SE37 中手工创建（过程本身就是第9课的教学内容），创建时对照本目录：

## 对象清单

| 对象 | 类型 | 说明 |
|------|------|------|
| `ZAC_FLIGHT_UTILS` | Function Group | 航班工具函数组 |
| `ZAC_CALC_FLIGHT_DURATION` | Function Module | 计算航线飞行时长（源码见下） |

## 创建步骤（详见课文 Demo 分步）

1. SE37 → Goto → Function Groups → Create Group → `zac_flight_utils`；
2. SE37 新建 FM `zac_calc_flight_duration`，归入该组；
3. Import：`IV_CARRID TYPE S_CARR_ID`、`IV_CONNID TYPE S_CONN_ID`（均勾 Pass Value）；
4. Export：`EV_FOUND TYPE ABAP_BOOL`、`EV_DURATION_MIN TYPE I`、`EV_DISTANCE TYPE S_DISTANCE`、`EV_CITYFROM TYPE S_FROM_CIT`、`EV_CITYTO TYPE S_TO_CIT`；
5. Exceptions：`NOT_FOUND`；
6. 粘贴 [zac_calc_flight_duration.fm.abap](zac_calc_flight_duration.fm.abap) 的源码并激活；
7. F8 单测（AA / 0017），再运行随仓库下发的 `zac_call_function`。

## 源码文件

- [`zac_calc_flight_duration.fm.abap`](zac_calc_flight_duration.fm.abap) —— FM 实现源码（含参数注释接口块）
