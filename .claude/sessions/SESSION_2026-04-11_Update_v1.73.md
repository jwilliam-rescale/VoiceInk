# Session: VoiceInk v1.73 Update, Skill Creation & Local CLI Enhancement

**Date:** 2026-04-11
**Duration:** ~45 minutes
**Working Directory:** ~/projects/voiceink

## Summary

Updated VoiceInk from v1.72 (commit 2ad8ff3) to v1.73 (commit e635edd), created a reusable `/update-voiceink` skill, and configured the new Local CLI enhancement feature to use Claude via AWS Bedrock.

## What Was Accomplished

### 1. VoiceInk Updated to v1.73
- Checked GitHub for latest release (v1.73, released 2026-04-10)
- Created timestamped backup: `/Applications/VoiceInk.app.backup-20260411-174548`
- Stashed local `PromptTemplates.swift` customizations
- Pulled 12 new commits (fast-forward, +1999/-469 lines)
- Reapplied local customizations (no conflicts)
- Built with `make local` (BUILD SUCCEEDED, whisper rebuild not needed)
- Deployed to `/Applications/VoiceInk.app`
- User confirmed app is working

### 2. New Features in v1.73
- Parakeet (FluidAudio) on-device real-time streaming support
- Speechmatics real-time transcription model support
- Local CLI enhancement (use Claude/Pi/Codex for AI enhancement instead of API calls)
- Multi-file transcription queue support
- Inline history view
- Auto-learn vocabulary (Experimental)
- Dictionary quick-add panel with shortcut
- Re-enhance only button in transcript history
- Bug fixes and stability improvements

### 3. `/update-voiceink` Skill Created
- Installed at: `~/.claude/skills/update-voiceink/SKILL.md`
- Also copied to source repo: `~/scripts/repos/work/john-wee-scripts/claude_skills/skills/update-voiceink/`
- Automates: backup → check release → stash → pull → reapply → build → deploy → cleanup
- Includes rollback procedure
- Keeps last 3 timestamped backups

### 4. Local CLI Enhancement Configured with Claude/Bedrock
- Analyzed `LocalCLIService.swift` — discovered macOS GUI app env var limitation
- Created wrapper script `~/scripts/voiceink-claude.sh` that sets Bedrock env vars
- Fixed stdin wait issue with `< /dev/null` redirect (saved ~7s per call)
- Made model switchable via UserDefaults key `voiceinkCLIModel` (haiku/sonnet)
- Tested and confirmed working with Haiku 4.5 (~13s per enhancement)
- Chose Option B: keep Ollama/gemma3:4b as default, Claude as high-quality alternative

### 5. Memory Updated
- Created `feedback_backup_first.md` — always backup app as first step
- Created `project_local_cli_enhancement.md` — full Local CLI setup reference
- Updated `project_build_status.md` — reflects v1.73 state and skill availability
- Updated `project_session_history.md` — session 5 with all work items

## Key Decisions

- **Backup policy**: Timestamped backups (keep last 3), mandatory before any changes
- **Local customizations**: Stash/reapply pattern for PromptTemplates.swift
- **whisper.cpp**: Skip rebuild unless release notes specifically mention it
- **Skill naming**: `/update-voiceink` (matches existing naming convention)
- **Enhancement strategy (Option B)**: Ollama/gemma3:4b for daily use (fast/free/offline), Claude via Local CLI for high-quality situations
- **Claude model for enhancement**: Haiku 4.5 by default (fast/cheap), switchable to Sonnet 4.6

## Files Created/Modified This Session

| File | Action | Location |
|------|--------|----------|
| `~/.claude/skills/update-voiceink/SKILL.md` | Created | Skill definition |
| `~/scripts/.../skills/update-voiceink/SKILL.md` | Created | Version-controlled copy |
| `~/scripts/voiceink-claude.sh` | Created | Bedrock wrapper for VoiceInk CLI |
| `~/.claude/projects/.../memory/feedback_backup_first.md` | Created | Memory |
| `~/.claude/projects/.../memory/project_local_cli_enhancement.md` | Created | Memory |
| `~/.claude/projects/.../memory/project_build_status.md` | Updated | Memory |
| `~/.claude/projects/.../memory/project_session_history.md` | Updated | Memory |
| `~/.claude/projects/.../memory/MEMORY.md` | Updated | Memory index |
| `/Applications/VoiceInk.app.backup-20260411-174548` | Created | App backup |
| `/Applications/VoiceInk.app` | Replaced | v1.73 build |

## UserDefaults Changed

| Key | Value | Purpose |
|-----|-------|---------|
| `localCLISelectedTemplate` | `claude` | CLI template selection |
| `localCLICommandTemplate` | `~/scripts/voiceink-claude.sh "$VOICEINK_FULL_PROMPT"` | Command to execute |
| `localCLITimeoutSeconds` | `45` | CLI timeout |
| `voiceinkCLIModel` | `haiku` | Which Bedrock model the wrapper uses |

## Next Steps

- Set up Power Mode per-app profiles (auto-switch Ollama↔Claude per app)
- Test streaming transcription with FluidAudio
- Commit CLAUDE.md and session docs if desired (`/git-project`)
- After validation period, clean up old Ollama models

## Resumption Notes

- VoiceInk is at v1.73, confirmed working
- Two enhancement providers: Ollama/gemma3:4b (default) + Local CLI/Claude (Haiku, switchable to Sonnet)
- Local PromptTemplates.swift has uncommitted customizations (11 templates from prior sessions)
- Future updates: just run `/update-voiceink`
- Switch CLI models: `defaults write com.prakashjoshipax.VoiceInk voiceinkCLIModel -string haiku|sonnet`
