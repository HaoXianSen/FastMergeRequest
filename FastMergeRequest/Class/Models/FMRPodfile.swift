//
//  FMRPodfile.swift
//  FastMergeRequest
//
//  Created by 郝玉鸿 on 2024/9/4.
//

import Cocoa

struct FMRPodfile {
    var podName: String = ""
    var version: String = ""
    var requirements: FMRPodRequirements?
    var checked: Bool = true
}

struct FMRPodRequirements {
    var git: String?
    var tag: String?
    var subspecs: [String]?
    var branch: String?
    var configurations: [String]?
    var targetBranch: String = "master"
}
