//
//  FMRFileAccessManager.swift
//  FastMergeRequest
//
//  Created by 郝玉鸿 on 2024/9/6.
//

import Foundation
import Cocoa

class FMRFileAccessManager: NSObject {
    static let manager = FMRFileAccessManager()
    
    func saveFilePermission(path: String) {
        let fileURL = URL(fileURLWithPath: path)
        let data = try? fileURL.bookmarkData(options: .withSecurityScope)
        UserDefaults.standard.setValue(data, forKey: path)
    }
    
    func accessFile(path: String) -> URL? {
        guard let data = UserDefaults.standard.data(forKey: path) else {
            return nil
        }
        
        var stable = false
        let restoreURL = try? URL(resolvingBookmarkData: data, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &stable)
        let _ = restoreURL?.startAccessingSecurityScopedResource()
        return restoreURL
    }
}
