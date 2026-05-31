//
//  AddWeightRecordView.swift
//  RiceWeight
//
//  Created by Codex on 2026/5/31.
//

// 导入 SwiftUI 框架，才能使用 View、Form、TextField、DatePicker 和 Button 等界面组件。
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

    /// 从父页面读取当前语言环境，让数字输入规则和 App 内语言保持一致。
    @Environment(\.locale) private var locale

    /// `@State` 表示视图自己拥有、并且会随交互变化的数据。
    /// 当这些值改变时，SwiftUI 会重新计算 `body`，刷新受影响的界面。
    ///
    /// `weightText` 保存输入框中的原始字符串。初始值 `""` 表示空字符串。
    @State private var weightText = ""

    /// `Date()` 创建当前时间，作为日期选择器的默认值。
    @State private var selectedDate = Date()

    /// `onSave` 是一个闭包，也就是可以像数据一样传递的函数。
    /// `(WeightRecord) -> Void` 表示：接收一条记录，不返回结果。
    /// 这里有点像Java中的function。或者说，这里像Consumer
    /// java: (T)->Void
    let onSave: (WeightRecord) -> Void

    /// 输入框中的字符串可能不是数字，因此保存按钮只在解析成功后启用。
    /// `Double?` 末尾的问号表示可选值：它可能是数字，也可能因为解析失败而是 nil。
    private var enteredWeight: Double? {
        // `NumberFormatter` 按用户所在地区解析数字。
        // 例如部分地区使用 `65,5`，而另一些地区使用 `65.5`。
        let formatter = NumberFormatter()

        // `.decimal` 表示按照普通十进制数字处理输入内容。
        formatter.numberStyle = .decimal

        // 使用 App 内选择的语言环境，兼容不同地区的小数格式。
        formatter.locale = locale

        // `number(from:)` 尝试把字符串变成 NSNumber；失败时返回 nil。
        // `?.doubleValue` 表示：仅在解析成功时继续读取 Double 类型的数值。
        return formatter.number(from: weightText)?.doubleValue
    }

    /// 这是一个计算属性。每次读取时都会重新执行花括号中的代码。
    private var canSave: Bool {
        // `guard let` 从可选值中取出真正的数字。
        // 如果 enteredWeight 是 nil，就提前返回 false。
        guard let enteredWeight else { return false }

        // 只有大于 0 的体重才是有效输入。
        return enteredWeight > 0
    }

    /// 每个 SwiftUI View 都必须提供 `body`，用声明式语法描述页面长什么样。
    var body: some View {
        // `NavigationStack` 提供导航栏，因此弹窗顶部可以显示标题和操作按钮。
        NavigationStack {
            // `Form` 是适合录入数据的系统表单容器。
            Form {
                // `Section` 把一组相关表单项放在一起。标题从本地化文件读取。
                Section(L10n.recordDetailsSection) {
                    // `$weightText` 中的 `$` 会创建双向绑定。
                    // 用户输入文字时，SwiftUI 会自动更新 weightText。
                    TextField(L10n.weightPlaceholder, text: $weightText)
                        // 弹出适合输入小数的数字键盘。
                        .keyboardType(.decimalPad)

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
                    // `!` 是逻辑取反。输入无效时，禁用保存按钮。
                    .disabled(!canSave)
                }
            }
        }
    }

    /// `private func` 声明仅在当前类型内部使用的方法。
    private func saveRecord() {
        // 再次校验输入，防止未来修改界面后意外保存无效数据。
        guard let enteredWeight, enteredWeight > 0 else { return }

        // 创建 WeightRecord，并通过 onSave 闭包把新记录交回首页。
        onSave(WeightRecord(weight: enteredWeight, date: selectedDate))

        // 保存成功后关闭弹窗。
        dismiss()
    }
}

// `#Preview` 只用于 Xcode 画布预览，不会成为正式 App 页面的一部分。
#Preview {
    // 预览时传入一个简单闭包，在控制台输出模拟保存的记录。
    AddWeightRecordView { record in
        print("Saved record: \(record.weight) kg")
    }
}
