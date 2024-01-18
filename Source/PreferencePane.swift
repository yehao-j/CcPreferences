//
//  PreferencePane.swift
//  PreferencesDemo
//
//  Created by niko on 2024/1/15.
//

import Cocoa

public enum CcPreferences {}

extension CcPreferences {
    public struct PaneIdentifier: Hashable, RawRepresentable, Codable {
        public let rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
}

extension CcPreferences {
    public enum Style {
        case toolbarItems
        case segmentedControl
    }
}

extension CcPreferences.PaneIdentifier {
    public init(_ rawValue: String) {
        self.init(rawValue: rawValue)
    }

    public init(fromToolbarItemIdentifier itemIdentifier: NSToolbarItem.Identifier) {
        self.init(rawValue: itemIdentifier.rawValue)
    }

    public var toolbarItemIdentifier: NSToolbarItem.Identifier {
        NSToolbarItem.Identifier(rawValue)
    }
}

public protocol CcPreferencePane: NSViewController {
    var preferencePaneIdentifier: CcPreferences.PaneIdentifier { get }
    var preferencePaneTitle: String { get }
    var toolbarItemIcon: NSImage { get }
}

extension CcPreferencePane {
    public var toolbarItemIdentifier: NSToolbarItem.Identifier {
        preferencePaneIdentifier.toolbarItemIdentifier
    }

    public var toolbarItemIcon: NSImage { .empty }
}
