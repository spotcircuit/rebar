# Claude Skills Library

#tools #claude-code #skills #marketing #content

235 production-ready Claude Code skills across 9 domains from alirezarezvani/claude-skills (MIT, 11K+ stars). Rebar uses the marketing pod (44 skills) for blog writing, social content, and SEO optimization.

## Key Skills in Use

| Skill | Path | Purpose |
|---|---|---|
| content-production | marketing-skill/content-production/ | Full blog pipeline: research, brief, draft, optimize |
| content-humanizer | marketing-skill/content-humanizer/ | Strip AI tells, fix rhythm, inject brand voice |
| social-content | marketing-skill/social-content/ | Platform-specific social posts (LinkedIn, X, FB) |
| marketing-context | marketing-skill/marketing-context/ | Foundation context doc all marketing skills read first |
| ai-seo | marketing-skill/ai-seo/ | Optimize for AI search citations (ChatGPT, Perplexity) |
| launch-strategy | marketing-skill/launch-strategy/ | Product Hunt, HN launch playbooks |

## Architecture

Each skill is a self-contained folder:
- `SKILL.md` -- master workflow doc with modes and triggers
- `scripts/` -- Python CLI tools (stdlib only, no heavy deps)
- `references/` -- expert knowledge bases (markdown)
- `assets/` -- user-facing templates

314 Python scripts total, 435 reference guides, 28 agents, 27 slash commands.

## Integration with Rebar

1. **marketing-context.md** auto-generated from expertise.yaml files (brand, positioning, ICP, keywords)
2. **Blog-writer agent** uses content-production + content-humanizer skills for daily posts
3. **Social-media-agent** enhanced with social-content skill templates
4. **humanizer_scorer.py** used as quality gate in scout pipeline

## Install

```bash
# Clone to local (skills are markdown, no server needed)
git clone https://github.com/alirezarezvani/claude-skills /tmp/claude-skills

# Or via plugin marketplace
/plugin marketplace add alirezarezvani/claude-skills
```

Source: tools/claude-skills/tool.yaml + tools/claude-skills/expertise.yaml | Evaluated: 2026-04-16

## Related

- [[publishing-pipeline]] -- blog-writer agent uses these skills
- [[paperclip]] -- agent orchestration runs the blog-writer
- [[social-outreach-extensions]] -- social-content skill enhances engagement
- [[ai-content-pipeline]] -- predecessor content approach before skills integration
