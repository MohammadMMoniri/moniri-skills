# Memory File Templates

Copy these exactly. Don't reformat. All paths are relative to `.memory/`.

## root.md
```
# <Project Name>

> Read this if: you need project identity, current state, or the memory file index.
> Skip if: you need team-specific history/todos/KPIs — go to teams/<team>/main.md instead (use teams/no-team/ if the project has no distinct teams).

schema_version: v1.0
last_updated: <YYYY-MM-DD> by <agent/team>

## What this project is
<20–40 word description — purpose/goal, even if there's no code>

## Current state
phase: <current phase/milestone, one line>
blockers: <one line each, or "none">

## Teams
- no-team → teams/no-team/main.md
- <team-name> → teams/<team-name>/main.md

## Audience
- <name/org> — <role: partner/customer/maintainer/stakeholder> — <relevance, one line>

## File index
- teams/no-team/main.md
- teams/<team>/main.md (if any additional teams exist)
- dependencies.md (if present)
```
Note: `no-team` is the default team, used until a real team exists — always include it. Add one `<team-name>` line per additional real team as they're introduced.

## teams/<team>/main.md
```
# <Team Name>

> Read this if: you're doing work assigned to this team, or need its history/todos/KPIs.
> Skip if: you need another team's context — go to teams/<other-team>/main.md.

Duty: <1–3 lines. For no-team: "General project work not yet split into distinct teams.">

Links:
- history.md
- todos.md
- kpi.md

Dependencies: <link to dependencies.md entries involving this team, or "none">
```
Note: use `teams/no-team/main.md` if the project has no distinct teams.

## history.md entry
```
[YYYY-MM-DD] <Title> — <one-line description> → tasks/<id>.md
```

## todos.md entry
```
[ ] <priority: high/med/low> <Title> → tasks/<id>.md
[~] <priority> <Title> → tasks/<id>.md   (in progress)
[x] <priority> <Title> → tasks/<id>.md   (done)
blocked_by: <team>/todos#<id>            (omit if not blocked)
```

## kpi.md entry
```
- name: <KPI name>
  target: <value>
  current: <value>
  unit: <unit>
  cadence: <weekly/monthly/etc>
  owner: CEO
  last_reviewed: <YYYY-MM-DD>
```

## tasks/<id>.md
```
# <Task Title>

> Read this if: you're assigned this task or need its full spec.
> Skip if: you only need status — check todos.md instead.

description: <what needs to be done>
acceptance_criteria:
  - <criterion 1>
  - <criterion 2>
status: <open/in-progress/done/blocked>
assignee: <agent/team>
linked_from: <history.md entry date, or todos.md entry>
```

## dependencies.md entry
```
<team-A> blocked by <team-B>/todos#<id> — <one-line reason>
```