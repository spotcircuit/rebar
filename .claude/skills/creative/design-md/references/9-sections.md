# The 9 sections of a DESIGN.md

Source: Google Stitch official spec (open-sourced 2026-04-21, Apache 2.0) + community patterns from VoltAgent/awesome-design-md.

Each section exists because without it, agents produce a specific, predictable failure. The failure mode each section prevents is called out below.

---

## Cluster 1 — Foundation: setting the brand

### 1. Visual Theme & Atmosphere

**What:** Two to four sentences describing the *feel* of the design, not the values.

**Example (Stripe):** "Technical and luxurious, precise and warm. Editorial layout with intentional whitespace. Confident but never cold."

**Prevents:** Generic clean-modern default. Without a north star, agents pick the safest aesthetic.

---

### 2. Color Palette & Roles

**What:** Every color gets both a hex value AND a documented role. Cover at minimum: primary, accent, error, warning, success, neutral scale, surface, border, shadow.

**Example (Stripe):**
> Blurple `#635bff` — primary actions and trust signals. Never decorative, never on error states.
> Ruby `#ea2261` — error states and destructive actions only. Never as accent.
> Emerald `#00d924` — success confirmations and positive change indicators.

**Prevents:** Color roulette. Each pick is reasonable in isolation; together they don't form a system.

**Lint rule:** every color must have a role sentence, not just a hex value.

---

### 3. Typography Rules

**What:** Font families, full size scale (12+ levels from display down to nano), weights, line-heights, letter-spacing, OpenType features. Include explicit "never" rules where they matter.

**Example (Stripe):** "Inter Display weight 300 for all H1/H2 headlines. Never weight 700 — looks generic. Inter weight 400 for body. Mono is JetBrains Mono for code, never SF Mono."

**Prevents:** Font chaos. System fallbacks and arbitrary sizes that don't relate to each other.

---

## Cluster 2 — Components: building the UI

### 4. Component Stylings

**What:** Per-component vocabulary with all states. Buttons (primary/secondary/destructive × default/hover/active/disabled/loading). Inputs (default/focus/error/disabled). Cards. Badges. Modals. Navigation.

**Prevents:** Every button is a blue rectangle with no hover state. Every card is a white box with `box-shadow: 0 2px 4px rgba(0,0,0,0.1)`.

---

### 5. Layout Principles

**What:** Base spacing unit (e.g., 8px), spacing scale, max content width, grid structure, border-radius scale, whitespace philosophy.

**Example:** "Base unit 8px. Scale: 4, 8, 12, 16, 24, 32, 48, 64. Max content 1280px. Border-radius scale: 4 (inputs), 8 (cards/buttons), 12 (modals). Never above 12."

**Prevents:** Cramped forms, inconsistent padding, arbitrary spacing decisions.

---

### 6. Depth & Elevation

**What:** Shadow system with explicit levels. Color of shadows (warm-tinted vs cool-tinted vs neutral) and what level applies where.

**Example (Stripe):** "Five-level system: Flat, Subtle, Resting, Floating, Deep. All shadows blue-gray tinted, never neutral gray. Resting on cards. Floating on dropdowns. Deep on modals only."

**Prevents:** The flat, generic `box-shadow: 0 2px 4px rgba(0,0,0,0.1)` agents paste on everything.

---

## Cluster 3 — Guardrails: keeping it consistent

### 7. Do's and Don'ts

**What:** Concrete rules. 5–10 do's and 5–10 don'ts. Format as imperatives, not descriptions.

**Example:**
> Do use Blurple for primary actions only.
> Don't use border-radius above 8px on interactive elements.
> Don't use pill-shaped buttons.
> Don't use weight 700 for headlines.
> Do use blue-tinted shadows.

**Prevents:** Plausible-but-wrong defaults. Pill buttons are a perfectly reasonable choice — they're just not Stripe. This section encodes the difference between "a good design" and "your design."

**This is the highest-leverage section.** Agents follow concrete imperatives more reliably than they follow descriptions.

---

### 8. Responsive Behavior

**What:** Breakpoint pixel ranges, per-component collapsing strategies, touch-target adjustments for mobile.

**Example:** "Breakpoints: mobile <640, tablet 640–1024, desktop 1024+. Nav collapses to hamburger below 640. Cards stack single-column below 768. All touch targets ≥44px below 640."

**Prevents:** Mobile output that's just desktop squeezed into a phone.

---

### 9. Agent Prompt Guide

**What:** Quick-reference color codes, ready-to-use component prompts, iteration checklists. The "cheat sheet" the agent slots into working memory.

**Example:**
> When generating a CTA button: use Blurple bg, white text, weight 500, 8px radius, 16px/24px padding, blue-tinted shadow on hover.
> When generating a form: 8px field radius, 1px border in Neutral-300, focus ring in Blurple-200 at 50% opacity.

**Prevents:** Cold-start drift. Every new conversation starts from zero unless this section gives the agent a fast on-ramp.

---

## Token budget

A complete 9-section DESIGN.md typically runs 25–35K tokens. With prompt caching, this amortizes well. For tight context budgets, the first four sections (Theme, Colors, Components, Do's/Don'ts) cover the highest-impact failure modes at roughly 8–12K tokens.

## What the spec doesn't yet cover

- Motion / animation tokens
- Icon system standards
- WCAG accessibility validation rules
- Sound and haptic design

If your project needs these, add them as additional sections or fold them into Do's and Don'ts.
