import Foundation
import Subprocess

@main
enum Script {
    static func main() async throws {
        // Usage: swift run thumbs-video -- [thumbnails_dir] [output_file]
        // If a file named "thumbnails.txt" exists in the current directory,
        // each non-empty line is treated as an image URL and downloaded via curl
        // into [thumbnails_dir] (default: "thumbnails"). Then ffmpeg creates
        // a video from the downloaded PNGs.
        let args = Array(CommandLine.arguments.dropFirst())
        let dir = args.first ?? "thumbnails"
        let out = args.dropFirst().first ?? "thumbnails.mp4"

        let urlsFile = "thumbnails.txt"
        if FileManager.default.fileExists(atPath: urlsFile) {
            // Ensure the target directory exists.
            try FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)

            // Read URLs and download each image, converting to sequential PNGs.
            let contents = try String(contentsOfFile: urlsFile, encoding: .utf8)
            let lines = contents.split(whereSeparator: { $0.isNewline })
                .map(String.init)
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty && !$0.hasPrefix("#") }

            if lines.isEmpty {
                fputs("thumbnails.txt is empty.\n", stderr)
                exit(64)
            }

            print("Found thumbnails.txt with \(lines.count) URLs. Downloading to \(dir)...")

            var index = 1
            var downloaded = 0
            for url in lines {
                let tmpPath = dir + "/.dl_\(UUID().uuidString)"
                let destPath = dir + "/" + String(format: "thumb_%04d.png", index)

                // Download to a temporary file
                let dl = try await run(
                    .name("curl"),
                    arguments: ["-sS", "-L", "--fail", "-o", tmpPath, url],
                    output: .string(limit: 1 << 18),
                    error: .string(limit: 1 << 18)
                )
                guard case .exited(0) = dl.terminationStatus else {
                    let err = dl.standardError ?? ""
                    if !err.isEmpty { fputs("curl failed for \(url):\n" + err + "\n", stderr) }
                    _ = try? FileManager.default.removeItem(atPath: tmpPath)
                    continue
                }

                // Convert to PNG (handles JPG/WEBP/etc.)
                let conv = try await run(
                    .name("ffmpeg"),
                    arguments: ["-y", "-i", tmpPath, destPath],
                    output: .string(limit: 1 << 18),
                    error: .string(limit: 1 << 18)
                )
                _ = try? FileManager.default.removeItem(atPath: tmpPath)

                switch conv.terminationStatus {
                case .exited(0):
                    downloaded += 1
                    index += 1
                default:
                    let err = conv.standardError ?? ""
                    if !err.isEmpty { fputs("ffmpeg convert failed for \(url):\n" + err + "\n", stderr) }
                }
            }

            if downloaded == 0 {
                fputs("No images prepared from \(urlsFile).\n", stderr)
                exit(1)
            } else {
                print("Prepared \(downloaded) PNG thumbnails in \(dir).")
            }
        }

        let r = try await run(
            .name("ffmpeg"),
            arguments: [
                "-y",
                "-framerate", "3",
                "-f", "image2",
                "-i", dir + "/thumb_%04d.png",
                // Preserve aspect ratio and fill the 1200x600 frame by cropping as needed (cover)
                "-vf", "scale=1200:600:force_original_aspect_ratio=increase,crop=1200:600",
                "-c:v", "libx264",
                "-pix_fmt", "yuv420p",
                out
            ],
            output: .string(limit: 1 << 20),
            error: .string(limit: 1 << 20)
        )

        switch r.terminationStatus {
        case .exited(0):
            print("Created \(out)")
        default:
            if let err = r.standardError, !err.isEmpty { fputs(err + "\n", stderr) }
            fputs("ffmpeg exited with: \(r.terminationStatus)\n", stderr)
            exit(1)
        }
    }
}
