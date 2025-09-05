#!/usr/bin/swift

import Foundation

let extra = Array(CommandLine.arguments.dropFirst())

let process = Process()
process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
process.arguments = ["diff", "--name-only"] + extra

let outPipe = Pipe()
let errPipe = Pipe()
process.standardOutput = outPipe
process.standardError = errPipe

do {
    try process.run()
    process.waitUntilExit()

    let out = outPipe.fileHandleForReading.readDataToEndOfFile()
    let err = errPipe.fileHandleForReading.readDataToEndOfFile()

    if process.terminationStatus == 0 {
        let text = String(data: out, encoding: .utf8) ?? ""
        // Split on any newline characters
        let files = text.split(whereSeparator: { $0.isNewline })
        print("Changed files: \(files.count)")
        if !files.isEmpty { print(files.joined(separator: "\n")) }
        exit(0)
    } else {
        if let e = String(data: err, encoding: .utf8), !e.isEmpty { fputs(e, stderr) }
        exit(Int32(process.terminationStatus))
    }
} catch {
    fputs("Error: \(error)\n", stderr)
    exit(1)
}
