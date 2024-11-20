//
//  ViewController.swift
//  FastMergeRequest
//
//  Created by 郝玉鸿 on 2024/8/28.
//

import Cocoa
import RxSwift

protocol FMRViewControllerDelegate: NSObjectProtocol {
    func openHomePage()
}

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
    
    weak var delegate: FMRViewControllerDelegate?
    var path: String!
    
    private lazy var reviewers: [String] = getReviwers()
    private lazy var targetBranches: [String] = getTargetBranches()
    private var viewModel: FMRMergeRequestViewModel!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildUI()
        setBindings()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.viewModel.getDevelopPods()
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
            self?.tableView.reloadData()
        } onError: { [weak self] error in
            guard let self = self else {
                return
            }
            showError(error.localizedDescription, on: self.view.window!, ok: { [weak self] in
                self?.delegate?.openHomePage()
            })
        }.disposed(by: disposeBag)
    }
    
    @IBAction func clickedSelectAll(_ sender: NSButton) {
        sender.title = self.viewModel.isSelectAll ? "unselect all" : "select all"
        self.viewModel.whetherSelectAll()
    }
    
    @IBAction func back(_ sender: Any) {
        delegate?.openHomePage()
    }
}

extension FMRViewController {
    private func getReviwers() -> [String] {
        return FMRCache.cache(for: FMRCache.reviewersCacheKey) ?? []
    }
    
    private func getTargetBranches() -> [String] {
        return FMRCache.cache(for: FMRCache.targetBranchesCacheKey) ?? []
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
        
        if identifier == .indexColum {
            let cell: FMRCheckCell? = getTableCell(from: tableView, id: .checkedRow)
            cell?.clickedCheckBoxFeedback = { [weak self] checked in
                guard let self = self else {
                    return
                }
                self.viewModel.select(index: row)
            }
            cell?.checked = self.viewModel.developPods[row].checked
            return cell
        } else if identifier == .podNameColum {
            let cell: NSTableCellView? = getTableCell(from: tableView, id: .textfiledRow)
            cell?.textField?.stringValue = self.viewModel.developPods[row].podName
            return cell
        } else if identifier == .sourceBranchColum {
            let cell: NSTableCellView? = getTableCell(from: tableView, id: .textfiledRow)
            cell?.textField?.stringValue = self.viewModel.developPods[row].requirements?.branch ?? "undefined"
            return cell
        } else if identifier == .targetBranchColum {
            let cell: FMRMenuTableCell? = getTableCell(from: tableView, id: .selectionRow)
            cell?.dataSource = targetBranches
            return cell
        } else if identifier == .assginColum {
            let cell: FMRMenuTableCell? = getTableCell(from: tableView, id: .selectionRow)
            cell?.dataSource = reviewers
            return cell
        } else if identifier == .commentColum {
            let cell: NSTableCellView? = getTableCell(from: tableView, id: .textfiledRow)
            cell?.textField?.isEditable = true
            cell?.textField?.stringValue = "Automatically create"
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
