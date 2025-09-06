import Subprocess

@main
enum Script {
    static func main() async throws {
        // Temporary: buffered output to keep working with Subprocess 0.1.0.
        // Prints one entry per line via `-1`.
        let result = try await run(
            .name("ls"),
            arguments: ["-1"],
            output: .string(limit: 1 << 20)
        )
        if let out = result.standardOutput, !out.isEmpty {
            print(out)
        }
    }
}
