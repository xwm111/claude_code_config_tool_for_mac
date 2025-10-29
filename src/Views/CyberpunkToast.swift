//
//  CyberpunkToast.swift
//  ClaudeCodeConfig
//
//  Created by weiming on 2025-10-29.
//  Copyright © 2025 weiming. All rights reserved.
//

import SwiftUI

/// Cyberpunk-style toast notification
struct CyberpunkToast: View {
    let message: String
    let isVisible: Bool
    let onDismiss: () -> Void

    var body: some View {
        if isVisible {
            VStack {
                Spacer()

                HStack {
                    Spacer()

                    VStack(spacing: 12) {
                        // 成功图标
                        Text("✓")
                            .font(.system(size: 24, weight: .black, design: .monospaced))
                            .foregroundColor(AppConstants.Colors.cyberGreen)
                            .shadow(color: AppConstants.Colors.cyberGreen, radius: 8, x: 0, y: 0)

                        // 消息文本
                        Text(message)
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)

                        // 关闭按钮
                        Button(action: onDismiss) {
                            Text("[CLOSE]")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(AppConstants.Colors.cyberGreen)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(AppConstants.Colors.cyberGreen, lineWidth: 1)
                                        .background(AppConstants.Colors.cyberGreen.opacity(0.1))
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(AppConstants.Colors.panelBackground.opacity(0.95))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                AppConstants.Colors.cyberGreen,
                                                AppConstants.Colors.cyberBlue
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2
                                    )
                            )
                    )
                    .shadow(color: AppConstants.Colors.cyberGreen.opacity(0.5), radius: 20, x: 0, y: 0)
                    .padding(.horizontal, 32)

                    Spacer()
                }

                Spacer()
            }
            .transition(.asymmetric(
                insertion: .scale.combined(with: .opacity),
                removal: .opacity
            ))
            .onAppear {
                // Auto-dismiss after 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    onDismiss()
                }
            }
        }
    }
}

/// Toast manager for showing toast notifications
class ToastManager: ObservableObject {
    @Published var showToast = false
    @Published var toastMessage = ""

    static let shared = ToastManager()

    private init() {}

    func showToast(_ message: String) {
        toastMessage = message
        showToast = true
    }

    func dismissToast() {
        showToast = false
    }
}