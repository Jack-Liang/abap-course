"""构建钩子：首页 REV 占位符替换 + 原生 HTML 内表链接改写。

1. 首页「内容进度 / REV」：扫描课次 frontmatter 的 status 字段。
   docs/ 下两位数字编号的课次文件（00-getting-started.md … 24-capstone.md）计入统计，
   status: final 记为定稿，其余（draft/beta/…）记为未定稿。index.md 中形如
   {{REV_TOTAL}} 的占位符在构建时被替换为计算结果，页面无需再手改。
2. 原生 HTML 里的 href="*.md"：MkDocs 只改写 Markdown 语法链接，手写 <a> 标签
   （如首页阶段卡片）原样输出 .md 后缀，站点上点开即 404。on_page_content
   把这类链接改写为最终站点 URL；源码保持 .md 写法，GitHub 上浏览仓库仍可点。
"""

import posixpath
import re
import subprocess
from pathlib import Path

from mkdocs.structure.files import Files
from mkdocs.structure.pages import Page
from mkdocs.utils import get_relative_url, log

LESSON_RE = re.compile(r"^\d{2}-.+\.md$")
STATUS_RE = re.compile(r"^status:\s*(\S+)", re.M)
RAW_MD_HREF_RE = re.compile(r'href="([^"#]+\.md)(#[^"]*)?"')


def _latest_commit_date(repo_dir: str) -> str:
    """docs/ 最近一次提交日期，格式「2026年9月5日」；无 git 环境时返回空串。
    不用 --format=%xx：Windows 下 MSYS 会把 %x 序列改写，改解析默认输出里的 Date 行。"""
    try:
        out = subprocess.run(
            ["git", "log", "-1", "--date=short", "--", "."],
            cwd=repo_dir, capture_output=True, text=True, timeout=10,
            check=True,
        ).stdout
        m = re.search(r"^Date:\s*(\d{4})-(\d{2})-(\d{2})", out, re.M)
        if not m:
            return ""
        y, mo, d = m.groups()
        return f"{int(y)}年{int(mo)}月{int(d)}日"
    except Exception:
        return ""


def _count_statuses(docs_dir: str) -> tuple[int, int, int]:
    """返回 (总课数, 定稿数, 未定稿数)。"""
    total = final = 0
    for f in sorted(Path(docs_dir).glob("*.md")):
        if not LESSON_RE.match(f.name):
            continue
        total += 1
        m = re.match(r"^---\n(.*?)\n(?:---|\.\.\.)", f.read_text(encoding="utf-8"), re.S)
        status = STATUS_RE.search(m.group(1)) if m else None
        if status and status.group(1).lower() == "final":
            final += 1
    return total, final, total - final


def on_page_markdown(markdown, page, config, files):
    if page.file.src_uri != "index.md":
        return markdown

    total, final, draft = _count_statuses(config["docs_dir"])
    final_pct = round(final * 100 / total) if total else 0
    values = {
        "REV_TOTAL": str(total),
        "REV_FINAL": str(final),
        "REV_DRAFT": str(draft),
        "REV_FINAL_PCT": str(final_pct),
        "REV_DRAFT_PCT": str(100 - final_pct),
        "REV_DATE": _latest_commit_date(config["docs_dir"]),
    }
    for name, value in values.items():
        markdown = markdown.replace("{{" + name + "}}", value)
    return markdown


def on_page_content(html: str, page: Page, config, files: Files) -> str:
    """把原生 HTML 锚点里的 .md 链接改写为站点 URL（含锚点部分原样保留）。

    外部绝对地址（带 scheme 或以 / 开头）不经 files 解析、原样返回；
    相对路径解析不到对应源文件时告警并保留原文，便于 strict 构建拦截笔误。
    """

    def _replace(m: re.Match) -> str:
        target, anchor = m.group(1), m.group(2) or ""
        if "://" in target or target.startswith("//"):
            return m.group(0)
        src = posixpath.normpath(
            posixpath.join(posixpath.dirname(page.file.src_uri), target)
        )
        target_file = files.get_file_from_path(src)
        if target_file is None:
            log.warning(
                f"hooks.py: 原生 HTML 链接未找到源文件，保留原文: {page.file.src_uri} -> {target}"
            )
            return m.group(0)
        return f'href="{get_relative_url(target_file.url, page.file.url)}{anchor}"'

    return RAW_MD_HREF_RE.sub(_replace, html)
