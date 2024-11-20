//
//  FMRHomeViewController.swift
//  FastMergeRequest
//
//  Created by 郝玉鸿 on 2024/8/29.
//

import Cocoa

class FMRHomeViewController: NSViewController, FMRNavigationControllerCompatible {
    weak var navigationController: FMRNavigationController?
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var openNewProject: NSButton!
    @IBOutlet weak var logoImageView: NSImageView!
    @IBOutlet weak var scrollView: NSScrollView!
    
    private var recentlyProjects: [String] = []
    private let cacheKey = "FMRHomeViewController.recentlyProjectsKey"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
        loadData()
    }
    
    private func buildUI() {
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = .white
        
        self.logoImageView.image = NSImage(named: "app_logo")
        self.logoImageView.imageScaling = .scaleAxesIndependently
    }
    
    private func loadData() {
        guard let cacheRecentlyList = UserDefaults.standard.array(forKey: cacheKey) as? [String] else {
            return
        }
        self.recentlyProjects =  cacheRecentlyList
        self.tableView.reloadData()
    }
    
    private func cacheRecentlyOpenList() {
        UserDefaults.standard.setValue(self.recentlyProjects, forKey: cacheKey)
        UserDefaults.standard.synchronize()
    }
    
    @IBAction func openNewProject(_ sender: Any) {
        openFileSelection()
    }
    
    private func openDirectory(_ path: URL) {
        let podfilePath = path.appending(component: "Podfile")
        if !FileManager.default.fileExists(atPath: podfilePath.path) {
            showError("Podfile can't exist in \(path.absoluteString)", on: self.view.window!)
            return
        }
        
        recentlyProjects.removeAll(where: {$0 == path.path() || $0 == path.path})
        recentlyProjects.insert(path.path, at: 0)
        cacheRecentlyOpenList()
        FMRFileAccessManager.manager.saveFilePermission(path: path.path)
        FMRFileAccessManager.manager.saveFilePermission(path: podfilePath.path)
        openProject(with: podfilePath.path())
        tableView.reloadData()
    }
    
    private func openProject(with path: String) {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        guard let viewController = storyboard.instantiateController(withIdentifier: "FMRViewController") as? FMRViewController else {
            return
        }
        viewController.path = path
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func openFileSelection() {
        let panel = NSOpenPanel()
        panel.prompt = "choose"
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.becomesKeyOnlyIfNeeded = true
        panel.beginSheetModal(for: self.view.window!, completionHandler: { [weak self] modalResponse in
            if modalResponse != .OK {
                return
            }
            
            let paths = panel.urls
            guard let path = paths.first else {
                return
            }
            self?.openDirectory(path)
        })
    }
}

extension FMRHomeViewController: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return recentlyProjects.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let id = tableColumn?.identifier else {
            return nil
        }
        
        if id.rawValue == "FileColumnIdentifier" {
            let cell = tableView.makeView(withIdentifier: id, owner: nil) as! NSTableCellView
            cell.textField?.stringValue = recentlyProjects[row]
            return cell
        }
        
        return nil
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        print("shouldSelectRow")
        return true
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard tableView.selectedRow != -1 else {
            return 
        }
        let path = recentlyProjects[tableView.selectedRow]
        guard let restoreURL = FMRFileAccessManager.manager.accessFile(path: path.appending("/Podfile")),
              let _ = FMRFileAccessManager.manager.accessFile(path: path) else {
            return
        }
        openProject(with: restoreURL.path())
        tableView.deselectRow(tableView.selectedRow)
    }
}
