//
//  WeightRecord.swift
//  RiceWeight
//
//  Created by RiceMarch on 2026/5/31.
//

// 导入 Foundation，才能使用 UUID 和 Date 这两个系统类型。
import Foundation

// 导入 SwiftData，才能使用 @Model 和 @Attribute 创建本地数据库模型。
import SwiftData

/// 一条体重记录的数据模型。
///
/// `@Model` 是 SwiftData 提供的宏。它会帮助我们生成数据库存储所需的代码。
/// 保存 WeightRecord 后，即使 App 完全退出，记录仍然可以从本地数据库中恢复。
///
/// SwiftData 的模型使用 `class`，也就是引用类型。
/// 这和之前只保存在内存中的 struct 模型不同。
@Model
final class WeightRecord {
    /// `@Attribute(.unique)` 表示数据库中不允许出现重复 id。
    /// SwiftUI 的列表也可以使用 id 区分每一条记录。
    ///
    /// 使用 `var` 是因为 SwiftData 需要管理模型属性。
    /// `UUID()` 会生成一个几乎不可能重复的标识符。
    @Attribute(.unique) var id: UUID

    /// `Double` 表示带小数的数字，例如 `65.5`。
    var weight: Double

    /// `Date` 表示一个绝对时间点，和时区无关。
    /// 属性名使用 measuredAt，明确表示这是“测量发生的时间”。
    ///
    /// `originalName` 告诉 SwiftData：这个属性以前叫作 date。
    /// 这样模型改名后，已有本地数据仍然可以迁移到新属性。
    @Attribute(originalName: "date") var measuredAt: Date

    /// 保存录入记录时的时区。
    ///
    /// Date 负责保存绝对时间点，timeZoneIdentifier 负责保留用户录入时所在的地区。
    /// 例如用户旅行到其他时区后，历史列表仍然可以展示原本记录的日期。
    var timeZoneIdentifier: String = TimeZone.autoupdatingCurrent.identifier

    /// 下面三个时间字段为未来云端同步预留。
    ///
    /// createdAt 表示记录首次创建的时间。
    var createdAt: Date = Date()

    /// updatedAt 表示记录最后一次修改的时间。
    /// 以后多个设备同步时，可以用它判断哪一份数据更新。
    var updatedAt: Date = Date()

    /// deletedAt 不为 nil 时，表示记录已经被删除。
    ///
    /// 云端同步时不能立刻物理删除数据，否则其他设备无法知道这条记录已经删除。
    /// 这种保留删除标记的做法通常叫作“软删除”。
    var deletedAt: Date?

    /// `init` 是初始化器，类似 Java 的构造方法。
    /// 创建一条记录时，调用方需要传入体重和测量时间。
    init(
        id: UUID = UUID(),
        weight: Double,
        measuredAt: Date,
        timeZoneIdentifier: String = TimeZone.autoupdatingCurrent.identifier,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        deletedAt: Date? = nil
    ) {
        self.id = id
        self.weight = weight
        self.measuredAt = measuredAt
        self.timeZoneIdentifier = timeZoneIdentifier
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
}
