#!/usr/bin/env python3

import argparse
import datetime as dt
import html
import json
import os
import re
import shutil
import subprocess
import sys
import unicodedata
from difflib import SequenceMatcher
from pathlib import Path


TRANSCRIPT_ROOT = Path("/tmp/transcripts")
SUBTITLE_PACKAGES = ["nixpkgs#yt-dlp"]
FFMPEG_PACKAGES = ["nixpkgs#ffmpeg"]
WHISPER_PACKAGES = ["nixpkgs#whisper-cpp"]
TRIVIAL_SEGMENTS = {
    "music",
    "applause",
    "laughter",
}


def parse_args():
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(dest="command", required=True)

    gather_parser = subparsers.add_parser("gather")
    gather_parser.add_argument("url")

    merge_parser = subparsers.add_parser("merge")
    merge_parser.add_argument("manifest_path")
    merge_parser.add_argument("output_markdown", nargs="?")

    return parser.parse_args()


def run_command(command, *, allow_failure=False):
    result = subprocess.run(command, capture_output=True, text=True)
    if result.returncode != 0 and not allow_failure:
        raise RuntimeError(
            "Command failed: {}\nstdout:\n{}\nstderr:\n{}".format(
                shell_join(command),
                result.stdout.strip(),
                result.stderr.strip(),
            )
        )
    return result


def shell_join(parts):
    return " ".join(shlex_quote(part) for part in parts)


def shlex_quote(value):
    if re.fullmatch(r"[A-Za-z0-9_./:=+-]+", value):
        return value
    return "'" + value.replace("'", "'\"'\"'") + "'"


def run_binary(binary, args, *, fallback_packages=None, allow_failure=False):
    if shutil.which(binary):
        command = [binary, *args]
    else:
        if not fallback_packages:
            raise RuntimeError(f"Required binary not found: {binary}")
        command = ["nix", "shell", *fallback_packages, "-c", binary, *args]
    return run_command(command, allow_failure=allow_failure)


def read_json(path):
    with open(path, "r", encoding="utf-8") as handle:
        return json.load(handle)


def write_json(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    with open(path, "w", encoding="utf-8") as handle:
        json.dump(data, handle, indent=2, ensure_ascii=False)
        handle.write("\n")


def write_text(path, text):
    path.parent.mkdir(parents=True, exist_ok=True)
    with open(path, "w", encoding="utf-8") as handle:
        handle.write(text)


def slugify(value):
    ascii_value = unicodedata.normalize("NFKD", value).encode("ascii", "ignore").decode("ascii")
    slug = re.sub(r"[^A-Za-z0-9]+", "-", ascii_value).strip("-").lower()
    return slug or "youtube-transcript"


def select_channel_name(info):
    return info.get("channel") or info.get("uploader") or info.get("creator") or "unknown-channel"


def clean_text(text):
    text = html.unescape(text)
    text = re.sub(r"<[^>]+>", " ", text)
    text = text.replace("\n", " ")
    text = text.replace("\u200b", " ")
    text = re.sub(r"\s+", " ", text).strip()
    return text


def normalize_text(text):
    return re.sub(r"[^a-z0-9]+", " ", text.lower()).strip()


def language_priority(language):
    if not language:
        return 99
    if language == "en":
        return 0
    if language.startswith("en-"):
        return 1
    if language.endswith("-orig"):
        return 2
    return 10


def kind_priority(kind):
    return {"manual": 0, "whisper": 1, "auto": 2}.get(kind, 9)


def get_video_info(url):
    result = run_binary(
        "yt-dlp",
        ["--dump-single-json", "--no-playlist", url],
        fallback_packages=SUBTITLE_PACKAGES,
    )
    return json.loads(result.stdout)


def ordered_languages(info):
    manual = list((info.get("subtitles") or {}).keys())
    auto = list((info.get("automatic_captions") or {}).keys())
    preferred = []

    def extend(values):
        for value in values:
            if value and value not in preferred:
                preferred.append(value)

    primary = info.get("language")
    extend(["en", "en-US", "en-GB", primary])
    extend(sorted([lang for lang in manual if lang.startswith("en")]))
    extend(sorted([lang for lang in auto if lang.startswith("en")]))
    extend(sorted([lang for lang in manual if lang.endswith("-orig")]))
    extend(sorted([lang for lang in auto if lang.endswith("-orig")]))
    extend(manual)
    extend(auto)
    return preferred[:6]


def download_subtitles(url, artifact_dir, languages):
    language_arg = ",".join(languages) if languages else "all"
    manual_dir = artifact_dir / "captions" / "manual"
    auto_dir = artifact_dir / "captions" / "auto"
    manual_dir.mkdir(parents=True, exist_ok=True)
    auto_dir.mkdir(parents=True, exist_ok=True)

    base_args = [
        "--no-playlist",
        "--skip-download",
        "--sub-format",
        "json3/vtt",
        "--sub-langs",
        language_arg,
        url,
    ]

    run_binary(
        "yt-dlp",
        [
            "-o",
            str(manual_dir / "%(id)s.%(ext)s"),
            "--write-subs",
            *base_args,
        ],
        fallback_packages=SUBTITLE_PACKAGES,
        allow_failure=True,
    )
    run_binary(
        "yt-dlp",
        [
            "-o",
            str(auto_dir / "%(id)s.%(ext)s"),
            "--write-auto-subs",
            *base_args,
        ],
        fallback_packages=SUBTITLE_PACKAGES,
        allow_failure=True,
    )
    return manual_dir, auto_dir


def download_audio(url, artifact_dir):
    audio_dir = artifact_dir / "audio"
    audio_dir.mkdir(parents=True, exist_ok=True)
    run_binary(
        "yt-dlp",
        [
            "--no-playlist",
            "-f",
            "bestaudio/best",
            "-o",
            str(audio_dir / "%(id)s.%(ext)s"),
            url,
        ],
        fallback_packages=SUBTITLE_PACKAGES,
    )
    candidates = sorted(path for path in audio_dir.iterdir() if path.is_file())
    if not candidates:
        raise RuntimeError("yt-dlp did not produce an audio file")
    return candidates[0]


def parse_vtt_timestamp(value):
    hours, minutes, seconds = value.replace(",", ".").split(":")
    return int(hours) * 3600 + int(minutes) * 60 + float(seconds)


def parse_vtt(path):
    blocks = []
    current = None
    text_lines = []
    with open(path, "r", encoding="utf-8") as handle:
        for raw_line in handle:
            line = raw_line.rstrip("\n")
            if "-->" in line:
                if current and text_lines:
                    current["text"] = clean_text(" ".join(text_lines))
                    blocks.append(current)
                start_text, end_text = [part.strip() for part in line.split("-->", 1)]
                current = {
                    "start": parse_vtt_timestamp(start_text),
                    "end": parse_vtt_timestamp(end_text.split(" ", 1)[0]),
                    "text": "",
                }
                text_lines = []
                continue
            if current is None:
                continue
            if not line.strip():
                if text_lines:
                    current["text"] = clean_text(" ".join(text_lines))
                    blocks.append(current)
                current = None
                text_lines = []
                continue
            if line.strip().isdigit():
                continue
            text_lines.append(line.strip())
    if current and text_lines:
        current["text"] = clean_text(" ".join(text_lines))
        blocks.append(current)
    return blocks


def parse_json3(path):
    payload = read_json(path)
    segments = []
    for event in payload.get("events", []):
        pieces = []
        for part in event.get("segs", []):
            value = part.get("utf8", "")
            if value:
                pieces.append(value)
        text = clean_text("".join(pieces))
        if not text:
            continue
        start = float(event.get("tStartMs", 0)) / 1000.0
        duration = float(event.get("dDurationMs", 0)) / 1000.0
        end = start + duration if duration > 0 else start + 0.01
        segments.append({"start": start, "end": end, "text": text})
    return segments


def normalize_segments(segments):
    normalized = []
    for segment in segments:
        text = clean_text(segment["text"])
        if not text:
            continue
        if normalize_text(text) in TRIVIAL_SEGMENTS:
            continue
        start = round(float(segment["start"]), 3)
        end = round(max(float(segment["end"]), start + 0.01), 3)
        if normalized:
            previous = normalized[-1]
            if normalize_text(previous["text"]) == normalize_text(text) and start - previous["end"] < 1.0:
                previous["end"] = end
                continue
        normalized.append({"start": start, "end": end, "text": text})
    return normalized


def infer_language(path):
    stem_parts = path.stem.split(".")
    if len(stem_parts) < 2:
        return "unknown"
    return stem_parts[-1]


def load_caption_sources(directory, kind, normalized_dir):
    entries = []
    for path in sorted(directory.glob("*")):
        if path.suffix not in {".json3", ".vtt"}:
            continue
        if path.suffix == ".json3":
            segments = parse_json3(path)
        else:
            segments = parse_vtt(path)
        segments = normalize_segments(segments)
        if not segments:
            continue
        language = infer_language(path)
        target = normalized_dir / f"{kind}-{slugify(language)}.json"
        payload = {"kind": kind, "language": language, "source_path": str(path), "segments": segments}
        write_json(target, payload)
        entries.append(
            {
                "kind": kind,
                "language": language,
                "normalized_path": str(target),
                "source_path": str(path),
                "segment_count": len(segments),
                "char_count": sum(len(segment["text"]) for segment in segments),
            }
        )
    return entries


def run_whisper(audio_path, output_path, language):
    whisper_dir = output_path.parent / "whisper-cpp"
    whisper_dir.mkdir(parents=True, exist_ok=True)
    models_dir = TRANSCRIPT_ROOT / "models"
    models_dir.mkdir(parents=True, exist_ok=True)

    requested_language = (language or "").split("-", 1)[0].lower()
    model_name = "base.en" if requested_language in {"", "en"} else "base"
    model_path = models_dir / f"ggml-{model_name}.bin"
    if not model_path.exists():
        run_binary(
            "whisper-cpp-download-ggml-model",
            [model_name, str(models_dir)],
            fallback_packages=WHISPER_PACKAGES,
        )

    wav_path = whisper_dir / f"{audio_path.stem}.wav"
    run_binary(
        "ffmpeg",
        ["-y", "-i", str(audio_path), "-ar", "16000", "-ac", "1", str(wav_path)],
        fallback_packages=FFMPEG_PACKAGES,
    )

    output_prefix = whisper_dir / audio_path.stem
    command = [
        "-m",
        str(model_path),
        "-f",
        str(wav_path),
        "-oj",
        "-of",
        str(output_prefix),
        "-np",
        "-l",
        requested_language or "auto",
    ]
    run_binary("whisper-cli", command, fallback_packages=WHISPER_PACKAGES)

    raw_json = output_prefix.with_suffix(".json")
    payload = read_json(raw_json)
    raw_segments = payload.get("segments") or payload.get("transcription") or []
    segments = []
    for raw_segment in raw_segments:
        if "offsets" in raw_segment:
            start = float(raw_segment["offsets"].get("from", 0.0)) / 1000.0
            end = float(raw_segment["offsets"].get("to", 0.0)) / 1000.0
        else:
            start = float(raw_segment.get("start", 0.0))
            end = float(raw_segment.get("end", 0.0))
        text = clean_text(raw_segment.get("text", ""))
        if not text:
            continue
        segments.append(
            {
                "start": round(start, 3),
                "end": round(end, 3),
                "text": text,
            }
        )
    write_json(
        output_path,
        {
            "kind": "whisper",
            "language": payload.get("result", {}).get("language") or payload.get("language") or requested_language or "unknown",
            "model": model_name,
            "segments": normalize_segments(segments),
        },
    )


def load_source_documents(manifest):
    documents = []
    for source in manifest["sources"]:
        payload = read_json(source["normalized_path"])
        payload["segment_count"] = source["segment_count"]
        payload["char_count"] = source["char_count"]
        documents.append(payload)
    documents.sort(key=lambda item: (kind_priority(item["kind"]), language_priority(item.get("language")), -item["char_count"]))
    unique_documents = []
    seen_signatures = set()
    for document in documents:
        signature = (
            document["kind"],
            normalize_text(" ".join(segment["text"] for segment in document["segments"])),
        )
        if signature in seen_signatures:
            continue
        seen_signatures.add(signature)
        unique_documents.append(document)
    return unique_documents


def overlap_amount(a_start, a_end, b_start, b_end):
    return max(0.0, min(a_end, b_end) - max(a_start, b_start))


def text_similarity(left, right):
    return SequenceMatcher(None, normalize_text(left), normalize_text(right)).ratio()


def repetition_score(text):
    words = normalize_text(text).split()
    if not words:
        return 0.0
    return 1.0 - (len(set(words)) / len(words))


def collect_candidate_text(document, start, end):
    best_match = None
    best_score = 0.0
    for segment in document["segments"]:
        overlap = overlap_amount(start, end, segment["start"], segment["end"])
        if overlap <= 0:
            continue
        if overlap < min(0.35, (segment["end"] - segment["start"]) * 0.2):
            continue
        score = overlap + (len(segment["text"]) / 10000.0)
        if score > best_score:
            best_score = score
            best_match = segment["text"]
    if not best_match:
        return ""
    return clean_text(best_match)


def choose_text(base_segment, base_kind, candidates):
    meaningful = [candidate for candidate in candidates if candidate["text"]]
    if not meaningful:
        return base_segment["text"]

    manual = [candidate for candidate in meaningful if candidate["kind"] == "manual"]
    if manual:
        return max(manual, key=lambda candidate: len(candidate["text"]))["text"]

    base_text = base_segment["text"]
    whisper = [candidate for candidate in meaningful if candidate["kind"] == "whisper"]
    auto = [candidate for candidate in meaningful if candidate["kind"] == "auto"]

    if base_kind == "auto" and whisper:
        whisper_text = max(whisper, key=lambda candidate: len(candidate["text"]))["text"]
        if len(whisper_text) > len(base_text) * 1.2:
            return whisper_text
        if repetition_score(base_text) > repetition_score(whisper_text) + 0.15:
            return whisper_text
        if text_similarity(base_text, whisper_text) > 0.6 and len(whisper_text) > len(base_text):
            return whisper_text

    return base_text


def merge_documents(documents):
    if not documents:
        return []

    base = documents[0]
    merged = []
    for segment in base["segments"]:
        candidates = []
        for document in documents:
            candidate_text = collect_candidate_text(document, segment["start"], segment["end"])
            candidates.append({"kind": document["kind"], "language": document.get("language"), "text": candidate_text})
        text = choose_text(segment, base["kind"], candidates)
        merged.append({"start": segment["start"], "end": segment["end"], "text": text})

    for document in documents[1:]:
        for segment in document["segments"]:
            covered = False
            for existing in merged:
                overlap = overlap_amount(existing["start"], existing["end"], segment["start"], segment["end"])
                if overlap >= min(existing["end"] - existing["start"], segment["end"] - segment["start"]) * 0.5:
                    covered = True
                    break
            if not covered and len(segment["text"]) >= 24:
                merged.append(segment)

    merged.sort(key=lambda item: (item["start"], item["end"]))
    return normalize_segments(merged)


def format_timestamp(seconds):
    total = int(seconds)
    hours = total // 3600
    minutes = (total % 3600) // 60
    secs = total % 60
    if hours:
        return f"{hours:02d}:{minutes:02d}:{secs:02d}"
    return f"{minutes:02d}:{secs:02d}"


def render_markdown(manifest, documents, segments):
    blocks = []
    current = None
    for segment in segments:
        if current is None:
            current = {"start": segment["start"], "end": segment["end"], "parts": [segment["text"]]}
            continue
        gap = segment["start"] - current["end"]
        current_text = clean_text(" ".join(current["parts"]))
        if gap > 8 or len(current_text) >= 420 or (current_text.endswith((".", "?", "!")) and len(current_text) >= 220):
            blocks.append({"start": current["start"], "text": current_text})
            current = {"start": segment["start"], "end": segment["end"], "parts": [segment["text"]]}
            continue
        current["end"] = segment["end"]
        current["parts"].append(segment["text"])
    if current is not None:
        blocks.append({"start": current["start"], "text": clean_text(" ".join(current["parts"]))})

    source_summary = ", ".join(
        f"{document['kind']}:{document.get('language', 'unknown')}" for document in documents
    )
    generated_at = dt.datetime.now(dt.timezone.utc).replace(microsecond=0).isoformat()

    lines = [
        f"# {manifest['title']}",
        "",
        f"- URL: {manifest['url']}",
        f"- Channel: {manifest['channel_name']}",
        f"- Video ID: `{manifest['video_id']}`",
        f"- Generated: `{generated_at}`",
        f"- Sources consulted: {source_summary}",
        "",
        "## Transcript",
        "",
    ]

    for block in blocks:
        lines.append(f"### {format_timestamp(block['start'])}")
        lines.append("")
        lines.append(block["text"])
        lines.append("")

    return "\n".join(lines).strip() + "\n"


def gather(url):
    TRANSCRIPT_ROOT.mkdir(parents=True, exist_ok=True)
    info = get_video_info(url)
    title = info.get("title") or info.get("fulltitle") or info.get("id") or "youtube-transcript"
    channel_name = select_channel_name(info)
    video_id = info.get("id") or slugify(title)
    channel_slug = slugify(channel_name)
    slug = slugify(title)
    channel_dir = TRANSCRIPT_ROOT / channel_slug
    artifact_dir = channel_dir / f"{slug}.artifacts"
    normalized_dir = artifact_dir / "normalized"
    artifact_dir.mkdir(parents=True, exist_ok=True)
    normalized_dir.mkdir(parents=True, exist_ok=True)

    languages = ordered_languages(info)
    manual_dir, auto_dir = download_subtitles(url, artifact_dir, languages)
    sources = []
    sources.extend(load_caption_sources(manual_dir, "manual", normalized_dir))
    sources.extend(load_caption_sources(auto_dir, "auto", normalized_dir))

    audio_path = download_audio(url, artifact_dir)
    whisper_path = normalized_dir / "whisper.json"
    whisper_language = info.get("language") or ""
    run_whisper(audio_path, whisper_path, whisper_language)
    whisper_payload = read_json(whisper_path)
    sources.append(
        {
            "kind": "whisper",
            "language": whisper_payload.get("language") or whisper_language or "unknown",
            "normalized_path": str(whisper_path),
            "source_path": str(audio_path),
            "segment_count": len(whisper_payload.get("segments", [])),
            "char_count": sum(len(segment["text"]) for segment in whisper_payload.get("segments", [])),
        }
    )

    sources.sort(key=lambda item: (kind_priority(item["kind"]), language_priority(item.get("language")), -item["char_count"]))
    manifest = {
        "title": title,
        "channel_name": channel_name,
        "channel_slug": channel_slug,
        "video_id": video_id,
        "url": info.get("webpage_url") or url,
        "slug": slug,
        "artifact_dir": str(artifact_dir),
        "output_markdown": str(channel_dir / f"{slug}.md"),
        "sources": sources,
    }
    manifest_path = artifact_dir / "sources.json"
    write_json(manifest_path, manifest)
    print(
        json.dumps(
            {
                "title": title,
                "video_id": video_id,
                "manifest_path": str(manifest_path),
                "artifact_dir": str(artifact_dir),
                "output_markdown": manifest["output_markdown"],
                "source_count": len(sources),
            }
        )
    )


def merge(manifest_path, output_markdown=None):
    manifest = read_json(Path(manifest_path))
    documents = load_source_documents(manifest)
    segments = merge_documents(documents)
    markdown = render_markdown(manifest, documents, segments)
    output_path = Path(output_markdown or manifest["output_markdown"])
    write_text(output_path, markdown)
    print(
        json.dumps(
            {
                "title": manifest["title"],
                "output_markdown": str(output_path),
                "segments": len(segments),
                "sources": [f"{document['kind']}:{document.get('language', 'unknown')}" for document in documents],
            }
        )
    )


def main():
    args = parse_args()
    if args.command == "gather":
        gather(args.url)
        return
    if args.command == "merge":
        merge(args.manifest_path, args.output_markdown)
        return
    raise RuntimeError(f"Unknown command: {args.command}")


if __name__ == "__main__":
    main()
