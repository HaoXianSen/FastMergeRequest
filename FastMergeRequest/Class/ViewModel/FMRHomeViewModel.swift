//
//  FMRHomeViewModel.swift
//  FastMergeRequest
//
//  Created by 郝玉鸿 on 2024/11/20.
//

import Cocoa
import RxSwift
import RxRelay

class FMRHomeViewModel: NSObject {
    let recentOpenedProjectsSubject: BehaviorRelay<[String]> = BehaviorRelay(value: [])
    private let disposeBag = DisposeBag()
    
    func loadRecentOpenedProjects() {
        guard let cacheRecentlyList: [String] = FMRCache.cache(for: FMRCache.recentlyOpenedProjectKey) else {
            return
        }
        recentOpenedProjectsSubject.accept(cacheRecentlyList)
    }
    
    func addProject(projectPath: URL) {
        let podfilePath = projectPath.appending(component: "Podfile")
        var projects = recentOpenedProjectsSubject.value
        let projectPathString = projectPath.path
        projects.removeAll(where: {$0 == projectPathString})
        projects.insert(projectPathString, at: 0)
        FMRCache.cache(value: projects, for: FMRCache.recentlyOpenedProjectKey)
        FMRFileAccessManager.manager.saveFilePermission(path: projectPathString)
        FMRFileAccessManager.manager.saveFilePermission(path: podfilePath.path)
        recentOpenedProjectsSubject.accept(projects)
    }
}
