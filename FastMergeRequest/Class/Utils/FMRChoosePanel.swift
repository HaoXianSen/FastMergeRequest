//
//  FMRChoosePannel.swift
//  FastMergeRequest
//
//  Created by 郝玉鸿 on 2024/12/16.
//

import Cocoa

public class FMRChoosePanel {
    public static func singleDirectorySelectionPanel(title: String, window: NSWindow, completionHandler: @escaping (_ path: URL) -> Void) {
        let panel = NSOpenPanel()
        panel.prompt = title
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.becomesKeyOnlyIfNeeded = true
        panel.beginSheetModal(for: window, completionHandler: { modalResponse in
            if modalResponse != .OK {
                return
            }
            
            let paths = panel.urls
            guard let path = paths.first else {
                return
            }
            
            completionHandler(path)
        })
    }
}
