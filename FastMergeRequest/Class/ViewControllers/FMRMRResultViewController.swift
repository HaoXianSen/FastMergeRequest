//
//  FMRMergeRequestResultViewController.swift
//  FastMergeRequest
//
//  Created by 郝玉鸿 on 2024/12/9.
//

import Cocoa
import AppKit

class FMRMRResultViewController: NSViewController {
    
    @IBOutlet weak var tableView: NSTableView!
    var mrResults: [FMRMergeRequestResult]!
    
    private var exportViewModel: FMRExportViewModel!
    
    @IBOutlet weak var exportButton: NSComboButton!
    @IBOutlet weak var excelMenuItem: NSMenuItem!
    
    @IBOutlet weak var textMenuItem: NSMenuItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
        configurate()
    }
    
    private func buildUI() {
        exportButton.menu.selectionMode = .selectOne
    }
    
    private func configurate() {
        self.exportViewModel = FMRExportViewModel(mrResults: self.mrResults)
    }
    
    @IBAction func exportButtonClicked(_ sender: Any) {
        guard let selectedItem = exportButton.menu.selectedItems.first else {
            return
        }
        
        FMRChoosePanel.singleDirectorySelectionPanel(title: "Export Path", window: self.view.window!) { [weak self] path in
            guard let self = self else {
                return
            }
            FMRLoadingView.show(hint: "Exporting", on: self.view)
            let exportType = FMRExportViewModel.ExportType(rawValue: selectedItem.title) ?? .excel
            self.exportViewModel.export(withType:exportType , destination: path) { error in
                FMRLoadingView.hide(on: self.view)
                if let error = error {
                    FMRToast.show(hint: error.localizedDescription, in: self.view)
                    return
                }
                FMRToast.show(hint: "Export success!", in: self.view)
            }
        }
    }
    
    @IBAction func textMenuItemSelected(_ sender: NSMenuItem) {
        excelMenuItem.state = .off
        textMenuItem.state = .on
    }
    
    @IBAction func excelMenuItemSelected(_ sender: NSMenuItem) {
        excelMenuItem.state = .on
        textMenuItem.state = .off
    }
}

extension FMRMRResultViewController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return mrResults.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let result = mrResults[row]
        guard let identifier = tableColumn?.identifier.rawValue else {
            return nil
        }
        
        if identifier == "podNameColumId" {
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "textTableCellViewId"), owner: self) as! NSTableCellView
            cell.textField?.stringValue = result.pod.podName
            return cell
            
        } else if identifier == "sourceBranchColumId" {
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "textTableCellViewId"), owner: self) as! NSTableCellView
            cell.textField?.stringValue = result.pod.branch ?? "null"
            return cell
            
        } else if identifier == "targetBranchColumId" {
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "textTableCellViewId"), owner: self) as! NSTableCellView
            cell.textField?.stringValue = result.pod.targetBranch?.name ?? "null"
            return cell
        } else if identifier == "reviewerColumId" {
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "textTableCellViewId"), owner: self) as! NSTableCellView
            cell.textField?.stringValue = result.pod.reviewer?.name ?? "null"
            return cell
        } else if identifier == "resultColumId" {
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "textTableCellViewId"), owner: self) as! NSTableCellView
            cell.textField?.stringValue = self.exportViewModel.resultMessage(withModel: result)
            cell.textField?.textColor = self.exportViewModel.isResultOccurredError(withModel: result) ? NSColor.red : NSColor.green
            return cell
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        let result = self.exportViewModel.resultMessage(withModel: mrResults[row])
        let size = result.boundingRect(with: NSSize(width: 100, height: CGFloat.infinity), options: [.usesLineFragmentOrigin], attributes: [.font: NSFont.systemFont(ofSize: 13)])
        return size.height
    }
}
