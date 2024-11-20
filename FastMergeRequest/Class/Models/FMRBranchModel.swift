//
//  FMRBranchModel.swift
//  FastMergeRequest
//
//  Created by 郝玉鸿 on 2024/11/15.
//

import Foundation

public struct FMRBranchModel: Codable {
    var name: String?
    var merged: Bool?
    var protected: Bool?
    var `default`: Bool?
    var developers_can_push: Bool?
    var developers_can_merge: Bool?
    var can_push: Bool?
    var web_url: String?
    var commit: FMRCommitModel?
}

struct FMRCommitModel: Codable {
    var author_email: String?
    var author_name: String?
    var authored_date: String?
    var committed_date: String?
    var committer_email: String?
    var committer_name: String?
    var id: String?
    var short_id: String?
    var title: String?
    var message: String?
    var parent_ids: Array<String>?
}
