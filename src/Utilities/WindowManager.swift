//
//  WindowManager.swift
//  ClaudeCodeConfig
//
//  Created by weiming on 2025-10-29.
//  Copyright © 2025 weiming. All rights reserved.
//

import SwiftUI
import AppKit
import Combine

/// Manages the application window state and activation
class WindowManager: ObservableObject {
    static let shared = WindowManager()

    private var mainWindow: NSWindow?

    private init() {}

    /// Sets the main application window
    func setMainWindow(_ window: NSWindow) {
        self.mainWindow = window
    }

    /// Activates and brings the window to front
    func activateWindow() {
        DispatchQueue.main.async {
            NSApp.activate(ignoringOtherApps: true)
            if let window = self.mainWindow ?? NSApp.keyWindow {
                window.makeKeyAndOrderFront(nil)
                window.level = .normal
            }
        }
    }

    /// Shows the application window
    func showWindow() {
        DispatchQueue.main.async {
            NSApp.activate(ignoringOtherApps: true)
            if let window = self.mainWindow ?? NSApp.keyWindow {
                window.makeKeyAndOrderFront(nil)
                window.level = .normal
            }
        }
    }

    /// Hides the application window
    func hideWindow() {
        DispatchQueue.main.async {
            if let window = self.mainWindow ?? NSApp.keyWindow {
                window.orderOut(nil)
            }
        }
    }

    /// Minimizes the application window
    func minimizeWindow() {
        DispatchQueue.main.async {
            if let window = self.mainWindow ?? NSApp.keyWindow {
                window.miniaturize(nil)
            }
        }
    }

    /// Gets the current main window
    func getMainWindow() -> NSWindow? {
        return mainWindow
    }

    /// Checks if the window is visible
    func isWindowVisible() -> Bool {
        return mainWindow?.isVisible ?? false
    }
}