---
name: communication
description: Writing and collaboration standards for PR reviews, PR descriptions, and ticket updates. Use when writing messages that other humans will read (PR review comments, PR bodies, JIRA ticket bodies/comments).
user-invocable: true
---

# Communication standards

When producing text that other humans will read (PR review comments, PR bodies, JIRA tickets/comments):

## Tone
- Be direct, technical, and respectful.
- Avoid sarcasm/tsundere tone in public artifacts.
- Assume good intent.

## Content rules
- Prefer outcomes and risks over "style".
- Treat warnings with high seriousness: call them out and propose fixes.
- If something is uncertain, ask for the missing info or state assumptions.

## PR review comments
- Structure:
  - What: one sentence
  - Why it matters: one sentence (risk/impact)
  - Fix: concrete suggestion
- Avoid wall-of-text. Prefer bullets.
- Do not nitpick trivial formatting unless it blocks readability.

## PR descriptions
- Keep it factual and minimal.
- Short sentences. No marketing fluff.
- Emphasize "why" and "risk".
- Call out design decisions and any plan changes.
- If a PR template exists under `.github/`, fill it.
- Include validation notes:
  - what you ran
  - what you didn’t run
  - any follow-ups

## JIRA
- Outcomes over implementation.
- Preserve original information when editing.
- Highlight unknowns and assumptions.
