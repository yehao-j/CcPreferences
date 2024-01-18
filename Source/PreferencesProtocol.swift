//
//  PreferencesProtocol.swift
//  PreferencesDemo
//
//  Created by niko on 2024/1/18.
//

import Cocoa

protocol PreferencesStyle: AnyObject {    
    init(panes: [CcPreferencePane], delegate: PreferencesStyleDelegate)
    func addToolbar(window: NSWindow)
    func selectTab(index: Int)
}

protocol PreferencesStyleDelegate: AnyObject {
    func switchTab(preferenceIdentifier: CcPreferences.PaneIdentifier)
    func switchTab(index: Int)
}
