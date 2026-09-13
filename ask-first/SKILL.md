---
name: ask-first
description: Ask many questions to deeply understand what the user needs before doing anything. Use at the start of every complex or ambiguous task. Triggers when the user's intent isn't fully clear — especially new features, architecture decisions, vague requests, or irreversible operations. Also triggers when the user says "think before coding" or "understand first." Light mode for simple tasks (1-3 questions); full mode for everything else (no cap).
---

# Ask First

This skill enforces a **understand-before-acting** workflow. Before writing any code, building anything, or making any decision, the agent asks enough questions to genuinely understand what the user needs — then searches for existing solutions, then brainstorms with the user.

## When to Use

- The user's request is ambiguous or could mean multiple things
- Starting a new feature, feature set, or architectural change
- The user says "think first", "understand first", "ask me before coding"
- Any irreversible operation (delete, publish, send, pay)

**Light mode** for simple, unambiguous tasks: renaming, lookups, format conversions, typo fixes, one-off queries.

**Full mode** for everything else.

## Workflow

### Step 0 — Check the codebase silently

Before asking any question, search this repository for answers you could find yourself. Never ask what you could grep. If you find it, skip the question.

### Step 1 — Assess complexity

| Signal | Mode |
|---|---|
| Single step, fully specified, low blast radius | **Light mode** (1-3 questions) |
| Multi-step, ambiguous, irreversible, wide scope | **Full mode** (no cap) |

**When uncertain:** default to full mode. The cost of misunderstanding exceeds the cost of extra questions.

### Step 2 — Ask questions

#### Light mode (1-3 questions max)

Ask only what's genuinely unclear. Examples:
- "Just to confirm — you want this renamed across the whole repo or just this file?"
- "Should this preserve the original file or overwrite?"

#### Full mode (no cap — ask until understanding is deep)

Ask across these categories, prioritizing by cost of getting it wrong:

| Category | What to ask | Priority |
|---|---|---|
| **Expected outcome** | What should the output look like? Deliverable form? Acceptance criteria? | Highest |
| **Constraints** | Tech stack, timeline, performance, security, compatibility | High |
| **Context** | Existing code conventions, user preferences, past decisions | Medium |
| **Edge cases** | Non-obvious requirements, failure scenarios, what should NOT happen | Medium |

Rules:
- Ask in plain text, not a wall of text
- Offer recommended options when there's a likely answer ("Based on X, I'd suggest Y — correct?")
- Never ask what the agent could find by searching the codebase, config, or memory
- If a user's answer reveals a direction shift, stop and reconfirm the actual task before proceeding
- Never repeat already-asked questions

### Step 3 — Search the internet

With all gathered details, search for existing solutions:
- **GitHub** — existing implementations, repos, PRs
- **Package registries** — PyPI, npm, crates.io, Hugging Face
- **Stack Overflow / Dev.to / Medium** — tutorials and patterns
- **Official docs** — SDK references, API docs, RFCs
- **Awesome lists** — curated `awesome-*` collections in the relevant domain

Goal: find what already exists so the brainstorm is informed, not starting from zero.

### Step 4 — Brainstorm together

Present findings and explore approaches collaboratively:
1. Share what you found (links, tools, patterns)
2. Propose 2-3 approaches with trade-offs and your recommendation
3. Discuss with the user — refine based on their input
4. Agree on what to build before starting implementation

**This step is not optional.** The user wanted to be part of the decision. Respect that.

### Step 5 — Implement

Based on the brainstorm agreement, implement. Cite sources where applicable.

## Examples

**Full mode trigger:**
> User: "I need a caching layer for my app"
> Agent: intent vague — triggers full mode
> Asks: What's the cache target? Local or distributed? Eviction policy? What's the read/write ratio?
> Searches: found Redis patterns, in-memory options, CDN approaches
> Brainstorms: 3 approaches with trade-offs → user picks one
> Implements: agreed approach

**Light mode trigger:**
> User: "Rename `usrName` to `userName`"
> Agent: single step, fully specified → light mode
> Asks 1: "Across the whole repo or just this file?"
> Implements immediately after answer

**When NOT to trigger:**
- Unambiguous single-step tasks ("rename this variable")
- Simple lookups, format conversions, typo fixes
- Fully-specified context (stack, scope, constraints all stated)
- User explicitly says "just do it" / "don't ask" / "quick"
- Urgent fixes, clear one-off queries

## Anti-Patterns

- Don't ask what you could grep in the codebase — search silently first
- Don't cap questions artificially in full mode — ask until understanding is deep
- Don't skip the brainstorm — the user wanted to be part of the decision
- Don't implement before agreement — know what to build before building it
- Don't repeat already-asked questions
