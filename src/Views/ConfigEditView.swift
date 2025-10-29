//
//  ConfigEditView.swift
//  ClaudeCodeConfig
//
//  Created by weiming on 2025-10-29.
//  Copyright © 2025 weiming. All rights reserved.
//

import SwiftUI
import AppKit

/// Configuration edit/create view with cyberpunk styling
struct ConfigEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var groupManager = GroupManager.shared
    @State private var config: Config
    @State private var isGroupSelectorExpanded = false
    let onSave: (Config) -> Void
    let isEditing: Bool

    init(config: Config? = nil, onSave: @escaping (Config) -> Void) {
        self._config = State(initialValue: config ?? Config())
        self.onSave = onSave
        self.isEditing = config != nil
    }

    // 获取分组颜色（用于编辑视图）
    private func getGroupColorForEdit(_ colorString: String) -> Color {
        switch colorString {
        case "blue": return Color(red: 0.0, green: 1.0, blue: 1.0)
        case "green": return Color(red: 0.0, green: 1.0, blue: 0.5)
        case "red": return Color(red: 1.0, green: 0.0, blue: 0.5)
        case "orange": return Color(red: 1.0, green: 0.5, blue: 0.0)
        case "purple": return Color(red: 0.8, green: 0.0, blue: 1.0)
        case "pink": return Color(red: 1.0, green: 0.2, blue: 0.8)
        default: return Color(red: 0.0, green: 1.0, blue: 1.0)
        }
    }

    var body: some View {
        ZStack {
            // 赛博朋克背景
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.0, blue: 0.1),
                    Color(red: 0.1, green: 0.05, blue: 0.15),
                    Color(red: 0.02, green: 0.0, blue: 0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                // 赛博朋克标题
                VStack(spacing: 8) {
                    Text(isEditing ? "EDIT_CONFIG".localized() : "NEW_CONFIG".localized())
                        .font(.system(size: 24, weight: .black, design: .monospaced))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    AppConstants.Colors.cyberBlue,
                                    AppConstants.Colors.cyberPurple
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: AppConstants.Colors.cyberBlue, radius: 8, x: 0, y: 0)

                    Text("CONFIGURATION_PROTOCOL_ACTIVE".localized())
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(AppConstants.Colors.cyberGreen)
                }
                .padding(.top, 24)

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // 配置名称字段
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Text("◆")
                                    .font(.system(size: 12, weight: .black, design: .monospaced))
                                    .foregroundColor(AppConstants.Colors.cyberRed)
                                Text("CONFIG_NAME".localized())
                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                                    .foregroundColor(AppConstants.Colors.cyberBlue)
                            }
                            TextField("ENTER_CONFIG_NAME".localized(), text: $config.name)
                                .font(.system(size: 13, design: .monospaced))
                                .foregroundColor(Color.black)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(AppConstants.Colors.cyberBlue, lineWidth: 1)
                                        .background(Color(red: 0.9, green: 0.9, blue: 0.95))
                                )
                                .disableAutocorrection(true)
                        }

                        // API URL字段
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Text("◆")
                                    .font(.system(size: 12, weight: .black, design: .monospaced))
                                    .foregroundColor(AppConstants.Colors.cyberRed)
                                Text("API_ENDPOINT".localized())
                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                                    .foregroundColor(AppConstants.Colors.cyberBlue)
                            }
                            TextField("API_URL_PLACEHOLDER".localized(), text: $config.apiUrl)
                                .font(.system(size: 13, design: .monospaced))
                                .foregroundColor(Color.black)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(AppConstants.Colors.cyberBlue, lineWidth: 1)
                                        .background(Color(red: 0.9, green: 0.9, blue: 0.95))
                                )
                                .disableAutocorrection(true)
                        }

                        // API Key字段
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Text("◆")
                                    .font(.system(size: 12, weight: .black, design: .monospaced))
                                    .foregroundColor(AppConstants.Colors.cyberRed)
                                Text("API_KEY".localized())
                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                                    .foregroundColor(AppConstants.Colors.cyberBlue)
                            }
                            SecureField("API_KEY_PLACEHOLDER".localized(), text: $config.apiKey)
                                .font(.system(size: 13, design: .monospaced))
                                .foregroundColor(Color.black)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(AppConstants.Colors.cyberBlue, lineWidth: 1)
                                        .background(Color(red: 0.9, green: 0.9, blue: 0.95))
                                )
                                .disableAutocorrection(true)
                        }

                        // 工作目录字段
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Text("◆")
                                    .font(.system(size: 12, weight: .black, design: .monospaced))
                                    .foregroundColor(AppConstants.Colors.cyberRed)
                                Text("WORKING_DIRECTORY".localized())
                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                                    .foregroundColor(AppConstants.Colors.cyberBlue)
                            }
                            HStack(spacing: 12) {
                                TextField("WORKING_DIR_PLACEHOLDER".localized(), text: $config.workingDirectory)
                                    .font(.system(size: 13, design: .monospaced))
                                    .foregroundColor(Color.black)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(AppConstants.Colors.cyberBlue, lineWidth: 1)
                                            .background(Color(red: 0.9, green: 0.9, blue: 0.95))
                                    )
                                    .disableAutocorrection(true)

                                Button(action: selectWorkingDirectory) {
                                    Text("BROWSE".localized())
                                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                                        .foregroundColor(AppConstants.Colors.cyberGreen)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 6)
                                                .stroke(AppConstants.Colors.cyberGreen, lineWidth: 1)
                                                .background(AppConstants.Colors.cyberGreen.opacity(0.1))
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        // 分组选择字段
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Text("◆")
                                    .font(.system(size: 12, weight: .black, design: .monospaced))
                                    .foregroundColor(AppConstants.Colors.cyberRed)
                                Text("PROJECT_GROUP".localized())
                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                                    .foregroundColor(AppConstants.Colors.cyberBlue)
                            }

                            GroupSelectorView(
                                groups: groupManager.groups,
                                selectedGroupId: $config.groupId,
                                isExpanded: $isGroupSelectorExpanded,
                                getGroupColor: getGroupColorForEdit
                            )
                        }

                        // 模型名称字段
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Text("◆")
                                    .font(.system(size: 12, weight: .black, design: .monospaced))
                                    .foregroundColor(AppConstants.Colors.cyberRed)
                                Text("MODEL_NAME".localized())
                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                                    .foregroundColor(AppConstants.Colors.cyberBlue)
                            }
                            TextField("MODEL_PLACEHOLDER".localized(), text: $config.modelName)
                                .font(.system(size: 13, design: .monospaced))
                                .foregroundColor(Color.black)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(AppConstants.Colors.cyberBlue, lineWidth: 1)
                                        .background(Color(red: 0.9, green: 0.9, blue: 0.95))
                                )
                                .disableAutocorrection(true)
                        }

                        // 选项设置
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 8) {
                                Text("◆")
                                    .font(.system(size: 12, weight: .black, design: .monospaced))
                                    .foregroundColor(AppConstants.Colors.cyberRed)
                                Text("OPTIONS".localized())
                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                                    .foregroundColor(AppConstants.Colors.cyberBlue)
                            }

                            VStack(spacing: 12) {
                                Toggle(isOn: $config.isDangerousMode) {
                                    HStack {
                                        Text("DANGEROUS_MODE_LABEL".localized())
                                            .font(.system(size: 12, design: .monospaced))
                                            .foregroundColor(.white)
                                        Text("DANGEROUS_MODE_FLAG".localized())
                                            .font(.system(size: 10, design: .monospaced))
                                            .foregroundColor(AppConstants.Colors.cyberRed)
                                    }
                                }
                                .toggleStyle(CyberpunkToggleStyle())
                            }
                        }
                    }
                    .padding(.horizontal, 32)
                }

                // 保存按钮区域
                HStack(spacing: 16) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("CANCEL".localized())
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(AppConstants.Colors.cyberRed.opacity(0.8))
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    

                    Spacer()

                    Button(action: {
                        onSave(config)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("SAVE_CONFIG".localized())
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                AppConstants.Colors.cyberBlue,
                                                AppConstants.Colors.cyberGreen
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .opacity(0.8)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    .disabled(!config.isValid)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
        }
        .frame(minWidth: 600, minHeight: 700)
    }

    private func selectWorkingDirectory() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false

        if panel.runModal() == .OK, let url = panel.url {
            config.workingDirectory = url.path
        }
    }
}

/// Group selector component for configuration editing
struct GroupSelectorView: View {
    let groups: [ConfigGroup]
    @Binding var selectedGroupId: UUID
    @Binding var isExpanded: Bool
    let getGroupColor: (String) -> Color

    var body: some View {
        VStack(spacing: 0) {
            // 当前选中的分组显示
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    if let selectedGroup = groups.first(where: { $0.id == selectedGroupId }) {
                        HStack(spacing: 8) {
                            Text("●")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(getGroupColor(selectedGroup.color))
                            Text(selectedGroup.name)
                                .font(.system(size: 13, design: .monospaced))
                                .foregroundColor(Color.black)
                        }
                    } else {
                        Text("SELECT_GROUP".localized())
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(Color.black)
                    }

                    Spacer()
                    Text(isExpanded ? "▼" : "▶")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(AppConstants.Colors.cyberBlue)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(AppConstants.Colors.cyberBlue, lineWidth: 1)
                        .background(Color(red: 0.9, green: 0.9, blue: 0.95))
                )
            }
            .buttonStyle(.plain)

            // 展开的分组列表
            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(groups) { group in
                        Button(action: {
                            selectedGroupId = group.id
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isExpanded = false
                            }
                        }) {
                            HStack {
                                Text("●")
                                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                                    .foregroundColor(getGroupColor(group.color))
                                Text(group.name)
                                    .font(.system(size: 13, design: .monospaced))
                                    .foregroundColor(Color.black)
                                Spacer()
                                if selectedGroupId == group.id {
                                    Text("✓")
                                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                                        .foregroundColor(AppConstants.Colors.cyberGreen)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color(red: 0.9, green: 0.9, blue: 0.95))
                        }
                        .buttonStyle(.plain)

                        if group.id != groups.last?.id {
                            Divider()
                                .background(AppConstants.Colors.cyberBlue.opacity(0.3))
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(AppConstants.Colors.cyberBlue, lineWidth: 1)
                        .background(Color(red: 0.9, green: 0.9, blue: 0.95))
                )
                .padding(.top, 4)
            }
        }
    }
}

/// Cyberpunk toggle style
struct CyberpunkToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(configuration.isOn ? AppConstants.Colors.cyberGreen : AppConstants.Colors.textSecondary.opacity(0.3))
                .frame(width: 44, height: 24)
                .overlay(
                    Circle()
                        .fill(Color.white)
                        .frame(width: 20, height: 20)
                        .offset(x: configuration.isOn ? 10 : -10)
                        .animation(.easeInOut(duration: 0.2), value: configuration.isOn)
                )
                .onTapGesture {
                    configuration.isOn.toggle()
                }

            configuration.label
        }
    }
}