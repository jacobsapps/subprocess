import Subprocess

@main
enum Script {
    static func main() async throws {
        let result = try await run(
            .name("ls"),
            arguments: ["-1"],
            output: .string(limit: 1 << 20)
        )
        print(result.standardOutput ?? "")
    }
}
