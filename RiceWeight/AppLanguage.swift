//
//  AppLanguage.swift
//  RiceWeight
//
//  Created by Codex on 2026/5/31.
//

// 导入 Foundation，才能使用 Locale、Bundle 和 UserDefaults。
import Foundation

/// App 支持的语言列表。
///
/// `enum` 适合表示数量固定的选项。这里的每个 case 都对应一种语言。
/// 冒号后的 `String` 表示每个 case 都拥有一个字符串原始值，例如日语是 `"ja"`。
/// `CaseIterable` 让 Swift 自动生成 `allCases` 数组，设置页可以遍历全部语言。
/// `Identifiable` 让 SwiftUI 能够识别列表中的每个语言选项。
enum AppLanguage: String, CaseIterable, Identifiable {
    // `"ja"`、`"zh-Hans"` 和 `"en"` 是 Apple 资源目录使用的语言标识符。
    case japanese = "ja"
    case simplifiedChinese = "zh-Hans"
    case english = "en"

    /// `@AppStorage` 和 UserDefaults 使用同一个 key 保存用户选择。
    static let storageKey = "selectedAppLanguage"

    /// 用户第一次安装并打开 App 时，默认使用日语。
    static let defaultLanguage: AppLanguage = .japanese

    /// 读取当前保存的语言。如果还没有保存过，返回默认日语。
    static var current: AppLanguage {
        // UserDefaults 是 iOS 提供的轻量级本地存储，适合保存语言偏好等简单设置。
        let savedValue = UserDefaults.standard.string(forKey: storageKey)

        // 如果 savedValue 可以转换成 AppLanguage，就返回用户选择；否则返回默认值。
        return AppLanguage(rawValue: savedValue ?? "") ?? defaultLanguage
    }

    /// App 启动时使用的语言。
    ///
    /// `static let` 只会初始化一次，因此用户在设置页切换选项后，
    /// 当前运行中的页面不会立刻变化。完全退出并重新启动 App 后，
    /// 它才会重新读取 UserDefaults 中保存的新语言。
    static let launchLanguage = current

    /// `Identifiable` 协议要求提供 id。语言标识符本身已经唯一，可以直接作为 id。
    var id: String {
        rawValue
    }

    /// 创建当前语言对应的 Locale。
    /// Locale 会影响日期顺序、小数点形式等地区相关格式。
    var locale: Locale {
        Locale(identifier: rawValue)
    }

    /// 从 App 安装包中找到当前语言对应的翻译资源目录。
    var bundle: Bundle {
        // 例如日语翻译编译后位于 `ja.lproj` 目录。
        guard let path = Bundle.main.path(forResource: rawValue, ofType: "lproj"),
              let languageBundle = Bundle(path: path) else {
            // 如果找不到语言资源，就使用 App 主 Bundle，避免页面崩溃。
            return .main
        }

        return languageBundle
    }

    /// 语言选择页始终使用各语言自己的名称。
    /// 即使用户当前看不懂日语，也仍然可以找到熟悉的语言选项。
    var displayName: String {
        switch self {
        case .japanese:
            return "日本語"
        case .simplifiedChinese:
            return "简体中文"
        case .english:
            return "English"
        }
    }
}
