//
//  FMRResponseModel.swift
//  FastMergeRequest
//
//  Created by 郝玉鸿 on 2024/10/30.
//

import Foundation

public struct FMRMergeRequestModel: Codable {
    var id: Int?
    var iid: Int?
    var project_id: Int?
    var title: String?
    var description: String?
    var state: String?
    var created_at: String?
    var target_branch: String?
    var web_url: String?
    var author: FMRUserModel?
    var assignee: FMRUserModel?
    var updated_at: String?
    var merge_error: String?
}

struct FMRMergeRequestError: Codable {
    let errors: [String]
    let code: Int
}

struct FMRMergeRequestResult: Codable {
    let mergeRequest: FMRMergeRequestModel?
    let pod: FMRPodModel
    let error: FMRMergeRequestError?
}
