import Foundation
import Subprocess

@main
enum Script {
    static func main() async throws {
        let args = Array(CommandLine.arguments.dropFirst())
        guard let target = args.first else {
            fputs("Usage: swift run sub-zip -- <folder-to-zip>\n", stderr)
            exit(64)
        }

        var isDir: ObjCBool = false
        guard FileManager.default.fileExists(atPath: target, isDirectory: &isDir), isDir.boolValue else {
            fputs("Error: \(target) is not a directory\n", stderr)
            exit(66)
        }

        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone(secondsFromGMT: 0)
        df.dateFormat = "yyyyMMdd-HHmmss"
        let ts = df.string(from: Date())
        let zipName = "backup-\(ts).zip"

        let r = try await run(
            .name("zip"),
            arguments: ["-r", zipName, target],
            output: .string(limit: 1 << 22),
            error: .string(limit: 1 << 20)
        )

        let out = r.standardOutput ?? ""
        if !out.isEmpty { print(out) }
        switch r.terminationStatus {
        case .exited(0):
            print("Created \(zipName)")
        default:
            fputs("zip exited with: \(r.terminationStatus)\n", stderr)
            let err = r.standardError ?? ""
            if !err.isEmpty { fputs(err, stderr) }
            exit(1)
        }
    }
}
