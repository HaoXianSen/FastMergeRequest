//
//  FMRMenuTableCell.swift
//  FastMergeRequest
//
//  Created by 郝玉鸿 on 2024/10/8.
//

import Cocoa

class FMRMenuTableCell: NSTableCellView {

    @IBOutlet weak var popUpButtonCell: NSPopUpButtonCell!
    @IBOutlet weak var items: NSMenu!
    
    var dataSource: [String] = [] {
        didSet {
            self.setItems()
        }
    }
    
    private func setItems() {
        let menuItems: [NSMenuItem] = dataSource.map { title in
            let item = NSMenuItem()
            item.title = title
            return item
        }
        self.items.items = menuItems
        self.items.selectionMode = .selectOne
        popUpButtonCell.selectItem(at: 0)
    }
    
}

extension FMRMenuTableCell: NSMenuDelegate {
    func numberOfItems(in menu: NSMenu) -> Int {
        return dataSource.count
    }
}
