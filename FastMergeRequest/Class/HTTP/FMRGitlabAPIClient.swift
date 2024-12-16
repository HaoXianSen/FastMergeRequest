//
//  FMRNetwork.swift
//  FastMergeRequest
//
//  Created by 郝玉鸿 on 2024/10/28.
//

import Cocoa
import Alamofire

public class FMRGitlabAPIClient {
    
    private let hostCommunicator: FMRHostCommunicator
    
    public var privateToken: String {
        get {
            return hostCommunicator.privateToken
        }
        set {
            hostCommunicator.privateToken = newValue
        }
    }
    public var host: URL {
        get {
            return hostCommunicator.host
        }
        set {
            hostCommunicator.host = newValue
        }
    }
    
    public var userEndpoint: FMRUserEndpointGroup {
        return creatEndpointGroup()
    }
    
    public var brancheEndpoint: FMRBranchEndpointGroup {
        return creatEndpointGroup()
    }
    
    public var mergeRequestEndpoint: FMRMergeRequestEndpointGroup {
        return creatEndpointGroup()
    }
    
    init(hostCommunicator: FMRHostCommunicator) {
        self.hostCommunicator = hostCommunicator
    }
    
    convenience init(host: URL) {
        let privateToken = FMRAccountManager.manager.accountModel?.privateToken
        self.init(hostCommunicator: FMRHostCommunicator(privateToken: privateToken ?? "", host: host))
    }
    
    convenience init(host: URL, privateToken: String) {
        self.init(hostCommunicator: FMRHostCommunicator(privateToken: privateToken, host: host))
    }
    
    convenience init() {
        let privateToken = FMRAccountManager.manager.accountModel?.privateToken
        let host = FMRAccountManager.manager.accountModel?.host ?? "https://gitlab.com"
        let hostURL = URL(string: host)!
        self.init(host: hostURL , privateToken: privateToken ?? "")
    }
    
    private func creatEndpointGroup<T: FMREndpointGroup>() -> T {
        return T(hostCommunicator: self.hostCommunicator)
    }
}
