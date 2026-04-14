#!/usr/bin/env python3
"""
paperclip-start-issues.py — Start Paperclip issues by commenting "start"

Navigates to each issue in the Paperclip UI, types "start" in the comment box,
and clicks Comment. Paperclip picks it up and assigns the agent to execute.

Usage:
    python3 scripts/paperclip-start-issues.py --project "Rebar MCP Features"
    python3 scripts/paperclip-start-issues.py --issues CON-19,CON-20,CON-21
    python3 scripts/paperclip-start-issues.py --project "Rebar MCP Features" --list
    python3 scripts/paperclip-start-issues.py --issues CON-19 --message "start with phase 1 only"
"""

import argparse
import sys

PAPERCLIP_URL = "http://127.0.0.1:3100"


def get_playwright():
    try:
        from playwright.sync_api import sync_playwright
        return sync_playwright
    except ImportError:
        from patchright.sync_api import sync_playwright
        return sync_playwright


def list_project_issues(page, project_slug):
    """Navigate to project and list all issues."""
    page.goto(f"{PAPERCLIP_URL}/CON/projects/{project_slug}/issues",
              wait_until="networkidle", timeout=15000)
    page.wait_for_timeout(2000)

    issues = page.evaluate("""() => {
        const results = [];
        const links = document.querySelectorAll('a[href*="/issues/CON-"]');
        for (const a of links) {
            const href = a.getAttribute('href') || '';
            const match = href.match(/CON-\\d+/);
            if (match) {
                const lines = a.innerText.split('\\n').map(l => l.trim()).filter(l => l);
                results.push({
                    id: match[0],
                    title: lines[0] || '',
                });
            }
        }
        return results;
    }""")
    return issues


def comment_on_issue(page, issue_id, message="start"):
    """Navigate to issue, type message in comment box, click Comment."""
    page.goto(f"{PAPERCLIP_URL}/CON/issues/{issue_id}",
              wait_until="networkidle", timeout=15000)
    page.wait_for_timeout(2000)

    # Get the title for logging
    title = page.evaluate("""() => {
        const h = document.querySelector('h1, [class*="title"]');
        return h ? h.innerText.trim().substring(0, 60) : '';
    }""")

    # Find the comment textbox (last contenteditable textbox on the page)
    textboxes = page.locator('[role="textbox"][contenteditable="true"]')
    count = textboxes.count()
    if count == 0:
        print(f"  [{issue_id}] No comment box found", flush=True)
        return False

    # Use the last textbox (comment box, not the description)
    comment_box = textboxes.last
    comment_box.click()
    page.wait_for_timeout(300)

    # Type the message
    comment_box.fill(message)
    page.wait_for_timeout(300)

    # Click the Comment button
    comment_btn = page.locator('button:has-text("Comment")')
    if comment_btn.count() > 0:
        # Find the submit button (not the tab button)
        for i in range(comment_btn.count()):
            btn = comment_btn.nth(i)
            btn_text = btn.inner_text().strip()
            if btn_text == "Comment":
                btn.click()
                page.wait_for_timeout(2000)
                print(f"  [{issue_id}] '{message}' → {title}", flush=True)
                return True

    print(f"  [{issue_id}] Could not find Comment button", flush=True)
    return False


def slugify(name):
    return name.lower().replace(" ", "-").replace("_", "-")


def main():
    parser = argparse.ArgumentParser(description="Start Paperclip issues by commenting")
    parser.add_argument("--project", type=str, help="Project name")
    parser.add_argument("--issues", type=str, help="Comma-separated issue IDs (CON-19,CON-20)")
    parser.add_argument("--message", type=str, default="start",
                        help="Message to comment (default: 'start')")
    parser.add_argument("--list", action="store_true", help="Just list issues")
    args = parser.parse_args()

    if not args.project and not args.issues:
        parser.print_help()
        return

    sync_playwright = get_playwright()

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()

        if args.project:
            slug = slugify(args.project)
            issues = list_project_issues(page, slug)

            if args.list:
                print(f"\nIssues in '{args.project}':")
                for i in issues:
                    print(f"  {i['id']:8s} {i['title']}")
                browser.close()
                return

            issue_ids = [i['id'] for i in issues]
        else:
            issue_ids = [i.strip() for i in args.issues.split(",")]

        print(f"\nStarting {len(issue_ids)} issues with '{args.message}'...\n")

        success = 0
        for issue_id in issue_ids:
            if comment_on_issue(page, issue_id, args.message):
                success += 1
            page.wait_for_timeout(1000)

        print(f"\nDone. {success}/{len(issue_ids)} issues started.")
        browser.close()


if __name__ == "__main__":
    main()
