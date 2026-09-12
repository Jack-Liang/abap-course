---
name: "abap-course-deploy"
description: "双仓库发布 ABAP 课程：素材仓库（abap-course-assets）+ 课文仓库（abap-course）提交推送、图片命名/引用一致性校验、jsDelivr 强刷、等待 GitHub Actions 部署、线上验证。当用户要求 push/发布/部署课次课文或图片时调用。"
---

# ABAP 课程双仓库发布

固化 abap-course 项目的标准发布链路。两个仓库必须协同：课文通过 jsDelivr CDN 引用素材仓库的图片，因此**素材先推、课文后推**。

## 仓库布局

| 仓库 | 本地路径 | 分支 | 沙箱 |
|---|---|---|---|
| 课文 abap-course | `c:\Users\Jack\Documents\GitHub\abap-course` | `master` | 默认可写 |
| 素材 abap-course-assets | `C:\Users\Jack\Documents\GitHub\abap-course-assets` | `main` | **在可写目录之外，Shell 必须 `dangerouslyDisableSandbox: true`** |

站点：`https://abap.jack-liang.com/`，由 GitHub Actions（`.github/workflows/docs.yml`）push master 后 `mkdocs gh-deploy` 自动部署。

## 标准流程

### 1. 双仓库状态检查（并行）

```powershell
git status --short --branch; git diff --stat
# 素材仓库（沙箱外）
cd C:\Users\Jack\Documents\GitHub\abap-course-assets; git status --short --branch
```

### 2. 素材入库前校验（在素材仓库操作）

- **命名**：英文 `kebab-case`、语义化，惯例「事务码-语义」如 `se11-foreign-keys.gif`、`se16-insert-data.jpg`；不允许大写字母和下划线（`SE16-INSERT_DATA.jpg` 这类先 `Rename-Item` 改正）
- **体积**：单图 ≤ 500KB
  - GIF 超限用 ffmpeg 重编码（SAP GUI 平涂 UI 实测有效参数：667KB→486KB，抽帧画质几乎无损）：
    ```powershell
    ffmpeg -y -loglevel error -i in.gif -lavfi "fps=10,split[s0][s1];[s0]palettegen=max_colors=64[p];[s1][p]paletteuse=dither=none" out.gif
    ```
    若不达标再依次降 max_colors（128→64→32），缩放用 `scale=N:-1` 放在 split 之前；UI 截图**先试 dither=none**（抖动常使平涂色变大）
- **杂图拦截**：文章未引用的文件（如 `se.jpg`）不要提交，先向用户确认
- **双向一致性**：
  - grep 课文 `jsdelivr.*<课次目录>`，每个引用与素材仓库实际文件逐一核对：**扩展名**（常见错误：引用写 `.png` 实际是 `.jpg`）、文件名大小写
  - 反过来检查课文引用了但素材缺失的文件（上线即 404 裂图）

### 3. 课文改动核对

- frontmatter `status: draft/final/beta` 决定首页进度（`hooks.py` 构建时自动扫描 `docs/NN-*.md` 统计，**不要手改 index.md 的进度数字**）
- 同一文件的多个 Edit **串行执行**（并行编辑同一文件会互相覆盖），完成后 grep 复核

### 4. 提交推送：先素材，后课文

- 素材仓库：`git add <具体文件>; git commit -m "feat(NN): ..."; git push origin main`（禁用 `git add -A`）
- 课文仓库：`git add <文件>; git commit -m "docs(NN): ..."; git push origin master`
- PowerShell 不支持 bash heredoc；提交信息用单个 `-m "..."`，命令用 `;` 串联
- commit message 用 Conventional Commits + 中文描述（`feat`/`docs`/`fix`/`chore`/`style`，scope 用课号如 `(03)`）
- `.gitignore` 等非 `docs/**`/`mkdocs.yml`/`hooks.py`/workflow 的改动不触发部署，无需等构建

### 5. jsDelivr CDN 强刷（新图必做，否则约 12 小时缓存）

```powershell
Invoke-RestMethod -Uri "https://purge.jsdelivr.net/gh/jack-liang/abap-course-assets@main/<目录>/<文件>"
# 返回 status=finished 即可；逐张刷，可循环
```

### 6. 等待并验证部署

- 本机没有 `gh` CLI，用公开 API 轮询（约 100 秒后查）：
  `https://api.github.com/repos/Jack-Liang/abap-course/actions/runs?per_page=2`
  需要 **"Deploy docs site"** 和 **"pages build and deployment"** 两个 run 均 `completed / success`
- 线上页面验证（加随机参数绕缓存）：
  ```powershell
  $r = Invoke-WebRequest -Uri "https://abap.jack-liang.com/<课slug>/?v=$(Get-Random)" -UseBasicParsing
  ($r.Content | Select-String -Pattern '<目录>/[a-z0-9.-]+' -AllMatches).Matches.Value | Select-Object -Unique
  ```
- 图片可用性：对 CDN URL 发 `Method Head` 请求确认 200（注意 PowerShell 里 `Content-Length` 头是 `String[]`，取 `[0]`）

## 常见坑（本项目实测）

- 素材仓库所有写操作（含 `Rename-Item`）都要在沙箱外执行
- `docs.yml` 的 paths 触发器包含 `hooks.py`——改钩子会正常触发部署
- 文章中练习对象命名与课程下发对象区分：课文示例用个人前缀（如 `zmy_ac_`），仓库对象用 `zac_` 前缀
