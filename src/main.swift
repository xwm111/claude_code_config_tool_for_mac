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

        // 背景 - 深色赛博朋克背景
        let backgroundGradient = NSGradient(colors: [
            NSColor(red: 0.1, green: 0.0, blue: 0.2, alpha: 1.0),    // 深紫
            NSColor(red: 0.05, green: 0.0, blue: 0.15, alpha: 1.0),   // 深蓝紫
            NSColor(red: 0.02, green: 0.0, blue: 0.1, alpha: 1.0)     // 更深
        ])
        backgroundGradient?.draw(in: rect, angle: 45)

        // 外边框 - 霓虹蓝边框
        let borderPath = NSBezierPath(roundedRect: rect.insetBy(dx: 20, dy: 20), xRadius: 48, yRadius: 48)
        NSColor(red: 0.0, green: 0.8, blue: 1.0, alpha: 1.0).setStroke()
        borderPath.lineWidth = 8
        borderPath.stroke()

        // 内边框 - 赛博绿边框
        let innerBorderPath = NSBezierPath(roundedRect: rect.insetBy(dx: 40, dy: 40), xRadius: 36, yRadius: 36)
        NSColor(red: 0.0, green: 1.0, blue: 0.5, alpha: 1.0).setStroke()
        innerBorderPath.lineWidth = 4
        innerBorderPath.stroke()

        // 中心CCC文字 - 赛博朋克风格
        let attributedString = NSAttributedString(
            string: "CCC",
            attributes: [
                .font: NSFont.monospacedSystemFont(ofSize: 140, weight: .black),
                .foregroundColor: NSColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0)  // 霓虹蓝
            ]
        )

        let textSize = attributedString.size()
        let textRect = NSRect(
            x: (iconSize.width - textSize.width) / 2,
            y: (iconSize.height - textSize.height) / 2 + 20,
            width: textSize.width,
            height: textSize.height
        )

        // 文字发光效果
        let shadow = NSShadow()
        shadow.shadowColor = NSColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0)
        shadow.shadowBlurRadius = 20
        shadow.shadowOffset = NSSize(width: 0, height: 0)

        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedSystemFont(ofSize: 140, weight: .black),
            .foregroundColor: NSColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0),
            .shadow: shadow
        ]

        let glowingText = NSAttributedString(string: "CCC", attributes: textAttributes)
        glowingText.draw(in: textRect)

        // 底部装饰线
        let decorRect = NSRect(x: 100, y: 380, width: 312, height: 4)
        NSColor(red: 0.8, green: 0.0, blue: 1.0, alpha: 1.0).setFill()
        NSBezierPath(rect: decorRect).fill()

        // 角落装饰 - 小圆点
        let corners = [
            NSPoint(x: 60, y: 60),
            NSPoint(x: 452, y: 60),
            NSPoint(x: 60, y: 452),
            NSPoint(x: 452, y: 452)
        ]

        for corner in corners {
            let dotPath = NSBezierPath(ovalIn: NSRect(x: corner.x - 8, y: corner.y - 8, width: 16, height: 16))
            NSColor(red: 0.0, green: 1.0, blue: 0.5, alpha: 1.0).setFill()
            dotPath.fill()
        }

        image.unlockFocus()
        NSApplication.shared.applicationIconImage = image
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            // 创建自定义赛博朋克风格图标
            let statusIcon = createStatusBarIcon()
            button.image = statusIcon
            button.toolTip = AppConstants.appName
        }

        setupMenu()
    }

    private func createStatusBarIcon() -> NSImage {
        let iconSize = NSSize(width: 16, height: 16)
        let image = NSImage(size: iconSize)
        image.lockFocus()
        let rect = NSRect(origin: .zero, size: iconSize)

        // 背景 - 深色圆角矩形
        let backgroundPath = NSBezierPath(roundedRect: rect.insetBy(dx: 2, dy: 2), xRadius: 4, yRadius: 4)
        NSColor(red: 0.1, green: 0.0, blue: 0.2, alpha: 1.0).setFill()
        backgroundPath.fill()

        // 霓虹边框
        NSColor(red: 0.0, green: 0.8, blue: 1.0, alpha: 1.0).setStroke()
        backgroundPath.lineWidth = 1
        backgroundPath.stroke()

        // CCC文字 - 缩小版本
        let font = NSFont.monospacedSystemFont(ofSize: 8, weight: .black)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0)
        ]

        let text = "CCC"
        let textSize = text.size(withAttributes: attributes)
        let textRect = NSRect(
            x: (iconSize.width - textSize.width) / 2,
            y: (iconSize.height - textSize.height) / 2 + 1,
            width: textSize.width,
            height: textSize.height
        )

        text.draw(in: textRect, withAttributes: attributes)

        image.unlockFocus()
        return image
    }

    private func setupMenu() {
        statusMenu = NSMenu()

        // 显示应用菜单项
        let showItem = NSMenuItem(title: "显示", action: #selector(showApp), keyEquivalent: "")
        showItem.target = self
        statusMenu?.addItem(showItem)

        statusMenu?.addItem(NSMenuItem.separator())

        // 帮助菜单项
        let helpItem = NSMenuItem(title: "帮助", action: #selector(showHelp), keyEquivalent: "?")
        helpItem.target = self
        statusMenu?.addItem(helpItem)

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

    @objc private func showHelp() {
        showDeveloperInfo()
    }

    private func showDeveloperInfo() {
        let alert = NSAlert()
        alert.messageText = "Claude Code Config"
        alert.informativeText = """
        开发者: \(AppConstants.developer)
        联系邮箱: \(AppConstants.developerEmail)
        版本: \(AppConstants.version)

        感谢使用 Claude Code CLI 配置管理工具！
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "确定")
        alert.runModal()
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