//
//  SimpleGroupEditView.swift
//  ClaudeCodeConfig
//
//  Created by weiming on 2025-10-29.
//  Copyright © 2025 weiming. All rights reserved.
//

import SwiftUI

/// Simple group editing view with cyberpunk styling
struct SimpleGroupEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var groupName = ""
    @State private var selectedColor = "blue"
    let onSave: (ConfigGroup) -> Void
    private let editingGroup: ConfigGroup?
    private let isEditing: Bool

    private let availableColors = [
        ("blue", "BLUE_COLOR".localized(), Color(red: 0.0, green: 1.0, blue: 1.0)),
        ("green", "GREEN_COLOR".localized(), Color(red: 0.0, green: 1.0, blue: 0.5)),
        ("red", "PINK_COLOR".localized(), Color(red: 1.0, green: 0.0, blue: 0.5)),
        ("orange", "ORANGE_COLOR".localized(), Color(red: 1.0, green: 0.5, blue: 0.0)),
        ("purple", "PURPLE_COLOR".localized(), Color(red: 0.8, green: 0.0, blue: 1.0)),
        ("pink", "NEON_COLOR".localized(), Color(red: 1.0, green: 0.2, blue: 0.8))
    ]

    // 赛博朋克背景渐变
    private var cyberBackground: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.05, green: 0.0, blue: 0.1),
                Color(red: 0.1, green: 0.05, blue: 0.15),
                Color(red: 0.02, green: 0.0, blue: 0.08)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    init(group: ConfigGroup? = nil, onSave: @escaping (ConfigGroup) -> Void) {
        self.editingGroup = group
        self.isEditing = group != nil
        self.onSave = onSave

        if let group = group {
            _groupName = State(initialValue: group.name)
            _selectedColor = State(initialValue: group.color)
        }
    }

    var body: some View {
        ZStack {
            // 赛博朋克背景
            cyberBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // 赛博朋克标题
                VStack(spacing: 8) {
                    Text(isEditing ? "EDIT_GROUP".localized() : "NEW_GROUP".localized())
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

                    Text("GROUP_CONFIGURATION_PROTOCOL".localized())
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(AppConstants.Colors.cyberGreen)
                }
                .padding(.top, 24)
                .padding(.bottom, 20)

                // 主要内容区域
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // 分组名称字段
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Text("◆")
                                    .font(.system(size: 12, weight: .black, design: .monospaced))
                                    .foregroundColor(AppConstants.Colors.cyberRed)
                                Text("GROUP_NAME".localized())
                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                                    .foregroundColor(AppConstants.Colors.cyberBlue)
                            }
                            TextField("ENTER_GROUP_NAME".localized(), text: $groupName)
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

                        // 分组颜色选择区域
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Text("◆")
                                    .font(.system(size: 12, weight: .black, design: .monospaced))
                                    .foregroundColor(AppConstants.Colors.cyberRed)
                                Text("GROUP_COLOR".localized())
                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                                    .foregroundColor(AppConstants.Colors.cyberBlue)
                            }

                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                                ForEach(availableColors, id: \.0) { color in
                                    Button(action: {
                                        selectedColor = color.0
                                    }) {
                                        HStack(spacing: 8) {
                                            Circle()
                                                .fill(color.2)
                                                .frame(width: 12, height: 12)
                                            Text(color.1)
                                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                                .foregroundColor(.white)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 6)
                                                .stroke(selectedColor == color.0 ? color.2 : AppConstants.Colors.cyberBlue.opacity(0.5), lineWidth: selectedColor == color.0 ? 2 : 1)
                                                .background(selectedColor == color.0 ? color.2.opacity(0.2) : AppConstants.Colors.panelBackground.opacity(0.3))
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 32)
                }

                Spacer()

                // 按钮区域
                HStack(spacing: 16) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("CANCEL".localized())
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(AppConstants.Colors.cyberRed.opacity(0.8))
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    

                    Button(action: {
                        let group = ConfigGroup(
                            id: editingGroup?.id ?? UUID(),
                            name: groupName,
                            color: selectedColor,
                            icon: "folder",
                            sortOrder: editingGroup?.sortOrder ?? 0
                        )
                        onSave(group)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("CREATE".localized())
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
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
                    
                    .disabled(groupName.isEmpty)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
        }
        .frame(minWidth: 450, minHeight: 500)
        .onAppear {
            if let group = editingGroup {
                groupName = group.name
                selectedColor = group.color
            }
        }
    }
}