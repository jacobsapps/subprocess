#!/usr/bin/swift

import Foundation

let process = Process()
process.executableURL = URL(fileURLWithPath: "/bin/ls")

let pipe = Pipe()
process.standardOutput = pipe

try! process.run()
process.waitUntilExit()
let data = pipe.fileHandleForReading.readDataToEndOfFile()
if let output = String(data: data, encoding: .utf8) {
    print(output)
}
