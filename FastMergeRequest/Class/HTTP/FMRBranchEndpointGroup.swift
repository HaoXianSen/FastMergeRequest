//
//  FMRBranchEndpointGroup.swift
//  FastMergeRequest
//
//  Created by 郝玉鸿 on 2024/11/15.
//

import Cocoa
import RxSwift

public class FMRBranchEndpointGroup: FMREndpointGroup {
    enum Endpoint {
        case branches(projectPath: String)
        
        func path() -> String {
            switch self {
            case .branches(let projectPath):
                let encodePath = projectPath.replacingOccurrences(of: "/", with: "%2F")
                return "/projects/\(encodePath)/repository/branches"
            }
        }
    }
    
    public func branches(for project: String) -> Observable<[FMRBranchModel]> {
        return self.request(path: Endpoint.branches(projectPath: project).path(), parameters: ["per_page": 100])
    }
}
