//
//  FMRCache.swift
//  FastMergeRequest
//
//  Created by 郝玉鸿 on 2024/10/18.
//

import Cocoa

class FMRCache: NSObject {
    typealias CacheKey = String
    static let reviewersCacheKey: CacheKey = "FMRSettingViewController.cacheKey"
    static let targetBranchesCacheKey: CacheKey = "FMRSettingViewController.targetBranchCacheKey"
    static let accountKey: CacheKey = "FMRSettingViewController.accountKey"
    
    static func cache(value: Any?, for key: CacheKey) {
        UserDefaults.standard.setValue(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    static func cache<T>(for key: CacheKey) -> T? {
        return UserDefaults.standard.value(forKey: key) as? T
    }
}

//MARK: - get or cache objects
extension FMRCache {
    static func objects<T: Codable>(cacheKey: String) -> T? {
        guard let accounts: String = self.cache(for: cacheKey),
              let json = accounts.data(using: .utf8)  else {
            return nil
        }
        
        do {
            let jsonDecoder = JSONDecoder()
            let models = try jsonDecoder.decode(T.self, from: json)
            return models
        } catch(let error) {
           print(error)
        }
        return nil
    }
    
    static func cacheObjects<T: Codable>(cacheKey: String, objects: T) {
        do {
            let jsonEncoder = JSONEncoder()
            jsonEncoder.outputFormatting = .prettyPrinted
            let result = try jsonEncoder.encode(objects)
            let string = String(data: result, encoding: .utf8)
            self.cache(value: string, for: cacheKey)
        } catch (let error) {
            print(error)
        }
    }
}

//MARK: Reviewers
extension FMRCache {
    static func reviewers() -> [FMRUserModel] {
        return objects(cacheKey: self.reviewersCacheKey) ?? []
    }
    
    static func syncReviewers(_ accountModels: [FMRUserModel]) {
        cacheObjects(cacheKey: self.reviewersCacheKey, objects: accountModels)
    }
}


//MARK: - accounts
extension FMRCache {
    static func accountModels() -> [FMRUserModel] {
        return objects(cacheKey: self.accountKey) ?? []
    }
    
    static func syncAccountModels(_ accountModels: [FMRUserModel]) {
        FMRAccountManager.manager.accountModel = accountModels.first(where: { $0.select ?? false })
        cacheObjects(cacheKey: self.accountKey, objects: accountModels)
    }
}
