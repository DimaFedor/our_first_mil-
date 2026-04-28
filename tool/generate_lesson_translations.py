#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import math
import random
import re
import time
from pathlib import Path
from typing import Any

import requests

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

PROTECTED_PROGRAMMING_TERMS = [
    "console.log",
    "__init__",
    "print",
    "input",
    "self",
    "init",
    "len",
    "append",
    "dict",
    "tuple",
    "int",
    "float",
    "str",
    "bool",
    "None",
    "True",
    "False",
    "null",
    "undefined",
    "printf",
    "scanf",
    "cout",
    "cin",
    "println",
]

FENCED_CODE_PATTERN = re.compile(r"```[\s\S]*?```", re.MULTILINE)
INLINE_CODE_PATTERN = re.compile(r"`[^`\n]+`")
FUNCTION_CALL_PATTERN = re.compile(r"(?<![A-Za-z0-9_])[A-Za-z_][A-Za-z0-9_]*\(\)")
GOOGLE_TRANSLATE_URL = "https://translate.googleapis.com/translate_a/single"
BATCH_SEPARATOR = " __COPILOT_SPLIT__ "
REQUEST_PAUSE_SECONDS = 0.12

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


def protect_text(text: str) -> tuple[str, dict[str, str]]:
    protected = text
    placeholders: dict[str, str] = {}
    placeholder_index = 0

    def reserve_placeholder(value: str) -> str:
        nonlocal placeholder_index
        placeholder = f"__COPILOT_KEEP_{placeholder_index}__"
        placeholder_index += 1
        placeholders[placeholder] = value
        return placeholder

    def protect_pattern(input_text: str, pattern: re.Pattern[str]) -> str:
        return pattern.sub(lambda match: reserve_placeholder(match.group(0)), input_text)

    protected = protect_pattern(protected, FENCED_CODE_PATTERN)
    protected = protect_pattern(protected, INLINE_CODE_PATTERN)
    protected = protect_pattern(protected, FUNCTION_CALL_PATTERN)

    for term in PROTECTED_PROGRAMMING_TERMS:
        term_pattern = re.compile(
            rf"(?<![A-Za-z0-9_]){re.escape(term)}(?![A-Za-z0-9_])"
        )
        protected = protect_pattern(protected, term_pattern)

    return protected, placeholders


def restore_text(text: str, placeholders: dict[str, str]) -> str:
    restored = text
    for placeholder, original in placeholders.items():
        restored = restored.replace(placeholder, original)
    return restored


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
    target_language_code: str,
    chunk: list[str],
) -> list[str]:
    protected_items = [protect_text(text) for text in chunk]

    def translate_text_with_google(text: str) -> str:
        for attempt in range(7):
            try:
                response = requests.post(
                    GOOGLE_TRANSLATE_URL,
                    params={
                        "client": "gtx",
                        "sl": "auto",
                        "tl": target_language_code,
                        "dt": "t",
                    },
                    data={"q": text},
                    timeout=30,
                )

                if response.status_code == 429:
                    backoff_seconds = min(90.0, (2**attempt) + random.random())
                    time.sleep(backoff_seconds)
                    continue

                response.raise_for_status()
                decoded = response.json()
                if not isinstance(decoded, list) or not decoded:
                    return text
                sentence_blocks = decoded[0]
                if not isinstance(sentence_blocks, list):
                    return text
                translated_parts: list[str] = []
                for sentence in sentence_blocks:
                    if (
                        isinstance(sentence, list)
                        and sentence
                        and isinstance(sentence[0], str)
                    ):
                        translated_parts.append(sentence[0])
                translated_text = "".join(translated_parts)
                if REQUEST_PAUSE_SECONDS > 0:
                    time.sleep(REQUEST_PAUSE_SECONDS)
                return translated_text or text
            except requests.RequestException:
                if attempt == 6:
                    raise
                time.sleep(min(20.0, 0.8 * (attempt + 1)))

        return text

    def translate_items(items: list[tuple[str, dict[str, str]]], source: list[str]) -> list[str]:
        protected_texts = [item[0] for item in items]
        placeholders_list = [item[1] for item in items]

        for attempt in range(3):
            try:
                translated_batch = translate_text_with_google(
                    BATCH_SEPARATOR.join(protected_texts)
                )
                translated = translated_batch.split(BATCH_SEPARATOR)
                if len(translated) == len(source):
                    return [
                        restore_text(translated_text or source_text, placeholders)
                        for source_text, placeholders, translated_text in zip(
                            source,
                            placeholders_list,
                            translated,
                        )
                    ]
            except Exception:
                if attempt < 2:
                    time.sleep(0.35 * (attempt + 1))

        if len(items) == 1:
            source_text = source[0]
            protected_text, placeholders = items[0]
            translated_text = source_text
            for attempt in range(3):
                try:
                    translated_text = translate_text_with_google(protected_text)
                    break
                except Exception:
                    if attempt == 2:
                        translated_text = source_text
                    else:
                        time.sleep(0.35 * (attempt + 1))
            return [restore_text(translated_text, placeholders)]

        midpoint = len(items) // 2
        left = translate_items(items[:midpoint], source[:midpoint])
        right = translate_items(items[midpoint:], source[midpoint:])
        return left + right

    return translate_items(protected_items, chunk)


def build_translations_map(
    strings: list[str],
    language_code: str,
    batch_size: int,
    cache: dict[str, str],
    cache_file: Path | None = None,
) -> dict[str, str]:
    if not strings:
        return {}

    translator_code = TRANSLATOR_LANGUAGE_MAP.get(language_code, language_code)

    uncached_strings = [
        text for text in strings if f"{language_code}|{text}" not in cache
    ]
    chunks = chunked(uncached_strings, batch_size)
    total_chunks = len(chunks)

    for chunk_index, chunk in enumerate(chunks, start=1):
        translated_chunk = translate_chunk(translator_code, chunk)
        for source_text, translated_text in zip(chunk, translated_chunk):
            cache[f"{language_code}|{source_text}"] = translated_text or source_text

        if cache_file is not None:
            save_cache(cache_file, cache)

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

        all_strings: set[str] = set()
        for payload in course_payloads.values():
            collect_translatable_strings(payload, None, all_strings)

        print(
            f"  [{normalized_language}] unique source strings: {len(all_strings)}",
            flush=True,
        )
        translations_map = build_translations_map(
            strings=sorted(all_strings),
            language_code=normalized_language,
            batch_size=args.batch_size,
            cache=translation_cache,
            cache_file=cache_file,
        )
        save_cache(cache_file, translation_cache)

        for index, (course_id, payload) in enumerate(course_payloads.items(), start=1):
            translated_payload = apply_translations(payload, None, translations_map)
            output_file = target_dir / f"{course_id}.json"
            output_file.write_text(
                json.dumps(translated_payload, ensure_ascii=False, indent=2),
                encoding="utf-8",
            )
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
