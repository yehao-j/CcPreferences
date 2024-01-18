//
//  PreferencesWindowController.swift
//  PreferencesDemo
//
//  Created by niko on 2024/1/15.
//

import Cocoa

public final class CcPreferencesWindowController: NSWindowController {
    private let tabViewController = PreferencesTabViewController()
    private var panes = [CcPreferencePane]()
    private var activeTab: Int?
    private var preferencesStyle: PreferencesStyle!
    /// 是否切换的时候，保持x中心位置不变
    public var isKeepingWindowCentered = false {
        didSet {
            tabViewController.isKeepingWindowCentered = isKeepingWindowCentered
        }
    }
    /// 切换的时候，是否展示切换动画
    public var isAnimated: Bool = true
    ///  单个item是否隐藏toolbar
    public var hidesToolbarForSingleItem: Bool = true {
        didSet {
            updateToolbarVisibility()
        }
    }
    
    private var toolbarItemIdentifiers: [NSToolbarItem.Identifier] {
        var toolbarItemIdentifiers = [NSToolbarItem.Identifier]()
        for pane in panes {
            toolbarItemIdentifiers.append(pane.toolbarItemIdentifier)
        }
        return toolbarItemIdentifiers
    }
    
    public init(preferencePanes: [CcPreferencePane], style: CcPreferences.Style = .toolbarItems) {
        precondition(!preferencePanes.isEmpty, "You need to set at least one view controller")
        
        let window = UserInteractionPausableWindow(contentRect: preferencePanes[0].view.bounds, styleMask: [.titled, .closable], backing: .buffered, defer: true)
        super.init(window: window)
        window.contentViewController = tabViewController
        
        if style == .segmentedControl {
            self.preferencesStyle = SegmentStyle(panes: preferencePanes, delegate: self)
        } else {
            self.preferencesStyle = ToolbarStyle(panes: preferencePanes, delegate: self)
        }
        self.preferencesStyle.addToolbar(window: window)
        tabViewController.window = window
        self.panes = preferencePanes
        
        window.titleVisibility = {
            switch style {
            case .toolbarItems:
                return .visible
            case .segmentedControl:
                return preferencePanes.count <= 1 ? .visible : .hidden
            }
        }()
        
        updateToolbarVisibility()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func show(preferencePane preferenceIdentifier: CcPreferences.PaneIdentifier? = nil) {
        if let preferenceIdentifier = preferenceIdentifier {
            activateTab(preferenceIdentifier: preferenceIdentifier, animated: false)
        } else {
            activateTab(index: 0, animated: false)
        }

        showWindow(self)
        restoreWindowPosition()
        NSApp.activate(ignoringOtherApps: true)
    }
    
    private func updateToolbarVisibility() {
        window?.toolbar?.isVisible = (hidesToolbarForSingleItem == false) || (panes.count > 1)
    }
    
    private func restoreWindowPosition() {
        guard let window = window else { return }
        
        if let screenContainingWindow = window.screen {
            window.setFrameOrigin(CGPoint(x: screenContainingWindow.visibleFrame.midX - window.frame.width / 2, y: screenContainingWindow.visibleFrame.midY - window.frame.height / 2))
        } else {
            window.setFrameOrigin(CGPoint.zero)
        }
        /// 保持上次关闭的位置
        window.setFrameAutosaveName(.preferences)
        window.setFrameUsingName(.preferences)
    }
    
    private func activateTab(preferenceIdentifier: CcPreferences.PaneIdentifier, animated: Bool) {
        guard let index = (panes.firstIndex { $0.preferencePaneIdentifier == preferenceIdentifier }) else {
            return activateTab(index: 0, animated: animated)
        }
        
        activateTab(index: index, animated: animated)
    }
    
    private func activateTab(index: Int, animated: Bool) {
        defer {
            activeTab = index
            if index < panes.count {
                if panes.count > 1 {
                    window?.title = panes[index].preferencePaneTitle
                } else {
                    window?.title = Localization[.preferences]
                }
                
                preferencesStyle.selectTab(index: index)
            }
        }
        
        if activeTab == nil {
            tabViewController.immediatelyDisplayTab(pane: panes[index])
        } else {
            guard index != activeTab else { return }
            
            let from = panes[activeTab!]
            let to = panes[index]
            tabViewController.animateTabTransition(from: from, to: to, animated: animated)
        }
    }
}

extension CcPreferencesWindowController: PreferencesStyleDelegate {
    func switchTab(index: Int) {
        activateTab(index: index, animated: isAnimated)
    }
    
    func switchTab(preferenceIdentifier: CcPreferences.PaneIdentifier) {
        activateTab(preferenceIdentifier: preferenceIdentifier, animated: isAnimated)
    }
}
