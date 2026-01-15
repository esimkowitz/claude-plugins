# Evan's Claude Code Plugins

Personal Claude Code plugins for productivity and workflow automation.

## Installation

Add this marketplace to Claude Code:

```bash
/plugin marketplace add esimkowitz/claude-plugins
```

Then install the plugins you want:

```bash
/plugin install save-plan@esimkowitz-plugins
/plugin install task-discovery@esimkowitz-plugins
```

## Plugins

| Plugin                                      | Description                                            |
|---------------------------------------------|--------------------------------------------------------|
| [save-plan](plugins/save-plan/)             | Save and find plan mode documents for future reference |
| [task-discovery](plugins/task-discovery/)   | Auto-discover Taskfile.yml tasks at session start      |

## Adding New Plugins

1. Create a directory under `plugins/` with your plugin name
2. Add `.claude-plugin/plugin.json` with name, description, and version
3. Add your components (commands, skills, hooks, agents) in the appropriate directories
4. Add a `README.md` for documentation
5. Commit and push

## License

MIT
