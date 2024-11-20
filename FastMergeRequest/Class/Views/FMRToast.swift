//
//  FMRToast.swift
//  FastMergeRequest
//
//  Created by 郝玉鸿 on 2024/9/2.
//

import Cocoa

class FMRToast: NSView {
    private lazy var containnerView: NSView = getContainnerView()
    private lazy var textLabel: NSTextField = getTextLabel()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        buildUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func show(hint: String, in superView: NSView, delayHide: CGFloat = 2) {
        let toast = FMRToast()
        toast.textLabel.stringValue = hint
        superView.addSubview(toast)
        toast.translatesAutoresizingMaskIntoConstraints = false
        let toastLeading = toast.leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: 0)
        let toastTrailing = toast.trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: 0)
        let toastTop = toast.topAnchor.constraint(equalTo: superView.topAnchor, constant: 0)
        let toastBottom = toast.bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: 0)
        superView.addConstraints([toastLeading, toastTrailing, toastTop, toastBottom])
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayHide) {
            toast.removeFromSuperview()
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        // noting
    }
    
    class func hide(in superView: NSView) {
        let toast = superView.subviews.first(where: {$0 is FMRToast})
        toast?.removeFromSuperview()
    }
    
    private func buildUI() {
        self.wantsLayer = true
        self.layer?.backgroundColor = .clear
        
        addSubview(containnerView)
        containnerView.addSubview(textLabel)
        
        containnerView.translatesAutoresizingMaskIntoConstraints = false
        let containerCenterX = containnerView.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        let containerCenterY = containnerView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        self.addConstraints([containerCenterX, containerCenterY])
        
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        let textLabelLeading = textLabel.leadingAnchor.constraint(equalTo: containnerView.leadingAnchor, constant: 8)
        let textLabelTrailing = textLabel.trailingAnchor.constraint(equalTo: containnerView.trailingAnchor, constant: -8)
        let textLabelTop = textLabel.topAnchor.constraint(equalTo: containnerView.topAnchor, constant: 8)
        let textLabelBottom = textLabel.bottomAnchor.constraint(equalTo: containnerView.bottomAnchor, constant: -8)
        containnerView.addConstraints([textLabelLeading, textLabelTrailing, textLabelTop, textLabelBottom])
    }
    
}

extension FMRToast {
    private func getTextLabel() -> NSTextField {
        let label = NSTextField(labelWithString: "")
        label.backgroundColor = .clear
        label.textColor = .white
        label.font = NSFont.systemFont(ofSize: 14)
        return label
    }
    
    private func getContainnerView() -> NSView {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.cornerRadius = 3
        view.clipsToBounds = true
        view.layer?.backgroundColor = NSColor(white: 0, alpha: 0.8).cgColor
        return view
    }
}
