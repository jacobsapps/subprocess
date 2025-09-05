import Foundation
import Subprocess

@main
enum Script {
    static func main() async throws {
        let extra = Array(CommandLine.arguments.dropFirst())
        let args = ["diff", "--name-only"] + extra

        let r = try await run(
            .name("git"),
            arguments: Arguments(args),
            output: .string(limit: 1 << 22),
            error: .string(limit: 1 << 20)
        )

        switch r.terminationStatus {
        case .exited(0):
            let out = r.standardOutput ?? ""
            let lines = out.split(separator: "\n").map(String.init)
            print("Changed files: \(lines.count)")
            if !lines.isEmpty { print(lines.joined(separator: "\n")) }
        default:
            let err = r.standardError ?? ""
            if !err.isEmpty { fputs(err, stderr) }
            fputs("git exited with: \(r.terminationStatus)\n", stderr)
            exit(1)
        }
    }
}
