//
//  FMRConfigurationView.swift
//  FastMergeRequest
//
//  Created by 郝玉鸿 on 2024/10/11.
//

import Cocoa
import AppKit
import RxSwift
import RxRelay

@IBDesignable
class FMRConfigurationView: NibView {
    @IBOutlet weak var configurationTitleLabel: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var containerView: NSView!
    private var _icon = NSImage(named: "icon_reviewer")
    
    var dataSource: [String] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    @IBInspectable var icon: NSImage? {
        get {
            return _icon
        }
        set {
            _icon = newValue
            self.tableView.reloadData()
        }
    }
    
    @IBInspectable var configutationTitle: String? {
        get {
            return configurationTitleLabel.stringValue
        }
        set {
            guard let _ = configurationTitleLabel else {
                return
            }
            guard let title = newValue else {
                configurationTitleLabel.stringValue = "Reviewers"
                return
            }
            configurationTitleLabel.stringValue = title
        }
    }
    
    /// Whether it is allowed to start adding a new one item
    var shouldBeginAddNew: (() -> Bool)!
    /// Remove item
    var remove: ((_ item: String) -> Void)!
    /// Add a new item
    var addNew: ((_ item: String) -> Void)!
    /// Exchange item to anthoer
    var replace: ((_ origin: String, _ new: String) -> Void)!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUI()
    }
    
    private func setUI() {
        self.wantsLayer = true
        self.containerView.wantsLayer = true
        self.containerView.layer?.borderColor = NSColor.separatorColor.cgColor
        self.containerView.layer?.borderWidth = 0.5
        self.containerView.layer?.backgroundColor = NSColor.white.cgColor
    }
    
    @IBAction func addNewMember(_ sender: Any) {
        guard shouldBeginAddNew() else {
            return
        }
        
        if let last = dataSource.last,
           last.isEmpty {
            tableView.editColumn(0, row: dataSource.count - 1, with: nil, select: true)
        } else {
            dataSource.append("")
            tableView.editColumn(0, row: dataSource.count - 1, with: nil, select: true)
        }
        tableView.selectRowIndexes(IndexSet(integer: dataSource.count - 1), byExtendingSelection: true)
    }
    
    @IBAction func removeAMember(_ sender: Any) {
        guard tableView.selectedRow != -1 else {
            return
        }
        guard !dataSource[tableView.selectedRow].isEmpty else {
            dataSource.remove(at: tableView.selectedRow)
            return
        }
        remove(dataSource[tableView.selectedRow])
    }
}

extension FMRConfigurationView: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let id = tableColumn?.identifier else {
            return nil
        }
        
        if id.rawValue == "MembersColumnIdentifier" {
            let cell = tableView.makeView(withIdentifier: id, owner: self) as! NSTableCellView
            cell.textField?.stringValue = dataSource[row]
            cell.textField?.delegate = self
            cell.imageView?.image = _icon
            return cell
        }
        return nil
    }
}

extension FMRConfigurationView: NSTextFieldDelegate {
    func controlTextDidEndEditing(_ obj: Notification) {
        let selectRow = self.tableView.selectedRow
        var dataSource = self.dataSource
        guard let textfield = obj.object as? NSTextField,
              selectRow != -1 else {
            return
        }
        guard !textfield.stringValue.isEmpty else {
            dataSource.remove(at: selectRow)
            self.dataSource = dataSource
            return
        }
        
        let text = textfield.stringValue
        // exchange
        if selectRow != dataSource.count - 1 ||
            (selectRow == dataSource.count - 1 && !dataSource.last!.isEmpty) {
            self.replace(dataSource[selectRow], text)
            return
        }
        // add new
        self.addNew(text)
    }
}
