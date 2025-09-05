#!/usr/bin/swift

import Foundation

let process = Process()
process.executableURL = URL(fileURLWithPath: "/bin/ls")
process.arguments = [] // add flags if desired, e.g. ["-la"]

let pipe = Pipe()
process.standardOutput = pipe

do {
    try process.run()
    process.waitUntilExit()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    if let output = String(data: data, encoding: .utf8) {
        print(output)
    }
} catch {
    fputs("Error: \(error)\n", stderr)
}

