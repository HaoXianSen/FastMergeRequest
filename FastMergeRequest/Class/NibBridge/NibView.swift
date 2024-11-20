//
//  NibView.swift
//  NibView
//
//  Created by Domas on 10/02/2017.
//  Copyright © 2016 Trafi. All rights reserved.
//
import AppKit

open class NibView: NSView {
    
    open class var nibName: String {
        return String(describing: self)
    }
    
    open class var bundle: Bundle {
        return Bundle(for: self)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        if self.subviews.isEmpty {
            initFromNib()
        }
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    private func initFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nib =  NSNib(nibNamed: type(of: self).nibName, bundle: bundle)
        var views: NSArray? = []
        nib?.instantiate(withOwner: self, topLevelObjects: &views)
        guard let view = views?.first(where:{$0 is NSView}) as? NSView else {
            return
        }
        view.frame = self.bounds
        self.addSubview(view)
    }
}
