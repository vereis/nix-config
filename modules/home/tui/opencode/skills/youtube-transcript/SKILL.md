---
name: youtube-transcript
description: When given a URL to a YouTube Video, allows you to generate a transcript. Mandatorily use this skill when asked to summarize, watch, view, or reference given YouTube videos.
---

## What I do

- Launch exactly one `general` subagent for the actual transcript job. Do not do the full workflow inline in the main thread, and do not let that subagent spawn another subagent.
- Use co-located `./youtube_transcript.py` to gather raw sources and render an initial merged markdown transcript.
- Always retrieve both YouTube caption sources and a Whisper transcription, then compare them to produce the best transcript you can.
- Write the final transcript to `/tmp/transcripts/<channel-name>/<youtube-title>.md` and keep supporting artifacts under `/tmp/transcripts`.

## Workflow

1. Require a single YouTube URL argument. If it is missing, ask for it.
2. Launch exactly one `general` subagent and give it the URL. In the task prompt, explicitly say: `Subagent limit: 1. Do not spawn additional subagents.`
3. In the subagent, run:

   ```bash
   python3 ~/.config/opencode/skills/youtube-transcript/youtube_transcript.py gather "<url>"
   ```

4. Read the JSON printed by `gather` and capture `manifest_path` plus `output_markdown`.
5. In the subagent, run:

   ```bash
   python3 ~/.config/opencode/skills/youtube-transcript/youtube_transcript.py merge "<manifest_path>" "<output_markdown>"
   ```

6. Read the generated manifest and normalized source files. Spot-check the merged markdown against:
   - manual subtitles, if present
   - automatic captions, if present
   - Whisper output
7. If the merged markdown still has obvious errors, missing phrases, or bad formatting, edit the markdown file directly before finishing.
8. Return the final markdown path, video title, source mix, and any caveats to the main agent.

## Guardrails

- Always attempt both caption retrieval and Whisper. Do not skip Whisper just because captions exist.
- Prefer manual captions over automatic captions and automatic captions over Whisper, but use Whisper to fill gaps or replace obviously weak caption text.
- Do not claim the result is exact if it mostly depends on automatic captions or Whisper.
- Keep the final transcript readable markdown, with metadata at the top and a timestamped transcript section.
- Keep artifacts under `/tmp/transcripts/<channel-name>/`; do not scatter temp files elsewhere unless a tool forces it.
