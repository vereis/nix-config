---
description: Build a best-effort YouTube transcript in /tmp/transcripts
agent: build
---

# YouTube Transcript

Generate a consolidated transcript for `$ARGUMENTS`.

If the `youtube-transcript` skill is available, load it first.

The workflow should gather manual subtitles, automatic captions, and Whisper output, reconcile them, and write the final markdown transcript to `/tmp/transcripts/<channel-name>/<youtube-title>.md`.

If `$ARGUMENTS` is empty, ask the user for the YouTube URL.
