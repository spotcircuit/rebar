---
name: extract-pdf
description: Extract text, tables, and images from PDFs (and scanned PDFs via OCR) using pymupdf for light/fast jobs and marker-pdf for OCR/equations/complex layouts. Use when an operator needs to pull content out of a client deck, contract, scanned form, research paper, or any PDF artifact — pick pymupdf for text-based PDFs (~25 MB install, instant) and marker-pdf only when OCR, equations, or layout reconstruction is required (3–5 GB models).
type: productivity
---

# extract-pdf — PDF and document extraction

Adapted from the Hermes Agent `ocr-and-documents` skill. Two extractors, one decision: pymupdf for speed, marker-pdf for hard cases.

For DOCX use `python-docx` (parses real document structure — better than OCR). For PPTX use a `python-pptx`-based flow. This skill is **PDFs and scanned documents**.

When this skill writes outputs (extracted markdown, tables, images), drop them under `clients/{client}/pdf-extract-{YYYY-MM-DD}/` or `apps/{app}/pdf-extract-{date}/`. Never write to `~/`.

## Step 1: URL? Try web extract first

If the PDF has a URL, prefer a remote-fetch tool (e.g. WebFetch / Firecrawl) before installing local extractors. No deps, instant.

Use local extraction when: the file is local, the remote fetch fails, or you need batch/offline processing.

## Step 2: Pick the extractor

| Feature                 | pymupdf (~25 MB) | marker-pdf (~3–5 GB) |
| ----------------------- | ---------------- | --------------------- |
| Text-based PDF          | yes              | yes                   |
| Scanned PDF (OCR)       | no               | yes (90+ languages)   |
| Tables                  | basic            | high accuracy         |
| Equations / LaTeX       | no               | yes                   |
| Code blocks             | no               | yes                   |
| Forms                   | no               | yes                   |
| Header/footer removal   | no               | yes                   |
| Reading-order detection | no               | yes                   |
| Image extraction        | embedded         | with context          |
| Image OCR               | no               | yes                   |
| EPUB                    | yes              | yes                   |
| Markdown output         | via pymupdf4llm  | native, higher quality|
| Speed                   | instant          | 1–14 s/page CPU       |

**Default to pymupdf.** Reach for marker-pdf only when you actually need OCR, equations, forms, or layout analysis.

If the user needs marker capabilities but the system lacks ~5 GB free disk, escalate before installing. Tell them their options: free disk, supply a URL we can WebFetch, or accept pymupdf's text-only result.

---

## pymupdf (lightweight)

```bash
pip install pymupdf pymupdf4llm
```

Helper script:

```bash
SKILL=.claude/skills/productivity/extract-pdf/scripts
python3 $SKILL/extract_pymupdf.py document.pdf              # plain text
python3 $SKILL/extract_pymupdf.py document.pdf --markdown   # markdown
python3 $SKILL/extract_pymupdf.py document.pdf --tables     # tables
python3 $SKILL/extract_pymupdf.py document.pdf --images out/ # extract images
python3 $SKILL/extract_pymupdf.py document.pdf --metadata   # title, author, pages
python3 $SKILL/extract_pymupdf.py document.pdf --pages 0-4  # specific pages
```

Inline:

```bash
python3 -c "
import pymupdf
doc = pymupdf.open('document.pdf')
for page in doc:
    print(page.get_text())
"
```

---

## marker-pdf (high-quality OCR)

```bash
# Check disk space first
python3 .claude/skills/productivity/extract-pdf/scripts/extract_marker.py --check
pip install marker-pdf
```

Helper script:

```bash
SKILL=.claude/skills/productivity/extract-pdf/scripts
python3 $SKILL/extract_marker.py document.pdf              # markdown
python3 $SKILL/extract_marker.py document.pdf --json       # JSON + metadata
python3 $SKILL/extract_marker.py document.pdf --output_dir out/
python3 $SKILL/extract_marker.py scanned.pdf               # scanned PDF (OCR)
python3 $SKILL/extract_marker.py document.pdf --use_llm    # LLM-boosted accuracy
```

CLI (installed with marker-pdf):

```bash
marker_single document.pdf --output_dir ./output
marker /path/to/folder --workers 4    # batch
```

---

## Split, merge, search

pymupdf covers these natively:

```python
# Split: extract pages 1-5
import pymupdf
doc = pymupdf.open("report.pdf")
new = pymupdf.open()
for i in range(5):
    new.insert_pdf(doc, from_page=i, to_page=i)
new.save("pages_1-5.pdf")

# Merge multiple PDFs
result = pymupdf.open()
for path in ["a.pdf", "b.pdf", "c.pdf"]:
    result.insert_pdf(pymupdf.open(path))
result.save("merged.pdf")

# Search across pages
doc = pymupdf.open("report.pdf")
for i, page in enumerate(doc):
    if page.search_for("revenue"):
        print(f"Page {i+1} hit")
```

## Notes

- WebFetch / remote extract first when a URL is available
- pymupdf is the safe default; install marker-pdf only when needed
- marker-pdf downloads ~2.5 GB to `~/.cache/huggingface/` on first use
- Both helper scripts accept `--help`
- For Word docs: `pip install python-docx`
- For PPT: use a python-pptx flow (separate skill)
