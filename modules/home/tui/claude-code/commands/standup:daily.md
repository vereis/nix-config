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
  - Bash(gh search:*)
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

### GitHub activity

- Viewer login: !`gh api user --jq .login`

#### PRs opened / merged by me

- PRs opened: !`gh search prs "is:pr author:$(gh api user --jq .login) created:>=$(date -d \"${ARGUMENTS:-yesterday}\" +%Y-%m-%d 2>/dev/null || date -d yesterday +%Y-%m-%d)" --limit 30 --json url,title,repository,number,createdAt,state || true`
- PRs merged: !`gh search prs "is:pr author:$(gh api user --jq .login) merged:>=$(date -d \"${ARGUMENTS:-yesterday}\" +%Y-%m-%d 2>/dev/null || date -d yesterday +%Y-%m-%d)" --limit 30 --json url,title,repository,number,mergedAt || true`

#### Reviews + comments by me (GraphQL)

- Review activity: !`gh api graphql -F login="$(gh api user --jq .login)" -F from="$(date -u -d "${ARGUMENTS:-yesterday}" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -d yesterday +%Y-%m-%dT%H:%M:%SZ)" -F to="$(date -u +%Y-%m-%dT%H:%M:%SZ)" -f query='query($login: String!, $from: DateTime!, $to: DateTime!) { user(login: $login) { contributionsCollection(from: $from, to: $to) { pullRequestReviewContributions(first: 100) { nodes { occurredAt pullRequest { title url repository { nameWithOwner } } pullRequestReview { state url submittedAt } } } pullRequestReviewCommentContributions(first: 100) { nodes { occurredAt pullRequest { title url repository { nameWithOwner } } pullRequestReviewComment { url path } } } issueCommentContributions(first: 100) { nodes { occurredAt issue { __typename title url } } } } } }' || true`

### Jira activity (best effort)

Prefer only tickets assigned to me.

- Assigned + created: !`jira issue list -q "assignee = currentUser() AND created >= \"$(date -d \"${ARGUMENTS:-yesterday}\" +%Y-%m-%d 2>/dev/null || date -d yesterday +%Y-%m-%d)\" ORDER BY created DESC" --plain --no-headers --columns KEY,STATUS,SUMMARY 2>/dev/null || true`
- Assigned + status changed by me: !`jira issue list -q "assignee = currentUser() AND status CHANGED BY currentUser() AFTER \"$(date -d \"${ARGUMENTS:-yesterday}\" +%Y-%m-%d 2>/dev/null || date -d yesterday +%Y-%m-%d)\" ORDER BY updated DESC" --plain --no-headers --columns KEY,STATUS,UPDATED,SUMMARY 2>/dev/null || true`
- Assigned + updated by me (proxy for comments): !`jira issue list -q "assignee = currentUser() AND issuekey in updatedBy(currentUser(), \"$(date -d \"${ARGUMENTS:-yesterday}\" +%Y-%m-%d 2>/dev/null || date -d yesterday +%Y-%m-%d)\", \"$(date +%Y-%m-%d)\") ORDER BY updated DESC" --plain --no-headers --columns KEY,STATUS,UPDATED,SUMMARY 2>/dev/null || true`

## Task

Apply the `standup` Skill and return only Markdown.
