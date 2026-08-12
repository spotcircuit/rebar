# Cloudflare Pages Deploy Pattern

#patterns #deployment #cloudflare #site-builder

Deploy static sites to Cloudflare Pages via wrangler CLI with automatic project limit management.

## How It Works

1. Build React site into `dist/`
2. Call `npx wrangler pages deploy dist/ --project-name={slug} --branch=main`
3. Wrangler uploads files and returns deployment URL
4. Production URL: `https://{project-name}.pages.dev`

## Project Naming

Business name slugified + first 6 chars of job ID: `site-joes-plumbing-f47ac1`

## Auto-Cleanup on Limit Hit

Cloudflare has an account-level project limit. When error code 8000027 fires:
1. List all projects sorted by `created_on` ascending
2. Delete the oldest project
3. Retry creation

This is a good [[idempotency-guard]] pattern — the operation self-heals rather than failing.

## Env Vars

- `CLOUDFLARE_API_TOKEN` — API token with Pages permissions
- `CLOUDFLARE_ACCOUNT_ID` — account identifier

## Related

- [[site-builder-overview]] -- full pipeline context
- [[idempotency-guard]] -- self-healing pattern parallel

---
Source: raw/site-builder-deployment.md | Ingested: 2026-04-08
