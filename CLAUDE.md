# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

VoiceInk is a native macOS (14.4+) SwiftUI application that transcribes speech to text using on-device AI models. It uses [whisper.cpp](https://github.com/ggerganov/whisper.cpp) for local transcription via OpenAI's Whisper model — all processing happens offline.

**Source:** Forked/cloned from [Beingpax/VoiceInk](https://github.com/Beingpax/VoiceInk). The project is GPLv3 licensed and not accepting pull requests (fork-and-modify model).

## Quick Reference: When the User Asks to Update or Rebuild VoiceInk

When the user says anything like "update VoiceInk", "rebuild the app", "pull the latest version", or "there's a new release":

1. `cd ~/projects/voiceink && git pull`
2. Try `make local` — if it succeeds, you're done. App is at `/Applications/VoiceInk.app` (or `~/Downloads/VoiceInk.app` if not yet moved).
3. If `make local` fails during the whisper step (CMake Xcode generator error), follow the **Step 2 workaround** below to build whisper.cpp manually, then run `make local` again.
4. If `make local` fails during the VoiceInk Xcode build step, check the Troubleshooting table below.
5. Move the app: `mv ~/Downloads/VoiceInk.app /Applications/`
6. Tell the user: `open /Applications/VoiceInk.app`

If the user says whisper.cpp also changed or you need a clean rebuild:
1. `rm -rf ~/VoiceInk-Dependencies/whisper.cpp/build-apple ~/VoiceInk-Dependencies/whisper.cpp/build-macos`
2. `cd ~/VoiceInk-Dependencies/whisper.cpp && git pull`
3. Follow **Step 2** below to rebuild whisper.cpp, then `cd ~/projects/voiceink && make local`

## Building VoiceInk from Source (Complete Procedure)

This section documents the full end-to-end build process, including workarounds for Xcode 26.x compatibility issues. Follow these steps to build a fresh copy or update to a new release.

### Prerequisites

| Requirement | Install command | Verification |
|-------------|----------------|--------------|
| macOS 14.4+ | — | `sw_vers` |
| Full Xcode (not just CLI tools) | App Store | `xcode-select -p` should show `/Applications/Xcode.app/Contents/Developer` |
| Xcode CLI tools pointed to Xcode | `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer` | `xcodebuild -version` |
| Xcode first launch completed | `xcodebuild -runFirstLaunch` | Required before `xcodebuild -create-xcframework` works |
| Xcode license accepted | `sudo xcodebuild -license accept` | — |
| Git | `brew install git` | `git --version` |
| CMake 3.28+ | `brew install cmake` | `cmake --version` |

**IMPORTANT:** The `sudo` commands (`xcode-select -s`, `xcodebuild -license accept`) require a terminal with password prompts. If running from Claude Code, ask the user to execute these manually via `! <command>`.

### Step 1: Clone or Update the Repository

**Fresh clone:**
```bash
git clone https://github.com/Beingpax/VoiceInk.git ~/projects/voiceink
cd ~/projects/voiceink
```

**Update existing clone:**
```bash
cd ~/projects/voiceink
git pull
```

### Step 2: Build the whisper.cpp XCFramework

The project's `Makefile` includes a `whisper` target that runs whisper.cpp's `build-xcframework.sh`. However, this script uses CMake's Xcode generator which **fails on Xcode 26.x** with the error:

```
CMake Error: Xcode 1.5 not supported.
No CMAKE_C_COMPILER could be found.
```

**Root cause:** CMake 4.x misparses Xcode 26.x version numbers when using the `-G Xcode` generator. The `Unix Makefiles` generator works fine.

**Before attempting `make local`, first check if the stock build works:**
```bash
make check    # Verify prerequisites
make whisper  # Try the stock whisper build
```

**If `make whisper` fails with the Xcode generator error**, use the workaround below. If it succeeds (e.g., whisper.cpp or CMake has been updated), skip to Step 3.

#### Workaround: Build whisper.cpp with Unix Makefiles Generator

This builds a macOS-only (arm64) XCFramework, which is all VoiceInk needs.

**Phase A — Compile whisper.cpp static libraries:**

```bash
cd ~/VoiceInk-Dependencies/whisper.cpp

# Clean previous attempts
rm -rf build-apple build-macos

# Configure with Unix Makefiles instead of Xcode generator
cmake -B build-macos -G "Unix Makefiles" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=13.3 \
    -DCMAKE_OSX_ARCHITECTURES="arm64" \
    -DCMAKE_C_FLAGS="-Wno-macro-redefined -Wno-shorten-64-to-32 -Wno-unused-command-line-argument -g" \
    -DCMAKE_CXX_FLAGS="-Wno-macro-redefined -Wno-shorten-64-to-32 -Wno-unused-command-line-argument -g" \
    -DBUILD_SHARED_LIBS=OFF \
    -DWHISPER_BUILD_EXAMPLES=OFF \
    -DWHISPER_BUILD_TESTS=OFF \
    -DWHISPER_BUILD_SERVER=OFF \
    -DGGML_METAL=ON \
    -DGGML_METAL_EMBED_LIBRARY=ON \
    -DGGML_BLAS_DEFAULT=ON \
    -DGGML_METAL_USE_BF16=ON \
    -DGGML_NATIVE=OFF \
    -DGGML_OPENMP=OFF \
    -DWHISPER_COREML=ON \
    -DWHISPER_COREML_ALLOW_FALLBACK=ON \
    -S .

# Build (uses all CPU cores)
cmake --build build-macos --config Release -j$(sysctl -n hw.ncpu)
```

**Phase B — Assemble the macOS framework structure:**

```bash
# Create versioned framework directory structure
build_dir="build-macos"
fw="whisper"
mkdir -p ${build_dir}/framework/${fw}.framework/Versions/A/{Headers,Modules,Resources}
ln -sf A ${build_dir}/framework/${fw}.framework/Versions/Current
ln -sf Versions/Current/Headers ${build_dir}/framework/${fw}.framework/Headers
ln -sf Versions/Current/Modules ${build_dir}/framework/${fw}.framework/Modules
ln -sf Versions/Current/Resources ${build_dir}/framework/${fw}.framework/Resources
ln -sf Versions/Current/${fw} ${build_dir}/framework/${fw}.framework/${fw}

# Copy headers
cp include/whisper.h ${build_dir}/framework/${fw}.framework/Versions/A/Headers/
for h in ggml.h ggml-alloc.h ggml-backend.h ggml-metal.h ggml-cpu.h; do
    cp ggml/include/$h ${build_dir}/framework/${fw}.framework/Versions/A/Headers/
done

# Create module map
cat > ${build_dir}/framework/${fw}.framework/Versions/A/Modules/module.modulemap << 'EOF'
framework module whisper {
    header "whisper.h"
    header "ggml.h"
    header "ggml-alloc.h"
    header "ggml-backend.h"
    header "ggml-metal.h"
    header "ggml-cpu.h"
    export *
}
EOF

# Create Info.plist
cat > ${build_dir}/framework/${fw}.framework/Versions/A/Resources/Info.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key><string>en</string>
    <key>CFBundleExecutable</key><string>whisper</string>
    <key>CFBundleIdentifier</key><string>org.ggml.whisper</string>
    <key>CFBundleInfoDictionaryVersion</key><string>6.0</string>
    <key>CFBundleName</key><string>whisper</string>
    <key>CFBundlePackageType</key><string>FMWK</string>
    <key>CFBundleShortVersionString</key><string>1.0</string>
    <key>CFBundleVersion</key><string>1</string>
    <key>MinimumOSVersion</key><string>13.3</string>
</dict>
</plist>
EOF
```

**Phase C — Link static libraries into a dynamic framework and create XCFramework:**

Use `-Wl,-all_load` to link all symbols from the static archives (required because ARM NEON symbols live in architecture-specific .o files inside the .a archives).

```bash
# Link into dynamic library (must list .a files explicitly, not via shell expansion)
clang -dynamiclib \
    -install_name @rpath/whisper.framework/Versions/A/whisper \
    -o ${build_dir}/framework/${fw}.framework/Versions/A/${fw} \
    -Wl,-all_load \
    "${build_dir}/ggml/src/libggml-base.a" \
    "${build_dir}/ggml/src/ggml-blas/libggml-blas.a" \
    "${build_dir}/ggml/src/libggml-cpu.a" \
    "${build_dir}/ggml/src/ggml-metal/libggml-metal.a" \
    "${build_dir}/ggml/src/libggml.a" \
    "${build_dir}/src/libwhisper.a" \
    "${build_dir}/src/libwhisper.coreml.a" \
    -framework Foundation -framework Accelerate -framework Metal \
    -framework MetalKit -framework CoreML \
    -lc++ -mmacosx-version-min=13.3 -arch arm64

# Generate debug symbols
mkdir -p ${build_dir}/dSYMs
dsymutil ${build_dir}/framework/${fw}.framework/Versions/A/${fw} \
    -o ${build_dir}/dSYMs/${fw}.dSYM

# Create XCFramework
mkdir -p build-apple
xcodebuild -create-xcframework \
    -framework "$(pwd)/${build_dir}/framework/${fw}.framework" \
    -debug-symbols "$(pwd)/${build_dir}/dSYMs/${fw}.dSYM" \
    -output "$(pwd)/build-apple/whisper.xcframework"
```

**Verify:** `ls ~/VoiceInk-Dependencies/whisper.cpp/build-apple/whisper.xcframework/` should show `Info.plist` and `macos-arm64/`.

**NOTE on static library paths:** If whisper.cpp updates its build structure, the .a file paths in Phase C may change. Run `find build-macos -name "*.a" -type f` to discover the current paths and update the `clang` command accordingly.

### Step 3: Build VoiceInk

Once the XCFramework exists at `~/VoiceInk-Dependencies/whisper.cpp/build-apple/whisper.xcframework`, the Makefile's `make local` command will skip the whisper build step and proceed directly to building VoiceInk:

```bash
cd ~/projects/voiceink
make local
```

This command:
1. Skips `make whisper` (XCFramework already exists)
2. Builds VoiceInk with ad-hoc code signing (no Apple Developer certificate)
3. Uses `LocalBuild.xcconfig` + `VoiceInk.local.entitlements`
4. Sets the `LOCAL_BUILD` Swift compilation flag
5. Copies the final app to `~/Downloads/VoiceInk.app`

**Output on success:** `Build complete! App saved to: ~/Downloads/VoiceInk.app`

### Step 4: Launch

```bash
open ~/Downloads/VoiceInk.app
```

**First launch:** macOS will block the unsigned app. Go to System Settings > Privacy & Security, find the "VoiceInk was blocked" message, click **Open Anyway**. Grant Microphone and Accessibility permissions when prompted.

### Updating to a New Release

```bash
cd ~/projects/voiceink
git pull

# If only VoiceInk source changed (no whisper.cpp changes):
make local

# If whisper.cpp also needs updating (check release notes):
rm -rf ~/VoiceInk-Dependencies/whisper.cpp/build-apple ~/VoiceInk-Dependencies/whisper.cpp/build-macos
cd ~/VoiceInk-Dependencies/whisper.cpp && git pull
# Then repeat Step 2 (whisper build) and Step 3 (make local)
```

### Troubleshooting

| Problem | Solution |
|---------|----------|
| `xcodebuild: error: tool requires Xcode` | `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer` |
| `CMake Error: Xcode 1.5 not supported` | Use Unix Makefiles generator workaround (Step 2) |
| `xcodebuild failed to load a required plug-in` | Run `xcodebuild -runFirstLaunch` |
| `cmake: command not found` | `brew install cmake` |
| Linker errors: undefined symbols (`quantize_row_*`, `ggml_gemm_*`) | Use `-Wl,-all_load` flag when linking (Phase C) — don't extract .o files from archives individually |
| App won't open on first launch | Right-click > Open, or System Settings > Privacy & Security > Open Anyway |
| `sudo` commands fail in Claude Code | Ask user to run `! sudo <command>` in the prompt |

### Key File Paths

| What | Where |
|------|-------|
| VoiceInk source | `~/projects/voiceink/` |
| whisper.cpp clone | `~/VoiceInk-Dependencies/whisper.cpp/` |
| whisper XCFramework | `~/VoiceInk-Dependencies/whisper.cpp/build-apple/whisper.xcframework` |
| Local build derived data | `~/projects/voiceink/.local-build/` |
| Built app (after `make local`) | `~/Downloads/VoiceInk.app` → move to `/Applications/VoiceInk.app` |
| Custom build scripts (workaround) | `~/VoiceInk-Dependencies/build-macos-only.sh`, `~/VoiceInk-Dependencies/link-framework.sh` |
| Local build config | `LocalBuild.xcconfig`, `VoiceInk/VoiceInk.local.entitlements` |

### Other Makefile Commands

```bash
make check          # Verify git, xcodebuild, swift are installed
make all            # Full build (requires Apple Developer cert)
make dev            # Build + run
make whisper        # Clone and build whisper.cpp XCFramework (stock method)
make clean          # Remove ~/VoiceInk-Dependencies and build artifacts
make run            # Launch built app
```

## Architecture

Native macOS SwiftUI app built with Xcode (`.xcodeproj`, not SPM). Key areas:

- **VoiceInk/** — Main app source
  - `VoiceInk.swift` — App entry point and main SwiftUI App struct
  - `AppDelegate.swift` — NSApplicationDelegate lifecycle
  - `CoreAudioRecorder.swift` — Low-level audio capture (largest source file)
  - `Recorder.swift` — Higher-level recording coordination
  - `HotkeyManager.swift` — Global keyboard shortcut handling
  - `MenuBarManager.swift` — macOS menu bar integration
  - `WindowManager.swift` — Window lifecycle management
  - `CursorPaster.swift` — Pastes transcribed text at cursor position
- **VoiceInk/Views/** — SwiftUI views
- **VoiceInk/Models/** — Data models
- **VoiceInk/Services/** — Service layer
- **VoiceInk/Transcription/** — Whisper transcription integration
- **VoiceInk/PowerMode/** — Context-aware app detection and auto-configuration
- **VoiceInk/AppIntents/** — Siri/Shortcuts integration
- **VoiceInkTests/** / **VoiceInkUITests/** — Test targets

## Key Dependencies

Managed via Xcode project (not Package.swift):
- **whisper.cpp** — Core speech-to-text engine (XCFramework, built separately)
- **Sparkle** — Auto-update framework
- **KeyboardShortcuts** / **LaunchAtLogin** — sindresorhus utilities
- **MediaRemoteAdapter** — Media playback control during recording
- **SelectedTextKit** — Get selected text from any app
- **Swift Atomics** — Thread-safe atomic operations

## Local Build Limitations

When built with `make local` (ad-hoc signing, `LOCAL_BUILD` flag):
- No iCloud dictionary sync
- No automatic updates (must `git pull && make local` to update)
- First launch requires: System Settings > Privacy & Security > Open Anyway
- Must grant Microphone and Accessibility permissions
