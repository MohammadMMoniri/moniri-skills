---
name: memory-system
description: Use when setting up, updating, or querying an agent memory system stored in memory/. Also trigger proactively at the start or end of any task in a project containing a memory/ directory. Covers team histories, todo tracking, KPI tracking, and any reference to "save/check/update memory," "what do we remember about X," or memory files.
---

# Memory System

This skill covers how to interact with the agent memory system — a structured, file-based memory store at `memory/`. Every file follows a strict convention so agents can decide relevance without reading everything.

## The Two Rules

Non-negotiable:

1. **Read-me-if line on every file** — controls what gets opened. Every memory file starts with:
   ```
   > Read this if: you need X.
   > Skip if: you're doing Y — go to <file> instead.
   ```
2. **Hard cap + rotation on history** — `history.md` keeps only the last 20 entries. Older entries move to `history-archive/YYYY-MM.md`. Never let an agent scan more than one screen to know "what happened recently."

## Memory Structure

```
memory/
  root.md              — identity (static) + state (live)
  teams/
    <team>/
      main.md          — team duty + links to history, todos, kpi
      history.md       — reverse-chronological, 20-entry cap
      history-archive/
        YYYY-MM.md      — overflow from history.md
      todos.md         — [ ]/[~]/[x] priority Title → tasks/<id>.md
      kpi.md           — fixed schema per KPI
      tasks/
        <id>.md        — Jira-style task
  temp/                — short-lived scratch files
  dependencies.md      — optional, cross-team blockers only
```

See `references/templates.md` for exact, copy-pasteable skeletons for every file type. Always use these skeletons verbatim — don't improvise formatting, or the convention drifts across sessions.

## First-Time Setup

If `memory/` doesn't exist yet:
1. Create `memory/root.md` using the root template — fill identity fields (name, description, teams, audience) from context, or ask the user if unclear.
2. Set `schema_version: v1.0` and `last_updated` to today.
3. Create `memory/temp/`.
4. Don't pre-create team folders — create `teams/<team>/` lazily, the first time that team is actually referenced, using the team templates.

## Reading Memory (do this at session start)

1. Start at `memory/root.md` — check `last_updated`, `schema_version`, current phase, active blockers, and the file index.
2. Follow the read-me-if lines. Don't open files that don't apply to the current task.
3. For team-specific work, go to `teams/<team>/main.md` and follow its links.
4. For recent context, check `history.md` only (never the archive unless you specifically need older history).
5. For actionable items, check `todos.md` — inline status/priority means you don't need to open task files just to know what's actionable.

## Updating Memory (do this after finishing work, even if not asked)

### After completing work
1. Update `last_updated` and the live state section in `memory/root.md`.
2. Add a reverse-chronological entry to the relevant team's `history.md`:
   `[date] Title — one-line description → tasks/<id>.md`
3. If `history.md` now exceeds 20 entries, move the oldest overflow to `history-archive/YYYY-MM.md`.
4. Update `todos.md` — mark completed `[x]`, in-progress `[~]`.
5. If a KPI changed, update its `current` value and `last_reviewed` in `kpi.md`.

### Creating a new task
1. Create `memory/teams/<team>/tasks/<id>.md` using the task template: title, description, acceptance criteria, status, assignee, linked-from.
2. Add an entry to `todos.md`: `[ ] priority Title → tasks/<id>.md`.
3. If the task is blocked by another team, add `blocked_by: <team>/todos#<id>` to the entry, and note it in `memory/dependencies.md`.

## Temp Files

- Naming: `temp/<agent>-<yyyymmdd>-<slug>.md` — no exceptions, no "unnamed" scratch files.
- Garbage collection: any temp file untouched for 7 days → auto-archive to `temp/archive/` or delete.

## Common Mistakes

- **Forgetting the read-me-if line** on a new file — every memory file must start with one, or agents waste tokens reading irrelevant content.
- **Editing a file that's missing its read-me-if line without fixing it** — add the line before editing further; don't propagate the omission.
- **Letting history grow past 20 entries** without archiving — a single-screen scan is the design constraint, not a suggestion.
- **Putting task-level detail in root.md** — root.md is identity + state only. Task detail goes in `tasks/`, team history goes in `teams/<team>/history.md`.
- **Stale KPI values** — after any measurable work, update `current` and `last_reviewed` in `kpi.md`.
- **Freeform formatting** — always use `references/templates.md` skeletons instead of writing entries from memory of the convention.

## Reference files

- `references/templates.md` — exact fill-in templates for root.md, main.md, history.md entries, todos.md entries, kpi.md entries, task files, and dependencies.md. Read this before creating or editing any memory file for the first time in a session.
