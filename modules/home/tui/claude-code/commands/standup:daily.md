---
description: Generate a daily standup update in Markdown
argument-hint: [time window / flags]
disable-model-invocation: true
allowed-tools: Bash(date:*), Bash(git status:*), Bash(git log:*), Bash(git diff:*), Bash(gh pr status:*), Bash(gh pr list:*), Bash(gh issue list:*), Bash(jira issue list:*), Bash(jira issue view:*)
---

Generate a daily standup update in **Markdown**.

Args: `$ARGUMENTS`

Guidance:
- If the user passed a time window, use it.
- Otherwise default to yesterday → now.

Apply the `standup` Skill.

Return only the Markdown.
