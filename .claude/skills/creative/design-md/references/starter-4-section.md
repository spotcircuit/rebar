# DESIGN.md — 4-section starter template

Use this when seeding a new DESIGN.md for a project that doesn't have an established brand yet. Covers the four highest-impact sections. Add Typography, Layout, Depth, Responsive, and Agent Prompt Guide later as you hit inconsistencies.

Replace `{{...}}` placeholders. Keep section ordering — agents follow this structure.

---

```markdown
# DESIGN.md — {{Project Name}}

A design system spec for AI coding agents. Read this before generating or refactoring any UI in this project.

## 1. Visual Theme & Atmosphere

{{Two to four sentences on the FEEL. Not the values. Examples:
- "Calm, deliberate, premium. Editorial spacing, never cramped. Confident without shouting."
- "Technical and warm. Code-forward but not cold. Developer audience expects precision, not whimsy."
- "Playful but not childish. Approachable enough for non-technical users, sharp enough that builders take it seriously."}}

## 2. Color Palette & Roles

Every color has a role. Never use a color outside its documented role.

### Primary

- **{{Primary Name}}** `{{#hex}}` — primary actions, brand identity, trust signals. Never decorative. Never on error states.

### Accent

- **{{Accent Name}}** `{{#hex}}` — secondary highlights, focus rings, hover lifts. Never the main CTA color.

### Semantic

- **Error** `{{#hex}}` — error states and destructive actions only. Never as accent.
- **Success** `{{#hex}}` — confirmations and positive change. Never decorative.
- **Warning** `{{#hex}}` — non-blocking warnings only.

### Neutrals

- **Neutral-900** `{{#hex}}` — primary text on light surfaces
- **Neutral-700** `{{#hex}}` — secondary text
- **Neutral-500** `{{#hex}}` — tertiary text, disabled states
- **Neutral-300** `{{#hex}}` — borders, dividers
- **Neutral-100** `{{#hex}}` — subtle surfaces, hover backgrounds
- **Neutral-0** `{{#hex}}` — primary surface

## 3. Component Stylings

### Buttons

**Primary**
- Background: Primary
- Text: Neutral-0 (white)
- Padding: 12px 20px
- Radius: 8px
- Weight: 500
- Hover: brightness +5%, subtle shadow lift
- Active: brightness -5%
- Disabled: 40% opacity, no hover effect
- Loading: spinner left of label, label dimmed

**Secondary**
- Background: transparent
- Border: 1px Neutral-300
- Text: Neutral-900
- Hover: background Neutral-100
- Other states: same as Primary

**Destructive**
- Background: Error
- All other rules: same as Primary

### Cards

- Background: Neutral-0
- Border: 1px Neutral-300 OR shadow (pick one — never both)
- Radius: 8px
- Padding: 24px
- Hover (if interactive): subtle shadow lift, no color change

### Inputs

- Background: Neutral-0
- Border: 1px Neutral-300
- Radius: 6px
- Padding: 10px 12px
- Focus: 2px Accent ring at 40% opacity, no border color change
- Error: 1px Error border, error message in Error color below
- Disabled: Neutral-100 background, Neutral-500 text

## 4. Do's and Don'ts

### Do

- Use Primary for the single most important action on a page. One per view.
- Use roles, not raw colors. If you reach for a hex, you've drifted.
- Keep border-radius consistent within a component family.
- Lift on hover with shadow, not with color change.
- Reserve Error color for genuine errors. Not for emphasis.

### Don't

- Don't use Primary decoratively (icons, backgrounds, accents).
- Don't use border-radius above 12px on interactive elements.
- Don't use pill-shaped buttons unless explicitly added to this spec.
- Don't combine border AND shadow on the same component.
- Don't introduce a new color without adding it to this file with a role.
- Don't use heavy font weights (700+) for headlines unless the Theme section calls for it.
```

---

## After authoring

1. Save to `<base>/DESIGN.md`
2. Run lint: `.claude/skills/creative/design-md/scripts/lint.sh <base>/DESIGN.md`
3. Commit alongside CLAUDE.md
4. Reference from `frontend-design` and any UI-generating skill

## When to expand to 9 sections

- Project has a substantial UI surface (not just a landing page)
- Pages are drifting despite the 4-section starter
- Team is adding designers or contractors who need a contract
- Project ships motion / depth / responsive complexity that the starter doesn't cover

See `9-sections.md` for the full spec.
