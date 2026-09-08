---
name: agent-skill-creator
description: Use this skill when the user wants to create, draft, scaffold, package, or improve an Agent Skill (a SKILL.md-based capability) that follows the open Agent Skills format from agentskills.io — for Claude or any other Agent-Skills-compatible client. Trigger on requests like "make a skill for X", "turn this doc/checklist/runbook into a skill", "write a SKILL.md", "review my skill", "why isn't my skill triggering", or "package this as a skill", even if the user doesn't name "agentskills.io" or "SKILL.md" directly. Also use when the user asks about the Agent Skills spec itself (frontmatter fields, directory layout, naming rules, description writing, progressive disclosure).
---

# Agent Skill Creator

Creates and refines Agent Skills that conform to the open **Agent Skills** specification (agentskills.io) — the portable `SKILL.md` format usable across Claude and other compliant agent clients. This is a spec-first counterpart to any client-specific skill tooling: it produces a correct, portable skill folder; packaging it (e.g. zipping into a `.skill` file for a specific client) is a separate, optional last step.

## Step 1 — Ground the skill in real material

Do not invent generic best-practice prose from memory. A good skill encodes specific expertise. Get this from the user:

- **A completed task or transcript** — the actual steps, corrections, and tool calls that worked.
- **Existing artifacts** — docs, runbooks, style guides, API specs, checklists, code review comments, past fixes.
- **A clear description of the recurring task** — if no artifact exists, ask what a competent human would need to know that the agent doesn't already.

If the user hands you a document, checklist, or spec, treat it as the source of truth for the skill's content — don't dilute it with generic filler ("handle errors appropriately," "follow best practices"). Cut anything the agent already knows (what a PDF is, how HTTP works) and keep what it wouldn't otherwise know (specific tools, conventions, edge cases, gotchas).

## Step 2 — Lay out the directory

```
skill-name/
├── SKILL.md          # Required: frontmatter + instructions
├── scripts/           # Optional: executable code the agent can run
├── references/        # Optional: docs loaded into context only when needed
├── assets/             # Optional: templates, images, data files used in output
└── LICENSE.txt         # Optional
```

Only add `scripts/`, `references/`, or `assets/` if there's real content for them — an empty folder adds nothing.

## Step 3 — Write the frontmatter

```markdown
---
name: skill-name
description: What it does and when to use it.
---
```

| Field | Required | Constraints |
|---|---|---|
| `name` | Yes | 1–64 chars. Lowercase letters, numbers, hyphens only. No leading/trailing hyphen, no `--`. **Must match the parent directory name.** |
| `description` | Yes | 1–1024 chars. Says what the skill does *and* when to use it. |
| `license` | No | License name, or "see LICENSE.txt". |
| `compatibility` | No | ≤500 chars. Only include if there are real environment requirements (e.g. "Requires git, docker, jq, and internet access"). Most skills omit this. |
| `metadata` | No | Free-form string→string map for client-specific extras (e.g. `author`, `version`). |
| `allowed-tools` | No | Space-separated pre-approved tools, e.g. `Bash(git:*) Read`. Experimental; support varies by client. |

**Naming — valid vs invalid:**
- ✅ `pdf-processing`, `data-analysis`, `code-review`
- ❌ `PDF-Processing` (uppercase), `-pdf` (leading hyphen), `pdf--processing` (double hyphen)

**Writing the description** — this is the *only* thing the agent sees before deciding to load the skill, so it carries the entire triggering burden:
- Use **imperative framing**: "Use this skill when…", not "This skill does…".
- Describe **user intent**, not internal mechanics — match what the user would actually say, including phrasings that don't name the domain directly.
- **Err pushy**: spell out edge-case triggers explicitly ("even if they don't say X").
- Keep it to a few sentences — long enough to cover scope, short enough not to bloat context across many skills.

```
# Poor
description: Helps with PDFs.

# Good
description: Extracts text and tables from PDF files, fills PDF forms, and
merges multiple PDFs. Use when working with PDF documents or when the user
mentions PDFs, forms, or document extraction.
```

A note on calibration: agents typically only reach for a skill when a task needs specialized knowledge beyond what they can already do — a one-line "read this PDF" may not trigger a PDF skill even with a perfect description, because the agent doesn't need help. Write for the tasks where the skill actually adds value.

## Step 4 — Write the body

No format is mandated — write whatever helps the agent do the task. Useful defaults:

- **Step-by-step instructions**, not a specific answer to one instance of the problem — teach a reusable *method* ("read the schema, then join on the `_id` convention, then filter, then aggregate"), not a one-off fact ("join orders to customers on customer_id").
- **A gotchas section** for environment facts that defy reasonable assumptions — these are usually the highest-value content in a skill:
  ```markdown
  ## Gotchas
  - The `users` table uses soft deletes — queries need `WHERE deleted_at IS NULL`.
  - The user ID is `user_id` in the DB, `uid` in auth, `accountId` in billing — same value, three names.
  ```
- **A template** when output format matters — agents pattern-match against concrete structures better than prose descriptions of format.
- **A checklist** for multi-step workflows with dependencies, so the agent can track progress.
- **A validation loop** for fragile or destructive operations: do the work → run a validator (script or checklist) → fix → repeat until it passes. For batch/destructive work, add a plan-then-validate-then-execute gate before anything irreversible happens.
- **Calibrate specificity to fragility**: give the agent room to use judgment where multiple approaches are valid (and explain *why*, not just *what*); be strictly prescriptive ("run exactly this command, do not add flags") where a specific sequence must be followed. Provide one clear default tool/approach rather than a menu of equal options.

Keep `SKILL.md` **under ~500 lines / ~5000 tokens**. If the domain needs more, move detail into `references/*.md` and tell the agent exactly when to load each one ("Read `references/api-errors.md` if the API returns non-200"), not just "see references/ for details."

## Step 5 — Add optional supporting files, if warranted

- `scripts/` — self-contained executable code (Python/Bash/JS), with clear error messages and graceful edge-case handling. Bundle a script when you notice the same logic would otherwise be reinvented every run (parsing a format, validating output, generating a chart).
- `references/` — focused, on-demand docs (`REFERENCE.md`, domain files). Keep each one narrow; agents load these only when told to, so smaller files cost less context.
- `assets/` — templates, images, schemas, lookup tables actually used in the output.
- Keep file references **one level deep** from `SKILL.md` — avoid chains of references pointing to other references.

## Step 6 — Validate before delivering

Run through this checklist:

- [ ] Directory name == `name` field exactly
- [ ] `name`: lowercase alphanumeric + hyphens only, no leading/trailing/double hyphens, ≤64 chars
- [ ] `description`: non-empty, ≤1024 chars, states both *what* and *when*
- [ ] `SKILL.md` body stays well under 500 lines; heavy material moved to `references/`
- [ ] No filler the agent already knows; every instruction earns its tokens
- [ ] Gotchas, templates, or checklists included where the task is fragile or format-sensitive
- [ ] Any `scripts/` are self-contained and error-handle gracefully
- [ ] File references are relative paths, one level deep

If the reference validator is available in the environment, prefer running it over eyeballing:
```bash
skills-ref validate ./skill-name
```
(`scripts/scaffold.sh` in this skill can also be adapted as a quick starting-point generator — see below.)

## Step 7 — Testing whether the description triggers (optional, for high-stakes skills)

For skills that matter a lot, don't just eyeball the description — test it:

1. Write ~20 realistic eval queries: 8–10 that *should* trigger the skill, 8–10 that *shouldn't* (near-misses that share keywords but need something else are the most informative negatives).
2. Split roughly 60/40 into train/validation sets.
3. Run each query a few times against the target agent (behavior is nondeterministic) and compute a trigger rate.
4. Revise the description based on train-set failures only; broaden if should-trigger queries are missing, add boundary language if should-not-trigger queries are false-triggering. Avoid overfitting to exact failed phrasings — fix the underlying category instead.
5. Check the validation set only to confirm the change generalized; pick the iteration with the best validation performance, which may not be the last one.

This is worth doing for skills that will be used often or by other people; for a quick personal skill, a manual sanity check of a few phrasings is usually enough.

## Step 8 — Packaging is a separate, client-specific step

The spec itself only defines the folder + `SKILL.md`. How a skill gets *installed* varies by client (e.g. a `.claude/skills/` directory, a zipped `.skill` bundle for a Claude product, a different path for another agent). Don't conflate this skill's job (produce a correct, portable skill folder) with any one client's packaging/installation mechanism — ask which target the user needs, or produce the plain folder and note that packaging is client-specific if it's ambiguous.

## Reference

For the full field-by-field spec this skill is based on, see `references/spec-summary.md`.