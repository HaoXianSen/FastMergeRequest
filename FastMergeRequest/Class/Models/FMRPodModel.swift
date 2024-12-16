//
//  FMRPodModel.swift
//  FastMergeRequest
//
//  Created by 郝玉鸿 on 2024/9/4.
//

import Cocoa

struct FMRPodModel: Codable {
    var podName: String = ""
    var version: String = ""
    var git: String? {
        didSet {
            encodePath = getGitPathCode(with: git)
        }
    }
    var branch: String?
    var targetBranch: FMRBranchModel?
    var targetBranches: [FMRBranchModel]?
    var tag: String?
    var checked: Bool = true
    var reviewers: [FMRUserModel]?
    var reviewer: FMRUserModel?
    var title = "auto merge request"
    private(set) var encodePath: String = ""
    
    /// get path of git project
    private func getGitPathCode(with git: String?) -> String{
        guard let git = git,
              !git.isEmpty else {
            return ""
        }
        var newGit = git
        if git.hasPrefix("git@") {
            newGit = newGit.replacingOccurrences(of: ":", with: "/").replacingOccurrences(of: "git@", with: "https://")
        }
        guard var gitURL = URL(string: newGit) else {
            return ""
        }
        gitURL = gitURL.deletingPathExtension()
        var path = gitURL.path()
        path.removeFirst()
        return path
    }
}
