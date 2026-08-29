---
status: final
---

# 第0课（准备篇）：环境搭建与仓库导入

> 上课之前，把"教室"准备好：一套带 SFLIGHT 演示数据的 ABAP 系统，并用 abapGit 把本仓库的课程代码拉进去。

**预计耗时：** 2～4 小时（大部分时间在下载 23GB 镜像和等待系统初始化）

**完成标志：** SE38 里能运行 `ZAC_HELLO_WORLD`，输出 Hello ABAP 和航空公司信息。

---

## 一、选择你的练习系统（三选一）

| 方案 | 适合谁 | 课程兼容性 | 成本 |
|------|--------|-----------|------|
| **A. ABAP 官方试用镜像**（推荐） | 自学者 | ✅ 24 课全部兼容 | 免费；本机 Docker，需 16GB+ 内存 / 170GB 磁盘 |
| B. 公司/学校的开发系统 | 有导师带、有开发账号 | ✅ 基本兼容，个别课受权限/网络限制 | 需要申请开发权限 |
| C. BTP 试用版（ABAP 环境） | 只想体验现代开发 | ⚠️ 仅部分课程适用（见下方说明） | 免费，注册即用 |

> **为什么推荐官方试用镜像：** 本课程以传统 ABAP 开发为主线（SE38/SE11/SE16、经典 ALV、函数模块、BAPI），这些都是 SAP GUI + NetWeaver 技术栈的内容，试用镜像完整支持；而 BTP 上的 ABAP 环境是 ABAP Cloud，没有 SAP GUI，也不放开经典 ALV / 函数模块 / 多数 BAPI。

### 方案 A：ABAP 官方试用镜像（推荐）

SAP 官方发布的免费试用系统 [`sapse/abap-cloud-developer-trial`](https://hub.docker.com/r/sapse/abap-cloud-developer-trial)（Docker Hub），底层是完整的 ABAP Platform + HANA，**同时支持 SAP GUI 经典技术栈与现代 ABAP Cloud 开发**，本课程 24 课全部兼容。

**硬件要求（以官方 Docker Hub 页面为准，以下为 2025 版数值）：**

| 项目 | 要求 |
|------|------|
| CPU | 4 核及以上 |
| 内存 | **最低 16GB，官方强烈建议 32GB**（Windows 在 `.wslconfig` 设置 `memory=24GB`；macOS 在 Docker Desktop 中分配 16GB+） |
| 磁盘 | Linux **150GB**；Windows/macOS 给 Docker Desktop 分配 **170GB**（镜像压缩约 23GB，解压后超过 53GB） |

**部署步骤：**

1. 在 [Docker Hub](https://hub.docker.com) 注册并本机执行 `docker login`——**该镜像不开放匿名拉取**；
2. 拉取镜像（TAG 以页面最新为准，当前为 `2025`）：

```bash
docker pull sapse/abap-cloud-developer-trial:2025
```

3. 启动容器。Linux 原生环境：

```bash
docker run --stop-timeout 3600 -it --name a4h -h vhcala4hci \
  sapse/abap-cloud-developer-trial:2025
```

   Windows / macOS（Docker Desktop）必须映射端口并加 `-skip-limits-check`：

```bash
docker run --stop-timeout 3600 -i --name a4h -h vhcala4hci \
  -p 3200:3200 -p 3300:3300 -p 8443:8443 -p 30213:30213 \
  -p 50000:50000 -p 50001:50001 \
  sapse/abap-cloud-developer-trial:2025 -skip-limits-check
```

**关键参数说明：**

| 参数 | 作用 |
|------|------|
| `-h vhcala4hci` | 主机名是固定值，改了系统无法启动（确需自定义时用 `-skip-hostname-check`） |
| `--stop-timeout 3600` | 停容器时给 HANA 留足内存数据落盘时间；停止请用 `docker stop -t 7200 a4h`，**不要直接关机或杀进程** |
| `-skip-limits-check` | Mac/Windows 无法修改宿主机内核参数（shmmax 等），必须加 |
| `-agree-to-sap-license` | 预先同意开发者许可，免去每次启动的交互确认 |
| `--mac-address 02:42:ac:11:00:11` | 固定容器 MAC，防止重启后硬件 key 变化导致许可失效（官方 Docker Hub 页提示的坑；此为页面示例值，可自定，之后保持不变即可） |

常用端口：`3200` SAP GUI、`3300` RFC、`30213` HANA、`8443` Cloud Connector、`50000/50001` HTTP/HTTPS。注意**不要用大写 `-P`**（随机分配端口会导致 SAP GUI 等客户端连不上）。

4. 首次启动：该镜像**未预加载数据（initial load）**，启动后第一次打开事务码和程序会明显偏慢，请等 CPU 负载降下来、内存占用趋于稳定后再登录。

服务器就绪后，还差最后一步：装客户端、建连接并首次登录——见下方专门小节。

> **Apple Silicon（M 系列芯片）注意：** 镜像为 x86_64 架构，在 M 系列 Mac 上需通过 Rosetta 模拟运行，参考 Docker Hub 页面链接的社区指南。
>
> **许可证：** 仅限学习/演示用途；ABAP 许可证有效期约 3 个月，到期后用 SAP*（客户端 000）进 SLICENSE 取硬件 key，到 minisap 页面选择 A4H 系统下载新许可，并挂载 `/opt/sap/ASABAP_license` 更新。**未到期却报许可无效**，多半是容器 MAC 变了、硬件 key 跟着变——启动命令加固定 `--mac-address` 可防（见上方参数表）。
>
> **提示：** `DDIC` / `SAP*` 仅用于系统管理（比如 DEVELOPER 密码过期时用 SU01 重置），日常开发请始终用 DEVELOPER 登录。网上流传的旧版社区镜像（如 7.52）已不再维护，建议直接用官方镜像。

### 安装 SAP GUI 客户端并首次登录（方案 A 必读）

容器只是**服务器**——登录还需要在自己电脑上准备一个客户端。按你的系统三选一：

| 客户端 | 适合系统 | 获取方式 | 说明 |
|--------|---------|---------|------|
| SAP GUI for Windows | Windows | [SAP Support Portal 软件下载区](https://support.sap.com/en/my-support/software-downloads.html)（需 S-user 下载权限） | 公司电脑通常已由 IT 预装 |
| SAP GUI for Java | macOS / Linux | 同上（同一下载区） | 7.80 起原生支持 Apple Silicon（M 系列） |
| SAP GUI for HTML（浏览器版） | 任何系统，**零安装** | 无需下载，浏览器直接访问 | 界面细节与桌面版略有差异；拿不到桌面版时的兜底路线 |

> **个人自学者注意：** 两款桌面版 GUI 都挂在 SAP Support Portal 的下载区，需要 SAP 客户/合作伙伴的 S-user 授权才能下载——没有公司渠道的自学者常卡在这一步，此时用浏览器版即可完成全部课程（做法见本节末尾）。版本与系统要求以 [SAP GUI 官方页面](https://pages.community.sap.com/topics/gui/family)为准。

**桌面版创建连接（Windows / Java 参数通用）：**

- Windows（SAP Logon）：新建条目 → 用户指定系统 → 应用服务器 `localhost`、系统编号 `00`、系统 ID `A4H`；
- macOS / Linux（SAP GUI for Java）：新建连接，连接串填 `conn=/H/localhost/S/3200`，描述随意（如 `A4H Trial`）。

**首次登录：** 客户端 `001`，用户 **DEVELOPER**，初始密码以镜像页面为准（2025 版为 `ABAPtr2025#SP00`，`SAP*` 和 `DDIC` 同密码），首次登录会强制修改密码。第1课的"打开 SAP GUI、选中连接"指的就是这里建好的连接。

**浏览器版做法（零安装兜底）：** 先给本机 hosts 文件（Windows：`C:\Windows\System32\drivers\etc\hosts`；macOS / Linux：`/etc/hosts`）加一行 `127.0.0.1 vhcala4hci`，再在浏览器打开：

```
http://vhcala4hci:50000/sap/bc/gui/sap/its/webgui
```

> 课程演示与截图均以桌面版 SAP GUI（英文界面）为准；浏览器版事务码与功能一致，个别布局、快捷键有差异。若浏览器版打不开，多半是该服务未启用——仍需想办法装桌面版。

### 方案 B：公司/学校的开发系统

有导师或账号支持时的首选，省去自建服务器。需要向管理员申请：

- SAP GUI 客户端（公司电脑一般由 IT 统一安装，先确认有没有，没有就一并申请）；
- SE38 / SE80 / SE11 / SE16 / SE16N / SE37 / SE24 / SE91 / SE19 等事务码的开发权限；
- 一个可以自建对象的**开发包（Package）**和 Workbench 传输请求；
- 注意：第 16 课调用外部 REST API，公司内网通常需要代理或防火墙放行，请提前确认。

### 方案 C：BTP 试用版（仅部分课程适用）

注册 [SAP BTP Trial](https://www.sap.com/products/technology-platform/trial.html) 后可免费开通 ABAP 环境，用 Eclipse + ADT（ABAP Development Tools）开发。但它是 ABAP Cloud：

| 课程 | BTP 上是否可用 |
|------|--------------|
| 第2/4/5/8/13/18/19 课（基础语法、内表、SQL、OO、新语法） | ✅ 可用（ADT 中运行控制台程序） |
| 第20/21/23 课（CDS、BTP） | ✅ 完全适用 |
| 第1/3/6/7/9～12/14～17/22/24 课 | ❌ 不适用（依赖 SAP GUI、经典事务码、函数模块、经典 ALV、BAPI） |

结论：BTP Trial 可以作为**第二套体验环境**，但不能作为本课程的主环境。

---

## 二、确认 SFLIGHT 演示数据

**官方试用镜像默认已预置 SFLIGHT 数据**。先用 SE16 查看表数据 `SCARR` 验证（试用镜像没有 SE16N，本课程统一以 SE16 演示，公司环境两者的差异在第1课说明）：能看到 LH/AA/QF 等航空公司记录（且 `SFLIGHT`/`SBOOK` 有数据）就直接进入第三节。

以下情况需要跑 SAP 自带的生成器（重新生成或重置数据）：

1. 系统里没有预置数据（部分公司系统如此）；
2. 练习时把数据改乱了（如第5课的 INSERT/UPDATE/DELETE Demo），想恢复原始数据集。

做法：SE38 运行程序 **`SAPBC_DATA_GENERATOR`**，选择 **Standard**（标准规模：SCARR 约 15 家航空公司、SPFLI 航线、SFLIGHT 航班、SBOOK 数万条预订）执行即可。

> 课程 Demo 中大量示例以 `carrid = 'AA'`、`connid = '0017'` 为例，预置/生成的数据里这两条一定有数据。若你的系统 SE38 里找不到该生成器，参考 SAP Community 上 "SFLIGHT data" 相关的替代生成方案。

---

## 三、用 abapGit 导入本仓库

### 1. 启动 abapGit

**官方试用镜像已自带独立版 abapGit**：SE38 中直接运行程序 `ZABAPGIT_STANDALONE`，能看到 abapGit 仓库列表界面即可开始（镜像自带的版本可能略旧，学习用途足够）。

若你的系统里没有（公司老系统、旧版镜像等），手动安装一次性完成：

1. 从 [abapgit.org](https://abapgit.org) 下载独立版程序 `zabapgit_standalone.prog.abap`（GitHub 上游：abapGit/abapGit 的 Releases）；
2. SE38 新建程序 `ZABAPGIT_STANDALONE`，把下载的源码整个粘贴进去，保存并**激活**；
3. 运行（F8）即可。

### 2. 创建开发包（仓库包 + 个人练习包）

SE80（右键 → Create → Package）创建**两个**包，职责从现在起就分开：

| 包 | 名字 | 类型 | 放什么 |
|----|------|------|--------|
| 课程仓库包 | **`ZABAP_COURSE`**（描述随意，如 "ABAP Course"） | 普通开发包，**不能是本地包** | abapGit 仓库——随本仓库分发的课程对象 |
| 个人练习包 | 自定，如 `ZMY_PRACTICE` | 普通包或本地包 `$TMP` 均可 | 你跟课敲的练习代码、课后作业 |

> **仓库包别选"本地包"（$TMP）：** abapGit 无法把仓库挂在本地包下。创建普通开发包时系统会提示创建 Workbench 请求，确认即可（单机练习用不到真实传输）。
>
> **练习包反而推荐 $TMP：** 本地包的对象不进传输请求，最省事；想让练习对象也能走传输（第17课主题），就建普通包。两类包分开，练习代码就不会混进 abapGit 仓库、干扰后续 Pull——原因见第4节的约定。

### 3. 在线克隆本仓库

1. 运行 `ZABAPGIT_STANDALONE`，点击 **New Online**；
2. 填写：
   - Git repository URL：`https://github.com/Jack-Liang/abap-course`
   - Package：`ZABAP_COURSE`
   - Branch：`master`
3. 点击 **Clone**，之后进入仓库页面点击 **Pull** 拉取全部对象；
4. Pull 完成后对象列表应为绿色（全部激活）。

**如果 Pull 报 SSL 证书错误**（试用镜像常见，系统里没有 GitHub 的受信证书）：

- 方法一（治本）：浏览器导出 `github.com` 的证书链，事务码 **STRUST** 导入到 SSL client (Anonymous) / (Standard) 后重试；
- 方法二（绕开）：GitHub 上 Code → Download ZIP 下载本仓库，abapGit 菜单选择 **Import from ZIP** 离线导入，效果相同（只是之后无法直接 Pull 更新）。

### 4. 验证

SE38 运行 `ZAC_HELLO_WORLD`，看到 `Hello ABAP!` 与航空公司信息，环境就绪。

---

## 四、命名规范与对象对照

### 先分清：仓库代码和个人练习

课程里的开发分两条线，**命名规范只约束第一条**：

| | 课程仓库代码 | 个人练习代码 |
|---|---|---|
| 放哪个包 | `ZABAP_COURSE`（第三节建的仓库包） | 自己的个人练习包（或 `$TMP`） |
| 怎么命名 | 遵守下方 `zac_` 项目规范 | 随意——`z` 开头带上自己的标识（如 `zhello_developer`），不与其他对象重名即可 |
| 什么时候写它 | 运行课程 Demo、给本仓库贡献代码 | 跟课"从零敲一遍"、课后作业、自己折腾 |

> 一句话：**`zac_` 规范管的是进本仓库的代码，不管你的练习。** 自己做练习，一律放个人练习包，怎么方便怎么来；只有当你要把代码提交到本仓库（Pull Request）时，才在 `ZABAP_COURSE` 包里开发并遵守项目规范。个别课需要手工复建的仓库对象（如第9课的函数组）名字必须照抄——课文里会单独说明，但包照样放自己的练习包。

### 命名规范（项目规范）

本仓库所有开发对象统一带课程前缀 **`zac_`**（Z + ABAP Course），避免与系统里其他项目的 Z 对象重名。**课号不写进对象名**——课序调整时对象名不受影响；课与对象的对应关系维护在下方矩阵表中，各程序的头注释同时标注了所属课次，方便在系统里就近查找。

| 对象类型 | 命名规则 | 示例 |
|---------|---------|------|
| 报表程序 / INCLUDE | `zac_<语义名>` | `zac_sql_crud`、`zac_flight_top` |
| 类 | `zcl_ac_<语义名>` | `zcl_ac_flight_query` |
| 接口 | `zif_ac_<语义名>` | —— |
| 函数组 / 函数模块 | `zac_<语义名>` | `zac_flight_utils` / `zac_calc_flight_duration` |
| CDS 视图 | `zac_<语义名>` | `zac_flight_detail` |
| 表 / 消息类 | `zac_<语义名>` | `zac_flight_ext` / `zac_flight_msg` |

> 补充约定：仓库开发包为 `ZABAP_COURSE`；一个对象可服务多课（见矩阵"涉及课程"列），新增对象时先查矩阵避免重复造轮子。

### 对象对照矩阵

| 对象 | 类型 | 涉及课程 | 说明 |
|------|------|---------|------|
| `zac_hello_world` | 程序 | 第2课 | Hello World 与基本数据类型 |
| `zac_doms_priority` + `zac_de_priority` | 域 + 数据元素 | 第3课 | 优先级字段的域（固定值 1/2/3）与数据元素 |
| `zac_flight_ext` | 透明表 | 第3课、第15课 | 建表演示；增强示例引用 |
| `zac_internal_table` | 程序 | 第4课 | 内表与结构体操作 |
| `zac_sql_crud` | 程序 | 第5课 | Open SQL 增删改查 |
| `zac_selection_screen` | 程序 | 第7课 | 选择屏幕 |
| `zac_formatting` | 程序 | 第8课 | 字符串/日期/货币格式化 |
| `zac_call_function` + `zac_flight_utils`（函数组）+ `zac_calc_flight_duration`（FM，均已入库） | 程序 + FM | 第9课 | 函数模块调用 |
| `zac_alv_basic` | 程序 | 第10课 | 经典 ALV 基础 |
| `zac_alv_events` | 程序 | 第11课 | ALV 交互事件 |
| `zac_excel` | 程序 | 第12课 | Excel 导入导出 |
| `zac_oo_basic` + `zcl_ac_flight_query` | 程序 + 类 | 第13课 | OO 基础及其工具类 |
| `zac_bapi` | 程序 | 第14课 | BAPI 调用 |
| `zcl_ac_flight_service` | 类 | 第14课、第24课 | 第14课引入，综合实战的主役业务服务类 |
| `zac_rest_api` | 程序 | 第16课 | 调用外部 REST 接口（需外网） |
| `zac_message` + `zac_flight_msg` | 程序 + 消息类 | 第18课 | 消息处理 |
| `zac_new_syntax` | 程序 | 第19课 | 新语法专题 |
| `zac_flight_detail` / `zac_flight_stats` | CDS 视图 | 第20/21课、第24课 | 航班详情/统计视图，综合实战复用 |
| `zac_cds_basic` / `zac_cds_advanced` | 程序 | 第20/21课 | CDS 视图消费端 demo |
| `zac_oo_alv` | 程序 | 第22课 | OO ALV |
| `zac_flight_manager` + 5 个 INCLUDE | 程序 | 第24课 | 综合实战主程序（`zac_flight_top/sel/pbo/pai/forms`），参考源码已随仓库提供于 `capstone-source/zac_flight_manager/` |

> 第24课主程序尚未作为正式对象入库（其余对象均可 Pull 获取），完整参考源码（含 Screen 100 元素清单）已先行提供在 `capstone-source/zac_flight_manager/` 目录，可手工建对象激活体验。

---

## 五、常见问题（FAQ）

**Q1：DEVELOPER 用户密码过期/锁死了怎么办？**
用 `DDIC` 登录，SU01 里输入 DEVELOPER，解锁并重置密码，重新登录。

**Q2：SE16 查 SFLIGHT 没有数据？**
官方试用镜像默认预置了数据；若确实为空（如公司系统），运行 `SAPBC_DATA_GENERATOR` 生成（见第二节），跑完后等几分钟数据落库再查。

**Q3：第16课 REST Demo 报连接失败？**
该课调用公网汇率 API（`api.exchangerate-api.com`）。公司内网需要配置代理；试用容器需要宿主机能访问外网，且 STRUST 中已导入对应 SSL 证书。跑不通可先跳过，不影响后续课程。

**Q4：abapGit Pull 时提示对象已存在？**
说明系统里已有同名 Z 对象——多半是手工练习时建进了 `ZABAP_COURSE`（练习请放个人练习包，见第四节）。先删除同名对象再 Pull，或换一个干净的开发包。

**Q5：课程里中文注释在系统里显示乱码？**
SAP GUI 登录语言选英文（EN）即可——仓库母语为 E，中文以 UTF-8 存储在代码和文本池中，不影响编译运行；若 GUI 显示异常，检查 SAP GUI 选项里的字符编码设置。

---

## 环境就绪清单

- [ ] SAP GUI 客户端已就绪并登录成功（客户端 `001` / `DEVELOPER`），SE38/SE11/SE16/SE80 都能打开
- [ ] SCARR/SFLIGHT/SBOOK 有数据（官方镜像默认预置；为空则跑 `SAPBC_DATA_GENERATOR`）
- [ ] abapGit 可运行（官方镜像自带），本仓库已 Clone/Pull 到仓库包 `ZABAP_COURSE`
- [ ] 个人练习包已建好（跟课练习、课后作业放这里，与仓库包分开）
- [ ] `ZAC_HELLO_WORLD` 运行成功

全部打勾，就可以正式开始下一课了。

---

下一课：[第1课：SAP 系统入门与开发环境](01-sap-overview.md)——正式走进 SAP 的世界。

