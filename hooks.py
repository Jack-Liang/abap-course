"""构建时自动计算首页「内容进度 / REV」：扫描课次 frontmatter 的 status 字段。

docs/ 下两位数字编号的课次文件（00-getting-started.md … 24-capstone.md）计入统计，
status: final 记为定稿，其余（draft/beta/…）记为未定稿。index.md 中形如
{{REV_TOTAL}} 的占位符在构建时被替换为计算结果，页面无需再手改。
"""

import re
from pathlib import Path

LESSON_RE = re.compile(r"^\d{2}-.+\.md$")
STATUS_RE = re.compile(r"^status:\s*(\S+)", re.M)


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
    }
    for name, value in values.items():
        markdown = markdown.replace("{{" + name + "}}", value)
    return markdown
