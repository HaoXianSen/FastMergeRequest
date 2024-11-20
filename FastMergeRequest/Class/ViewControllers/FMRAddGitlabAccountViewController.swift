//
//  FMRAddGitlabAccountViewController.swift
//  FastMergeRequest
//
//  Created by 郝玉鸿 on 2024/10/23.
//

import Cocoa
import RxSwift
import RxCocoa

class FMRAddGitlabAccountViewController: NSViewController {
    let addedUserSubject: PublishRelay<FMRUserModel> = PublishRelay<FMRUserModel>()
    
    private let addAccountViewModel = FMRAddAccountViewModel()
    
    @IBOutlet weak var hostTextField: NSTextField!
    @IBOutlet weak var personAccessKeyTextField: NSTextField!
    @IBOutlet weak var addAccountButton: NSButton!
    @IBOutlet weak var cancelButton: NSButton!

    @IBOutlet weak var warningsView: NSView!
    @IBOutlet weak var warningsLabel: NSTextField!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setRx()
    }
    
    private func setRx() {
        let hostValid = hostTextField.rx.text.orEmpty
            .map({ $0.count > 0 && FMRVerify.validateUrlLegal(url: $0) })
            .share(replay: 1)
        let privateTokenValid = personAccessKeyTextField.rx.text.orEmpty
            .map({$0.count > 0})
            .share(replay: 1)
        let allValid = Observable.combineLatest(hostValid, privateTokenValid)
            .map({$0 && $1})
        allValid.bind(to: addAccountButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        hostValid.bind(to: warningsView.rx.isHidden)
            .disposed(by: disposeBag)
        
        hostValid.map({$0 ? "" : "Host is invalid"})
            .bind(to: warningsLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    
    @IBAction func cancelButtonClicked(_ sender: Any) {
        self.dismiss(nil)
    }

    @IBAction func addAccountButtonClicked(_ sender: Any) {
        self.view.window?.makeFirstResponder(nil)
        
        FMRLoadingView.show(hint: "verifying...", on: self.view)
        let host = self.hostTextField.stringValue
        let privateToken = self.personAccessKeyTextField.stringValue
        
        addAccountViewModel.addAccount(host: host, privateToken: privateToken).subscribe { accountModel in
            FMRLoadingView.hide(on: self.view)
            FMRToast.show(hint: "Verifyed success", in: self.view)
            self.addedUserSubject.accept(accountModel)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.dismiss(nil)
            }
        } onError: { error in
            FMRLoadingView.hide(on: self.view)
            FMRToast.show(hint: "Verifyed failed: \(error.localizedDescription)", in: self.view, delayHide: 4)
        }.disposed(by: disposeBag)
    }
}
