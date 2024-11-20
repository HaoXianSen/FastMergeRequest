//
//  FMRCmd.swift
//  FastMergeRequest
//
//  Created by 郝玉鸿 on 2024/9/4.
//

import Cocoa

public typealias CommandResult = (output: String?, error: String?)

public func executeCommand(commond: String, executeURL: URL = URL(fileURLWithPath: "/bin/bash"), currentDirectoryURL: URL? = nil) -> CommandResult {
    let process = Process()
    process.executableURL = executeURL
    process.arguments = ["-c", commond]
    let outputPipe = Pipe()
    let errorPipe = Pipe()
    process.standardOutput = outputPipe
    process.standardError = errorPipe
    process.currentDirectoryURL = currentDirectoryURL
    
    try? process.run()
    process.waitUntilExit()
    
    var outputString: String?
    var errorString: String?
    if let outputData = try? outputPipe.fileHandleForReading.readToEnd() {
        outputString = String(decoding: outputData, as: UTF8.self)
    }
    if let errorData = try? errorPipe.fileHandleForReading.readToEnd() {
        errorString = String(decoding: errorData, as: UTF8.self)
    }
    
    return CommandResult(outputString, errorString)
}


public func executeRubyScript(scriptPath: String, params: String) -> CommandResult {
    let whichRuby = executeCommand(commond: "which ruby")
    guard whichRuby.error == nil,
          let output = whichRuby.output else {
        return whichRuby
    }
    
    return executeCommand(commond: "ruby \(scriptPath) \(params)")
}
