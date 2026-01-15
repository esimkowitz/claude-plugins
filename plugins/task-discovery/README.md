# task-discovery

Auto-discover Taskfile.yml tasks at session start and after context compaction.

## Features

Hooks that automatically discover and display available tasks from `Taskfile.yml` when you start a Claude Code session (or after context compaction) in a project that uses [Task](https://taskfile.dev).

- **Repository-aware**: Looks for `Taskfile.yml` at the git repository root, so it works even when starting Claude Code from a subdirectory
- **Fallback behavior**: If not in a git repo, uses the current working directory
- **Context-aware output**: Tells Claude where to run the tasks from (repository root or current directory)
- **Compaction-resilient**: Re-injects task info before context compaction so it survives long conversations

## Usage

Automatic - the hooks run at session start and before context compaction if:
1. The `task` command is installed (`brew install go-task`)
2. A `Taskfile.yml` or `Taskfile.yaml` exists at the repo root (or current directory)

## Example Output

```
## Available Tasks

Run tasks from the repository root with `task <name>`. Available tasks:

- `task build` - Build the project
- `task test` - Run tests
- `task lint` - Run linter
```

## Requirements

- [Task](https://taskfile.dev) installed and available in PATH
- A `Taskfile.yml` or `Taskfile.yaml` in your project
