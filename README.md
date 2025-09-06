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
- `swift run thumbs-video -- [thumbnails_dir] [output.mp4]` (defaults: `thumbnails`, `thumbnails.mp4`).
  - Frame rate: 3 fps.
  - Aspect: images keep their aspect ratio and are scaled to fill a 1200x600 frame (cropped as needed; no stretching).
  - If a `thumbnails.txt` file exists, each non-empty, non-comment line is treated as an image URL. The script downloads each URL, converts it to PNG, and stores it as `thumb_0001.png`, `thumb_0002.png`, … in `[thumbnails_dir]`, then builds the video from that numbered PNG sequence.

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
