import Foundation
import Subprocess

@main
enum Script {
    static func main() async throws {
        // Usage: swift run thumbs-video -- [thumbnails_dir] [output_file]
        let args = Array(CommandLine.arguments.dropFirst())
        let dir = args.first ?? "thumbnails"
        let out = args.dropFirst().first ?? "thumbnails.mp4"

        let r = try await run(
            .name("ffmpeg"),
            arguments: [
                "-y",
                "-f", "image2",
                "-pattern_type", "glob",
                "-framerate", "1",
                "-i", dir + "/*.[pP][nN][gG]",
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
