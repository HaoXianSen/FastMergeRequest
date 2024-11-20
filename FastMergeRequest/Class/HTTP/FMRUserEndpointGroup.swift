//
//  FMRUserAPI.swift
//  FastMergeRequest
//
//  Created by 郝玉鸿 on 2024/11/7.
//

import Cocoa
import RxSwift

public final class FMRUserEndpointGroup: FMREndpointGroup {
    enum Endpoint {
        case currentUser
        case users(username: String)
        
        func path() -> String {
            switch self {
            case .currentUser:
                return "/user"
            case .users(let username):
                return "/users?username=\(username)"
            }
        }
    }
    
    public func getCurrentUser() -> Observable<FMRUserModel> {
         return self.request(path: Endpoint.currentUser.path(), parameters: [:])
    }
    
    public func getUser(with username: String) -> Observable<[FMRUserModel]> {
        return self.request(path: Endpoint.users(username: username).path(), parameters: [:])
    }
    
}
