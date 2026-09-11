---
name: creating-opencode-plugins
description: Use when creating, debugging, or modifying OpenCode plugins or command configurations, especially when commands don't appear, fail to register, or paths resolve incorrectly.
---

# Creating OpenCode Plugins

How to create, configure, and debug plugins for OpenCode — based on real debugging of a multi-file command plugin.

## Overview

OpenCode plugins are Node.js modules that export an async factory returning hook functions. Plugins register commands, inject system prompts, and extend configuration. The entire config is loaded once at startup — **restart OpenCode after any change**.

## Project Layout

OpenCode looks for project config in `.opencode/opencode.json` (inside the `.opencode/` directory). Plugin paths in this config are **relative to `.opencode/`**, not the project root.

```
project-root/
├── .opencode/
│   ├── opencode.json          # Project config (plugin/skill registration)
│   ├── plugins/               # Plugin modules live here
│   │   └── my-plugin.mjs
│   └── node_modules/          # Plugin dependencies (e.g. toml)
├── my-skills/                 # Skill directories (referenced by global config)
└── ...
```

## Config File

### Project config: `.opencode/opencode.json`

Register plugins here. Paths are relative to `.opencode/`:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "plugin": ["./plugins/my-plugin.mjs"]
}
```

**Gotcha:** `"./plugins/my-plugin.mjs"` resolves to `.opencode/plugins/my-plugin.mjs`, NOT `project-root/plugins/my-plugin.mjs`. If you write `"./.opencode/plugins/my-plugin.mjs"`, it resolves to `.opencode/.opencode/plugins/my-plugin.mjs` (wrong).

### Global config: `~/.config/opencode/opencode.jsonc`

Register global skills paths here:

```jsonc
{
  "skills": { "paths": ["/home/mohammad/projects/moniri-skills"] }
}
```

## Plugin Structure

### Simple command-only plugin

For a plugin that just registers commands (no TOML, no system prompts):

```javascript
export default async function () {
  return {
    async config(config) {
      config.command.hello = {
        description: "Say hello to someone",
        template: "You are a friendly assistant. The user said: $ARGUMENTS",
      };
    },
  };
}
```

### Full-featured plugin

Plugin at `.opencode/plugins/my-plugin.mjs` — use this pattern when you need TOML commands, system prompt injection, or skills registration:

```javascript
import path from "node:path";
import { parse } from "toml";
import { readFile } from "node:fs/promises";

const REPO_ROOT = path.resolve(import.meta.dirname, "..", "..");
// import.meta.dirname = .opencode/plugins/
// REPO_ROOT = project-root/

export default async function () {
  return {
    async config(config) {
      // Parse TOML command definitions
      const tomlPath = path.join(REPO_ROOT, "my-skills", "commands", "my-command.toml");
      const toml = parse(await readFile(tomlPath, "utf8"));

      // Register each command: extract description + template from TOML
      for (const [name, def] of Object.entries(toml.command || {})) {
        config.command[name] = {
          description: def.description,
          template: def.prompt,  // Command template from TOML
        };
      }

      // Register skills paths (so OpenCode discovers SKILL.md files)
      config.skills.paths.push(path.join(REPO_ROOT, "my-skills"));

      // Inject persona/system prompt every chat turn
      config.experimental?.chat?.system?.transform?.push(
        async () => {
          try {
            const persona = await readFile(
              path.join(REPO_ROOT, "my-skills", "AGENTS.md"),
              "utf8"
            );
            return persona;
          } catch {
            return "";
          }
        }
      );
    },
  };
}
```

### Key hooks in the returned object

| Hook | Purpose |
|------|---------|
| `config(config)` | Mutate OpenCode's config: register commands, skills, system prompts |
| `load()` | Run once at startup (one-time initialization) |

## Command Definitions (TOML)

Commands are defined in TOML files, parsed by the plugin at startup:

```toml
[command.my-command]
description = "What this command does"
prompt = """
Use $ARGUMENTS to do the thing.
Round 1: do initial research.
Round 2: go deeper using $ARGUMENTS.
"""
```

**Critical:** The field name in TOML is `prompt`, but the plugin maps it to OpenCode's `template` key in config. OpenCode requires `template` — not `prompt` — for commands. If the plugin doesn't do this mapping, commands will fail with `Missing key at ["command"]["name"]["template"]`.

### `$ARGUMENTS` placeholder

`$ARGUMENTS` is OpenCode's placeholder for text typed after the command name. E.g., `/my-command hello world` → `$ARGUMENTS` = `hello world`.

## TOML Dependency

Plugins that parse TOML command files need the `toml` package. Place it in `.opencode/node_modules/toml/` so it resolves from the plugin's directory:

```
.opencode/
├── plugins/my-plugin.mjs
└── node_modules/
    └── toml/          # npm install toml in .opencode/
```

The plugin does `import { parse } from "toml"` which resolves from `.opencode/plugins/`.

## Restart Requirement

**OpenCode loads all config and plugins once at startup.** After any change to:

- `.opencode/opencode.json`
- `.opencode/plugins/*.mjs`
- Command `.toml` files
- `~/.config/opencode/opencode.jsonc`

You **must restart** OpenCode for changes to take effect. Check for a running server process and kill it, then restart.

Debug current config with:

```bash
opencode debug config
```

## Common Bugs

### Command not found

- Config not reloaded → restart OpenCode
- Plugin path wrong → check it resolves from `.opencode/` not project root
- Command uses `prompt` instead of `template` → OpenCode requires `template` key
- Plugin fails silently → run Node.js test: `node --input-type=module -e "import plugin from './.opencode/plugins/my-plugin.mjs'; ..."`)

### Double `.opencode/` in path

When `REPO_ROOT` uses `path.resolve(__dirname, '..')` from `.opencode/plugins/`, it resolves to `.opencode/` (correct project root is one more `..` up). Use `path.resolve(__dirname, '..', '..')` or `path.resolve(import.meta.dirname, '..', '..')`.

### AGENTS.md not injected

Verify the `experimental.chat.system.transform` hook is in the config object returned by the plugin, and that the AGENTS.md file path is correct.

## Validation Checklist

After writing a plugin:

- [ ] `opencode debug config` shows the command with correct description and template
- [ ] Template is a usable instruction string, not raw TOML text
- [ ] Plugin file path in config resolves correctly (no double `.opencode/`)
- [ ] `toml` package is importable from plugin directory
- [ ] Command TOML uses `prompt` field (plugin maps to `template`)
- [ ] Restart OpenCode and verify command appears
- [ ] `$ARGUMENTS` substitution works at runtime
