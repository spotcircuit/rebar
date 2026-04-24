# Multi-Format Ingest Strategy

#decisions #patterns #ingestion #config-driven

Handle incoming data in multiple formats (JSON, CSV, XML, plain text) using config-driven mapping where structure is known, and AI drafting where it isn't.

## Decision

Two-track approach based on whether the source format is predictable:

**Track 1 — Config-driven mapping (structured sources)**
- Source schema is stable (Jira webhooks, GitHub events, Slack exports)
- Define field mappings in YAML config
- Zero AI cost; deterministic; fast
- See [[config-driven-routing]] for implementation

**Track 2 — AI drafting (unstructured sources)**
- Source format varies or is unstructured (meeting transcripts, PDFs, web clips)
- Claude extracts structured data from raw text
- Higher cost; more flexible; requires output validation

## Selection Criteria

Use config-driven mapping when:
- Source has a documented schema
- Format is controlled by a third party with stable API versioning
- Throughput is >100 records/day (AI cost would accumulate)

Use AI drafting when:
- Source is human-generated text
- Field names are inconsistent or implicit
- Volume is low (<50 records/day)

Source: raw/demo-jira-notes.md | Ingested: 2026-04-13

## Related

- [[config-driven-routing]] -- config-driven mapping implementation detail
- [[claude-json-extraction]] -- 3-tier fallback for extracting structured data from AI responses
- [[mock-data-strategy]] -- test both tracks without real API calls
