# Productivity skills

External-tool integrations: Airtable, Google Workspace, Linear, Notion, Maps, PDF tooling, OCR. Load when an agent needs to read from or write to a third-party SaaS surface.

## Skills here

- `maps-osm/` — free OSM/Nominatim/Overpass/OSRM alternative to Google Maps (zero API key).
- `extract-pdf/` — pymupdf for text PDFs (light, 25MB), marker-pdf for scans/equations (heavy, 3-5GB).
- `nano-pdf/` — NL-prompt PDF text editing (`nano-pdf edit deck.pdf 1 "fix typo"`).
- `google-workspace/` — OAuth 2.0 PKCE + Gmail/Calendar/Drive/Docs/Sheets/Contacts. Per-client token isolation.

Pending ports: `powerpoint/` (python-pptx, license-verify pending), `airtable/` and `notion/` and `linear/` are wiki-pattern only at `wiki/patterns/{vendor}-api.md`.

## When to load this category

- Reading/writing Airtable, Notion, Linear, Google Workspace
- Extracting structured data from a PDF
- Geocoding or routing without a Google Maps key

## Status

Reserved namespace. Patterns (curl recipes for Airtable, Notion, Linear) live in `wiki/patterns/`; full skills land here when ported.
