//
//  FMRAddReviewerViewModel.swift
//  FastMergeRequest
//
//  Created by 郝玉鸿 on 2024/11/13.
//

import Cocoa
import RxSwift
import RxRelay

class FMRSettingViewModel {
    let reviewers: BehaviorRelay<[FMRUserModel]> = BehaviorRelay(value: [])
    let branches: BehaviorRelay<[String]> = BehaviorRelay(value: [])
    let accounts: BehaviorRelay<[FMRUserModel]> = BehaviorRelay(value: [])
    let disposeBag = DisposeBag()
    
    func loadCacheData() {
        let reviewers: [FMRUserModel] = FMRCache.reviewers()
        let targetBranches: [String]? = FMRCache.cache(for: FMRCache.targetBranchesCacheKey)
        let accoutModels = FMRCache.accountModels()
        self.reviewers.accept(reviewers)
        self.branches.accept(targetBranches?.filter({ !$0.isEmpty }) ?? [])
        self.accounts.accept(accoutModels)
    }
    
    func leave() {
        let reviewers = self.reviewers.value
        FMRCache.syncReviewers(reviewers)
        let targetBranches = self.branches.value.filter({ !$0.isEmpty })
        FMRCache.cache(value: targetBranches, for: FMRCache.targetBranchesCacheKey)
    }
    
}

//MARK: - Reviewers
extension FMRSettingViewModel {
    func removeReviewer(username: String) {
        var reviewersModels = self.reviewers.value
        reviewersModels.removeAll(where: {$0.userName == username})
        reviewers.accept(reviewersModels)
    }
    
    private func addReviewer(with model: FMRUserModel) {
        var reviewersModels = self.reviewers.value
        reviewersModels.append(model)
        reviewers.accept(reviewersModels)
    }
    
    private func replace(username1: String, to user2: FMRUserModel) {
        var reviewersModels = self.reviewers.value
        if let index = reviewersModels.firstIndex(where: { $0.userName == username1 }) {
            let range = index..<index+1
            reviewersModels.replaceSubrange(range, with: [user2])
            reviewers.accept(reviewersModels)
        }
    }
    
    func addReviewer(username: String, completion: @escaping (_ error: Error?) -> Void) {
        getUser(with: username) { user, error in
            if let user = user {
                self.addReviewer(with: user)
                completion(nil)
            } else if let error = error {
                self.reviewers.accept(self.reviewers.value)
                completion(error)
            }
        }
    }
    
    func replace(username1: String, to username2: String, completion: @escaping (_ error: Error?) -> Void) {
        getUser(with: username2) { user, error in
            if let user = user {
                self.replace(username1: username1, to: user)
                completion(nil)
            } else if let error = error {
                self.reviewers.accept(self.reviewers.value)
                completion(error)
            }
        }
        
    }
    
    func getUser(with email: String,  completion: @escaping (_ user: FMRUserModel?, _ error: Error?) -> Void) {
        let client = FMRGitlabAPIClient()
        client.userEndPoint.getUser(with: email).subscribe { userModels in
            guard let userModel = userModels.first else {
                completion(nil, NSError(error: "Can't find \(email) user"))
                return
            }
            
            completion(userModel, nil)
        } onError: { error in
            completion(nil, error)
        }.disposed(by: disposeBag)
    }
}

//MARK: - Branches
extension FMRSettingViewModel {
    func removeBranch(branch: String) {
        var branches = self.branches.value
        branches.removeAll(where: {$0 == branch})
        self.branches.accept(branches)
    }
    
    func addBranch(_ branch: String) {
        guard !isContainedBranch(branch) else {
            self.branches.accept(self.branches.value)
            return
        }
        var branches = self.branches.value
        branches.append(branch)
        self.branches.accept(branches)
    }
    
    func replace(branch: String, to branch2: String) {
        guard !isContainedBranch(branch2) else {
            self.branches.accept(self.branches.value)
            return
        }
        
        var branches = self.branches.value
        if let index = branches.firstIndex(where: { $0 == branch }) {
            let range = index..<index+1
            branches.replaceSubrange(range, with: [branch2])
            self.branches.accept(branches)
        }
        
    }
    
    private func isContainedBranch(_ branch: String) -> Bool {
        return self.branches.value.contains(where: {$0 == branch})
    }
}
