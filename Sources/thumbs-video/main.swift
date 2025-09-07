import Foundation
import Subprocess

@main
enum Script {
    static func main() async throws {

        let args = Array(CommandLine.arguments.dropFirst())
        let out = args.first ?? "thumbnails.mp4"

        let urls = try readURLs("thumbnails.txt")

        try await shPrepareDir("thumbs_tmp")

        var index = 1
        for url in urls {
            try await shFetchAndConvert(url: url, index: index, into: "thumbs_tmp")
            index += 1
        }

        try await shMakeVideo(from: "thumbs_tmp", output: out, fps: 3)
    }

    /// Read non-empty, non-comment lines from a text file into an array of URLs.
    static func readURLs(_ path: String) throws -> [String] {
        let contents = try String(contentsOfFile: path, encoding: .utf8)
        return contents
            .split(whereSeparator: { $0.isNewline })
            .map(String.init)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && !$0.hasPrefix("#") }
    }

    /// Safely single-quote a string for use in a shell command.
    static func shQuote(_ s: String) -> String {
        return "'" + s.replacingOccurrences(of: "'", with: "'\"'\"'") + "'"
    }

    /// Remove and recreate a directory using shell commands (rm, mkdir).
    static func shPrepareDir(_ path: String) async throws {
        _ = try await run(
            .name("rm"),
            arguments: ["-rf", path],
            output: .string(limit: 1 << 16),
            error: .string(limit: 1 << 16)
        )
        _ = try await run(
            .name("mkdir"),
            arguments: ["-p", path],
            output: .string(limit: 1 << 16),
            error: .string(limit: 1 << 16)
        )
    }

    /// Download a URL to a temp file, convert to a numbered PNG, then delete the temp file.
    static func shFetchAndConvert(url: String, index: Int, into dir: String) async throws {
        let src = "\(dir)/" + String(format: "src_%04d", index)
        let dest = "\(dir)/" + String(format: "thumb_%04d.png", index)
        _ = try await run(
            .name("curl"),
            arguments: ["-fsSL", "-o", src, url],
            output: .string(limit: 1 << 18),
            error: .string(limit: 1 << 18)
        )
        _ = try await run(
            .name("ffmpeg"),
            arguments: ["-y", "-i", src, dest],
            output: .string(limit: 1 << 18),
            error: .string(limit: 1 << 18)
        )
        _ = try await run(
            .name("rm"),
            arguments: ["-f", src],
            output: .string(limit: 1 << 16),
            error: .string(limit: 1 << 16)
        )
    }

    /// Create a video from numbered PNGs at the given FPS with cover-style scaling.
    static func shMakeVideo(from dir: String, output out: String, fps: Int) async throws {
        let vf = "scale=1200:600:force_original_aspect_ratio=increase,crop=1200:600"
        let r = try await run(
            .name("ffmpeg"),
            arguments: [
                "-y",
                "-framerate", String(fps),
                "-f", "image2",
                "-i", "\(dir)/thumb_%04d.png",
                "-vf", vf,
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
            let err = r.standardError ?? ""
            if !err.isEmpty { fputs(err + "\n", stderr) }
            fputs("ffmpeg exited with: \(r.terminationStatus)\n", stderr)
            exit(1)
        }
    }
}
