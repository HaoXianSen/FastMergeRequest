//
//  FMRAccountView.swift
//  FastMergeRequest
//
//  Created by 郝玉鸿 on 2024/10/17.
//

import AppKit
import Kingfisher

protocol FMRAccountViewDelegate: NSObjectProtocol {
    func accountView(_ accountView: FMRAccountView, clickedAddAccountButton button: NSButton)
}

@IBDesignable
class FMRAccountView: NibView {
    @IBOutlet weak var menuItem: NSMenu!
    @IBOutlet weak var popUpButton: NSPopUpButton!
    
    weak var delegate: FMRAccountViewDelegate?
    
    var accountModels: [FMRUserModel] = [] {
        didSet {
            updateData()
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        updateData()
    }
    
    private func updateData() {
        var items = accountModels.map { account in
            let menuItem = NSMenuItem(title: account.userName, action: #selector(handleMenuItemSelect(sender:)), keyEquivalent: "")
            let image = NSImage(named: "gitlab_logo")
            image?.size = NSSize(width: 15, height: 15)
            menuItem.image = image
            menuItem.target = self
            return menuItem
        }
        let addAccountItem = NSMenuItem(title: "Add Account", action: #selector(handleMenuItemSelect(sender:)), keyEquivalent: "")
        addAccountItem.target = self
        items.append(addAccountItem)
        self.menuItem.items = items
        let selectAccount = accountModels.first(where: {$0.select ?? false})
        self.popUpButton.select(items.first(where: {$0.title == selectAccount?.userName}))
    }
    
    @objc
    private func handleMenuItemSelect(sender: NSMenuItem) {
        if sender.title == "Add Account" {
            self.delegate?.accountView(self, clickedAddAccountButton: self.popUpButton)
        } else {
            self.accountModels = self.accountModels.map { model in
                var model = model
                model.select = sender.title == model.userName
                return model
            }
            FMRCache.syncAccountModels(accountModels)
        }
    }
}

final class HeaderFieldModifier: AsyncImageDownloadRequestModifier {
    var onDownloadTaskStarted: (@Sendable (DownloadTask?) -> Void)? { return nil }
    private let token: String
    
    init(token: String) {
        self.token = token
    }
    
    func modified(for request: URLRequest) -> URLRequest? {
        var r = request
        r.setValue(self.token, forHTTPHeaderField: "PRIVATE-TOKEN")
        return r
    }
}
