# Multi-Format Ingest Strategy

#decisions #architecture #ingest #ai #config-driven

How to handle incoming data in multiple formats from multiple sources. The core decision: known formats get deterministic config-driven mapping; unknown formats get AI-assisted draft config followed by human review; PDFs and unstructured documents get AI extraction at the edges.

Decision made 2026-04. Validated against cost and reliability analysis.

---

## The Problem

A single integration may receive data in dozens of formats from different sources. Options:

1. **Pure AI** -- let an LLM parse and map every incoming document at runtime.
2. **Pure deterministic** -- hand-code a parser for every format.
3. **Hybrid** -- config-driven mapping for known formats, AI only for unknown formats and unstructured documents.

---

## The Decision: Hybrid Approach

**Known format = deterministic config mapping.**
**Unknown format = AI draft config, then human review.**
**Unstructured document (PDF, etc.) = AI extraction, then config validation.**

### Known Formats

When you know what a source sends (e.g., a trading partner always sends the same schema), store the mapping in a config record and process deterministically. Zero AI at runtime. Fully auditable. Fast.

```
[ingest] --> [lookup config by source + type] --> [apply mapping] --> [validate] --> [process]
```

Config record example:
```
source: partner-a
format: TYPE_X_V2
field_map:
  their_field_name: our_canonical_field
  their_date_format: ISO8601
  their_status_codes: { "01": "ACCEPTED", "05": "REJECTED" }
```

Adding a new source = adding a config record. No code change. No deployment.

### Unknown Formats

When a new source sends a format not in the config store:

1. AI reads a sample document and drafts a config record.
2. Human reviews and approves the draft.
3. Approved config enters the config store.
4. All future documents from that source use deterministic processing.

AI is used once per format, not at every runtime.

### Unstructured Documents (PDF, Free Text)

AI extraction is appropriate here because deterministic parsing is not feasible. The AI extracts structured fields, then those fields are validated against a known schema and processed deterministically.

```
[PDF ingest] --> [AI extraction] --> [schema validation] --> [deterministic processing]
```

---

## Cost Analysis

| Approach | AI calls per document | Relative cost at scale |
|----------|----------------------|------------------------|
| Pure AI | 1 per document | 400x baseline |
| Hybrid (known format) | 0 per document | 1x (config lookup only) |
| Hybrid (new format setup) | 1 per format, amortized | ~0 at volume |
| Hybrid (PDF extraction) | 1 per document | 400x, but only for PDFs |

**The hybrid approach is approximately 400x cheaper than pure AI at runtime** for known-format documents, which make up the majority of volume in any mature integration. The cost differential grows with volume.

---

## Parts Catalog Model

For integrations with a known universe of data types (e.g., a parts catalog, a product catalog, a code table), the config store functions as the canonical reference. Incoming data is looked up against the catalog rather than parsed freeform.

- Known item in catalog: deterministic match, zero AI.
- Unknown item: AI attempts to match against nearest catalog entry, flags for human review.
- Confirmed match: added to catalog for future deterministic resolution.

This is a specialization of the config-driven routing pattern applied to data content rather than data format.

---

## When to Use Pure AI

Pure AI at runtime is appropriate when:
- Documents are genuinely unstructured and format varies per document (not per source).
- Volume is low enough that cost is not a constraint.
- Speed of setup matters more than runtime cost.
- The domain is novel and a catalog/config approach would require constant maintenance.

Pure AI is not appropriate when:
- Volume is high (cost scales linearly with documents).
- Auditability is required (AI mappings are not deterministically reproducible).
- The same source sends the same format repeatedly (config-driven is strictly better).

---

## Implementation Notes

- Start with AI-assisted config generation even for known formats if you are building from scratch. Let the AI draft the config, then lock it down. Faster than hand-coding from scratch.
- Version config records. A bad config change is a deployment event.
- Keep the AI extraction and the deterministic validation as separate steps with a clear boundary. Do not let AI decisions flow through to output without a validation gate.
- Human review of AI-drafted configs is not optional. The AI will be wrong on edge cases. Review cadence: every new format, sampled review of AI-extracted PDFs.

---

## Related

- [[config-driven-routing]] -- the config-driven approach this decision implements
- [[error-handling]] -- unknown formats that fail AI extraction route to exception queues
- [[mock-data-strategy]] -- mock configs for testing new formats before real data arrives
- [[pre-release-checklist]] -- config records must be reviewed before release
