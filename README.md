# RiceWeight

RiceWeight 是一个用于学习 iOS 和 SwiftUI 开发的体重记录 Demo。

这个项目不仅用于实现功能，也用于理解一个 SwiftUI App 从入口、数据模型、页面状态、用户交互到国际化资源的基本结构。Swift 源文件中保留了较详细的中文注释，适合第一次接触 Swift 的开发者逐行阅读。

## 当前功能

- 展示当前体重
- 展示目标体重
- 计算距离目标还差多少
- 新增一条体重记录
- 查看历史记录
- 左滑删除历史记录
- 支持英文和简体中文文案
- 根据用户地区格式化日期、数字和小数输入

## 当前限制

- 体重记录仅保存在内存中。关闭 App 后，新增记录会消失。
- 目标体重暂时固定为 `75.0 kg`。
- App 会跟随系统或 iOS 中为 App 单独设置的语言，目前还没有 App 内语言切换页面。

这些限制适合作为后续学习任务：使用 SwiftData 保存数据、增加目标体重设置页面、增加 App 内语言切换。

## 运行项目

1. 使用 Xcode 打开 `RiceWeight.xcodeproj`。
2. 在 Xcode 顶部选择一个 iPhone Simulator。
3. 点击运行按钮，或者按下 `Command + R`。

## 推荐阅读顺序

第一次阅读时，建议按照下面的顺序打开文件：

1. `RiceWeight/RiceWeightApp.swift`
   - App 的程序入口
   - `@main`
   - `App`
   - `WindowGroup`

2. `RiceWeight/WeightRecord.swift`
   - 一条体重记录的数据模型
   - `struct`
   - `let`
   - `Double`
   - `Date`
   - `Identifiable`

3. `RiceWeight/ContentView.swift`
   - 首页布局
   - `NavigationStack`
   - `List`
   - `Section`
   - `@State`
   - `ForEach`
   - `.sheet`
   - `.onDelete`

4. `RiceWeight/AddWeightRecordView.swift`
   - 新增记录弹窗
   - `Form`
   - `TextField`
   - `DatePicker`
   - `$` 双向绑定
   - `@Environment`
   - 闭包回传数据

5. `RiceWeight/L10n.swift`
   - 集中管理国际化文案 key
   - `enum`
   - `static let`
   - `String(localized:)`

6. `RiceWeight/Localizable.xcstrings`
   - 英文和简体中文翻译
   - String Catalog 的基本结构

## 数据流

首页 `ContentView` 拥有体重记录数组：

```swift
@State private var records = [
    WeightRecord(weight: 103.6, date: Date())
]
```

点击首页加号后，SwiftUI 弹出 `AddWeightRecordView`。首页在创建弹窗时传入一个闭包：

```swift
AddWeightRecordView { newRecord in
    records.append(newRecord)
}
```

这段代码的完整写法是：

```swift
AddWeightRecordView(
    onSave: { newRecord in
        records.append(newRecord)
    }
)
```

新增页面使用一个属性保存这个闭包：

```swift
let onSave: (WeightRecord) -> Void
```

用户点击保存后，新增页面创建一条记录，并调用首页传入的闭包：

```swift
onSave(WeightRecord(weight: enteredWeight, date: selectedDate))
```

完整流程：

```text
ContentView 把保存闭包交给 AddWeightRecordView
        ↓
用户在 AddWeightRecordView 中输入体重并点击保存
        ↓
AddWeightRecordView 创建 WeightRecord
        ↓
AddWeightRecordView 调用 onSave(newRecord)
        ↓
ContentView 执行 records.append(newRecord)
        ↓
@State 发生变化，SwiftUI 自动刷新首页
```

## Swift 闭包与 Java 对照

如果熟悉 Java，可以把 Swift 闭包理解为更直接的函数式类型。

| Swift | Java 中的近似概念 |
| --- | --- |
| `() -> Void` | `Runnable` |
| `(T) -> Void` | `Consumer<T>` |
| `() -> T` | `Supplier<T>` |
| `(T) -> R` | `Function<T, R>` |
| `(T) -> Bool` | `Predicate<T>` |

本项目中的：

```swift
let onSave: (WeightRecord) -> Void
```

可以类比为：

```java
Consumer<WeightRecord> onSave;
```

## 国际化

页面中不直接硬编码用户可见文案。例如，首页标题没有写成：

```swift
Text("体重记录")
```

而是通过 `L10n` 读取：

```swift
L10n.homeTitle
```

`L10n.swift` 使用稳定的语义 key：

```swift
static let homeTitle = String(
    localized: "home.title",
    defaultValue: "Weight Records"
)
```

翻译内容保存在 `Localizable.xcstrings`：

| Key | English | 简体中文 |
| --- | --- | --- |
| `home.title` | `Weight Records` | `体重记录` |
| `action.addRecord` | `Add Record` | `新增记录` |
| `action.save` | `Save` | `保存` |

使用语义 key 的好处是：修改中文或英文文案时，不需要修改页面代码，也不会影响其他语言。

### 切换 App 语言

可以在 iPhone 或 Simulator 中打开：

```text
设置 → App → RiceWeight → 语言
```

也可以在 Xcode 中打开：

```text
Scheme → Edit Scheme... → Run → Options → App Language
```

### 地区格式

国际化不仅包括翻译，也包括数字和日期格式。

- 日期通过 SwiftUI 的 `Date.FormatStyle` 展示，会自动适配地区顺序。
- 数字通过 `formatted(.number...)` 展示，会自动适配小数点或小数逗号。
- 输入通过 `NumberFormatter` 解析，兼容不同地区的小数习惯。

## 项目结构

```text
RiceWeight/
├── RiceWeightApp.swift          # App 入口
├── WeightRecord.swift           # 体重记录模型
├── ContentView.swift            # 首页、概览和历史记录列表
├── AddWeightRecordView.swift    # 新增记录弹窗
├── L10n.swift                   # 国际化文案入口
├── Localizable.xcstrings        # 英文和简体中文翻译
└── Assets.xcassets              # 图片、颜色和 App 图标资源
```

## 后续学习路线

1. 使用 SwiftData 持久化体重记录。
2. 增加目标体重设置页面。
3. 增加 App 内语言切换功能。
4. 使用图表展示体重变化趋势。
5. 增加单元测试和 UI 测试。
