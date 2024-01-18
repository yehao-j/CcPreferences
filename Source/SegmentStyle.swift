//
//  SegmentStyle.swift
//  PreferencesDemo
//
//  Created by niko on 2024/1/18.
//

import Cocoa

extension NSToolbarItem.Identifier {
    static let toolbarSegmentedControlItem = Self("toolbarSegmentedControlItem")
}

extension NSUserInterfaceItemIdentifier {
    static let toolbarSegmentedControl = Self("toolbarSegmentedControl")
}

class SegmentStyle: NSObject, PreferencesStyle {
    private var panes: [CcPreferencePane]
    private var toolbar: NSToolbar!
    private var segmentControl: NSSegmentedControl!
    private weak var delegate: PreferencesStyleDelegate?
    
    required init(panes: [CcPreferencePane], delegate: PreferencesStyleDelegate) {
        self.panes = panes
        self.delegate = delegate
        super.init()
        self.addSegmentedControl()
    }
    
    private func toolbarItemIdentifiers() -> [NSToolbarItem.Identifier] {
        [.flexibleSpace, .toolbarSegmentedControlItem, .flexibleSpace]
    }
    
    private func addSegmentedControl() {
        let segmentedControl = NSSegmentedControl()
        segmentedControl.segmentCount = panes.count
        segmentedControl.segmentStyle = .texturedSquare
        segmentedControl.target = self
        segmentedControl.action = #selector(segmentedControlSelected)

        if let cell = segmentedControl.cell as? NSSegmentedCell {
            cell.controlSize = .regular
            cell.trackingMode = .selectOne
        }

        let segmentSize: CGSize = {
            let insets = CGSize(width: 36, height: 12)
            var maxSize = CGSize.zero

            for preferencePane in panes {
                let title = preferencePane.preferencePaneTitle
                let titleSize = title.size(withAttributes: [.font: NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .regular))])

                maxSize = CGSize(width: max(titleSize.width, maxSize.width), height: max(titleSize.height, maxSize.height))
            }

            return CGSize(width: maxSize.width + insets.width, height: maxSize.height + insets.height)
        }()

        let segmentBorderWidth = CGFloat(panes.count) + 1
        let segmentWidth = segmentSize.width * CGFloat(panes.count) + segmentBorderWidth
        let segmentHeight = segmentSize.height
        segmentedControl.frame = CGRect(x: 0, y: 0, width: segmentWidth, height: segmentHeight)

        for (index, preferencePane) in panes.enumerated() {
            segmentedControl.setLabel(preferencePane.preferencePaneTitle, forSegment: index)
            segmentedControl.setWidth(segmentSize.width, forSegment: index)
            if let cell = segmentedControl.cell as? NSSegmentedCell {
                cell.setTag(index, forSegment: index)
            }
        }

        self.segmentControl = segmentedControl
    }
    
    @objc private func segmentedControlSelected(_ control: NSSegmentedControl) {
        let index = control.selectedSegment
        delegate?.switchTab(index: index)
    }
    
    func addToolbar(window: NSWindow) {
        toolbar = NSToolbar(identifier: "PreferencesToolbar")
        toolbar.displayMode = .iconAndLabel
        toolbar.delegate = self
        toolbar.allowsUserCustomization = false
        toolbar.showsBaselineSeparator = true
        
        window.toolbar = toolbar
    }
    
    func selectTab(index: Int) {
        segmentControl.selectedSegment = index
    }
}

extension SegmentStyle: NSToolbarDelegate {
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        toolbarItemIdentifiers()
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        toolbarItemIdentifiers()
    }

    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        if itemIdentifier == .flexibleSpace {
            return nil
        }

        let toolbarItemGroup = NSToolbarItemGroup(itemIdentifier: itemIdentifier)
        toolbarItemGroup.view = self.segmentControl
        return toolbarItemGroup
    }
}
