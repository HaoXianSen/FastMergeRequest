//
//  FMRCheckCell.swift
//  FastMergeRequest
//
//  Created by 郝玉鸿 on 2024/10/18.
//

import Cocoa

class FMRCheckCell: NSTableCellView {
    var clickedCheckBoxFeedback: ((_ checked: Bool) -> Void)?
    @IBOutlet weak var checkBox: NSButton!
    
    @IBInspectable var checked: Bool {
        get {
            return checkBox.state == .on
        }
        set {
            checkBox.state = newValue ? .on : .off
        }
    }
    
    @IBAction func clickedCheckBox(_ sender: NSButton) {
        clickedCheckBoxFeedback?(checked)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
