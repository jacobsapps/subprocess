import Subprocess

@main
enum Script {
    static func main() async throws {
        let result = try await run(.name("ls"), output: .string(limit: 4096))
        let out = result.standardOutput ?? ""
        print(out)
    }
}
