#!/usr/bin/swift

import Foundation

func printUsageAndExit() -> Never {
    fputs("Usage: ./zipdir.swift <folder-to-zip>\n", stderr)
    exit(64)
}

let args = Array(CommandLine.arguments.dropFirst())
guard let target = args.first else { printUsageAndExit() }

let fm = FileManager.default
var isDir: ObjCBool = false
guard fm.fileExists(atPath: target, isDirectory: &isDir), isDir.boolValue else {
    fputs("Error: \(target) is not a directory\n", stderr)
    exit(66)
}

let df = DateFormatter()
df.locale = Locale(identifier: "en_US_POSIX")
df.timeZone = TimeZone(secondsFromGMT: 0)
df.dateFormat = "yyyyMMdd-HHmmss"
let ts = df.string(from: Date())

let zipName = "backup-\(ts).zip"

let process = Process()
process.executableURL = URL(fileURLWithPath: "/usr/bin/zip")
process.arguments = ["-r", zipName, target]

let outPipe = Pipe()
let errPipe = Pipe()
process.standardOutput = outPipe
process.standardError = errPipe

do {
    try process.run()
    process.waitUntilExit()
    let outData = outPipe.fileHandleForReading.readDataToEndOfFile()
    let errData = errPipe.fileHandleForReading.readDataToEndOfFile()
    if let s = String(data: outData, encoding: .utf8), !s.isEmpty { print(s) }
    if process.terminationStatus == 0 {
        print("Created \(zipName)")
        exit(0)
    } else {
        if let e = String(data: errData, encoding: .utf8), !e.isEmpty { fputs(e, stderr) }
        exit(Int32(process.terminationStatus))
    }
} catch {
    fputs("Error: \(error)\n", stderr)
    exit(1)
}

