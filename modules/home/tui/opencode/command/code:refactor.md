---
description: Analyze code for refactoring opportunities and cleanup
agent: general
---

1. Determine scope (in priority order):
   - **User-specified path**: If user provides path, analyze that (e.g., `/code:refactor src/auth`)
   - **Staged/unstaged changes**: If no path given, check `git diff HEAD` for any changes
   - **Previous commit**: If no uncommitted changes, analyze `git diff HEAD~1..HEAD`
   - **Prompt user**: If none of the above apply, ask what to analyze

2. Load the refactoring skill and analyze against its full checklist

3. Follow the skill's report format and respect the codebase's existing patterns
