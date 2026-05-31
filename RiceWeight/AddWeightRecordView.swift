//
//  AddWeightRecordView.swift
//  RiceWeight
//
//  Created by Codex on 2026/5/31.
//

// 导入 SwiftUI 框架，才能使用 View、Form、Picker、DatePicker 和 Button 等界面组件。
import SwiftUI

/// 新增记录弹窗。
///
/// 这个页面只负责收集用户输入。保存后的记录通过 `onSave` 闭包交回主页面，
/// 因此它不需要知道列表如何展示，也不直接修改主页面的数据。
///
/// `struct` 声明结构体；冒号后的 `View` 表示这个结构体遵守 SwiftUI 的 View 协议。
struct AddWeightRecordView: View {
    /// `dismiss` 由 SwiftUI 环境提供，用来关闭当前弹窗。
    /// `@Environment` 表示从 SwiftUI 当前界面的环境中读取一个系统能力。
    /// `\.dismiss` 是 KeyPath（键路径）语法，表示我们想读取名为 dismiss 的环境值。
    @Environment(\.dismiss) private var dismiss

    /// 从父页面读取当前语言环境，让数字展示格式和 App 内语言保持一致。
    @Environment(\.locale) private var locale

    /// `@State` 表示视图自己拥有、并且会随交互变化的数据。
    /// 当这些值改变时，SwiftUI 会重新计算 `body`，刷新受影响的界面。
    ///
    /// 体重选择器分成整数和小数两部分。
    /// 它们的初始值由下方 init 方法根据最近一次记录计算出来。
    @State private var selectedIntegerWeight: Int
    @State private var selectedDecimalDigit: Int

    /// `Date()` 创建当前时间，作为日期选择器的默认值。
    @State private var selectedDate = Date()

    /// `onSave` 是一个闭包，也就是可以像数据一样传递的函数。
    /// `(WeightRecord) -> Void` 表示：接收一条记录，不返回结果。
    /// 这里有点像Java中的function。或者说，这里像Consumer
    /// java: (T)->Void
    let onSave: (WeightRecord) -> Void

    /// 自定义初始化方法。
    ///
    /// `initialWeight` 是父页面传入的最近一次体重。
    /// 它只是一个已经计算好的值，因此不需要像 onSave 一样使用闭包。
    init(initialWeight: Double, onSave: @escaping (WeightRecord) -> Void) {
        // 滚轮只支持 30.0 到 250.9 kg，先把外部传入值限制在有效范围内。
        let clampedWeight = min(max(initialWeight, 30.0), 250.9)

        // 乘以 10 并四舍五入，把浮点数转换成稳定的一位小数整数。
        // 例如 65.5 会转换成 655。
        let weightInTenths = Int((clampedWeight * 10).rounded())

        // `_selectedIntegerWeight` 是 @State 在底层生成的包装器属性。
        // 使用 State(initialValue:) 可以为滚轮状态设置动态初始值。
        _selectedIntegerWeight = State(initialValue: weightInTenths / 10)

        // `%` 是取余运算符。655 % 10 得到 5，也就是小数位。
        _selectedDecimalDigit = State(initialValue: weightInTenths % 10)

        // 保存父页面传入的闭包，用户点击保存时再调用它。
        self.onSave = onSave
    }

    /// 将两个滚轮的值组合成真正保存的体重。
    /// 例如整数 `65` 和小数位 `5` 会组合成 `65.5`。
    private var selectedWeight: Double {
        Double(selectedIntegerWeight) + Double(selectedDecimalDigit) / 10
    }

    /// 每个 SwiftUI View 都必须提供 `body`，用声明式语法描述页面长什么样。
    var body: some View {
        // `NavigationStack` 提供导航栏，因此弹窗顶部可以显示标题和操作按钮。
        NavigationStack {
            // `Form` 是适合录入数据的系统表单容器。
            Form {
                // `Section` 把一组相关表单项放在一起。标题从本地化文件读取。
                Section(L10n.recordDetailsSection) {
                    // VStack 把体重标题、当前值和滚轮从上到下排列。
                    VStack(alignment: .leading) {
                        // 展示字段标题。
                        Text(L10n.weight)

                        // 展示滚轮当前组合出的体重。
                        Text(formattedWeight)
                            .font(.title2)
                            .fontWeight(.semibold)

                        // HStack 把整数滚轮、小数滚轮和单位横向排列。
                        HStack(spacing: 0) {
                            // 第一个 Picker 选择整数公斤数。
                            Picker(L10n.weight, selection: $selectedIntegerWeight) {
                                // `30...250` 是闭区间，表示允许选择 30 到 250。
                                ForEach(30...250, id: \.self) { weight in
                                    Text("\(weight)")
                                        .tag(weight)
                                }
                            }
                            .pickerStyle(.wheel)

                            // 第二个 Picker 选择一位小数。
                            Picker(L10n.decimalDigit, selection: $selectedDecimalDigit) {
                                ForEach(0...9, id: \.self) { digit in
                                    Text(".\(digit)")
                                        .tag(digit)
                                }
                            }
                            .pickerStyle(.wheel)

                            // 滚轮右侧展示公斤单位。
                            Text(L10n.kilogramShort)
                                .font(.headline)
                        }
                        // 限制滚轮高度，避免占据过多页面空间。
                        .frame(height: 150)
                    }

                    // `DatePicker` 是系统日期选择器。
                    DatePicker(
                        // 第一项参数是在日期选择器左侧展示的本地化标题。
                        L10n.date,
                        // `$selectedDate` 让选择器和状态值双向同步。
                        selection: $selectedDate,
                        // `...Date()` 是闭区间语法，表示只允许选择今天及以前的日期。
                        in: ...Date(),
                        // 这里只需要日期，不需要具体时间。
                        displayedComponents: .date
                    )
                }
            }
            // 点语法表示给上面的 Form 追加一个修饰器，设置导航栏标题。
            .navigationTitle(L10n.addWeightTitle)
            // `.inline` 让标题以较紧凑的样式显示在导航栏中。
            .navigationBarTitleDisplayMode(.inline)
            // `toolbar` 用于配置导航栏上的操作按钮。
            .toolbar {
                // `.cancellationAction` 会把按钮放到符合系统习惯的取消位置。
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.cancel) {
                        // 调用 dismiss() 关闭弹窗。
                        dismiss()
                    }
                }

                // `.confirmationAction` 会把按钮放到符合系统习惯的确认位置。
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.save) {
                        // 点击保存后，调用下方封装好的方法。
                        saveRecord()
                    }
                }
            }
        }
    }

    /// `private func` 声明仅在当前类型内部使用的方法。
    private func saveRecord() {
        // 创建 WeightRecord，并通过 onSave 闭包把新记录交回首页。
        onSave(WeightRecord(weight: selectedWeight, measuredAt: selectedDate))

        // 保存成功后关闭弹窗。
        dismiss()
    }

    /// 按当前语言环境格式化体重数字。
    private var formattedWeight: String {
        let number = selectedWeight.formatted(
            .number
                .precision(.fractionLength(1))
                .locale(locale)
        )

        return "\(number) \(L10n.kilogramShort)"
    }
}

// `#Preview` 只用于 Xcode 画布预览，不会成为正式 App 页面的一部分。
#Preview {
    // 预览时传入一个简单闭包，在控制台输出模拟保存的记录。
    AddWeightRecordView(initialWeight: 65.5) { record in
        print("Saved record: \(record.weight) kg")
    }
}
