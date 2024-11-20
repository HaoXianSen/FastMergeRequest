//
//  SourceEditorCommand.swift
//  FastMergeRequestExtension
//
//  Created by 郝玉鸿 on 2024/8/28.
//

import Foundation
import XcodeKit
import AppKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        openPannel()
        completionHandler(nil)
    }
    
    func openPannel() {
//        let configuration = NSWorkspace.OpenConfiguration()
//        configuration.createsNewApplicationInstance = true
//        NSWorkspace.shared.openApplication(at: URL(fileURLWithPath: "FastMergeRequest.app"), configuration: configuration)
        print("\(FileManager.default.currentDirectoryPath)")
        print("\(FileManager.default.homeDirectoryForCurrentUser)")
        NSWorkspace.shared.launchApplication(withBundleIdentifier: "com.youdao.netease.FastMergeRequest", additionalEventParamDescriptor: nil, launchIdentifier: nil)
    }
    
}
