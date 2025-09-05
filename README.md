# swift-subprocess Quick Start

### Old-style scripts (no build):
- `./old_process_api/ls.swift`
- `./old_process_api/zipdir.swift <folder>`
- `./old_process_api/git-diff.swift` (e.g., `--cached`)
- `./old_process_api/thumbs-video.swift [thumbnails_dir] [output.mp4]` (defaults: `thumbnails`, `thumbnails.mp4`)

### Subprocess demos (SwiftPM):
- `swift run ls` (flags: `swift run ls -- -la`)
- `swift run zipdir -- <folder>`
- `swift run git-diff` (extra: `--cached`)
- `swift run thumbs-video -- [thumbnails_dir] [output.mp4]` (defaults: `thumbnails`, `thumbnails.mp4`, duration 10s) 

### Prerequisites:
- FFmpeg is required for both `thumbs-video` variants: `brew install ffmpeg`.

### Quieter runs:
- Build once: `swift build -c release`
- Run binary: `$(swift build -c release --show-bin-path)/ls`

## Open in Xcode:
- From Terminal: `xed .` (or `open Package.swift`).
- Or in Xcode: File → Open… and select the folder with `Package.swift`.
- Choose a scheme (`ls`, `zipdir`, `git-diff`, `thumbs-video`) and Run.
- Pass arguments via Product → Scheme → Edit Scheme… → Run → Arguments.

## Notes

- Requires macOS 13 for Subprocess.
- `swift-subprocess` is pinned to release 0.1.0 in `Package.swift`
 - Old-style scripts use Foundation's `Process` API and run directly with shebang.
