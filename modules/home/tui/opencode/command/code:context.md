---
description: Load project context files (CLAUDE.md, AGENTS.md)
agent: code-context
subtask: true
---

Load project context files from current directory and subdirectories.

1. Check current directory for CLAUDE.md, AGENTS.md
2. Check parent directories (for monorepos)
3. Check subdirectories (for nested contexts)
4. Read and summarize all found context files

Working directory context: $ARGUMENTS
