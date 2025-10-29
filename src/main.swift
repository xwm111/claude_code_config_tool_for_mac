//
//  main.swift
//  ClaudeCodeConfig
//
//  Created by weiming on 2025-10-29.
//  Copyright © 2025 weiming. All rights reserved.
//

import SwiftUI
import Foundation
import AppKit

// MARK: - Application Entry Point

@main
struct cccfgApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: AppConstants.windowWidth, minHeight: AppConstants.windowHeight)
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Configuration") {
                    // Handle new configuration
                }
                .keyboardShortcut("n", modifiers: .command)
            }
        }
    }
}

// MARK: - Application Delegate

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var statusMenu: NSMenu?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupEnvironment()
        setupDockIcon()
        setupStatusItem()
        NSApp.setActivationPolicy(.regular)
    }

    private func setupEnvironment() {
        let currentPath = ProcessInfo.processInfo.environment["PATH"] ?? ""
        let nodePath = AppConstants.nodePath
        let newPath = "\(nodePath):\(currentPath)"
        setenv("PATH", newPath, 1)
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            WindowManager.shared.showWindow()
        }
        return true
    }

    private func setupDockIcon() {
        let iconSize = NSSize(width: 512, height: 512)
        let image = NSImage(size: iconSize)
        image.lockFocus()
        let rect = NSRect(origin: .zero, size: iconSize)
        NSColor.controlAccentColor.setFill()
        NSBezierPath(roundedRect: rect, xRadius: 64, yRadius: 64).fill()
        image.unlockFocus()
        NSApplication.shared.applicationIconImage = image
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            if let icon = NSImage(systemSymbolName: "gear.circle.fill", accessibilityDescription: nil) {
                icon.size = NSSize(width: 16, height: 16)
                button.image = icon
            }
            button.toolTip = AppConstants.appName
        }

        setupMenu()
    }

    private func setupMenu() {
        statusMenu = NSMenu()

        // 显示应用菜单项
        let showItem = NSMenuItem(title: "Show \(AppConstants.appName)", action: #selector(showApp), keyEquivalent: "")
        showItem.target = self
        statusMenu?.addItem(showItem)

        statusMenu?.addItem(NSMenuItem.separator())

        // 启动配置菜单项
        let launchItem = NSMenuItem(title: "启动配置", action: #selector(launchDefaultConfig), keyEquivalent: "l")
        launchItem.keyEquivalentModifierMask = [.command, .shift]
        launchItem.target = self
        statusMenu?.addItem(launchItem)

        statusMenu?.addItem(NSMenuItem.separator())

        // 退出菜单项
        let quitItem = NSMenuItem(title: "退出", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        statusMenu?.addItem(quitItem)

        statusItem?.menu = statusMenu
    }

    @objc private func showApp() {
        WindowManager.shared.showWindow()
    }

    @objc private func launchDefaultConfig() {
        // Launch default configuration logic
        let launcher = CLILauncher()
        let configManager = ConfigManager.shared
        let configs = configManager.loadConfigs()

        if let defaultConfig = configs.first(where: { $0.isDefault }) {
            launcher.launchConfiguration(defaultConfig)
        }
    }

    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}

// MARK: - Window Accessory

struct WindowAccessor: NSViewRepresentable {
    var onWindowOpen: ((NSWindow) -> Void)?

    func makeNSView(context: Context) -> NSView {
        let view = NSView()

        DispatchQueue.main.async {
            if let window = view.window {
                self.onWindowOpen?(window)
            }
        }

        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}

    class Coordinator: NSObject, NSWindowDelegate {
        var parent: WindowAccessor

        init(_ parent: WindowAccessor) {
            self.parent = parent
        }

        func windowDidBecomeKey(_ notification: Notification) {
            if let window = notification.object as? NSWindow {
                WindowManager.shared.setMainWindow(window)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}