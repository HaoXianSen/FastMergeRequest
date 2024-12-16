//
//  FMRExportViewModel.swift
//  FastMergeRequest
//
//  Created by 郝玉鸿 on 2024/12/12.
//

import Cocoa
import SwiftXLSX

class FMRExportViewModel {
    enum ExportType: String {
        case excel = "Excel"
        case text = "Text"
    }
    
    enum ExcelFilterType {
        case success
        case failed
    }
    
    let mrResults: [FMRMergeRequestResult]
    
    init(mrResults: [FMRMergeRequestResult]) {
        self.mrResults = mrResults
    }
    
    func export(withType exportType: ExportType, destination: URL, completionHandler: (_ error: Error?) -> Void) {
        switch exportType {
        case .excel:
            expertXLSX(destination: destination, completionHandler: completionHandler)
        case .text:
            exportTxt(destination: destination, completionHandler: completionHandler)
        }
    }
    
    func isResultOccurredError(withModel result: FMRMergeRequestResult) -> Bool {
        if let _ = result.error {
            return true
        } else if let requestModel = result.mergeRequest,
                  let _ = requestModel.web_url {
            return false
        } else {
            return true
        }
    }
    
    func resultMessage(withModel result: FMRMergeRequestResult) -> String {
        if let error = result.error {
            let errors = error.errors.joined(separator: "\n")
            return "Failed \ncode: \(error.code) \nerror: \(errors)"
        } else if let requestModel = result.mergeRequest, let web_url = requestModel.web_url {
            return "Success: \(web_url)"
        } else {
            return "Failed: \ncode: -1 \nerror: undefined error"
        }
    }
    
    private func expertXLSX(destination: URL, completionHandler: (_ error: Error?) -> Void) {
        let book = XWorkBook()
        buildSheet(withBook: book, filterType: .success)
        buildSheet(withBook: book, filterType: .failed)
        let path = book.save("mergeRequestResult.xlsx")
        let pathURL = URL(fileURLWithPath: path)
        let destinationURL = destination.appending(path: "mergeRequestResult.xlsx")
        print(pathURL)
        print(destinationURL)
        
        do {
            try FileManager.default.moveItem(at: pathURL, to: destinationURL)
        } catch let error {
            completionHandler(error)
            return
        }
        
        completionHandler(nil)
    }
    
    private func buildSheet(withBook book: XWorkBook, filterType: ExcelFilterType)  {
        let sheet = book.NewSheet(filterType == .success ? "Success" : "Failed")
        
        let filterResults = filterType == .success ? mrResults.filter({ $0.error == nil && $0.mergeRequest != nil}) : mrResults.filter({ $0.error != nil })
        
        let columnTitles = ["Pod Name", "Source Branch", "TargetBranch", "Reviewer", "Result"]
        
        for index in 1..<columnTitles.count+1 {
            let cell = sheet.AddCell(XCoords(row: 1, col: index))
            cell.value = .text(columnTitles[index-1])
            cell.Cols(txt: .white, bg: .blue)
            cell.alignmentHorizontal = .center
            cell.alignmentVertical = .center
            cell.Font = XFont(.TrebuchetMS, 13)
        }
        
        for row in 2..<filterResults.count+2 {
            let result = filterResults[row - 2];
            let branch = result.pod.branch ?? "null"
            let targetBranch = result.pod.targetBranch?.name ?? "null"
            let reviewer = result.pod.reviewer?.name ?? ""
            let resultMsg = resultMessage(withModel: result)
            let columsTitles = [result.pod.podName, branch, targetBranch, reviewer, resultMsg]
            for column in 1..<columsTitles.count+1 {
                let cell = sheet.AddCell(XCoords(row: row, col: column))
                cell.value = .text(columsTitles[column-1])
                cell.alignmentHorizontal = .center
                cell.alignmentVertical = .center
                cell.Border = true
            }
        }
        
        sheet.ForColumnSetWidth(1, 100)
        sheet.ForColumnSetWidth(2, 100)
        sheet.ForColumnSetWidth(3, 100)
        sheet.ForColumnSetWidth(4, 100)
        sheet.ForColumnSetWidth(5, 250)
        sheet.buildindex()
    }
    
    private func exportTxt(destination: URL, completionHandler: (_ error: Error?) -> Void) {
        let success = mrResults.filter({ $0.error == nil && $0.mergeRequest != nil})
        let failed =  mrResults.filter({ $0.error != nil })
        
        var text = ""
        let columnTitles = ["Pod Name", "Source Branch", "TargetBranch", "Reviewer", "Result"]
        for index in 0..<columnTitles.count {
            text.append("\t")
            text.append(columnTitles[index])
            if index == columnTitles.count - 1 {
                text.append("\n")
            }
        }
        
        for index in 0..<success.count {
            let result = success[index];
            let branch = result.pod.branch ?? "null"
            let targetBranch = result.pod.targetBranch?.name ?? "null"
            let reviewer = result.pod.reviewer?.name ?? ""
            let resultMsg = resultMessage(withModel: result)
            let columsTitles = [result.pod.podName, branch, targetBranch, reviewer, resultMsg]
            for column in 0..<columsTitles.count {
                text.append("\t")
                text.append(columsTitles[column])
            }
            text.append("\n")
        }
        
        for index in 0..<failed.count {
            let result = failed[index];
            let branch = result.pod.branch ?? "null"
            let targetBranch = result.pod.targetBranch?.name ?? "null"
            let reviewer = result.pod.reviewer?.name ?? ""
            let resultMsg = resultMessage(withModel: result)
            let columsTitles = [result.pod.podName, branch, targetBranch, reviewer, resultMsg]
            for column in 0..<columsTitles.count {
                text.append("\t")
                text.append(columsTitles[column])
            }
            text.append("\n")
        }
        
        let destinationURL = destination.appending(path: "mergeRequestResult.txt")
        do {
            try text.write(to: destinationURL, atomically: true, encoding: .utf8)
        } catch let error {
            completionHandler(error)
            return
        }
        completionHandler(nil)
    }
    
}
