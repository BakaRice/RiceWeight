//
//  WeightRecord.swift
//  RiceWeight
//
//  Created by Codex on 2026/5/31.
//

// 导入 Foundation，才能使用 UUID 和 Date 这两个系统类型。
import Foundation

/// 一条体重记录的数据模型。
///
/// `struct` 是值类型，适合描述一份简单数据。之后接入 SwiftData 时，
/// 可以再把它替换为可持久化的模型。
///
/// 冒号后的 `Identifiable` 是一个协议。遵守它以后，每条记录都必须提供唯一 id。
struct WeightRecord: Identifiable {
    /// `Identifiable` 要求每条数据有稳定且唯一的 `id`。
    /// SwiftUI 的 `List` 会用它区分每一行，并正确处理插入和删除动画。
    ///
    /// `let` 声明不可修改的常量；`UUID()` 会生成一个几乎不可能重复的标识符。
    let id = UUID()

    /// `Double` 表示带小数的数字，例如 `65.5`。
    let weight: Double

    /// `Date` 表示一个时间点。这个 Demo 在界面上只展示年月日。
    let date: Date
}
