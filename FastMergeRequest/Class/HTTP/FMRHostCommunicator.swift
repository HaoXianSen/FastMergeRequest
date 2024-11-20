//
//  FMRHostCommunicator.swift
//  FastMergeRequest
//
//  Created by 郝玉鸿 on 2024/11/11.
//

import Cocoa
import Alamofire

public class FMRHostCommunicator: NSObject {
    public var privateToken: String
    public var host: URL
    public var apiVersion: String {
        return "api/v4"
    }
    
    public var header: HTTPHeaders {
        return ["PRIVATE-TOKEN": privateToken]
    }
    
    public var baseURL: URL {
        return host.appendingPathComponent(apiVersion)
    }
    
    public init(privateToken: String, host: URL) {
        self.privateToken = privateToken
        self.host = host
    }
}
