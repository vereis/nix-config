---
name: crit-review
description: Present code/plan changes to the user via Crit to solicit and address feedback before finalizing changes.
---

## What I do

- Look up the documentation for the `crit` CLI tool (https://github.com/tomasz-tomczyk/crit) to understand how to use it effectively.
- Launch Crit for a plan file or the current git diff.
    - Note: you **must** run `crit` in the background and leave it running for the duration of your session, otherwise you block the main conversation thread and the user cannot continue to interact with you.
- Wait for the user to review changes in the browser.
- Read `.crit.json` and address unresolved inline comments.
- Signal the next review round with `crit go <port>` when edits are done.

## Workflow

1. Decide whether to review a specific file or the current git diff.
2. Run `crit <file>` for an explicit file, or `crit` for git mode.
3. Tell the user to leave inline comments in the browser, click Finish Review, and reply with `go` when they are done.
4. Read `.crit.json` and find comments where `resolved` is `false`.
5. Revise the referenced files to address each unresolved comment.
6. Mark comments resolved in `.crit.json` if the workflow calls for it.
7. Run `crit go <port>` to trigger the next review round.

## Guardrails

- Do not continue past the review step until the user confirms they are done.
- Treat `.crit.json` as the source of truth for line references and comment status.
- If there are no unresolved comments, tell the user no changes were requested and stop.
