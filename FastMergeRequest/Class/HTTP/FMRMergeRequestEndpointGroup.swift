//
//  FMRMergeRequestEndpointGroup.swift
//  FastMergeRequest
//
//  Created by 郝玉鸿 on 2024/11/15.
//

import Cocoa
import RxSwift
import Alamofire

public class FMRMergeRequestEndpointGroup: FMREndpointGroup {
    enum Endpoint {
        case create(projectPath: String)
        
        func path() -> String {
            switch self {
            case .create(let projectPath):
                let encodePath = projectPath.replacingOccurrences(of: "/", with: "%2F")
                return "/projects/\(encodePath)/merge_requests"
            }
        }
    }
    
    public struct MergeRequestError<T>: Error, Sendable where T: Sendable {
        public let error: AFError
        public let response: AFDataResponse<T>
    }
    
    public func create(project: String, sourceBranch: String, targetBranch: String, title: String, assigneeIds: [Int], reviewerIds: [Int]) -> Observable<FMRMergeRequestModel> {
        return Observable<FMRMergeRequestModel>.create { anyObserver -> Disposable in
            let params: [String: Any] = ["source_branch": sourceBranch,
                          "target_branch": targetBranch,
                          "title": title,
                          "assigneeIds": assigneeIds,
                          "reviewer_ids": reviewerIds]
            self.request(path: Endpoint.create(projectPath: project).path(), method: .post, parameters: params)
                .responseDecodable(of: FMRMergeRequestModel.self) { response in
                    switch response.result {
                    case .success(let obj):
                        anyObserver.onNext(obj)
                    case .failure(let error):
                        anyObserver.onError(MergeRequestError(error: error, response: response))
                    }
                    anyObserver.onCompleted()
                }
            return Disposables.create()
        }
    }
}
