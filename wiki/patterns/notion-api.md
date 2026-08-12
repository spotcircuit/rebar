# Notion API — curl + integration token pattern

#api #notion #pattern

Reference for hitting Notion from agents and skills. Notion uses an integration token (not OAuth for our use cases) and a versioned API. The version header is mandatory — omit it and every request 400s.

## Auth — internal integration token

Create at https://www.notion.so/my-integrations. Share the target pages/databases with the integration explicitly (Notion's permission model is share-based, not scope-based — the integration only sees what's been shared with it).

```bash
export NOTION_TOKEN="secret_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
```

## Mandatory headers

Every request needs both:

```
Authorization: Bearer $NOTION_TOKEN
Notion-Version: 2025-09-03
```

If you skip `Notion-Version`, the API returns 400 with `validation_error`. Pin the version explicitly — Notion's "latest" silently changes payload shapes.

## Page + block model (mental model)

A Notion **page** has properties (the database row fields if it lives in a database) and a body of **blocks** (paragraphs, headings, to-do items, child pages). To read or write the body, you fetch/append the block children of the page id.

## Get a page (properties only)

```bash
curl -s "https://api.notion.com/v1/pages/$PAGE_ID" \
  -H "Authorization: Bearer $NOTION_TOKEN" \
  -H "Notion-Version: 2025-09-03"
```

## Get a page's body (blocks)

```bash
curl -s "https://api.notion.com/v1/blocks/$PAGE_ID/children?page_size=100" \
  -H "Authorization: Bearer $NOTION_TOKEN" \
  -H "Notion-Version: 2025-09-03"
```

Paginate via `next_cursor` from the response — pass back as `?start_cursor=...`.

## Query a database

```bash
curl -s -X POST "https://api.notion.com/v1/databases/$DB_ID/query" \
  -H "Authorization: Bearer $NOTION_TOKEN" \
  -H "Notion-Version: 2025-09-03" \
  -H "Content-Type: application/json" \
  -d '{"filter":{"property":"Status","select":{"equals":"Active"}},"page_size":50}'
```

## Append blocks to a page

```bash
curl -s -X PATCH "https://api.notion.com/v1/blocks/$PAGE_ID/children" \
  -H "Authorization: Bearer $NOTION_TOKEN" \
  -H "Notion-Version: 2025-09-03" \
  -H "Content-Type: application/json" \
  -d '{
    "children": [
      {"object":"block","type":"heading_2","heading_2":{"rich_text":[{"type":"text","text":{"content":"Section"}}]}},
      {"object":"block","type":"paragraph","paragraph":{"rich_text":[{"type":"text","text":{"content":"Body."}}]}}
    ]
  }'
```

## Create a page in a database

```bash
curl -s -X POST "https://api.notion.com/v1/pages" \
  -H "Authorization: Bearer $NOTION_TOKEN" \
  -H "Notion-Version: 2025-09-03" \
  -H "Content-Type: application/json" \
  -d '{
    "parent":{"database_id":"'"$DB_ID"'"},
    "properties":{
      "Name":{"title":[{"text":{"content":"New row"}}]},
      "Status":{"select":{"name":"Active"}}
    }
  }'
```

## Common gotchas

- "object_not_found" usually means the integration was never shared into the page/database, not that the id is wrong. Reshare from the Notion UI.
- Property names are case-sensitive and must match the database schema exactly.
- Rich text is always an array of segments — even a single string needs `[{"type":"text","text":{"content":"..."}}]`.
- Rate limit is ~3 req/s averaged; 429s come with `Retry-After`.

## Related

- [[airtable-api]] — sister vendor pattern; different mental model (records vs blocks)
- [[claude-json-extraction]] — useful if your agent emits Notion-bound payloads as JSON

---
Source: hermes-incorporation-action-items.md (P4 patterns) | Added: 2026-05-01 | CON-138
