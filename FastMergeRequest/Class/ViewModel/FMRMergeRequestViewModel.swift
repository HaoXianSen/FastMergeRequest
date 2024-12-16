//
//  FMRMergeRequestViewModel.swift
//  FastMergeRequest
//
//  Created by 郝玉鸿 on 2024/11/15.
//

import Foundation
import RxSwift
import RxRelay
import Alamofire

class FMRMergeRequestViewModel {
    let podfilePath: String
    let developPodsSubject: BehaviorSubject<[FMRPodModel]> = BehaviorSubject(value: [])
    var developPods: [FMRPodModel] {
        do {
            return try self.developPodsSubject.value()
        } catch _ {
            return []
        }
    }
    private(set) var isSelectAll: Bool = true
    private let projectPath: URL
    private let disposeBag = DisposeBag()
    
    
    init(podfilePath: String) {
        self.podfilePath = podfilePath
        self.projectPath = URL(fileURLWithPath: podfilePath).deletingLastPathComponent()
    }
    
   
}

//MARK: - Git project info generation
extension FMRMergeRequestViewModel {
    func getDevelopPods() {
        Observable.combineLatest(parseWorkspaceGit(), parsePodfile())
            .map { (main, developPods) in
                var developPods = developPods
                developPods.insert(main, at: 0)
                return developPods
            }
            .flatMapLatest(getBranches)
            .flatMapLatest(reviewerInfo)
            .subscribe { developPods in
                self.developPodsSubject.onNext(developPods)
            } onError: { error in
                self.developPodsSubject.onError(error)
            }
            .disposed(by: disposeBag)
    }
    
    /// git commond request workspace git info, like current branch、git remote url...
    private func parseWorkspaceGit() -> Observable<FMRPodModel> {
        return Observable<FMRPodModel>.create { anyObserver in
            let disposables = Disposables.create()

            let gitPath = self.projectPath.appending(path:".git")
            let branchCommand = "git --git-dir=\(gitPath.path) branch --show-current"
            let remoteCommand = "git --git-dir=\(gitPath.path) config remote.origin.url"
            
            let mainWorkspaceResult = executeCommand(commond: "\(branchCommand) ; \(remoteCommand)", currentDirectoryURL: self.projectPath)
            
            guard mainWorkspaceResult.error == nil,
                  let output = mainWorkspaceResult.output else {
                anyObserver.onError(NSError(error: "Get \"\(self.projectPath)\" git info error, please check it"))
                return disposables
            }
            let results = output.components(separatedBy: "\n")
            var mainPod = FMRPodModel()
            mainPod.podName = self.projectPath.lastPathComponent
            mainPod.branch = results.count > 0 ? results.first : ""
            mainPod.git = results.count > 1 ? results[1] : ""
            anyObserver.onNext(mainPod)
            anyObserver.onCompleted()
            return disposables
        }
    }
    
    /// Parse Pofile file and find develop pod, in other word，find Podfile branch reference
    private func parsePodfile() -> Observable<[FMRPodModel]> {
        return Observable<[FMRPodModel]>.create { anyObserver in
            let disposables = Disposables.create()
            guard let scriptPath = Bundle.main.path(forResource: "PodfileAnalysis", ofType: "rb") else {
                anyObserver.onError(NSError(error: "System error, Podfile parse script file not exist"))
                return disposables
            }
                                            
            let scriptResult = executeRubyScript(scriptPath: scriptPath, params: self.podfilePath)
            guard scriptResult.error == nil,
                  let output = scriptResult.output,
                  let jsonData = output.data(using: .utf8),
                  let pods =  try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? [[String: Any]] else {
                anyObserver.onError(NSError(error: "Parse pofile error, please ensure Podfile is exist"))
                return disposables
            }
            
            let podsModel = pods.map { dict in
                var pod = FMRPodModel()
                pod.podName = dict["podName"] as! String
                guard let requirements = dict["requirements"] as? [Any] else {
                    return pod
                }
                
                requirements.forEach { requirement in
                    if let version = requirement as? String {
                        pod.version = version
                    } else if let configuration = requirement as? [String: Any] {
                        pod.git = configuration["git"] as? String
                        pod.branch = configuration["branch"] as? String
                        pod.tag = configuration["tag"] as? String
                    }
                }
                return pod
            }
            
            let developPods = podsModel.filter({$0.branch != nil})
            anyObserver.onNext(developPods)
            anyObserver.onCompleted()
            return disposables
                                            
        }
    }
    
    /// gitAPI request all branches
    func getBranches(developPods: [FMRPodModel]) -> Observable<[FMRPodModel]> {
        let observers = developPods.map({FMRGitlabAPIClient().brancheEndpoint.branches(for: $0.encodePath)})
        return Observable.combineLatest(observers).map({ allBranches in
            var newDevelopPods: [FMRPodModel] = []
            for (index, pod) in developPods.enumerated() {
                var newPod = pod
                newPod.targetBranches = allBranches[index]
                newPod.targetBranch = newPod.targetBranches?.first
                newDevelopPods.append(newPod)
            }
            return newDevelopPods
        })
    }
    
    func reviewerInfo(developPods: [FMRPodModel]) -> Observable<[FMRPodModel]> {
        return Observable<[FMRPodModel]>.create { anyObserver in
            let newDevelopPods = developPods.map { pod in
                var newPod = pod
                newPod.reviewers = FMRCache.reviewers()
                newPod.reviewer = newPod.reviewers?.first
                return newPod
            }
            anyObserver.onNext(newDevelopPods)
            anyObserver.onCompleted()
            return Disposables.create()
        }
    }
}

// MARK: - Merge request
extension FMRMergeRequestViewModel {
    /// Create all selected pod merge request
    /// - Returns: return all pod merge request result
    func createMergeRequest() -> Observable<[FMRMergeRequestResult]> {
        Observable<[FMRMergeRequestResult]>.create { anyObserver in
            let needsCreateMergeRequestPods = self.developPods.filter({ $0.checked })
            let mergeReuqestObservables = needsCreateMergeRequestPods.map({ FMRGitlabAPIClient().mergeRequestEndpoint.create(project: $0.encodePath, sourceBranch: $0.branch ?? "", targetBranch: $0.targetBranch?.name ?? "", title: $0.title, assigneeIds: [FMRAccountManager.manager.accountModel?.id ?? 0], reviewerIds: [$0.reviewer?.id ?? 0]).materialize() })
            
            var mergeRequestResults: [FMRMergeRequestResult] = []
            Observable.combineLatest(mergeReuqestObservables)
            .subscribe { events in
                for index in 0..<events.count {
                    switch events[index] {
                        case .next(let data):
                            mergeRequestResults.append(FMRMergeRequestResult(mergeRequest: data, pod: needsCreateMergeRequestPods[index], error: nil))
                    case .error(let error):
                        let error = error as! FMRMergeRequestEndpointGroup.MergeRequestError<FMRMergeRequestModel>
                        var messages = ["unknow error!"]
                        let errorCode = error.error.responseCode ?? -1
                        if let data = error.response.data,
                           let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any],
                           let responseErrorMessages = json["message"] as? [String] {
                            messages = responseErrorMessages
                        }
                        mergeRequestResults.append(FMRMergeRequestResult(mergeRequest: nil, pod: needsCreateMergeRequestPods[index], error: FMRMergeRequestError(errors: messages, code: errorCode)))
                    case .completed: break
                    }
                }
                anyObserver.onNext(mergeRequestResults)
                anyObserver.onCompleted()
            }.disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
}

//MARK: - Selection
extension FMRMergeRequestViewModel {
    func whetherSelectAll() {
        self.isSelectAll = !self.isSelectAll
        let developPods = self.developPods
        let newDevelopPods = developPods.map { pod in
            var newPodfile = pod
            newPodfile.checked = self.isSelectAll
            return newPodfile
        }
        self.developPodsSubject.onNext(newDevelopPods)
    }
    
    func select(index: Int) {
        var developPods = self.developPods
        developPods[index].checked = true
        self.developPodsSubject.onNext(developPods)
    }
    
    func unSelect(index: Int) {
        var developPods = self.developPods
        developPods[index].checked = false
        self.developPodsSubject.onNext(developPods)
    }
}
