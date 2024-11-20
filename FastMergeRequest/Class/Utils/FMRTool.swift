//
//  FMRTool.swift
//  FastMergeRequest
//
//  Created by 郝玉鸿 on 2024/9/5.
//

import Foundation
import Cocoa

public func showError(_ information: String, on window: NSWindow, ok: (()->Void)? = nil) {
    let alert = NSAlert()
    alert.messageText = "提示"
    alert.informativeText = information
    alert.alertStyle = .warning
    alert.icon = NSImage(named: "app_logo")
    alert.beginSheetModal(for: window) { response in
        if response.rawValue == 0 {
            ok?()
        }
    }
}

extension NSError {
    convenience init(error: String) {
        self.init(domain: "com.netease.FastMergeRequest", code: 10001, userInfo: [NSLocalizedDescriptionKey: error])
    }
}
