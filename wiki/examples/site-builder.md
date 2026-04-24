# Site Builder

#examples #apps #cloudflare #playwright #claude

Google Maps listing to deployed React website in 60 seconds with AI-generated content. Given a business name and location, the pipeline scrapes the Maps listing, extracts structured data, generates copy with Claude, and deploys a static React site to Cloudflare Pages.

## What It Does

1. Scrape Google Maps for business info (name, address, hours, photos, reviews)
2. Scrape the business's own website if available
3. Feed structured data to Claude to generate hero copy, about section, services
4. Build a React static site with the generated content
5. Deploy to Cloudflare Pages with a unique subdomain

End to end: under 60 seconds from business name to live URL.

## Built Across Four Sessions

See [[site-builder-overview]] for the full four-session build journal. Key sessions:
- Session 3: [[site-builder-session-3]] -- Maps scraper, Claude JSON, Cloudflare deploy

## Key Patterns Used

- [[persistent-browser-context]] -- Google Maps requires session cookies
- [[headless-detection-bypass]] -- stealth mode for Playwright scraping
- [[claude-json-extraction]] -- structured data from Claude responses
- [[cloudflare-pages-deploy]] -- wrangler CLI deployment

Source: apps/site-builder -- built 2026-03 across four Claude Code sessions

## Related

- [[site-builder-overview]] -- full build journal and architecture
- [[site-builder-session-3]] -- Maps scraper + Cloudflare deploy session
- [[cloudflare-pages-deploy]] -- deployment pattern
- [[persistent-browser-context]] -- browser session management
