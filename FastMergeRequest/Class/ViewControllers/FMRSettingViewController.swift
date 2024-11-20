//
//  FMRSettingViewController.swift
//  FastMergeRequest
//
//  Created by 郝玉鸿 on 2024/8/30.
//

import Cocoa
import RxSwift

class FMRSettingViewController: NSViewController {
    @IBOutlet weak var reviewerConfigurationView: FMRConfigurationView!
    @IBOutlet weak var targetBranchConfigurationView: FMRConfigurationView!
    @IBOutlet weak var accountView: FMRAccountView!
    
    private var accountModels: [FMRUserModel] = []
    private let disposeBag = DisposeBag()
    private let viewModel = FMRSettingViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configConfigurationView()
        setBindings()
        viewModel.loadCacheData()
    }
    
    private func configConfigurationView() {
        reviewerConfigurationView.shouldBeginAddNew = {
            if FMRAccountManager.manager.accountModel != nil {
                return true
            } else {
                FMRToast.show(hint: "Please add or select a account first", in: self.view)
                return false
            }
        }
        reviewerConfigurationView.remove = { [weak self] item in
            self?.viewModel.removeReviewer(username: item)
        }
        reviewerConfigurationView.addNew = { [weak self] item in
            guard let self = self else {
                return
            }
            self.viewModel.addReviewer(username: item, completion: { error in
                if let error = error {
                    FMRToast.show(hint: error.localizedDescription, in: self.view)
                }
            })
        }
        reviewerConfigurationView.replace = { [weak self] item1, item2 in
            guard let self = self else {
                return
            }
            self.viewModel.replace(username1: item1, to: item2, completion: { error in
                if let error = error {
                    FMRToast.show(hint: error.localizedDescription, in: self.view)
                }
            })
        }
        
        targetBranchConfigurationView.shouldBeginAddNew = {
            if FMRAccountManager.manager.accountModel != nil {
                return true
            } else {
                FMRToast.show(hint: "Please add or select a account first", in: self.view)
                return false
            }
        }
        targetBranchConfigurationView.remove = { [weak self] item in
            self?.viewModel.removeBranch(branch: item)
        }
        targetBranchConfigurationView.addNew = { [weak self] item in
            self?.viewModel.addBranch(item)
        }
        targetBranchConfigurationView.replace = { [weak self] item1, item2 in
            self?.viewModel.replace(branch: item1, to: item2)
        }
        
        accountView.delegate = self
    }
    
    private func setBindings() {
        viewModel.reviewers.asObservable().map({ $0.map({ $0.userName }) })
            .bind(to: self.reviewerConfigurationView.rx.dataSource)
            .disposed(by: disposeBag)
        
        viewModel.branches.asObservable()
            .bind(to: self.targetBranchConfigurationView.rx.dataSource)
            .disposed(by: disposeBag)
        
        viewModel.accounts.asObservable()
            .bind(to: self.accountView.rx.accountModels)
            .disposed(by: disposeBag)
    }
    
    @IBAction func close(_ sender: Any) {
        viewModel.leave()
        self.dismiss(self)
    }
}

extension FMRSettingViewController: FMRAccountViewDelegate {
    func accountView(_ accountView: FMRAccountView, clickedAddAccountButton button: NSButton) {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        guard let viewController = storyboard.instantiateController(withIdentifier: "FMRAddGitlabAccountViewController") as? FMRAddGitlabAccountViewController else {
            return
        }
        viewController.addedUserSubject.asObservable().subscribe { model in
            var accountModels = self.accountView.accountModels
            accountModels.append(model)
            accountView.accountModels = accountModels
            FMRCache.syncAccountModels(accountModels)
        }.disposed(by: disposeBag)
        self.presentAsModalWindow(viewController)
    }
}
