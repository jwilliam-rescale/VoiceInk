import Foundation

struct TemplatePrompt: Identifiable {
    let id: UUID
    let title: String
    let promptText: String
    let icon: PromptIcon
    let description: String
    
    func toCustomPrompt() -> CustomPrompt {
        CustomPrompt(
            id: UUID(),  // Generate new UUID for custom prompt
            title: title,
            promptText: promptText,
            icon: icon,
            description: description,
            isPredefined: false
        )
    }
}

enum PromptTemplates {
    static var all: [TemplatePrompt] {
        createTemplatePrompts()
    }
    
    
    static func createTemplatePrompts() -> [TemplatePrompt] {
        [
            TemplatePrompt(
                id: UUID(),
                title: "System Default",
                promptText: """
                    - Clean up the <TRANSCRIPT> text for clarity and natural flow while preserving meaning and the original tone.
                    - Use informal, plain language unless the <TRANSCRIPT> clearly uses a professional tone; in that case, match it.
                    - Fix obvious grammar, remove fillers and stutters, collapse repetitions, and keep names and numbers.
                    - Handle backtracking and self-corrections: When the speaker corrects themselves mid-sentence using phrases like "scratch that", "actually", "sorry not that", "I mean", "wait no", or similar corrections, remove the incorrect part and keep only the corrected version. Example: "The meeting is on Tuesday, sorry not that, actually Wednesday" → "The meeting is on Wednesday."
                    - Respect formatting commands: When the speaker explicitly says "new line" or "new paragraph", insert the appropriate line break or paragraph break at that point.
                    - Automatically detect and format lists properly: if the <TRANSCRIPT> mentions a number (e.g., "3 things", "5 items"), uses ordinal words (first, second, third), implies sequence or steps, or has a count before it, format as an ordered list; otherwise, format as an unordered list.
                    - Apply smart formatting: Write numbers as numerals (e.g., 'five' → '5', 'twenty dollars' → '$20'), convert common abbreviations to proper format (e.g., 'vs' → 'vs.', 'etc' → 'etc.'), and format dates, times, and measurements consistently.
                    - Keep the original intent and nuance.
                    - Organize into short paragraphs of 2–4 sentences for readability.
                    - Do not add explanations, labels, metadata, or instructions.
                    - Output only the cleaned text.
                    - Don't add any information not available in the <TRANSCRIPT> text ever.
                    """,
                icon: "checkmark.seal.fill",
                description: "Default system prompt"
            ),
            TemplatePrompt(
                id: UUID(),
                title: "Chat",
                promptText: """
                    - Rewrite the <TRANSCRIPT> text as a chat message: informal, concise, and conversational.
                    - Keep emotive markers and emojis if present; don't invent new ones.
                    - Lightly fix grammar, remove fillers and repeated words, and improve flow without changing meaning.
                    - Keep the original tone; only be professional if the <TRANSCRIPT> already is.
                    - Automatically detect and format lists properly: if the <TRANSCRIPT> mentions a number (e.g., "3 things", "5 items"), uses ordinal words (first, second, third), implies sequence or steps, or has a count before it, format as an ordered list; otherwise, format as an unordered list.
                    - Write numbers as numerals (e.g., 'five' → '5', 'twenty dollars' → '$20').
                    - Format like a modern chat message - short lines, natural breaks, emoji-friendly.
                    - Do not add greetings, sign-offs, or commentary.
                    - Output only the chat message.
                    - Don't add any information not available in the <TRANSCRIPT> text ever.
                    """,
                icon: "bubble.left.and.bubble.right.fill",
                description: "Casual chat-style formatting"
            ),
            
            TemplatePrompt(
                id: UUID(),
                title: "Email",
                promptText: """
                    - Rewrite the <TRANSCRIPT> text as a complete email with proper formatting: include a greeting (Hi), body paragraphs (2-4 sentences each), and closing (Thanks).
                    - Use clear, friendly, non-formal language unless the <TRANSCRIPT> is clearly professional—in that case, match that tone.
                    - Improve flow and coherence; fix grammar and spelling; remove fillers; keep all facts, names, dates, and action items.
                    - Automatically detect and format lists properly: if the <TRANSCRIPT> mentions a number (e.g., "3 things", "5 items"), uses ordinal words (first, second, third), implies sequence or steps, or has a count before it, format as an ordered list; otherwise, format as an unordered list.
                    - Write numbers as numerals (e.g., 'five' → '5', 'twenty dollars' → '$20').
                    - Do not invent new content, but structure it as a proper email format.
                    - Don't add any information not available in the <TRANSCRIPT> text ever.
                    """,
                icon: "envelope.fill",
                description: "Professional email formatting"
            ),
            TemplatePrompt(
                id: UUID(),
                title: "Rewrite",
                promptText: """
                    - Rewrite the <TRANSCRIPT> text with enhanced clarity, improved sentence structure, and rhythmic flow while preserving the original meaning and tone.
                    - Restructure sentences for better readability and natural progression.
                    - Improve word choice and phrasing where appropriate, but maintain the original voice and intent.
                    - Fix grammar and spelling errors, remove fillers and stutters, and collapse repetitions.
                    - Format any lists as proper bullet points or numbered lists.
                    - Write numbers as numerals (e.g., 'five' → '5', 'twenty dollars' → '$20').
                    - Organize content into well-structured paragraphs of 2–4 sentences for optimal readability.
                    - Preserve all names, numbers, dates, facts, and key information exactly as they appear.
                    - Do not add explanations, labels, metadata, or instructions.
                    - Output only the rewritten text.
                    - Don't add any information not available in the <TRANSCRIPT> text ever.
                    """,
                icon: "pencil.circle.fill",
                description: "Rewrites with better clarity."
            ),

            // MARK: - Community-Sourced Templates

            TemplatePrompt(
                id: UUID(),
                title: "Code Dictation",
                promptText: """
                    - You are a technical dictation assistant. The user is dictating code, technical documentation, or developer notes.
                    - Convert spoken programming constructs to correct syntax:
                      - "open paren" / "left paren" → (
                      - "close paren" / "right paren" → )
                      - "open bracket" / "left bracket" → [
                      - "close bracket" / "right bracket" → ]
                      - "open brace" / "left brace" / "open curly" → {
                      - "close brace" / "right brace" / "close curly" → }
                      - "equals" / "equal sign" → =
                      - "double equals" → ==
                      - "arrow" / "dash greater than" → ->
                      - "fat arrow" / "equals greater than" → =>
                      - "dot" / "period" → .
                      - "colon" → :
                      - "semicolon" → ;
                      - "hash" / "pound" → #
                      - "at sign" → @
                      - "pipe" → |
                      - "ampersand" / "and sign" → &
                      - "backtick" → `
                      - "underscore" → _
                      - "forward slash" → /
                      - "backslash" → \\
                    - Format code blocks with appropriate markdown fencing (```language).
                    - Fix speech-to-text errors in technical terms (e.g., "funk" → "func", "var" stays "var", "let" stays "let").
                    - Preserve technical precision — do not paraphrase technical statements.
                    - For prose sections between code: clean up punctuation and remove fillers.
                    - Respect "new line" commands as literal line breaks in code.
                    - Output only the cleaned text/code with no commentary.
                    - Don't add any information not available in the <TRANSCRIPT> text ever.
                    """,
                icon: "terminal.fill",
                description: "Converts spoken code dictation to proper syntax."
            ),
            TemplatePrompt(
                id: UUID(),
                title: "Meeting Notes",
                promptText: """
                    - Transform the <TRANSCRIPT> into structured meeting notes.
                    - Use this format:

                    ## Summary
                    2–3 sentence overview of the meeting.

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
                    """,
                icon: "person.2.fill",
                description: "Structures transcripts into organized meeting notes."
            ),
            TemplatePrompt(
                id: UUID(),
                title: "Light Touch",
                promptText: """
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
                    """,
                icon: "hand.raised.fill",
                description: "Minimal cleanup preserving the speaker's natural voice."
            ),
            TemplatePrompt(
                id: UUID(),
                title: "Slack Message",
                promptText: """
                    - Rewrite the <TRANSCRIPT> as a Slack/messaging app message.
                    - Maintain the speaker's original voice and style with minimal adjustments.
                    - Correct obvious spelling mistakes.
                    - Add basic punctuation where needed.
                    - Remove excessive filler words only — keep casual speech patterns.
                    - Preserve idiomatic expressions and casual tone.
                    - Replace described emojis with actual emoji characters (e.g., "smiley face" → 😊, "thumbs up" → 👍, "heart" → ❤️, "fire" → 🔥, "check mark" → ✅).
                    - Keep it short and conversational — no one writes essays in Slack.
                    - Do not add greetings or sign-offs unless the speaker included them.
                    - Output only the message text.
                    - Don't add any information not available in the <TRANSCRIPT> text ever.
                    """,
                icon: "message.fill",
                description: "Casual Slack/messaging style with emoji support."
            ),
            TemplatePrompt(
                id: UUID(),
                title: "Professional Document",
                promptText: """
                    - Transform the <TRANSCRIPT> into a well-formatted professional document.
                    - Create paragraph breaks at natural topic transitions.
                    - Use bullet points or numbered lists when items are being listed.
                    - Add headings (## format) if the content has clear distinct sections.
                    - Fix grammar, punctuation, and sentence structure thoroughly.
                    - Convert spoken numbers to digits (five → 5, twenty dollars → $20).
                    - Standardize dates and times (3 PM, January 5, 2026).
                    - Standardize measurements and units consistently.
                    - Use professional but accessible language — don't "upgrade" simple language unnecessarily.
                    - Maintain the speaker's level of formality.
                    - Keep colloquialisms only if they serve the meaning clearly.
                    - Preserve all names, numbers, dates, facts, and key information exactly.
                    - Do not add explanations, labels, metadata, or commentary.
                    - Output only the formatted document.
                    - Don't add any information not available in the <TRANSCRIPT> text ever.
                    """,
                icon: "doc.text.fill",
                description: "Formal document with headings, lists, and professional formatting."
            ),
            TemplatePrompt(
                id: UUID(),
                title: "ASR Error Correction",
                promptText: """
                    - The voice transcription model frequently outputs phonetically similar but incorrect words. Your primary job is to fix these errors.
                    - Decision rule: "Would a native English speaker actually write this sentence?" If NO, fix it.
                    - Fix common ASR errors:
                      - "blessing in the skies" → "blessing in disguise"
                      - "took it for granite" → "took it for granted"
                      - "for all intensive purposes" → "for all intents and purposes"
                      - "should of" / "could of" / "would of" → "should have" / "could have" / "would have"
                      - "supposably" → "supposedly"
                      - "excetera" → "et cetera" / "etc."
                      - "Pacific" (when meaning specific) → "specific"
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
                    - Handle smart "like" disambiguation:
                      - Remove "like" when used as hesitation: "I was like thinking" → "I was thinking"
                      - Keep "like" in comparisons: "it was like ten degrees" → keep as-is
                      - Keep "like" as a verb: "I like this song" → keep as-is
                    - Remove standard fillers: um, uh, er, ah, "you know" (as filler), "basically" (as filler), "actually" (as filler).
                    - Add proper punctuation and capitalization.
                    - Output only the corrected text.
                    - Don't add any information not available in the <TRANSCRIPT> text ever.
                    """,
                icon: "textbox",
                description: "Fixes speech recognition errors, homophones, and common mishearings."
            ),
            TemplatePrompt(
                id: UUID(),
                title: "Technical Jargon",
                promptText: """
                    - Clean up the <TRANSCRIPT> while treating it as technical or domain-specific content.
                    - Preserve ALL technical terms, product names, acronyms, and abbreviations exactly as spoken.
                    - When in doubt about whether a word is a technical term, preserve it as-is rather than "correcting" it.
                    - Fix grammar, punctuation, and capitalization errors in the surrounding prose.
                    - Remove verbal filler words (um, uh, like, you know, sort of, kind of) while preserving meaning.
                    - Add paragraph breaks at logical topic transitions.
                    - Format lists and enumerations clearly (bullet points or numbered lists).
                    - Preserve version numbers, API names, function names, file paths, and URLs exactly.
                    - Convert spoken technical constructs where obvious:
                      - "dot" in domain/path context → "."
                      - "slash" in path context → "/"
                      - "dash" in naming context → "-"
                      - "underscore" in naming context → "_"
                    - Do NOT summarize — maintain full content and detail.
                    - Do NOT paraphrase technical explanations.
                    - Output only the cleaned text.
                    - Don't add any information not available in the <TRANSCRIPT> text ever.
                    """,
                icon: "gearshape.fill",
                description: "Preserves technical terminology while cleaning prose."
            )
        ]
    }
}
