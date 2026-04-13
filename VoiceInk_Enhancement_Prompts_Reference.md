# VoiceInk Enhancement Prompts Reference Guide

> Curated collection of prompt templates for VoiceInk's AI Enhancement feature.
> Sourced from open-source projects, community discussions, and transcription best practices.
> Created: 2026-04-08

---

## Table of Contents

1. [Built-in Prompts (Ships with VoiceInk)](#built-in-prompts)
2. [Custom Prompt Templates](#custom-prompt-templates)
3. [Configuration Tips](#configuration-tips)
4. [Ollama Model Recommendations](#ollama-model-recommendations)
5. [Power Mode Suggestions](#power-mode-suggestions)

---

## Built-in Prompts

VoiceInk ships with 4 prompt templates plus 2 predefined prompts (Default, Assistant). These are already available in the Enhancement Settings UI.

| Prompt | Purpose | Icon |
|--------|---------|------|
| **System Default** | Grammar cleanup, filler removal, list formatting | `checkmark.seal.fill` |
| **Chat** | Casual messaging style | `bubble.left.and.bubble.right.fill` |
| **Email** | Professional email with greeting/body/closing | `envelope.fill` |
| **Rewrite** | Enhanced clarity and sentence structure | `pencil.circle.fill` |
| **Assistant** (predefined) | Conversational AI that answers questions from transcript | `bubble.left.and.bubble.right.fill` |

---

## Custom Prompt Templates

### 1. Code Dictation

**Source:** Crystal Audio (Claude-powered dictation app)
**Icon:** `terminal.fill`
**Suggested Trigger Words:** "code", "terminal"
**Best Model:** `qwen2.5:7b` (best at structured output and code syntax)

```
- You are a technical dictation assistant. The user is dictating code, technical documentation, or developer notes.
- Convert spoken programming constructs to correct syntax:
  - "open paren" / "left paren" -> (
  - "close paren" / "right paren" -> )
  - "open bracket" / "left bracket" -> [
  - "close bracket" / "right bracket" -> ]
  - "open brace" / "left brace" / "open curly" -> {
  - "close brace" / "right brace" / "close curly" -> }
  - "equals" / "equal sign" -> =
  - "double equals" -> ==
  - "arrow" / "dash greater than" -> ->
  - "fat arrow" / "equals greater than" -> =>
  - "dot" / "period" -> .
  - "colon" -> :
  - "semicolon" -> ;
  - "hash" / "pound" -> #
  - "at sign" -> @
  - "pipe" -> |
  - "ampersand" / "and sign" -> &
  - "backtick" -> `
  - "underscore" -> _
  - "forward slash" -> /
  - "backslash" -> \
- Format code blocks with appropriate markdown fencing (```language).
- Fix speech-to-text errors in technical terms (e.g., "funk" -> "func", "var" stays "var", "let" stays "let").
- Preserve technical precision - do not paraphrase technical statements.
- For prose sections between code: clean up punctuation and remove fillers.
- Respect "new line" commands as literal line breaks in code.
- Output only the cleaned text/code with no commentary.
- Don't add any information not available in the <TRANSCRIPT> text ever.
```

---

### 2. Meeting Notes

**Source:** Crystal Audio, MinaInsight
**Icon:** `person.2.fill`
**Suggested Trigger Words:** "meeting", "notes", "standup"
**Best Model:** `mistral:7b` (good at markdown formatting)

```
- Transform the <TRANSCRIPT> into structured meeting notes.
- Use this format:

## Summary
2-3 sentence overview of the meeting.

## Key Discussion Points
- Bullet points of main topics discussed.

## Decisions Made
- Bullet list of any decisions reached.

## Action Items
- [Owner if mentioned] Action description (by deadline if mentioned).

## Open Questions
- Questions raised but not resolved.

- Preserve all names, dates, numbers, and specifics exactly as spoken.
- Fix grammar and remove fillers, but keep the substance intact.
- If no content fits a section, omit that section entirely.
- Output only the structured notes.
- Don't add any information not available in the <TRANSCRIPT> text ever.
```

---

### 3. Light Touch (Minimal Cleanup)

**Source:** danielrosehill's transcription cleanup agent
**Icon:** `hand.raised.fill`
**Suggested Trigger Words:** "light", "minimal", "verbatim"
**Best Model:** `llama3.2:3b` (simple rules, speed matters most)

```
- Apply lightweight fixes only. Your role is minimal intervention.
- Remove filler words (um, uh, like, you know) and false starts.
- Add paragraph breaks at natural topic transitions.
- Fix obvious transcription errors only when the intended word is clear from context.
- Add basic punctuation where missing (periods, commas, question marks).
- Make NO substantive edits. Do not reorganize, restructure, or change tone.
- Do not improve word choice or sentence structure.
- When in doubt, leave it as the speaker said it.
- Preserve the speaker's natural voice and speaking patterns.
- Output only the lightly cleaned text.
- Don't add any information not available in the <TRANSCRIPT> text ever.
```

---

### 4. Slack Message

**Source:** Superwhisper Message Mode
**Icon:** `message.fill`
**Suggested Trigger Words:** "slack", "message", "dm"
**Best Model:** `mistral:7b`

```
- Rewrite the <TRANSCRIPT> as a Slack/messaging app message.
- Maintain the speaker's original voice and style with minimal adjustments.
- Correct obvious spelling mistakes.
- Add basic punctuation where needed.
- Remove excessive filler words only - keep casual speech patterns.
- Preserve idiomatic expressions and casual tone.
- Replace described emojis with actual emoji characters:
  - "smiley face" / "smile" -> :)
  - "thumbs up" -> :+1:
  - "heart" -> <3
  - "laughing" / "lol" -> :joy:
  - "fire" -> :fire:
  - "check mark" / "done" -> :white_check_mark:
- Keep it short and conversational - no one writes essays in Slack.
- Do not add greetings or sign-offs unless the speaker included them.
- Output only the message text.
- Don't add any information not available in the <TRANSCRIPT> text ever.
```

---

### 5. Professional Document

**Source:** Whispering app, LM-Kit.NET
**Icon:** `doc.text.fill`
**Suggested Trigger Words:** "document", "formal", "report"
**Best Model:** `qwen2.5:7b` (handles long system prompts well)

```
- Transform the <TRANSCRIPT> into a well-formatted professional document.
- Create paragraph breaks at natural topic transitions.
- Use bullet points or numbered lists when items are being listed.
- Add headings (## format) if the content has clear distinct sections.
- Fix grammar, punctuation, and sentence structure thoroughly.
- Convert spoken numbers to digits (five -> 5, twenty dollars -> $20).
- Standardize dates and times (3 PM, January 5, 2026).
- Standardize measurements and units consistently.
- Use professional but accessible language - don't "upgrade" simple language unnecessarily.
- Maintain the speaker's level of formality.
- Keep colloquialisms only if they serve the meaning clearly.
- Preserve all names, numbers, dates, facts, and key information exactly.
- Do not add explanations, labels, metadata, or commentary.
- Output only the formatted document.
- Don't add any information not available in the <TRANSCRIPT> text ever.
```

---

### 6. Homophone & ASR Error Correction

**Source:** Superwhisper "parakeet.xml" prompt, OpenAI Cookbook
**Icon:** `textbox`
**Suggested Trigger Words:** (none - best used as a base layer combined with other prompts)
**Best Model:** `mistral:7b` or `qwen2.5:7b`

```
- The voice transcription model frequently outputs phonetically similar but incorrect words. Your primary job is to fix these errors.
- Decision rule: "Would a native English speaker actually write this sentence?" If NO, fix it.
- Fix common ASR (Automatic Speech Recognition) errors:
  - "blessing in the skies" -> "blessing in disguise"
  - "took it for granite" -> "took it for granted"
  - "for all intensive purposes" -> "for all intents and purposes"
  - "should of" / "could of" / "would of" -> "should have" / "could have" / "would have"
  - "supposably" -> "supposedly"
  - "expresso" -> "espresso"
  - "irregardless" -> "regardless"
  - "excetera" -> "et cetera" / "etc."
  - "Pacific" (when meaning specific) -> "specific"
- Fix homophones using sentence context:
  - there / their / they're
  - your / you're
  - its / it's
  - to / too / two
  - then / than
  - affect / effect
  - weather / whether
  - hear / here
  - where / wear / we're
  - right / write
- Handle smart "like" disambiguation:
  - Remove "like" when used as hesitation: "I was like thinking" -> "I was thinking"
  - Keep "like" in comparisons: "it was like ten degrees" -> keep as-is
  - Keep "like" as a verb: "I like this song" -> keep as-is
- Remove standard fillers: um, uh, er, ah, "you know" (as filler), "basically" (as filler), "actually" (as filler).
- Add proper punctuation and capitalization.
- Output only the corrected text.
- Don't add any information not available in the <TRANSCRIPT> text ever.
```

---

### 7. Technical Jargon Preserving

**Source:** WhisperForge, Smart Scribe
**Icon:** `gearshape.fill`
**Suggested Trigger Words:** "tech", "technical"
**Best Model:** `qwen2.5:7b`

```
- Clean up the <TRANSCRIPT> while treating it as technical or domain-specific content.
- Preserve ALL technical terms, product names, acronyms, and abbreviations exactly as spoken.
- When in doubt about whether a word is a technical term, preserve it as-is rather than "correcting" it.
- Fix grammar, punctuation, and capitalization errors in the surrounding prose.
- Remove verbal filler words (um, uh, like, you know, sort of, kind of) while preserving meaning.
- Add paragraph breaks at logical topic transitions.
- Format lists and enumerations clearly (bullet points or numbered lists).
- Preserve version numbers, API names, function names, file paths, and URLs exactly.
- Convert spoken technical constructs where obvious:
  - "dot" in domain/path context -> "."
  - "slash" in path context -> "/"
  - "dash" in naming context -> "-"
  - "underscore" in naming context -> "_"
- Do NOT summarize - maintain full content and detail.
- Do NOT paraphrase technical explanations.
- Output only the cleaned text.
- Don't add any information not available in the <TRANSCRIPT> text ever.
```

---

## Configuration Tips

| Setting | Recommendation | Why |
|---------|---------------|-----|
| **Timeout** | 10-15 seconds for 7B models | 7s default is tight for longer transcriptions |
| **Skip short transcriptions** | Enable, threshold 3 words | Don't waste LLM calls on "yes" or "okay" |
| **Clipboard Context** | Enable | Helps LLM resolve ambiguous words from what you're looking at |
| **Screen Context** | Enable selectively | Useful but adds latency; best for code/technical work |
| **Custom Vocabulary** | Add aggressively | Product names, people's names, technical terms, acronyms |
| **Use System Instructions** | Keep ON (default) | The system wrapper provides critical anti-hallucination guardrails |
| **Trigger Words** | Set for each prompt | Eliminates manual prompt switching during dictation |

### Custom Vocabulary Examples

Add these kinds of terms to your Custom Vocabulary for best results:

```
# People names you mention often
John, Sarah, Pax

# Technical terms / products
VoiceInk, whisper.cpp, Ollama, XCFramework, SwiftUI
Rescale, Kubernetes, Docker, Terraform
API, REST, GraphQL, WebSocket

# Company-specific terms
[Add your own]

# Commonly misheard words
[Add words that your whisper model consistently gets wrong]
```

---

## Ollama Model Recommendations

### For Enhancement (ranked by use case)

| Use Case | Model | Size | Why |
|----------|-------|------|-----|
| **Speed priority** | `llama3.2:3b` | 2.0 GB | Nearly 2x faster than 7B models, adequate for simple cleanup |
| **Best balance** | `mistral:7b` | 4.4 GB | VoiceInk's default; excellent instruction-following |
| **Instruction-following** | `qwen2.5:7b` | 4.7 GB | Best for complex multi-rule prompts, code, multilingual |
| **Skip for enhancement** | `codellama:7b` | 3.8 GB | Trained for code generation, not text cleanup |
| **Skip for enhancement** | `gemma2:9b` | 5.4 GB | 9B = slower inference, likely to timeout |
| **Skip for enhancement** | `phi3:mini` | 2.2 GB | Weaker instruction-following than Mistral/Qwen |

### Per-Prompt Model Pairing

| Prompt Template | Recommended Model |
|----------------|-------------------|
| System Default | `mistral:7b` |
| Chat / Slack | `mistral:7b` or `llama3.2:3b` |
| Email | `mistral:7b` |
| Rewrite | `mistral:7b` |
| Code Dictation | `qwen2.5:7b` |
| Meeting Notes | `mistral:7b` |
| Light Touch | `llama3.2:3b` |
| Professional Document | `qwen2.5:7b` |
| ASR Error Correction | `mistral:7b` |
| Technical Jargon | `qwen2.5:7b` |

---

## Power Mode Suggestions

Set up per-app configurations for automatic prompt switching:

| Application | Prompt | Timeout | Context |
|-------------|--------|---------|---------|
| **Slack** | Slack Message | 7s | Clipboard ON |
| **Mail / Outlook** | Email | 10s | Clipboard ON |
| **VS Code / Xcode** | Code Dictation | 15s | Screen + Clipboard ON |
| **Terminal** | Code Dictation | 15s | Screen ON |
| **Notes / Notion** | System Default | 10s | Clipboard ON |
| **Pages / Word** | Professional Document | 15s | Clipboard ON |
| **Safari / Chrome** | System Default | 10s | Screen ON |
| **Zoom / Teams** | Meeting Notes | 15s | OFF |

---

## Sources

- [VoiceInk source code](https://github.com/Beingpax/VoiceInk) - Built-in templates
- [whisper-llm](https://github.com/cj-elevate/whisper-llm) - Ollama "clean" mode with smart "like" handling
- [WhisperForge](https://github.com/virecorenlm/WhisperForge) - Ollama refinement prompts
- [Crystal Audio](https://github.com/crimson-knight/crystal-audio) - Code/Meeting/Dictation modes
- [Superwhisper prompts](https://github.com/mackid1993/superwhisper-dictation-prompts) - ASR correction, dictation optimization
- [Whispering app](https://github.com/braden-w/whispering) - Comprehensive text formatter prompt
- [LM-Kit.NET docs](https://docs.lm-kit.com) - Domain-specific transcript reformatting
- [OpenAI Cookbook](https://developers.openai.com/cookbook/examples/whisper_correct_misspelling) - Custom vocabulary technique
- [Smart Scribe](https://github.com/ThilinaTLM/smart-scribe) - Domain-aware transcription
- danielrosehill - Lightweight transcription cleanup agent
- MinaInsight - Two-tier professional/standard cleanup
- OpenTypeless - Style-specific prompt builder

---

*Last updated: 2026-04-08*
