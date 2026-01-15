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

## Available Plugins

### save-plan

**Description:** Save plan mode documents to repository for future reference

Provides a skill that saves Claude Code plan mode documents to `.aicontext/` in your repository with timestamped, descriptive filenames. Useful for preserving architectural decisions and implementation plans.

**Usage:** Invoke the `/save-plan` skill when finishing plan mode.

---

### task-discovery

**Description:** Auto-discover Taskfile.yml tasks at session start

A SessionStart hook that automatically discovers and displays available tasks from `Taskfile.yml` when you start a Claude Code session in a project that uses [Task](https://taskfile.dev).

**Usage:** Automatic - runs at session start if a Taskfile is present.

## Adding New Plugins

To add a new plugin:

1. Create a directory under `plugins/` with your plugin name
2. Add `.claude-plugin/plugin.json` with name, description, and version
3. Add your components (commands, skills, hooks, agents) in the appropriate directories
4. Commit and push

## Structure

```
claude-plugins/
├── .claude-plugin/
│   └── marketplace.json
├── README.md
└── plugins/
    ├── save-plan/
    │   ├── .claude-plugin/plugin.json
    │   ├── skills/save-plan/SKILL.md
    │   └── scripts/save-plan.sh
    └── task-discovery/
        ├── .claude-plugin/plugin.json
        └── hooks/
            ├── hooks.json
            └── scripts/discover-tasks.sh
```

## License

MIT
