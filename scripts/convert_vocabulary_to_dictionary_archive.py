#!/usr/bin/env python3
"""Convert the legacy v1.73-era vocabulary backup into VoiceInk v2.20's dictionary archive.

VoiceInk 2.20 added dictionary import/export (Settings > Dictionary). It reads a
specific schema defined in VoiceInk/Features/Dictionary/Workflows/DictionaryArchive.swift:

    {
      "format": "voiceink.dictionary",      # must match exactly, else unsupportedFormat
      "schemaVersion": 1,                   # must equal currentSchemaVersion
      "exportedAt": "<ISO8601>",            # required (non-optional Date)
      "appVersion": "2.20",                 # optional
      "vocabulary":   [{"term": "...", "createdAt": "<ISO8601>"?}],
      "replacements": [{"sources": [...], "replacement": "...", "createdAt": ...?}]
    }

Our legacy file (voiceink-vocabulary-import.json) is the old settings-backup shape:
`vocabularyWords: [{"word": ...}]` and `wordReplacements: {source: replacement}`.

Two non-obvious importer rules, both read out of the Swift source rather than guessed:

1. Commas are rejected in replacement sources (DictionaryImportExportService, the
   `sources.contains { $0.contains(",") }` guard) because the persisted dictionary
   uses commas as its own source separator. Such entries are counted in
   `commaContainingSourceCount` and skipped.

2. Case-only replacements ("numa" -> "NUMA") are rejected as CYCLIC.
   WordReplacementVariants.CycleDetector.insertIfAcyclic applies `key(for:)` to BOTH
   source and destination, and `key(for:)` case-folds. A case-only rule therefore
   becomes the self-edge graph["numa"] = ["numa"], and canReach() matches on its first
   iteration. We filter these out up front so the import reports no spurious "skipped
   cyclic entries" — they are redundant anyway when the term is also in the vocabulary
   list, which drives capitalization through <CUSTOM_VOCABULARY>.

The importer flattens each entry's `sources` and re-groups by destination internally,
so grouping here is cosmetic for correctness — but it matches the canonical export
shape, which keeps a later round-trip diff readable.

Usage:
    python3 scripts/convert_vocabulary_to_dictionary_archive.py \
        voiceink-vocabulary-import.json voiceink-dictionary-v2.20.json
"""

from __future__ import annotations

import json
import sys
from collections import OrderedDict
from datetime import datetime, timezone

FORMAT_IDENTIFIER = "voiceink.dictionary"
SCHEMA_VERSION = 1
APP_VERSION = "2.20"


def convert(legacy: dict) -> tuple[dict, dict]:
    """Return (archive, report). Report carries the counts worth showing a human."""
    report: dict[str, object] = {}

    # --- vocabulary: {"word": x} -> {"term": x}, trimmed, case-insensitively deduped ---
    seen_terms: set[str] = set()
    vocabulary = []
    blank = 0
    dupes = 0
    for entry in legacy.get("vocabularyWords", []):
        term = (entry.get("word") or "").strip()
        if not term:
            blank += 1
            continue
        key = term.casefold()
        if key in seen_terms:
            dupes += 1
            continue
        seen_terms.add(key)
        vocabulary.append({"term": term})

    report["vocabulary_in"] = len(legacy.get("vocabularyWords", []))
    report["vocabulary_out"] = len(vocabulary)
    report["vocabulary_blank"] = blank
    report["vocabulary_duplicates"] = dupes

    # --- replacements: {source: replacement} -> [{sources: [...], replacement: ...}] ---
    raw = legacy.get("wordReplacements", {})
    rejected_comma: list[str] = []
    rejected_case_only: list[str] = []

    # Group by exact destination text: destinationKey(for:) trims and normalizes
    # unicode but does NOT case-fold, so casing distinguishes destinations.
    grouped: "OrderedDict[str, list[str]]" = OrderedDict()
    for source, replacement in raw.items():
        source = source.strip()
        replacement = (replacement or "").strip()
        if not source or not replacement:
            continue
        if "," in source:
            rejected_comma.append(source)
            continue
        if source.casefold() == replacement.casefold():
            # Case-only rule -> self-edge -> importer counts it cyclic and skips it.
            rejected_case_only.append(f"{source} -> {replacement}")
            continue
        grouped.setdefault(replacement, []).append(source)

    replacements = [
        {"sources": sources, "replacement": replacement}
        for replacement, sources in grouped.items()
    ]

    report["replacements_in"] = len(raw)
    report["replacement_rules_out"] = len(replacements)
    report["replacement_sources_out"] = sum(len(r["sources"]) for r in replacements)
    report["rejected_comma"] = rejected_comma
    report["rejected_case_only"] = rejected_case_only

    archive = {
        "appVersion": APP_VERSION,
        "exportedAt": datetime.now(timezone.utc).isoformat(timespec="seconds").replace(
            "+00:00", "Z"
        ),
        "format": FORMAT_IDENTIFIER,
        "replacements": replacements,
        "schemaVersion": SCHEMA_VERSION,
        "vocabulary": vocabulary,
    }
    return archive, report


def main() -> int:
    if len(sys.argv) != 3:
        print(__doc__)
        return 2

    src, dst = sys.argv[1], sys.argv[2]
    with open(src, encoding="utf-8") as fh:
        legacy = json.load(fh)

    archive, report = convert(legacy)

    # sortedKeys + prettyPrinted mirrors the app's own encoder settings, so a file
    # exported by VoiceInk and one produced here diff cleanly against each other.
    with open(dst, "w", encoding="utf-8") as fh:
        json.dump(archive, fh, indent=2, ensure_ascii=False, sort_keys=True)
        fh.write("\n")

    print(f"wrote {dst}")
    print(
        f"  vocabulary:   {report['vocabulary_out']} terms "
        f"(from {report['vocabulary_in']}; "
        f"{report['vocabulary_blank']} blank, {report['vocabulary_duplicates']} dupes)"
    )
    print(
        f"  replacements: {report['replacement_rules_out']} rules / "
        f"{report['replacement_sources_out']} sources (from {report['replacements_in']})"
    )
    for label, key in (
        ("rejected (comma in source)", "rejected_comma"),
        ("filtered (case-only -> would import as cyclic)", "rejected_case_only"),
    ):
        items = report[key]
        if items:
            print(f"  {label}: {len(items)}")
            for item in items:
                print(f"      {item}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
