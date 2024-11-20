//
//  FMREndpointGroup.swift
//  FastMergeRequest
//
//  Created by 郝玉鸿 on 2024/11/11.
//

import Cocoa
import Alamofire
import RxSwift

public class FMREndpointGroup {
    internal enum Endpoint {}
    internal let hostCommunicator: FMRHostCommunicator
    
    public required init(hostCommunicator: FMRHostCommunicator) {
        self.hostCommunicator = hostCommunicator
    }
    
    internal func request<T: Codable>(path: String, method: HTTPMethod = .get, parameters: Parameters) -> Observable<T> {
        return Observable<T>.create { anyObserver -> Disposable in
            let path = self.hostCommunicator.baseURL.appendingPathComponent(path).absoluteString.removingPercentEncoding ?? ""
            let header = self.hostCommunicator.header
            AF.request(path, method: method, parameters: parameters, headers: header)
                .validate()
                .responseDecodable(of: T.self) { response in
                    switch response.result {
                    case .success(let obj):
                        anyObserver.onNext(obj)
                    case .failure(let error):
                        anyObserver.onError(error)
                    }
                    anyObserver.onCompleted()
                }
            return Disposables.create()
        }
    }
    
}
