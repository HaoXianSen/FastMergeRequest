//
//  FMRLoadingView.swift
//  FastMergeRequest
//
//  Created by 郝玉鸿 on 2024/8/29.
//

import Cocoa
import AppKit

class FMRLoadingView: NSView {
    private lazy var textField: NSTextField = getTextField()
    private lazy var progressIndocator: NSProgressIndicator = getProgressIndicator()
    private lazy var containerView: NSView = getContainerView()
    

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        buildUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
    }
    
    override func mouseDown(with event: NSEvent) {
        // do nothing
    }
    
    override func scrollWheel(with event: NSEvent) {
        // do noting
    }
    
    
    static func show(hint: String, on superView: NSView) {
        let loadingView = FMRLoadingView(frame: .zero)
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.textField.stringValue = hint
        superView.addSubview(loadingView)
        let loadingViewLeading = loadingView.leadingAnchor.constraint(equalTo: superView.leadingAnchor)
        let loadingViewTrailing = loadingView.trailingAnchor.constraint(equalTo: superView.trailingAnchor)
        let loadingViewTop = loadingView.topAnchor.constraint(equalTo: superView.topAnchor)
        let loadingViewBottom = loadingView.bottomAnchor.constraint(equalTo: superView.bottomAnchor)
        superView.addConstraints([loadingViewLeading, loadingViewTrailing, loadingViewTop, loadingViewBottom])
        loadingView.progressIndocator.startAnimation(nil)
    }
    
    static func hide(on superView: NSView) {
        guard let loadingView = superView.subviews.first(where: {$0 is FMRLoadingView}) else {
            return
        }
        loadingView.removeFromSuperview()
    }
    
    private func buildUI() {
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor(white: 0, alpha: 0.5).cgColor
        addSubview(containerView)
        containerView.addSubview(progressIndocator)
        containerView.addSubview(textField)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        let containerViewCenterX =  containerView.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        let containerViewCenterY = containerView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        let containerW = containerView.widthAnchor.constraint(equalToConstant: 85)
        let containerH = containerView.heightAnchor.constraint(equalToConstant: 85)
        self.addConstraints([containerViewCenterX, containerViewCenterY, containerW, containerH])
        
        progressIndocator.translatesAutoresizingMaskIntoConstraints = false
        let progressCenterX =  progressIndocator.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        let progressCenterY = progressIndocator.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -8)
        let progressW = progressIndocator.widthAnchor.constraint(equalToConstant: 40)
        let progressH = progressIndocator.heightAnchor.constraint(equalToConstant: 40)
        
        self.addConstraints([progressCenterX, progressCenterY, progressH, progressW])
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        let textfieldLeading = textField.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        let textfieldTrailing = textField.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        let textfieldTop = textField.topAnchor.constraint(equalTo: progressIndocator.bottomAnchor, constant: 8)
        
        self.addConstraints([textfieldLeading, textfieldTrailing, textfieldTop])
    }
    
}

extension FMRLoadingView {
    private func getContainerView() -> NSView {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = .white
        view.layer?.cornerRadius = 8
        view.layer?.masksToBounds = true
        return view
    }
    
    private func getTextField() -> NSTextField {
        let textField = NSTextField(frame: .zero)
        textField.isEditable = false
        textField.isSelectable = false
        textField.textColor = NSColor.black
        textField.stringValue = "loading..."
        textField.alignment = .center
        textField.backgroundColor = .clear
        textField.isBordered = false
        textField.font = NSFont.systemFont(ofSize: 14)
        return textField
    }
    
    private func getProgressIndicator() -> NSProgressIndicator {
        let progressIndocator = NSProgressIndicator(frame: .zero)
        progressIndocator.style = .spinning
        progressIndocator.controlSize = .large
        progressIndocator.sizeToFit()
        return progressIndocator
    }
}
