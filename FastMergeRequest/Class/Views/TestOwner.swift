//
//  TestOwner.swift
//  FastMergeRequest
//
//  Created by 郝玉鸿 on 2024/10/16.
//

import AppKit

class TestOwner: NSView, NibLoadable {
    override func awakeAfter(using coder: NSCoder) -> Any? {
        var views: NSArray? = []
        let nib = NSNib(nibNamed: "FMRConfigurationView", bundle: nil)
        nib?.instantiate(withOwner: nil, topLevelObjects: &views)
//        self.bundle.loadNibNamed(nibName, owner: nil, topLevelObjects: &views)
        guard let views = views,
              views.count > 0 else {
            fatalError("Failed loading the nib named \("FMRConfigurationView") for 'NibLoadable' view of type '\(self)'.")
        }
        
        guard let view = (views.first { $0 is FMRConfigurationView }) as? FMRConfigurationView else {
            fatalError("Did not find 'NibLoadable' view of type '\("FMRConfigurationView")' inside '\("FMRConfigurationView").xib'.")
        }
        self.addSubview(view)
        return self
    }
}
