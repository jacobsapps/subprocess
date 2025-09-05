#!/usr/bin/swift

import Foundation

// Usage: ./thumbs-video.swift [thumbnails_dir] [output.mp4]
// Defaults: thumbnails_dir = "thumbnails", output = "thumbnails.mp4"

let args = Array(CommandLine.arguments.dropFirst())
let dir = args.first ?? "thumbnails"
let out = args.dropFirst().first ?? "thumbnails.mp4"
let pattern = dir + "/*.[pP][nN][gG]"

let process = Process()
process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
process.arguments = [
    "ffmpeg",
    "-y",
    // show progress so it doesn't look stuck
    "-stats",
    "-f", "image2",
    "-pattern_type", "glob",
    "-framerate", "1",
    "-i", pattern,
    "-c:v", "libx264",
    "-pix_fmt", "yuv420p",
    out
]

// Stream output directly to the terminal to avoid pipe buffering deadlocks
process.standardOutput = FileHandle.standardOutput
process.standardError = FileHandle.standardError

do {
    try process.run()
    process.waitUntilExit()

    if process.terminationStatus == 0 {
        print("Created \(out)")
        exit(0)
    } else {
        // ffmpeg already wrote errors to stderr
        exit(process.terminationStatus)
    }
} catch {
    fputs("Error: \(error)\n", stderr)
    exit(1)
}
