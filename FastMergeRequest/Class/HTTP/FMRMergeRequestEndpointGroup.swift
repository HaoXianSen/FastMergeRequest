//
//  FMRMergeRequestEndpointGroup.swift
//  FastMergeRequest
//
//  Created by 郝玉鸿 on 2024/11/15.
//

import Cocoa
import RxSwift

public class FMRMergeRequestEndpointGroup: FMREndpointGroup {
    enum Endpoint {
        case create(projectPath: String)
        
        func path() -> String {
            switch self {
            case .create(let projectPath):
                let encodePath = projectPath.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? projectPath
                return "/projects/\(encodePath)/merge_requests"
            }
        }
    }
    
    public func create(project: String, sourceBranch: String, targetBranch: String, title: String, assigneeIds: [Int], reviewerIds: [Int]) -> Observable<FMRMergeRequestModel> {
        let params: [String: Any] = ["source_branch": sourceBranch,
                      "target_branch": targetBranch,
                      "title": title,
                      "assigneeIds": assigneeIds,
                      "reviewer_ids": reviewerIds]
        return self.request(path: Endpoint.create(projectPath: project).path(), method: .post, parameters: params)
    }
}
