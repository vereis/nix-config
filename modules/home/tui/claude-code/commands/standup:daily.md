---
description: Generate a daily standup update in Markdown (git + gh + jira)
argument-hint: [since]
disable-model-invocation: true
allowed-tools:
  - Bash(date:*)
  - Bash(git status:*)
  - Bash(git log:*)
  - Bash(gh api:*)
  - Bash(gh pr status:*)
  - Bash(jira issue list:*)
---

Generate a daily standup update in **Markdown**.

If `$ARGUMENTS` is provided, treat it as a `date -d` expression for the start of the window (e.g. `"2 days ago"`, `"last friday"`). Otherwise default to `"yesterday"`.

## Context

- Now (UTC): !`date -u +%Y-%m-%dT%H:%M:%SZ`
- Since expr: `$ARGUMENTS`
- Since (UTC, best-effort): !`date -u -d "${ARGUMENTS:-yesterday}" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -d yesterday +%Y-%m-%dT%H:%M:%SZ`

### Local git

- Commits: !`git log --since="${ARGUMENTS:-yesterday}" --no-merges --date=iso --pretty=format:"- %ad %s <%h>"`
- WIP: !`git status --porcelain`

### GitHub activity (reviews + comments)

- Viewer login: !`gh api user --jq .login`
- Review activity (GraphQL): !`gh api graphql -F login="$(gh api user --jq .login)" -F from="$(date -u -d "${ARGUMENTS:-yesterday}" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -d yesterday +%Y-%m-%dT%H:%M:%SZ)" -F to="$(date -u +%Y-%m-%dT%H:%M:%SZ)" -f query='query($login: String!, $from: DateTime!, $to: DateTime!) { user(login: $login) { contributionsCollection(from: $from, to: $to) { pullRequestReviewContributions(first: 100) { nodes { occurredAt pullRequest { title url repository { nameWithOwner } } pullRequestReview { state url submittedAt } } } pullRequestReviewCommentContributions(first: 100) { nodes { occurredAt pullRequest { title url repository { nameWithOwner } } pullRequestReviewComment { url path } } } issueCommentContributions(first: 100) { nodes { occurredAt issue { __typename title url } } } } } }' || true`

### Jira activity (best effort)

- Created: !`jira issue list -q "creator = currentUser() AND created >= startOfDay(-1) ORDER BY created DESC" --plain --no-headers --columns KEY,STATUS,SUMMARY 2>/dev/null || true`
- Status changes: !`jira issue list -q "status CHANGED BY currentUser() DURING (startOfDay(-1), now()) ORDER BY updated DESC" --plain --no-headers --columns KEY,STATUS,UPDATED,SUMMARY 2>/dev/null || true`
- Updated by me (proxy for comments): !`jira issue list -q "issuekey in updatedBy(currentUser(), startOfDay(-1), now()) ORDER BY updated DESC" --plain --no-headers --columns KEY,STATUS,UPDATED,SUMMARY 2>/dev/null || true`

## Task

Apply the `standup` Skill and return only Markdown.
