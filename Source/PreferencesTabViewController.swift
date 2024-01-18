//
//  PreferencesTabViewController.swift
//  PreferencesDemo
//
//  Created by niko on 2024/1/15.
//

import Cocoa

class PreferencesTabViewController: NSViewController {
    weak var window: NSWindow!
    var isKeepingWindowCentered = false
    
    override func loadView() {
        view = NSView()
    }
    
    func immediatelyDisplayTab(pane: CcPreferencePane?) {
        guard let pane = pane else { return }
        
        view.addSubview(pane.view)
        setWindowFrame(for: pane)
    }
    
    func animateTabTransition(from: CcPreferencePane?, to: CcPreferencePane?, animated: Bool) {
        guard let from = from, let to = to else { return }
        
        if animated {
            to.view.alphaValue = 0
            view.addSubview(to.view)
            
            NSAnimationContext.runAnimationGroup { context in
                context.allowsImplicitAnimation = true
                context.duration = 0.2
                context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                
                from.view.alphaValue = 0
                to.view.alphaValue = 1
                setWindowFrame(for: to)
            } completionHandler: {
                from.view.removeFromSuperview()
            }
        } else {
            from.view.removeFromSuperview()
            view.addSubview(to.view)
            
            setWindowFrame(for: to)
        }
    }
    
    private func setWindowFrame(for viewController: NSViewController) {
        let newWindowSize = window.frameRect(forContentRect: NSRect(origin: CGPoint.zero, size: viewController.view.bounds.size)).size
        var frame = window.frame
        frame.origin.y += frame.height - newWindowSize.height
        frame.size = newWindowSize
        
        if isKeepingWindowCentered {
            let horizontalDiff = (window.frame.width - newWindowSize.width) / 2
            frame.origin.x += horizontalDiff
        }
        
        window.setFrame(frame, display: false)
    }
}
