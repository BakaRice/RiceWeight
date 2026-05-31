//
//  L10n.swift
//  RiceWeight
//
//  Created by Codex on 2026/5/31.
//

// 导入 Foundation，才能使用 Bundle 读取当前语言对应的翻译资源。
import Foundation

/// `L10n` 是 Localization（本地化）的缩写。
///
/// 这个没有实例的枚举集中保存 App 的界面文案。页面只需要使用 `L10n.homeTitle`，
/// 不需要关心当前用户选择日语、中文还是英文。真正的翻译位于 `Localizable.xcstrings`。
///
/// 使用 `enum` 而不是 `struct`，是因为这里不需要创建 `L10n()` 实例。
enum L10n {
    // 这里使用 `static var` 计算属性，让所有文案都通过统一方法查询翻译资源。
    static var homeTitle: String { text("home.title", fallback: "体重記録") }
    static var emptyTitle: String { text("home.empty.title", fallback: "記録がありません") }
    static var emptyDescription: String {
        text("home.empty.description", fallback: "右上のプラスボタンをタップして、最初の体重を記録しましょう。")
    }
    static var historySection: String { text("home.history.section", fallback: "履歴") }
    static var currentWeight: String { text("home.summary.current", fallback: "現在の体重") }
    static var targetWeight: String { text("home.summary.target", fallback: "目標体重") }
    static var remainingWeight: String { text("home.summary.remaining", fallback: "目標まで") }
    static var reachedTarget: String { text("home.summary.reached", fallback: "目標達成") }
    static var addRecord: String { text("action.addRecord", fallback: "記録を追加") }
    static var cancel: String { text("action.cancel", fallback: "キャンセル") }
    static var save: String { text("action.save", fallback: "保存") }
    static var done: String { text("action.done", fallback: "完了") }
    static var addWeightTitle: String { text("add.title", fallback: "体重を追加") }
    static var recordDetailsSection: String { text("add.section.details", fallback: "記録内容") }
    static var weightPlaceholder: String { text("add.weight.placeholder", fallback: "例：65.5") }
    static var date: String { text("add.date", fallback: "日付") }
    static var settingsTitle: String { text("settings.title", fallback: "設定") }
    static var language: String { text("settings.language", fallback: "言語") }
    static var restartHint: String { text("settings.restartHint", fallback: "変更はアプリの再起動後に反映されます。") }
    static var kilogramShort: String { text("unit.kilogram.short", fallback: "kg") }

    /// 根据 App 启动时确定的语言，从对应 Bundle 中读取翻译。
    private static func text(_ key: String, fallback: String) -> String {
        AppLanguage.launchLanguage.bundle.localizedString(forKey: key, value: fallback, table: nil)
    }
}
