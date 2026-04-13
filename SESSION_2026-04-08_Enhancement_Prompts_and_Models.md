# Session Notes: VoiceInk Enhancement Prompts & Ollama Models

> **Date:** 2026-04-08
> **Context:** VoiceInk AI Enhancement configuration — researching prompt templates and Ollama models for transcription improvement
> **Pickup document:** Start here next session to continue this work

---

## Table of Contents

1. [Session Summary](#session-summary)
2. [Current Ollama Models (Installed)](#current-ollama-models-installed)
3. [Recommended New Ollama Models (To Install)](#recommended-new-ollama-models-to-install)
4. [Models to Retire](#models-to-retire)
5. [How VoiceInk Enhancement Works](#how-voiceink-enhancement-works)
6. [Prompt Templates Added to Codebase](#prompt-templates-added-to-codebase)
7. [Code Changes Made](#code-changes-made)
8. [Configuration Tips](#configuration-tips)
9. [Power Mode Setup Plan](#power-mode-setup-plan)
10. [Next Session Checklist](#next-session-checklist)

---

## Session Summary

This session focused on optimizing VoiceInk's AI Enhancement feature for transcription cleanup. Three areas were covered:

1. **Model analysis** — Evaluated all 6 installed Ollama models for transcription suitability and researched better alternatives
2. **Prompt research** — Scraped web, Reddit, GitHub, and open-source projects for community-tested prompt templates
3. **Code changes** — Added 7 new prompt templates to VoiceInk's `PromptTemplates.swift` (inactive until user creates prompts from them)

**Key artifacts produced:**
- `VoiceInk_Enhancement_Prompts_Reference.md` — Full reference guide with all prompts, tips, and model pairings
- `SESSION_2026-04-08_Enhancement_Prompts_and_Models.md` — This document (session pickup notes)
- Modified `VoiceInk/Models/PromptTemplates.swift` — 7 new template entries added

**VoiceInk has NOT been rebuilt yet.** Run `make local` to get the new templates into the app.

---

## Current Ollama Models (Installed)

As of 2026-04-08, these models are installed on the MacBook:

| Model | Size | Suitability for Enhancement | Verdict |
|-------|------|---------------------------|---------|
| `mistral:7b` | 4.4 GB | Excellent instruction-following, good speed | **Keep — good general default** |
| `qwen2.5:7b` | 4.7 GB | Best for complex prompts, code, multilingual | **Replace with qwen3:4b** |
| `llama3.2:3b` | 2.0 GB | Fast, adequate for simple cleanup | **Replace with phi4-mini** |
| `gemma2:9b` | 5.4 GB | Too slow (9B params), likely to timeout | **Replace with qwen3:8b** |
| `phi3:mini` | 2.2 GB | Weaker instruction-following than alternatives | **Can retire** |
| `codellama:7b` | 3.8 GB | Code-focused, not for text cleanup | **Not useful here** |

---

## Recommended New Ollama Models (To Install)

### Priority 1 — Install These Three

| Model | Size | Speed (est.) | Install Command | Replaces | Why Better |
|-------|------|-------------|-----------------|----------|------------|
| **`qwen3:4b`** | 2.5 GB | 3-7s | `ollama pull qwen3:4b` | `qwen2.5:7b` | Rivals Qwen2.5-72B quality at 18x smaller; 36T training tokens; dual thinking/non-thinking mode; half the size of qwen2.5:7b |
| **`phi4-mini`** | 2.5 GB | 2-5s | `ollama pull phi4-mini` | `llama3.2:3b` | Microsoft's DPO-trained for "precise instruction adherence"; beats models 2-3x its size; MMLU 67.3 vs llama3.2:3b's 61.8 |
| **`qwen3:8b`** | 5.2 GB | 6-12s | `ollama pull qwen3:8b` | `gemma2:9b` | Same Qwen3 architecture leap; better quality, similar size; dual thinking modes |

**Total additional disk:** ~10.2 GB

### Priority 2 — Optional Ultrafast

| Model | Size | Speed | Install Command | Use Case |
|-------|------|-------|-----------------|----------|
| `qwen3:1.7b` | 1.4 GB | 1-3s | `ollama pull qwen3:1.7b` | Ultra-fast for short dictation, voice commands |
| `gemma3:4b` | 3.3 GB | 3-6s | `ollama pull gemma3:4b` | Good for multilingual, summarization |

### Per-Prompt Model Pairing

| Prompt | Best Model | Fallback |
|--------|-----------|----------|
| System Default | `qwen3:4b` | `mistral:7b` |
| Chat / Slack Message | `qwen3:4b` | `phi4-mini` |
| Email | `qwen3:4b` | `mistral:7b` |
| Rewrite | `qwen3:4b` | `mistral:7b` |
| Code Dictation | `qwen3:8b` | `qwen3:4b` |
| Meeting Notes | `qwen3:4b` | `mistral:7b` |
| Light Touch | `phi4-mini` | `qwen3:1.7b` |
| Professional Document | `qwen3:8b` | `qwen3:4b` |
| ASR Error Correction | `qwen3:4b` | `mistral:7b` |
| Technical Jargon | `qwen3:8b` | `qwen3:4b` |

---

## Models to Retire

After installing the new models, these can be removed to free disk space:

| Model | Size | Remove Command | Reason |
|-------|------|---------------|--------|
| `qwen2.5:7b` | 4.7 GB | `ollama rm qwen2.5:7b` | Replaced by `qwen3:4b` (smaller, faster, better) |
| `gemma2:9b` | 5.4 GB | `ollama rm gemma2:9b` | Replaced by `qwen3:8b` (better quality, similar size) |
| `llama3.2:3b` | 2.0 GB | `ollama rm llama3.2:3b` | Replaced by `phi4-mini` (better instruction-following) |
| `codellama:7b` | 3.8 GB | `ollama rm codellama:7b` | Not useful for transcription cleanup |

**Disk freed:** ~15.9 GB | **Net savings** (after new installs): ~5.7 GB

---

## How VoiceInk Enhancement Works

Understanding this is key to choosing the right prompts and models:

1. User speaks → whisper.cpp transcribes locally to raw text
2. Raw text is wrapped in `<TRANSCRIPT>` tags
3. System prompt is constructed from: active prompt's instructions + system template wrapper (anti-hallucination guards) + optional context (clipboard, screen capture, custom vocabulary)
4. Sent to Ollama at `http://localhost:11434/api/generate` with `temperature: 0.3`, `stream: false`
5. Response returned as enhanced text → pasted at cursor

**Key constraints:**
- **Default timeout:** 7 seconds (configurable 3-60s)
- **Temperature:** Fixed at 0.3 (not configurable)
- **System template wrapper:** Automatically added when `useSystemInstructions: true` — tells the LLM "you are a TRANSCRIPTION ENHANCER, not a chatbot" with anti-conversational examples
- **Prompts are stored in:** UserDefaults as JSON-encoded `[CustomPrompt]` array
- **Templates vs Prompts:** Templates (in `PromptTemplates.swift`) are starting points; users must create actual prompts from them via the UI

**Important note on VoiceInk's model selection:** VoiceInk currently uses ONE model for all prompts (set in API Key Management > Ollama > Model picker). There is no per-prompt model selection yet (it's a feature request: GitHub issue #560).

---

## Prompt Templates Added to Codebase

7 new templates were added to `VoiceInk/Models/PromptTemplates.swift`. These appear in the template picker when you tap "Add New" in Enhancement Settings. They do NOT activate until you explicitly create a prompt from one.

| # | Template | Icon | Suggested Trigger Words | Source |
|---|----------|------|------------------------|--------|
| 1 | **Code Dictation** | `terminal.fill` | "code", "terminal" | Crystal Audio |
| 2 | **Meeting Notes** | `person.2.fill` | "meeting", "notes", "standup" | Crystal Audio, MinaInsight |
| 3 | **Light Touch** | `hand.raised.fill` | "light", "minimal", "verbatim" | danielrosehill |
| 4 | **Slack Message** | `message.fill` | "slack", "message", "dm" | Superwhisper |
| 5 | **Professional Document** | `doc.text.fill` | "document", "formal", "report" | Whispering, LM-Kit.NET |
| 6 | **ASR Error Correction** | `textbox` | (none — use as base) | Superwhisper "parakeet.xml" |
| 7 | **Technical Jargon** | `gearshape.fill` | "tech", "technical" | WhisperForge, Smart Scribe |

**To activate in VoiceInk:**
1. Open VoiceInk > Settings > Enhancement
2. Click "Add New" (+ button)
3. Select a template from the picker
4. Optionally customize title, trigger words, icon
5. Save — prompt now appears in your grid

---

## Code Changes Made

### Modified File: `VoiceInk/Models/PromptTemplates.swift`

- Added 7 `TemplatePrompt` entries after the existing "Rewrite" template
- Marked with `// MARK: - Community-Sourced Templates` comment
- Each uses appropriate SF Symbol icons from the existing `PromptIcon.allCases`
- All follow the same pattern as built-in templates (multi-line instruction text with `<TRANSCRIPT>` references)
- No other files were modified

### New File: `VoiceInk_Enhancement_Prompts_Reference.md`

- Full reference document with all prompt texts, configuration tips, model recommendations
- Located in project root (not in VoiceInk/ source directory)
- For user reference only — not part of the build

### Build Status

- **VoiceInk has NOT been rebuilt** — run `make local` to compile the new templates into the app
- The changes are purely additive (new template entries) so there is zero risk to existing functionality

---

## Configuration Tips

These were gathered from community research:

| Setting | Current | Recommended | Why |
|---------|---------|-------------|-----|
| **Timeout** | 7s (default) | 10-15s for 7B models | 7s is tight for longer transcriptions |
| **Skip short transcriptions** | ? | Enable, threshold 3 words | Don't waste LLM calls on "yes" or "okay" |
| **Clipboard Context** | ? | Enable | Helps resolve ambiguous words |
| **Screen Context** | ? | Enable selectively | Useful for code/tech work but adds latency |
| **Custom Vocabulary** | ? | Add aggressively | People names, technical terms, product names |
| **Use System Instructions** | ON (default) | Keep ON | Anti-hallucination wrapper is critical |

### Custom Vocabulary to Add

```
VoiceInk, whisper.cpp, Ollama, XCFramework, SwiftUI, Xcode
Rescale, Kubernetes, Docker, Terraform
Claude, Anthropic, Bedrock, AWS
[Add your own people names and project terms]
```

---

## Power Mode Setup Plan

For next session — configure per-app automatic prompt switching:

| Application | Prompt | Timeout | Clipboard | Screen |
|-------------|--------|---------|-----------|--------|
| Slack | Slack Message | 7s | ON | OFF |
| Mail / Outlook | Email | 10s | ON | OFF |
| VS Code / Xcode | Code Dictation | 15s | ON | ON |
| Terminal | Code Dictation | 15s | OFF | ON |
| Notes / Notion | System Default | 10s | ON | OFF |
| Pages / Word | Professional Document | 15s | ON | OFF |
| Safari / Chrome | System Default | 10s | OFF | ON |
| Zoom / Teams | Meeting Notes | 15s | OFF | OFF |

---

## Next Session Checklist

### Step 1: Install New Ollama Models
```bash
ollama pull qwen3:4b
ollama pull phi4-mini
ollama pull qwen3:8b

# Optional ultrafast:
ollama pull qwen3:1.7b
```

### Step 2: Retire Old Models (after testing new ones)
```bash
ollama rm qwen2.5:7b
ollama rm gemma2:9b
ollama rm llama3.2:3b
ollama rm codellama:7b
```

### Step 3: Rebuild VoiceInk with New Templates
```bash
cd ~/projects/voiceink
make local
# If make local fails at whisper step, follow CLAUDE.md Step 2 workaround
mv ~/Downloads/VoiceInk.app /Applications/VoiceInk.app
```

### Step 4: Configure VoiceInk Enhancement
1. Open VoiceInk Settings > API Key Management
2. Select Ollama as provider
3. Set model to `qwen3:4b` (new default)
4. Go to Enhancement Settings
5. Create prompts from the new templates (Code Dictation, Meeting Notes, etc.)
6. Set trigger words for each
7. Adjust timeout to 10-15 seconds
8. Enable Clipboard Context
9. Add Custom Vocabulary entries

### Step 5: Set Up Power Mode (Optional)
- Configure per-app profiles following the table above
- Test each app/prompt combination

### Step 6: Test and Compare
- Dictate sample text with each prompt
- Compare `qwen3:4b` vs `mistral:7b` for quality
- Compare `phi4-mini` vs `qwen3:4b` for speed
- Verify no timeouts with 10s setting

---

## Research Sources

Prompt templates were sourced from:
- [whisper-llm](https://github.com/cj-elevate/whisper-llm) — Ollama "clean" mode, smart "like" handling
- [WhisperForge](https://github.com/virecorenlm/WhisperForge) — Ollama refinement with mistral:7b
- [Crystal Audio](https://github.com/crimson-knight/crystal-audio) — Code/Meeting/Dictation modes
- [Superwhisper prompts](https://github.com/mackid1993/superwhisper-dictation-prompts) — ASR correction
- [Whispering app](https://github.com/braden-w/whispering) — Comprehensive text formatter
- [LM-Kit.NET](https://docs.lm-kit.com) — Domain-specific reformatting
- [OpenAI Cookbook](https://developers.openai.com/cookbook/examples/whisper_correct_misspelling) — Custom vocabulary technique
- [Smart Scribe](https://github.com/ThilinaTLM/smart-scribe) — Domain-aware transcription
- [VoiceInk-tweaks fork](https://github.com/bigloudjeff/VoiceInk-tweaks) — LLM prewarming, background enhancement

Model recommendations based on:
- Ollama model library and model cards
- Hugging Face benchmark data
- r/LocalLLaMA community discussions
- Microsoft Phi4-mini technical report
- Qwen3 release blog post

---

*Session ended: 2026-04-08*
*Next session: Install models, rebuild app, configure enhancement, test*
