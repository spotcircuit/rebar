# Inline Editor Pattern

#patterns #editor #site-builder #ux

Post-generation editing with live iframe preview. Edit structured data, rebuild site, redeploy — all without leaving the app.

## Architecture

480px sidebar (EditorPanel) + device-responsive iframe (DevicePreview). Editor modifies structured JSON data, then rebuilds the React site from that data.

## 13 Editable Sections

Hero, About, Services, Gallery, CTA, FAQ, Testimonials, Why Choose Us, How It Works, Contact, Design (theme), SEO, Visibility

## Key Interactions

- **Edit field** → `updateEditableField(path, value)` with dot-notation (e.g. `services.0.name`)
- **Quick Preview** → rebuilds HTML in iframe without deploying
- **Apply Changes** → POST `/api/rebuild-site` → full React rebuild → new HTML
- **Re-deploy** → POST `/api/redeploy` → push to Cloudflare/Vercel
- **AI Generate** → POST `/api/generate-section` → Claude generates new section content

## Dirty Detection

Pinia store compares `editableData` vs `savedDataSnapshot` via JSON comparison. Shows unsaved warning on close if dirty.

## Theme Presets

5 built-in themes (Modern, Classic, Bold, Minimal, Elegant) applied via CSS variable injection. Each theme defines primary/secondary/accent colors.

## Related

- [[site-builder-overview]] -- full system context
- [[ai-content-pipeline]] -- AI generation used for section regeneration

---
Source: raw/site-builder-editor.md | Ingested: 2026-04-08
