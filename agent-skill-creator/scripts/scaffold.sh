#!/usr/bin/env bash
# Scaffold a new Agent Skill folder that conforms to the agentskills.io spec.
#
# Usage:
#   scripts/scaffold.sh <skill-name> [target-dir]
#
# Creates:
#   <target-dir>/<skill-name>/SKILL.md   (minimal valid frontmatter + stub sections)
#
# The skill name is validated against the spec's naming rules before anything
# is written: lowercase alphanumeric + hyphens, no leading/trailing/double hyphens.

set -euo pipefail

NAME="${1:?Usage: scaffold.sh <skill-name> [target-dir]}"
TARGET_DIR="${2:-.}"

if ! [[ "$NAME" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
  echo "Error: '$NAME' is not a valid skill name." >&2
  echo "Rules: lowercase letters/numbers/hyphens only, no leading/trailing hyphen, no '--'." >&2
  exit 1
fi

if [ ${#NAME} -gt 64 ]; then
  echo "Error: skill name must be 64 characters or fewer (got ${#NAME})." >&2
  exit 1
fi

SKILL_DIR="$TARGET_DIR/$NAME"

if [ -e "$SKILL_DIR" ]; then
  echo "Error: '$SKILL_DIR' already exists." >&2
  exit 1
fi

mkdir -p "$SKILL_DIR"

cat > "$SKILL_DIR/SKILL.md" <<EOF
---
name: $NAME
description: TODO — describe what this skill does AND when the agent should use it. Use imperative phrasing ("Use this skill when...") and name concrete trigger phrases, even ones that don't mention the domain directly.
---

# TODO: Title

## Step 1 — TODO
Describe the first step of the procedure. Prefer a reusable method over a one-off answer.

## Gotchas
- TODO: any non-obvious, environment-specific facts the agent would otherwise get wrong.
EOF

echo "Created $SKILL_DIR/SKILL.md"
echo "Next: fill in the TODOs, then validate with: skills-ref validate $SKILL_DIR"