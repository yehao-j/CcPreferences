//
//  Utilities.swift
//  PreferencesDemo
//
//  Created by niko on 2024/1/17.
//

import Cocoa

extension NSWindow.FrameAutosaveName {
    static let preferences: NSWindow.FrameAutosaveName = "com.sindresorhus.Preferences.FrameAutosaveName"
}

extension NSView {
    @discardableResult
    func constrainToSuperviewBounds() -> [NSLayoutConstraint] {
        guard let superview = superview else {
            preconditionFailure("superview has to be set first")
        }

        var result = [NSLayoutConstraint]()
        result.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": self]))
        result.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": self]))
        translatesAutoresizingMaskIntoConstraints = false
        superview.addConstraints(result)

        return result
    }
}

extension NSEvent {
    /// Events triggered by user interaction.
    static let userInteractionEvents: [NSEvent.EventType] = {
        var events: [NSEvent.EventType] = [
            .leftMouseDown,
            .leftMouseUp,
            .rightMouseDown,
            .rightMouseUp,
            .leftMouseDragged,
            .rightMouseDragged,
            .keyDown,
            .keyUp,
            .scrollWheel,
            .tabletPoint,
            .otherMouseDown,
            .otherMouseUp,
            .otherMouseDragged,
            .gesture,
            .magnify,
            .swipe,
            .rotate,
            .beginGesture,
            .endGesture,
            .smartMagnify,
            .quickLook,
            .directTouch
        ]

        if #available(macOS 10.10.3, *) {
            events.append(.pressure)
        }

        return events
    }()

    /// Whether the event was triggered by user interaction.
    var isUserInteraction: Bool { NSEvent.userInteractionEvents.contains(type) }
}

class UserInteractionPausableWindow: NSWindow { // swiftlint:disable:this final_class
    var isUserInteractionEnabled = true

    override func sendEvent(_ event: NSEvent) {
        guard isUserInteractionEnabled || !event.isUserInteraction else {
            return
        }

        super.sendEvent(event)
    }

    override func responds(to selector: Selector!) -> Bool {
        // Deactivate toolbar interactions from the Main Menu.
        if selector == #selector(NSWindow.toggleToolbarShown(_:)) {
            return false
        }

        return super.responds(to: selector)
    }
}

extension NSImage {
    static var empty: NSImage { NSImage(size: .zero) }
}
