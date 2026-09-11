// researcher-mode — OpenCode plugin.
//
// Registers the /researcher command and injects the researcher-mode
// instructions into the system prompt every turn.
//
// Add to .opencode/opencode.json:
//   { "plugin": ["./plugins/researcher-mode.mjs"] }

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { parse } from 'toml';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const REPO_ROOT = path.resolve(__dirname, '..', '..');
const PLUGIN_DIR = path.resolve(__dirname);
const SKILLS_DIR = path.join(REPO_ROOT, 'researcher-mode', 'skills');
const AGENTS_PATH = path.join(REPO_ROOT, 'researcher-mode', 'AGENTS.md');

export default async () => {
  return {
    config: async (config) => {
      if (!config.command) config.command = {};
      if (!config.command.researcher) {
        const tomlPath = path.join(REPO_ROOT, 'researcher-mode', 'commands', 'researcher.toml');
        const tomlData = parse(fs.readFileSync(tomlPath, 'utf8'));
        config.command.researcher = {
          description: tomlData.description,
          template: tomlData.prompt,
        };
      }

      // Register skills directory.
      config.skills = config.skills || {};
      config.skills.paths = config.skills.paths || [];
      if (!config.skills.paths.includes(SKILLS_DIR)) {
        config.skills.paths.push(SKILLS_DIR);
      }
    },

    // Inject researcher-mode instructions into system prompt every turn.
    'experimental.chat.system.transform': async (_input, output) => {
      if (!fs.existsSync(AGENTS_PATH)) return;
      const instructions = fs.readFileSync(AGENTS_PATH, 'utf8');
      if (output.system.length > 0) {
        output.system[output.system.length - 1] += '\n\n---\n\n' + instructions;
      } else {
        output.system.push(instructions);
      }
    },
  };
};
