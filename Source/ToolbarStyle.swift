//
//  ToolbarStyle.swift
//  PreferencesDemo
//
//  Created by niko on 2024/1/18.
//

import Cocoa

class ToolbarStyle: NSObject, PreferencesStyle {
    private var panes: [CcPreferencePane]
    private var toolbar: NSToolbar!
    private weak var delegate: PreferencesStyleDelegate?
    
    required init(panes: [CcPreferencePane], delegate: PreferencesStyleDelegate) {
        self.panes = panes
        self.delegate = delegate
    }
    
    private func toolbarItemIdentifiers() -> [NSToolbarItem.Identifier] {
        var toolbarItemIdentifiers = [NSToolbarItem.Identifier]()
        for preferencePane in panes {
            toolbarItemIdentifiers.append(preferencePane.toolbarItemIdentifier)
        }
        return toolbarItemIdentifiers
    }
    
    func addToolbar(window: NSWindow) {
        toolbar = NSToolbar(identifier: "PreferencesToolbar")
        toolbar.displayMode = .iconAndLabel
        toolbar.delegate = self
        toolbar.allowsUserCustomization = false
        toolbar.showsBaselineSeparator = true
        
        if #available(macOS 11.0, *) {
            window.toolbarStyle = .preference
        }
        window.toolbar = toolbar
    }
    
    func selectTab(index: Int) {
        toolbar.selectedItemIdentifier = panes[index].toolbarItemIdentifier
    }
    
    @objc private func toolbarItemSelected(_ toolbarItem: NSToolbarItem) {
        let preferenceIdentifier = CcPreferences.PaneIdentifier(fromToolbarItemIdentifier: toolbarItem.itemIdentifier)
        delegate?.switchTab(preferenceIdentifier: preferenceIdentifier)
    }
}

extension ToolbarStyle: NSToolbarDelegate {
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        toolbarItemIdentifiers()
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        toolbarItemIdentifiers()
    }
    
    func toolbarSelectableItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        toolbarItemIdentifiers()
    }

    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        if itemIdentifier == .flexibleSpace {
            return nil
        }

        let preferenceIdentifier = CcPreferences.PaneIdentifier(fromToolbarItemIdentifier: itemIdentifier)
        guard let preference = (panes.first { $0.preferencePaneIdentifier == preferenceIdentifier }) else {
            preconditionFailure()
        }

        let toolbarItem = NSToolbarItem(itemIdentifier: preferenceIdentifier.toolbarItemIdentifier)
        toolbarItem.label = preference.preferencePaneTitle
        toolbarItem.image = preference.toolbarItemIcon
        toolbarItem.target = self
        toolbarItem.action = #selector(toolbarItemSelected)
        return toolbarItem
    }
}
