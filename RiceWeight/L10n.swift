//
//  L10n.swift
//  RiceWeight
//
//  Created by Codex on 2026/5/31.
//

// 导入 Foundation，才能使用 String(localized:) 和 NumberFormatter 等基础能力。
import Foundation

/// `L10n` 是 Localization（本地化）的缩写。
///
/// 这个没有实例的枚举集中保存 App 的界面文案。页面只需要使用 `L10n.homeTitle`，
/// 不需要关心当前设备使用中文还是英文。真正的翻译位于 `Localizable.xcstrings`。
///
/// 使用 `enum` 而不是 `struct`，是因为这里不需要创建 `L10n()` 实例。
enum L10n {
    // `static let` 表示属于类型本身、初始化后不再变化的常量。
    // `localized` 后面的 key 应保持稳定；`defaultValue` 是找不到翻译时使用的英文兜底文案。
    static let homeTitle = String(localized: "home.title", defaultValue: "Weight Records")
    static let emptyTitle = String(localized: "home.empty.title", defaultValue: "No Records Yet")
    static let emptyDescription = String(
        localized: "home.empty.description",
        defaultValue: "Tap the plus button in the top-right corner to record your first weight."
    )
    static let historySection = String(localized: "home.history.section", defaultValue: "History")
    static let currentWeight = String(localized: "home.summary.current", defaultValue: "Current Weight")
    static let targetWeight = String(localized: "home.summary.target", defaultValue: "Target Weight")
    static let remainingWeight = String(localized: "home.summary.remaining", defaultValue: "Remaining")
    static let reachedTarget = String(localized: "home.summary.reached", defaultValue: "Target Reached")
    static let addRecord = String(localized: "action.addRecord", defaultValue: "Add Record")
    static let cancel = String(localized: "action.cancel", defaultValue: "Cancel")
    static let save = String(localized: "action.save", defaultValue: "Save")
    static let addWeightTitle = String(localized: "add.title", defaultValue: "Add Weight")
    static let recordDetailsSection = String(localized: "add.section.details", defaultValue: "Record Details")
    static let weightPlaceholder = String(localized: "add.weight.placeholder", defaultValue: "For example: 65.5")
    static let date = String(localized: "add.date", defaultValue: "Date")
    static let kilogramShort = String(localized: "unit.kilogram.short", defaultValue: "kg")
}
