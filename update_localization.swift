#!/usr/bin/env swift

import Foundation

// Read the ContentView.swift file
let filePath = "/Users/weimingxu/Documents/AI/claude_code_config_tool/src/Views/ContentView.swift"
var content = try String(contentsOfFile: filePath)

// Dictionary of hardcoded text to localization keys
let replacements: [String: String] = [
    "\"◆ NODE SELECTION\"": "\"NODE_SELECTION\".localized()",
    "\"▶ ACCESS TERMINAL\"": "\"ACCESS_TERMINAL\".localized()",
    "\"◆ CONFIGURATION MATRIX\"": "\"CONFIGURATION_MATRIX\".localized()",
    "\"ACTIVE NODES:": "\"ACTIVE_NODES\":",
    "\"CREATE NEW CONFIG\"": "\"CREATE_NEW_CONFIG\".localized()",
    "\"SYSTEM_ARCHITECT:": "\"SYSTEM_ARCHITECT\":",
    "\"CONTACT_PROTOCOL:": "\"CONTACT_PROTOCOL\":",
    "\"READY\"": "\"READY\".localized()",
    "\"all groups": "\"ALL_GROUPS\".localized()",
    "\"未知分组\"": "\"UNKNOWN_GROUP\".localized()",
    "\"[COPY_CMD]\"": "\"COPY_CMD\".localized()",
    "\"[DUPLICATE]\"": "\"DUPLICATE\".localized()",
    "\"[LAUNCHING...]\"": "\"LAUNCHING\".localized()",
    "\"[LAUNCH]\"": "\"LAUNCH\".localized()",
    "\"[EDIT]\"": "\"EDIT\".localized()",
    "\"[DELETE]\"": "\"DELETE\".localized()",
    "\"DANGER_MODE\"": "\"DANGER_MODE\".localized()",
    "\"ACTIVE\"": "\"ACTIVE\".localized()",
    "\"PATH:\"": "\"PATH\".localized()",
    "\"API:\"": "\"API\".localized()",
    "\"删除分组\"": "\"DELETE_GROUP\".localized()",
    "\"取消\"": "\"CANCEL\".localized()",
    "\"删除\"": "\"DELETE\".localized()",
    "\"确定要删除分组 \\\"": "\"DELETE_GROUP_CONFIRMATION\".localized(arguments: ",
    "\"删除配置\"": "\"DELETE_CONFIG\".localized()",
    "\"确定要删除配置 \\\"": "\"DELETE_CONFIG_CONFIRMATION\".localized(arguments: ",
    "\"配置已删除\"": "\"CONFIG_DELETED\".localized()",
    "\"启动命令已复制到剪贴板\"": "\"LAUNCH_COMMAND_COPIED\".localized()",
    "\"已创建": "\"CONFIG_DUPLICATED\".localized(arguments: ",
    "\" 副本\"": ""
]

// Apply replacements
for (oldText, newText) in replacements {
    content = content.replacingOccurrences(of: oldText, with: newText)
}

// Write the updated content back to the file
try content.write(toFile: filePath, atomically: true, encoding: .utf8)

print("Successfully updated ContentView.swift with localization")