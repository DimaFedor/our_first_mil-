#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import math
import time
from pathlib import Path
from typing import Any

from deep_translator import GoogleTranslator

SKIP_TRANSLATION_KEYS = {
    "id",
    "courseId",
    "moduleId",
    "codeSnippet",
    "codeLanguage",
    "starterCode",
    "language",
    "solution",
    "input",
    "expectedOutput",
    "type",
}

TRANSLATOR_LANGUAGE_MAP = {
    "zh": "zh-CN",
}

DEFAULT_LANGUAGES = [
    "uk",
    "es",
    "de",
    "fr",
    "pl",
    "it",
    "pt",
    "nl",
    "cs",
    "ro",
    "tr",
    "sv",
    "ja",
    "ko",
    "zh",
    "hi",
    "ar",
]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Generate localized lesson JSON overlays from English exports.",
    )
    parser.add_argument(
        "--source-dir",
        default="tool/generated_lessons/en",
        help="Directory containing exported English lesson JSON files.",
    )
    parser.add_argument(
        "--assets-dir",
        default="assets/lessons",
        help="Root lessons assets directory.",
    )
    parser.add_argument(
        "--languages",
        nargs="*",
        default=DEFAULT_LANGUAGES,
        help="Target language codes (space-separated).",
    )
    parser.add_argument(
        "--batch-size",
        type=int,
        default=20,
        help="Batch size for translation API calls.",
    )
    parser.add_argument(
        "--course-ids",
        nargs="*",
        default=[],
        help="Optional subset of course IDs to process.",
    )
    parser.add_argument(
        "--cache-file",
        default="tool/generated_lessons/translation_cache.json",
        help="Path to translation cache JSON file.",
    )
    return parser.parse_args()


def should_translate(parent_key: str | None, value: str) -> bool:
    if parent_key in SKIP_TRANSLATION_KEYS:
        return False
    if not value.strip():
        return False
    return True


def collect_translatable_strings(
    value: Any,
    parent_key: str | None,
    strings: set[str],
) -> None:
    if isinstance(value, dict):
        for key, child in value.items():
            collect_translatable_strings(child, key, strings)
        return

    if isinstance(value, list):
        for child in value:
            collect_translatable_strings(child, parent_key, strings)
        return

    if isinstance(value, str) and should_translate(parent_key, value):
        strings.add(value)


def apply_translations(
    value: Any,
    parent_key: str | None,
    translations: dict[str, str],
) -> Any:
    if isinstance(value, dict):
        return {
            key: apply_translations(child, key, translations)
            for key, child in value.items()
        }

    if isinstance(value, list):
        return [apply_translations(child, parent_key, translations) for child in value]

    if isinstance(value, str) and should_translate(parent_key, value):
        return translations.get(value, value)

    return value


def chunked(values: list[str], size: int) -> list[list[str]]:
    if size <= 0:
        return [values]
    return [values[index : index + size] for index in range(0, len(values), size)]


def translate_chunk(
    translator: GoogleTranslator,
    chunk: list[str],
) -> list[str]:
    for attempt in range(3):
        try:
            translated = translator.translate_batch(chunk)
            if len(translated) == len(chunk):
                return translated
        except Exception:
            if attempt == 2:
                break
            time.sleep(0.35 * (attempt + 1))

    fallback_results: list[str] = []
    for text in chunk:
        translated_text = text
        for attempt in range(3):
            try:
                translated_text = translator.translate(text)
                break
            except Exception:
                if attempt == 2:
                    translated_text = text
                else:
                    time.sleep(0.35 * (attempt + 1))
        fallback_results.append(translated_text)
    return fallback_results


def build_translations_map(
    strings: list[str],
    language_code: str,
    batch_size: int,
    cache: dict[str, str],
) -> dict[str, str]:
    if not strings:
        return {}

    translator_code = TRANSLATOR_LANGUAGE_MAP.get(language_code, language_code)
    translator = GoogleTranslator(source="auto", target=translator_code)

    uncached_strings = [
        text for text in strings if f"{language_code}|{text}" not in cache
    ]
    chunks = chunked(uncached_strings, batch_size)
    total_chunks = len(chunks)

    for chunk_index, chunk in enumerate(chunks, start=1):
        translated_chunk = translate_chunk(translator, chunk)
        for source_text, translated_text in zip(chunk, translated_chunk):
            cache[f"{language_code}|{source_text}"] = translated_text or source_text

        if chunk_index % 10 == 0 or chunk_index == total_chunks:
            print(
                f"  [{language_code}] translated {chunk_index}/{max(total_chunks, 1)} chunks",
                flush=True,
            )

    return {text: cache.get(f"{language_code}|{text}", text) for text in strings}


def load_cache(cache_file: Path) -> dict[str, str]:
    if not cache_file.exists():
        return {}

    try:
        return json.loads(cache_file.read_text(encoding="utf-8"))
    except Exception:
        return {}


def save_cache(cache_file: Path, cache: dict[str, str]) -> None:
    cache_file.parent.mkdir(parents=True, exist_ok=True)
    cache_file.write_text(
        json.dumps(cache, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )


def main() -> None:
    args = parse_args()
    source_dir = Path(args.source_dir)
    assets_root = Path(args.assets_dir)
    cache_file = Path(args.cache_file)
    translation_cache = load_cache(cache_file)

    if not source_dir.exists():
        raise SystemExit(f"Source directory does not exist: {source_dir}")

    source_files = sorted(source_dir.glob("*.json"))
    if args.course_ids:
        allowed = {course_id.strip() for course_id in args.course_ids if course_id.strip()}
        source_files = [file for file in source_files if file.stem in allowed]
    if not source_files:
        raise SystemExit(f"No course JSON files found in: {source_dir}")

    course_payloads: dict[str, Any] = {}

    for source_file in source_files:
        payload = json.loads(source_file.read_text(encoding="utf-8"))
        course_payloads[source_file.stem] = payload

    print(f"Loaded {len(course_payloads)} courses.", flush=True)

    for language_code in args.languages:
        normalized_language = language_code.strip().lower()
        if not normalized_language or normalized_language == "en":
            continue

        print(f"Generating translations for '{normalized_language}'...", flush=True)
        target_dir = assets_root / normalized_language
        target_dir.mkdir(parents=True, exist_ok=True)

        for index, (course_id, payload) in enumerate(course_payloads.items(), start=1):
            course_strings: set[str] = set()
            collect_translatable_strings(payload, None, course_strings)
            translations_map = build_translations_map(
                strings=sorted(course_strings),
                language_code=normalized_language,
                batch_size=args.batch_size,
                cache=translation_cache,
            )
            translated_payload = apply_translations(payload, None, translations_map)
            output_file = target_dir / f"{course_id}.json"
            output_file.write_text(
                json.dumps(translated_payload, ensure_ascii=False, indent=2),
                encoding="utf-8",
            )
            save_cache(cache_file, translation_cache)
            print(
                f"  [{normalized_language}] {index}/{len(course_payloads)} {course_id}",
                flush=True,
            )

        print(
            f"Finished '{normalized_language}' -> {len(course_payloads)} course files.",
            flush=True,
        )

    print("Translation generation complete.", flush=True)


if __name__ == "__main__":
    main()
