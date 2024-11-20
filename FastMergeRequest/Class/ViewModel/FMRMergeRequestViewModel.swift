//
//  FMRMergeRequestViewModel.swift
//  FastMergeRequest
//
//  Created by 郝玉鸿 on 2024/11/15.
//

import Foundation
import RxSwift
import RxRelay

class FMRMergeRequestViewModel {
    let podfilePath: String
    let developPodsSubject: BehaviorSubject<[FMRPodfile]> = BehaviorSubject(value: [])
    var developPods: [FMRPodfile] {
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
    
    func getDevelopPods() {
        Observable.combineLatest(parseWorkspaceGit(), parsePodfile()).subscribe { (main, developPods) in
            var developPods = developPods
            developPods.insert(main, at: 0)
            self.developPodsSubject.onNext(developPods)
        } onError: { error in
            self.developPodsSubject.onError(error)
        }.disposed(by: disposeBag)

    }
    
    func parseWorkspaceGit() -> Observable<FMRPodfile> {
        return Observable<FMRPodfile>.create { anyObserver in
            let disposables = Disposables.create()

            let gitPath = self.projectPath.appending(path: ".git")
            let branchCommand = "git --git-dir=\(gitPath.path) branch --show-current"
            let remoteCommand = "git --git-dir=\(gitPath.path) config remote.origin.url"
            
            let mainWorkspaceResult = executeCommand(commond: "\(branchCommand) ; \(remoteCommand)", currentDirectoryURL: self.projectPath)
            
            guard mainWorkspaceResult.error == nil,
                  let output = mainWorkspaceResult.output else {
                anyObserver.onError(NSError(error: "Get \"\(self.projectPath)\" git info error, please check it"))
                return disposables
            }
            let results = output.components(separatedBy: "\n")
            var mainPod = FMRPodfile()
            var mainPodRequirements = FMRPodRequirements()
            mainPod.podName = self.projectPath.lastPathComponent
            mainPodRequirements.branch = results.count > 0 ? results.first : ""
            mainPodRequirements.git = results.count > 1 ? results[1] : ""
            mainPod.requirements = mainPodRequirements
            anyObserver.onNext(mainPod)
            anyObserver.onCompleted()
            return disposables
        }
    }
    
    func parsePodfile() -> Observable<[FMRPodfile]> {
//        FMRLoadingView.show(hint: "", on: self.view)
//        showError(scriptResult.error ?? "Parse pofile error, please ensure Podfile is exist", on: self.view.window!, ok: { [weak self] in
//            self?.delegate?.openHomePage()
//        })
        return Observable<[FMRPodfile]>.create { anyObserver in
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
                var podfile = FMRPodfile()
                podfile.podName = dict["podName"] as! String
                guard let requirements = dict["requirements"] as? [Any] else {
                    return podfile
                }
                
                requirements.forEach { requirement in
                    if let version = requirement as? String {
                        podfile.version = version
                    } else if let configuration = requirement as? [String: Any] {
                        var podRequirement = FMRPodRequirements()
                        podRequirement.git = configuration["git"] as? String
                        podRequirement.branch = configuration["branch"] as? String
                        podRequirement.tag = configuration["tag"] as? String
                        podRequirement.subspecs = configuration["subspecs"] as? [String]
                        podRequirement.configurations = configuration["configurations"] as? [String]
                        podfile.requirements = podRequirement
                    }
                }
                return podfile
            }
            
            let developPods = podsModel.filter({$0.requirements != nil && $0.requirements?.branch != nil})
            anyObserver.onNext(developPods)
            anyObserver.onCompleted()
            return disposables
                                            
        }
    }
    
    func whetherSelectAll() {
        self.isSelectAll = !self.isSelectAll
        let developPods = self.developPods
        let newDevelopPods = developPods.map { podfile in
            var newPodfile = podfile
            newPodfile.checked = self.isSelectAll
            return newPodfile
        }
        self.developPodsSubject.onNext(developPods)
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
