---
name: search-before-code
description: Before implementing any code, search the internet for existing solutions and verify the query has enough detail to produce meaningful results. Use when the user asks for a script, tool, or solution that is not in this repo — especially requests like "write me a script for..." or "implement...". Also triggers when the user's description is vague and needs refinement before searching.
---

# Search Before Code

This skill enforces a **search-first** workflow. Before writing any code, the agent must first search the internet for existing solutions and confirm the request has enough detail to produce meaningful search results.

## When to Use

- The user asks for a script, tool, or solution that does not exist in this repo
- The user describes a feature or implementation without referencing existing code
- The request is broad and could match many existing libraries or tools

**Do NOT use** when the task is clearly a new, one-off utility with no existing alternatives, or when the user explicitly says "don't research."

## Workflow

### Step 1 — Check the repo

Search this repository to confirm the solution doesn't already exist here. Use `grep`, `glob`, or relevant code search tools.

### Step 2 — Check query detail (unique to this skill)

Before searching, assess whether the user's description has enough detail to produce useful results. Ask for more detail if it doesn't:

**Enough detail:**
- "Fine-tune Whisper V3 Large using LoRA or QLoRA on Persian datasets"
- "Implement a Redis sliding window rate limiter in Go"
- "Create a Python script to batch resize images in a folder to 800x600 maintaining aspect ratio"

**Not enough detail — ask first:**
- "Give me a script" → ask: *What should it do? What language? What's the input/output?*
- "Build me a tool" → ask: *What problem does it solve? What are the constraints?*
- "Make something for data processing" → ask: *What data format? What transformation? What scale?*

The goal: a search query that returns relevant results, not a needle in a haystack.

### Step 3 — Search the internet

Search broadly across sources:
- **GitHub** — existing implementations, repos, PRs
- **Package registries** — PyPI, npm, crates.io, Hugging Face
- **Stack Overflow / Dev.to / Medium** — tutorials and patterns
- **Official docs** — SDK references, API docs, RFCs
- **Awesome lists** — curated `awesome-*` collections in the relevant domain

### Step 4 — Report findings before coding

Present what you found. Do not skip this step. For each finding:
- What it is
- How well it matches the request
- Link to source

### Step 5 — Implement

Based on search results, adapt (don't blindly copy) and write the code. Cite sources where applicable.

## Decision Matrix

| Search Result | Action |
|---|---|
| Exact match, well-maintained, permissive license | **Adopt** — use directly |
| Partial match, good foundation | **Extend** — use as base + write thin wrapper |
| Multiple weak matches | **Compose** — combine 2-3 small packages |
| Nothing suitable found | **Build** — write custom, but informed by research |

## Examples

**Good trigger:**
> User: "I need a script to download all videos from a YouTube playlist and convert to audio, not in the repo"
> Agent: searches YouTube-dl, yt-dlp, pafy → finds yt-dlp is the standard → reports finding → adapts and wraps it → writes glue script

**Bad trigger (missing detail):**
> User: "Give me a machine learning script"
> Agent: asks for more detail — what task? What data? What language? Then searches with the refined query

## Anti-Patterns

- Don't skip the detail check and search with a vague query — you'll waste time on irrelevant results
- Don't copy-paste search results — adapt to this repo's conventions
- Don't implement without reporting findings first — the user needs to know what exists
