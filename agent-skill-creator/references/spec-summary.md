# Agent Skills Specification — Reference Summary

Source: https://agentskills.io/specification (condensed; consult the live page if this drifts).

## Directory structure

```
skill-name/
├── SKILL.md          # Required: metadata + instructions
├── scripts/          # Optional: executable code
├── references/       # Optional: documentation
├── assets/           # Optional: templates, resources
└── ...               # Any additional files or directories
```

## Frontmatter fields (full detail)

### `name` (required)
- 1–64 characters.
- Unicode lowercase alphanumeric (`a-z`, `0-9`) and hyphens (`-`) only.
- Must not start or end with a hyphen.
- Must not contain consecutive hyphens (`--`).
- Must match the parent directory name exactly.

### `description` (required)
- 1–1024 characters, non-empty.
- Should describe both *what* the skill does and *when* to use it.
- Should include specific keywords that help agents identify relevant tasks.

### `license` (optional)
- License name, or reference to a bundled `LICENSE.txt`.
- Keep it short.

### `compatibility` (optional)
- 1–500 characters if present.
- Only include when the skill has real environment requirements: intended product, required system packages, network access needs.
- Examples: `Designed for Claude Code (or similar products)`, `Requires git, docker, jq, and access to the internet`, `Requires Python 3.14+ and uv`.
- Most skills do not need this field.

### `metadata` (optional)
- Map of string keys to string values.
- Clients may use this for properties outside the spec (e.g. `author`, `version`).
- Prefer reasonably unique key names to avoid collisions.

### `allowed-tools` (optional, experimental)
- Space-separated string of pre-approved tools, e.g. `Bash(git:*) Bash(jq:*) Read`.
- Support varies between agent implementations.

## Body content

No format is mandated. Recommended sections: step-by-step instructions, input/output examples, common edge cases. The full body loads into context once the skill activates, so weigh every section against what the agent would get wrong without it.

## Progressive disclosure (why structure matters)

Three loading tiers:
1. **Metadata** (~100 tokens): `name` + `description`, loaded for every skill at all times.
2. **Instructions** (<5000 tokens recommended): full `SKILL.md` body, loaded only once the skill activates.
3. **Resources** (as needed): `scripts/`, `references/`, `assets/` files, loaded only when the body tells the agent to.

Keep `SKILL.md` under 500 lines. Move detailed material to separate reference files rather than inlining everything.

## File references

Use relative paths from the skill root:
```markdown
See [the reference guide](references/REFERENCE.md) for details.
Run the extraction script:
scripts/extract.py
```
Keep references one level deep — avoid chains where a reference file points to another reference file.

## Optional directories in more detail

- **`scripts/`** — executable code (commonly Python, Bash, JS). Should be self-contained or clearly document dependencies, include helpful error messages, and handle edge cases gracefully.
- **`references/`** — additional docs loaded on demand: `REFERENCE.md`, `FORMS.md`, domain-specific files (`finance.md`, `legal.md`). Keep individual files focused so agents load only what's relevant.
- **`assets/`** — static resources actually used in output: templates, images/diagrams, data files, schemas, lookup tables.

## Validation

Use the reference implementation to check a skill folder:
```bash
skills-ref validate ./my-skill
```
This checks frontmatter validity and naming conventions (from https://github.com/agentskills/agentskills/tree/main/skills-ref).

## Design principles (from "Best practices for skill creators")

- Ground skills in real expertise — extracted from a completed task/transcript, or synthesized from real project artifacts (runbooks, API specs, code review history, past incident fixes) — not generic knowledge the agent already has.
- Add what the agent lacks; omit what it already knows.
- Scope a skill like a function: one coherent unit of work, not too narrow (forces many skills to co-load) and not too broad (hard to trigger precisely).
- Favor moderate detail and a working example over exhaustive documentation.
- Match instruction specificity to task fragility: loose + "why" for flexible tasks, strict + exact commands for fragile/destructive ones.
- Provide one clear default approach with a brief escape hatch, not a menu of equally-weighted options.
- Teach a reusable procedure, not a one-off answer to a single instance of the problem.
- Refine iteratively: run the skill on real tasks, read execution traces (not just outputs), and feed corrections back in — even one pass of execute-then-revise helps noticeably.

## Description-triggering principles (from "Optimizing skill descriptions")

- The description is the only thing loaded before a trigger decision — it carries the whole burden.
- Use imperative phrasing ("Use this skill when…"), focus on user intent over mechanics, and explicitly cover phrasings that don't name the domain directly.
- Agents generally only reach for a skill when the task needs specialized help; trivial one-step requests may not trigger even a well-written skill, and that's expected.
- To test rigorously: build ~20 eval queries (8–10 should-trigger, 8–10 should-not-trigger, with strong near-miss negatives), split ~60/40 train/validation, run each query multiple times (nondeterminism), and iterate on the description using train-set failures only, checking validation-set results to confirm the change generalizes rather than overfits.