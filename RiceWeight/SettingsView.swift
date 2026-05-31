//
//  SettingsView.swift
//  RiceWeight
//
//  Created by Codex on 2026/5/31.
//

// 导入 SwiftUI，才能创建设置页面和使用 @AppStorage。
import SwiftUI

/// App 设置页面。
struct SettingsView: View {
    /// `@Environment(\.dismiss)` 用于获得关闭当前弹窗的方法。
    @Environment(\.dismiss) private var dismiss

    /// `@AppStorage` 会把值保存到 UserDefaults。
    /// 它与 @State 类似，变化时会刷新界面；不同之处是重新启动 App 后仍然保留。
    @AppStorage(AppLanguage.storageKey)
    private var selectedLanguageCode = AppLanguage.defaultLanguage.rawValue

    var body: some View {
        // NavigationStack 提供顶部标题和“完成”按钮所在的导航栏。
        NavigationStack {
            // Form 是适合设置页的系统表单容器。
            Form {
                // Section 的 footer 用于提示用户：修改语言后需要重新启动 App。
                Section {
                    // Picker 让用户从多个语言中选择一个。
                    Picker(L10n.language, selection: $selectedLanguageCode) {
                        // 遍历 AppLanguage 中声明的全部语言选项。
                        ForEach(AppLanguage.allCases) { language in
                            // tag 告诉 Picker：点击这一行后，应保存哪个字符串值。
                            Text(language.displayName)
                                .tag(language.rawValue)
                        }
                    }
                    // inline 样式会直接展示全部选项，并在当前语言旁显示勾选标记。
                    .pickerStyle(.inline)
                } footer: {
                    Text(L10n.restartHint)
                }
            }
            // 设置导航栏标题。
            .navigationTitle(L10n.settingsTitle)
            // 使用紧凑标题，让标题和完成按钮位于同一行。
            .navigationBarTitleDisplayMode(.inline)
            // toolbar 用于向导航栏添加按钮。
            .toolbar {
                // confirmationAction 会把按钮放在符合系统习惯的确认位置。
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.done) {
                        // 点击按钮后关闭设置弹窗。
                        dismiss()
                    }
                }
            }
        }
    }
}

// 只用于 Xcode 画布预览。
#Preview {
    SettingsView()
}
