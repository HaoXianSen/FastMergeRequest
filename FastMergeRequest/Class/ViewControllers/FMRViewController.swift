//
//  ViewController.swift
//  FastMergeRequest
//
//  Created by 郝玉鸿 on 2024/8/28.
//

import Cocoa
import RxSwift

extension NSUserInterfaceItemIdentifier {
    static let indexColum = NSUserInterfaceItemIdentifier("indexColumIdentifier")
    static let podNameColum = NSUserInterfaceItemIdentifier("PodNameColumIdentifier")
    static let sourceBranchColum = NSUserInterfaceItemIdentifier("SourceBranchColumIdentifier")
    static let targetBranchColum = NSUserInterfaceItemIdentifier("TargetBranchCloumIdentifier")
    static let assginColum = NSUserInterfaceItemIdentifier("assiginColumIdentifier")
    static let commentColum = NSUserInterfaceItemIdentifier("commentColumnIdentifier")
    
    static let textfiledRow = NSUserInterfaceItemIdentifier("NSTableCellView")
    static let selectionRow = NSUserInterfaceItemIdentifier("FMRMenuTableCell")
    static let checkedRow = NSUserInterfaceItemIdentifier("FMRCheckCell")
    
}

class FMRViewController: NSViewController, FMRNavigationControllerCompatible {
    var navigationController: FMRNavigationController?
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var selectAllButton: NSButton!
    
    var path: String!
    
    private var viewModel: FMRMergeRequestViewModel!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildUI()
        setBindings()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        requestData()
    }
    
    private func buildUI() {
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = .white
        self.tableView.register(NSNib(nibNamed: "FMRMenuTableCell", bundle: nil), forIdentifier: .selectionRow)
    }
    
    private func setBindings() {
        viewModel = FMRMergeRequestViewModel(podfilePath: path)
        viewModel.developPodsSubject.asObserver()
            .skip(1)
            .subscribe { [weak self] developPods in
                guard let self = self else {
                    return
                }
                FMRLoadingView.hide(on: self.view)
                self.tableView.reloadData()
        } onError: { [weak self] error in
            guard let self = self else {
                return
            }
            FMRLoadingView.hide(on: self.view)
            showError(error.localizedDescription, on: self.view.window!, ok: { [weak self] in
                self?.navigationController?.popViewControllerAnimated(true)
            })
        }.disposed(by: disposeBag)
    }
    
    private func requestData() {
        FMRLoadingView.show(hint: "Loading", on: self.view)
        self.viewModel.getDevelopPods()
    }
    
    @IBAction func clickedSelectAll(_ sender: NSButton) {
        sender.title = self.viewModel.isSelectAll ? "Unselect all" : "Select all"
        self.viewModel.whetherSelectAll()
    }
    
    @IBAction func createMergeRequest(_ sender: Any) {
        FMRLoadingView.show(hint: "Creating...", on: self.view)
        self.viewModel.createMergeRequest().subscribe { [weak self] results in
            guard let self = self else {
                return 
            }
            FMRLoadingView.hide(on: self.view)
            let storyboard = NSStoryboard(name: "Main", bundle: nil)
            guard let viewController = storyboard.instantiateController(withIdentifier: "FMRMRResultViewController") as? FMRMRResultViewController else {
                return
            }
            viewController.mrResults = results
            self.presentAsModalWindow(viewController)
        }.disposed(by: self.disposeBag)

    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}

extension FMRViewController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.viewModel.developPods.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let identifier = tableColumn?.identifier else {
            return nil
        }
        
        let pod = self.viewModel.developPods[row]
        if identifier == .indexColum {
            let cell: FMRCheckCell? = getTableCell(from: tableView, id: .checkedRow)
            cell?.clickedCheckBoxFeedback = { [weak self] checked in
                guard let self = self else {
                    return
                }
                self.viewModel.select(index: row)
            }
            cell?.checked = pod.checked
            return cell
        } else if identifier == .podNameColum {
            let cell: NSTableCellView? = getTableCell(from: tableView, id: .textfiledRow)
            cell?.textField?.stringValue = pod.podName
            return cell
        } else if identifier == .sourceBranchColum {
            let cell: NSTableCellView? = getTableCell(from: tableView, id: .textfiledRow)
            cell?.textField?.stringValue = pod.branch ?? "undefined"
            return cell
        } else if identifier == .targetBranchColum {
            var brancheNames = pod.targetBranches?.map({ branch in
                return branch.name ?? ""
            })
            brancheNames?.removeAll(where: {$0.isEmpty})
            let cell: FMRMenuTableCell? = getTableCell(from: tableView, id: .selectionRow)
            cell?.dataSource = brancheNames ?? ["master"]
            return cell
        } else if identifier == .assginColum {
            let cell: FMRMenuTableCell? = getTableCell(from: tableView, id: .selectionRow)
            let names = pod.reviewers?.map({$0.name})
            cell?.dataSource = names ?? []
            return cell
        } else if identifier == .commentColum {
            let cell: NSTableCellView? = getTableCell(from: tableView, id: .textfiledRow)
            cell?.textField?.isEditable = true
            cell?.textField?.stringValue = pod.targetBranch?.commit?.message ?? "Automatically create"
            return cell
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 45
    }
    
    func getTableCell<T>(from tableView: NSTableView, id: NSUserInterfaceItemIdentifier, owner: Any? = FMRViewController.self) -> T? {
        let cell = tableView.makeView(withIdentifier: id, owner: self) as? T
        return cell
    }
}

