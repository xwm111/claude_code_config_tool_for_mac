//
//  CLILauncher.swift
//  ClaudeCodeConfig
//
//  Created by weiming on 2025-10-29.
//  Copyright © 2025 weiming. All rights reserved.
//

import Foundation
import AppKit
import Combine

/// Handles launching Claude CLI with configuration
class CLILauncher: ObservableObject {
    @Published var isLaunching = false
    @Published var launchStatus = ""

    private let nodePath = "/Users/weimingxu/.nvm/versions/node/v22.14.0/bin"

    /// Launches a configuration by opening iTerm and executing the command
    func launchConfiguration(_ config: Config) {
        guard config.isValid else {
            launchStatus = "❌ 配置无效"
            return
        }

        isLaunching = true
        launchStatus = "🚀 正在启动..."

        let command = buildLaunchCommand(config)
        
        // 启动 iTerm 并执行命令
        launchInITerm(command: command)
    }
    
    /// Launches command in iTerm
    private func launchInITerm(command: String) {
        let script = """
        tell application "iTerm2"
            if it is running then
                tell current window to create tab with default profile
            else
                activate
                delay 1
            end if
            
            tell current session of current window
                write text "\(command.replacingOccurrences(of: "\"", with: "\\\""))"
            end tell
        end tell
        """
        
        let appleScript = NSAppleScript(source: script)
        var error: NSDictionary?
        
        appleScript?.executeAndReturnError(&error)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isLaunching = false
            if error != nil {
                self.launchStatus = "❌ 启动失败"
            } else {
                self.launchStatus = "✅ 已在 iTerm 中启动"
            }
        }
    }

    /// Copies the launch command to clipboard without status updates
    func copyLaunchCommand(_ config: Config) {
        let command = buildLaunchCommand(config)

        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(command, forType: .string)
    }

    /// Builds the complete launch command for a configuration
    private func buildLaunchCommand(_ config: Config) -> String {
        var command = "export PATH=\"\(nodePath):$PATH\" && "
        command += "ANTHROPIC_AUTH_TOKEN=\"\(config.apiKey)\" "
        command += "ANTHROPIC_BASE_URL=\"\(config.apiUrl)\" "

        if !config.modelName.isEmpty {
            command += "ANTHROPIC_MODEL=\"\(config.modelName)\" "
        }

        command += "claude"

        // 添加危险模式参数
        if config.isDangerousMode {
            command += " --dangerously-skip-permissions"
        }

        if !config.workingDirectory.isEmpty {
            command = "cd \"\(config.workingDirectory)\" && " + command
        }

        return command
    }

    /// Validates if the configuration can be launched
    func canLaunch(_ config: Config) -> Bool {
        return config.isValid
    }
}