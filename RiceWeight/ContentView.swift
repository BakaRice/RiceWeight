//
//  ContentView.swift
//  RiceWeight
//
//  Created by RiceMarch on 2026/5/31.
//

// 导入 SwiftUI 框架，才能使用 View、List、Button、Text 等界面组件。
import SwiftUI

// 导入 SwiftData，才能使用 @Query 和 modelContext 访问本地数据库。
import SwiftData

/// 应用的首页：展示体重记录，并负责新增和删除操作。
///
/// `struct` 声明结构体；冒号后的 `View` 表示这个结构体遵守 SwiftUI 的 View 协议。
struct ContentView: View {
    /// `modelContext` 是 SwiftData 提供的数据库操作入口。
    /// 可以把它理解为当前页面连接到本地数据库的“会话”。
    @Environment(\.modelContext) private var modelContext

    /// `@Query` 会从 SwiftData 本地数据库中读取全部体重记录。
    /// `filter` 只保留没有被软删除的记录。
    /// `sort` 指定按测量时间排序，`.reverse` 表示从新到旧排列。
    ///
    /// 数据库内容变化后，SwiftUI 会自动刷新使用 records 的界面。
    @Query(
        filter: #Predicate<WeightRecord> { $0.deletedAt == nil },
        sort: \WeightRecord.measuredAt,
        order: .reverse
    )
    private var records: [WeightRecord]

    /// 第一版先使用固定目标，专注理解页面状态和列表交互。
    /// 后续可以增加设置页面，让用户自行修改目标体重。
    /// `let` 声明不可修改的常量，`Double` 类型会由小数 `75.0` 自动推断出来。
    private let targetWeight = 75.0

    /// 弹窗是否显示也是会变化的界面状态。
    /// `false` 表示 App 启动时先不显示新增记录弹窗。
    @State private var isShowingAddRecord = false

    /// 控制设置弹窗是否显示。
    @State private var isShowingSettings = false

    /// `WeightRecord?` 末尾的问号表示可选值：有记录时返回一条记录，没有时返回 nil。
    private var latestRecord: WeightRecord? {
        // @Query 已经按测量时间从新到旧排序，因此第一项就是最近记录。
        // 数组为空时，first 会安全地返回 nil。
        records.first
    }

    /// 差值不会小于 0。达到或低于目标时，首页会显示“已达到目标”。
    /// `Double?` 表示有记录时返回差值，没有记录时返回 nil。
    private var remainingWeight: Double? {
        // `guard let` 尝试从可选值中取出最近记录；如果没有记录，就提前返回 nil。
        guard let latestRecord else { return nil }

        // `max` 返回两个数字中较大的一个，确保差值最小是 0。
        return max(latestRecord.weight - targetWeight, 0)
    }

    /// 每个 SwiftUI View 都必须提供 `body`，用声明式语法描述页面长什么样。
    var body: some View {
        // `NavigationStack` 提供导航栏，让首页可以显示标题和右上角按钮。
        NavigationStack {
            // `List` 是可以滚动的系统列表容器。
            List {
                // 第一个 Section 用于展示首页概览。
                Section {
                    // 同时取出最近记录和差值。只有两个值都存在时，才显示概览。
                    if let latestRecord, let remainingWeight {
                        // 创建概览子视图，并把它需要的数据传进去。
                        WeightSummaryView(
                            currentWeight: latestRecord.weight,
                            targetWeight: targetWeight,
                            remainingWeight: remainingWeight
                        )
                    } else {
                        // 没有记录时，显示系统提供的空状态页面。
                        ContentUnavailableView(
                            // 用户可见文字从 L10n 读取，系统会根据设备语言选择翻译。
                            L10n.emptyTitle,
                            // `scalemass` 是 SF Symbols 中的系统图标名称。
                            systemImage: "scalemass",
                            // `Text` 用于展示一段文字。
                            description: Text(L10n.emptyDescription)
                        )
                    }
                }

                // 第二个 Section 用于展示历史记录列表。
                Section(L10n.historySection) {
                    // `ForEach` 遍历数据库查询结果，为每条记录创建一行界面。
                    ForEach(records) { record in
                        // `record` 是当前正在处理的那条数据。
                        WeightRecordRow(record: record)
                    }
                    // `onDelete` 开启系统列表的左滑删除能力。
                    .onDelete(perform: deleteRecords)
                }
            }
            // 设置首页导航栏标题。
            .navigationTitle(L10n.homeTitle)
            //如果希望标题和加号位于同一行
            //.navigationBarTitleDisplayMode(.inline)
            // `toolbar` 用于配置导航栏上的操作按钮。
            .toolbar {
                // `NavigationLink` 点击后会把趋势页面推入当前 NavigationStack。
                NavigationLink {
                    WeightChartView()
                } label: {
                    Label(L10n.showChart, systemImage: "chart.xyaxis.line")
                }

                // 在导航栏中加入齿轮按钮，点击后显示语言设置页。
                Button {
                    isShowingSettings = true
                } label: {
                    Label(L10n.settingsTitle, systemImage: "gearshape")
                }

                // 创建一个按钮。点击后会执行紧随其后的闭包。
                Button {
                    // 修改 @State 后，SwiftUI 会重新计算 body，并显示弹窗。
                    isShowingAddRecord = true
                } label: {
                    // `Label` 同时包含本地化文字和 SF Symbols 系统图标。
                    Label(L10n.addRecord, systemImage: "plus")
                }
            }
            // `sheet` 根据绑定的 Bool 值决定是否展示模态弹窗。
            // `$isShowingAddRecord` 中的 `$` 会创建双向绑定，让弹窗关闭时状态自动同步。
            .sheet(isPresented: $isShowingAddRecord) {
                // 创建新增页面。
                // 最近记录的体重作为滚轮默认值；没有记录时使用 65.5 kg。
                AddWeightRecordView(
                    initialWeight: latestRecord?.weight ?? 65.5,
                    onSave: { newRecord in
                        // `insert` 把弹窗返回的新记录写入 SwiftData 本地数据库。
                        modelContext.insert(newRecord)
                    }
                )
            }
            // 根据 isShowingSettings 决定是否显示设置弹窗。
            .sheet(isPresented: $isShowingSettings) {
                SettingsView()
            }
        }
    }

    /// `IndexSet` 中的位置来自当前正在展示的 records 查询结果。
    /// `private func` 声明仅在当前类型内部使用的方法。
    private func deleteRecords(at offsets: IndexSet) {
        // 遍历用户左滑删除的位置。
        for offset in offsets {
            // 软删除不会立刻移除数据库中的对象，而是为记录补上删除时间。
            // @Query 会自动隐藏 deletedAt 不为 nil 的记录。
            let record = records[offset]
            let now = Date()
            record.deletedAt = now
            record.updatedAt = now
        }
    }
}

/// 首页顶部的概览卡片。
/// 这里只接收展示所需的数据，不负责修改记录，因此全部使用常量属性。
struct WeightSummaryView: View {
    /// 从父视图读取当前语言环境，用于格式化数字。
    @Environment(\.locale) private var locale

    // 这三个 `let` 都是由父视图传入、不会在当前子视图中修改的常量。
    let currentWeight: Double
    let targetWeight: Double
    let remainingWeight: Double

    /// 子视图也必须提供 `body`。
    var body: some View {
        // `VStack` 把内部元素从上到下排列。
        // `alignment: .leading` 表示左对齐；`spacing: 16` 表示元素间距为 16 点。
        VStack(alignment: .leading, spacing: 16) {
            // 展示本地化后的“当前体重”。
            Text(L10n.currentWeight)
                // 使用较小的系统副标题字体。
                .font(.subheadline)
                // 使用系统次要文字颜色。
                .foregroundStyle(.secondary)

            // 调用下方方法，将数字格式化成带单位的文字。
            Text(formattedWeight(currentWeight))
                // 使用 44 点、半粗体的大号数字。
                .font(.system(size: 44, weight: .semibold))

            // 在概览内容之间加入系统分隔线。
            Divider()

            // `LabeledContent` 左边显示标题，右边显示对应内容。
            LabeledContent(L10n.targetWeight) {
                Text(formattedWeight(targetWeight))
                    .foregroundStyle(.secondary)
            }

            // 展示距离目标还差多少。
            LabeledContent(L10n.remainingWeight) {
                // 如果差值大于 0，就展示剩余公斤数。
                if remainingWeight > 0 {
                    Text(formattedWeight(remainingWeight))
                        .foregroundStyle(.secondary)
                } else {
                    // 否则展示绿色的“已达到目标”。
                    Text(L10n.reachedTarget)
                        .foregroundStyle(.green)
                }
            }
        }
        // 在 VStack 顶部和底部各增加 8 点留白。
        .padding(.vertical, 8)
    }

    /// 将体重数字转换成可展示文字。
    /// `formatted` 会根据用户地区决定使用小数点还是小数逗号。
    private func formattedWeight(_ weight: Double) -> String {
        // `fractionLength(1)` 表示固定保留一位小数。
        let number = weight.formatted(
            .number
                .precision(.fractionLength(1))
                .locale(locale)
        )

        // 字符串插值 `\(变量)` 会把变量内容放入字符串中。
        return "\(number) \(L10n.kilogramShort)"
    }
}

/// 历史记录列表中的一行。
/// 把它拆成独立视图后，首页的结构更容易阅读，也便于以后单独调整样式。
struct WeightRecordRow: View {
    /// 从父视图读取当前语言环境，用于格式化数字和日期。
    @Environment(\.locale) private var locale

    // 父视图为每一行传入一条记录。
    let record: WeightRecord

    /// 描述单行历史记录的布局。
    var body: some View {
        // `HStack` 把内部元素从左到右排列。
        HStack {
            // 日期格式会自动跟随用户地区，例如中文和英文环境的顺序可以不同。
            // 时区使用记录创建时保存的值，避免用户旅行后历史日期发生偏移。
            Text(record.measuredAt, format: dateFormat)

            // `Spacer` 尽可能占据中间空间，把日期和体重推向两侧。
            Spacer()

            // 展示格式化后的体重。
            Text(formattedWeight(record.weight))
                // 使用稍粗的字体。
                .fontWeight(.medium)
                // 使用系统次要文字颜色。
                .foregroundStyle(.secondary)
        }
    }

    /// 根据记录中保存的时区创建日期格式。
    private var dateFormat: Date.FormatStyle {
        let timeZone = TimeZone(identifier: record.timeZoneIdentifier) ?? .autoupdatingCurrent
        var format = Date.FormatStyle.dateTime
            .year()
            .month()
            .day()
        format.timeZone = timeZone
        return format
    }

    /// 历史记录行也需要展示体重，因此提供一个局部格式化方法。
    private func formattedWeight(_ weight: Double) -> String {
        // 根据用户地区格式化数字，并固定保留一位小数。
        let number = weight.formatted(
            .number
                .precision(.fractionLength(1))
                .locale(locale)
        )

        // 拼接格式化数字和本地化单位。
        return "\(number) \(L10n.kilogramShort)"
    }
}

// `#Preview` 只用于 Xcode 画布预览，不会成为正式 App 页面的一部分。
#Preview {
    // 创建 ContentView，让 Xcode 可以快速显示首页预览。
    ContentView()
        // 预览使用内存数据库，避免预览数据写入真实 App 数据库。
        .modelContainer(for: WeightRecord.self, inMemory: true)
}
