//
//  FMRAccountManager.swift
//  FastMergeRequest
//
//  Created by 郝玉鸿 on 2024/10/28.
//

import Cocoa

class FMRAccountManager: NSObject {
    static let manager = FMRAccountManager()
    
    private var _accountModel: FMRUserModel?
    
    var accountModel: FMRUserModel? {
        set{
            _accountModel = newValue
        }
        get {
            if let model = _accountModel {
                return model
            }
            return FMRCache.accountModels().first(where: { $0.select ?? false })
        }
    }
}
