//
//  FMRAddAccountViewModel.swift
//  FastMergeRequest
//
//  Created by 郝玉鸿 on 2024/11/12.
//

import Cocoa
import RxSwift

class FMRAddAccountViewModel: NSObject {
    private let disposeBag = DisposeBag()
    
    func addAccount(host: String, privateToken: String) -> Observable<FMRUserModel> {
        return Observable<FMRUserModel>.create { anyObserver -> Disposable in
            let disposables = Disposables.create()
            guard !FMRCache.accountModels().contains(where: { $0.privateToken == privateToken }) else {
                anyObserver.onError(NSError(error: "The personal access token has existed"))
                return disposables
            }
            
            guard let hostURL = URL(string: host) else {
                anyObserver.onError(NSError(error: "The host URL is illegal"))
                return disposables
            }
            
            let apiClient = FMRGitlabAPIClient(host: hostURL, privateToken: privateToken)
            apiClient.userEndpoint.getCurrentUser().subscribe { user in
                var newUser = user
                newUser.host = host
                newUser.privateToken = privateToken
                anyObserver.onNext(newUser)
                anyObserver.onCompleted()
            } onError: { error in
                anyObserver.onError(error)
            }.disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
}
