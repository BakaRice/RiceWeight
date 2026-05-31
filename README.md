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
- 使用 SwiftData 将体重记录保存到本地数据库
- 支持日语、简体中文和英文文案
- 支持在 App 设置页中选择语言，并在重新启动 App 后生效
- 根据用户地区格式化日期、数字和小数输入

## 当前限制

- 目标体重暂时固定为 `75.0 kg`。
- App 第一次启动时默认使用日语。用户可以通过首页齿轮按钮切换语言。
- SwiftData 数据库保存在 App 本地沙箱中。卸载 App 后，本地记录会被删除。

这些限制适合作为后续学习任务：增加目标体重设置页面、使用 iCloud 或服务器同步数据。

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
   - `.modelContainer`

2. `RiceWeight/WeightRecord.swift`
   - 一条体重记录的数据模型
   - `@Model`
   - `class`
   - `@Attribute(.unique)`
   - `Double`
   - `Date`

3. `RiceWeight/ContentView.swift`
   - 首页布局
   - `NavigationStack`
   - `List`
   - `Section`
   - `@Query`
   - `modelContext`
   - `ForEach`
   - `.sheet`
   - `.onDelete`

4. `RiceWeight/AddWeightRecordView.swift`
   - 新增记录弹窗
   - `Form`
   - `Picker`
   - `DatePicker`
   - `$` 双向绑定
   - `@Environment`
   - 闭包回传数据

5. `RiceWeight/L10n.swift`
   - 集中管理国际化文案 key
   - `enum`
   - `static var`
   - `Bundle.localizedString(forKey:value:table:)`

6. `RiceWeight/AppLanguage.swift`
   - App 支持的语言列表
   - `enum`
   - `CaseIterable`
   - `UserDefaults`
   - `Locale`
   - `Bundle`

7. `RiceWeight/SettingsView.swift`
   - App 内语言切换页面
   - `@AppStorage`
   - `Picker`

8. `RiceWeight/Localizable.xcstrings`
   - 日语、简体中文和英文翻译
   - String Catalog 的基本结构

## 数据流

App 入口通过 `.modelContainer` 创建 SwiftData 本地数据库：

```swift
.modelContainer(for: WeightRecord.self)
```

首页通过 `@Query` 从数据库读取体重记录：

```swift
@Query(
    filter: #Predicate<WeightRecord> { $0.deletedAt == nil },
    sort: \WeightRecord.measuredAt,
    order: .reverse
)
private var records: [WeightRecord]
```

点击首页加号后，SwiftUI 弹出 `AddWeightRecordView`。首页在创建弹窗时传入一个闭包：

```swift
AddWeightRecordView(
    initialWeight: latestRecord?.weight ?? 65.5
) { newRecord in
    modelContext.insert(newRecord)
}
```

这段代码的完整写法是：

```swift
AddWeightRecordView(
    initialWeight: latestRecord?.weight ?? 65.5,
    onSave: { newRecord in
        modelContext.insert(newRecord)
    }
)
```

新增页面使用一个属性保存这个闭包：

```swift
let onSave: (WeightRecord) -> Void
```

用户点击保存后，新增页面创建一条记录，并调用首页传入的闭包：

```swift
onSave(WeightRecord(weight: selectedWeight, measuredAt: selectedDate))
```

完整流程：

```text
ContentView 把保存闭包交给 AddWeightRecordView
        ↓
用户在 AddWeightRecordView 中选择体重并点击保存
        ↓
AddWeightRecordView 创建 WeightRecord
        ↓
AddWeightRecordView 调用 onSave(newRecord)
        ↓
ContentView 执行 modelContext.insert(newRecord)
        ↓
SwiftData 保存记录，@Query 自动刷新首页
```

## 本地数据库

这个项目使用 Apple 提供的 SwiftData 保存体重记录，不需要安装第三方依赖。

模型通过 `@Model` 声明：

```swift
@Model
final class WeightRecord {
    @Attribute(.unique) var id: UUID
    var weight: Double
    @Attribute(originalName: "date") var measuredAt: Date
    var timeZoneIdentifier: String
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
}
```

| 操作 | SwiftData API |
| --- | --- |
| 新增记录 | `modelContext.insert(newRecord)` |
| 查询记录 | `@Query(...) private var records` |
| 删除记录 | 设置 `deletedAt`，并由 `@Query` 隐藏软删除记录 |

数据库位于 App 的本地沙箱中。完全退出并重新打开 App 后，记录仍然存在。卸载 App 后，iOS 会删除沙箱，因此记录也会被删除。

`Date` 保存的是与时区无关的绝对时间点。模型额外保存 `timeZoneIdentifier`，用于在用户跨时区后仍按录入地点展示日期。`createdAt`、`updatedAt` 和 `deletedAt` 为后续云端同步保留了创建、更新和软删除信息。

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

`L10n.swift` 使用稳定的语义 key，并在每次读取时查询用户当前选择的语言：

```swift
static var homeTitle: String {
    text("home.title", fallback: "体重記録")
}
```

翻译内容保存在 `Localizable.xcstrings`。日语是当前 App 的默认语言：

| Key | 日本語 | English | 简体中文 |
| --- | --- | --- | --- |
| `home.title` | `体重記録` | `Weight Records` | `体重记录` |
| `action.addRecord` | `記録を追加` | `Add Record` | `新增记录` |
| `action.save` | `保存` | `Save` | `保存` |

使用语义 key 的好处是：修改中文或英文文案时，不需要修改页面代码，也不会影响其他语言。

### 切换 App 语言

点击首页右上角的齿轮按钮，可以在 App 内选择：

```text
日本語
简体中文
English
```

选择结果通过 `@AppStorage` 保存到 UserDefaults。为了避免页面中途切换语言，新的语言会在完全退出并重新启动 App 后生效。

`RiceWeightApp.swift` 会在启动时向页面树注入对应的 `Locale`，因此日期和数字格式也会使用新选择的语言环境。

### 地区格式

国际化不仅包括翻译，也包括数字和日期格式。

- 日期通过 SwiftUI 的 `Date.FormatStyle` 展示，会自动适配地区顺序。
- 数字通过 `formatted(.number...)` 展示，会自动适配小数点或小数逗号。
- 体重通过整数和小数两个滚轮选择，避免用户输入无效数字。
- 新增记录时，滚轮默认显示最近一次体重；没有历史记录时使用 `65.5 kg`。

## 项目结构

```text
RiceWeight/
├── RiceWeightApp.swift          # App 入口
├── WeightRecord.swift           # SwiftData 本地数据库模型
├── ContentView.swift            # 首页、概览和历史记录列表
├── AddWeightRecordView.swift    # 新增记录弹窗
├── AppLanguage.swift            # App 支持的语言和语言偏好读取逻辑
├── SettingsView.swift           # App 内语言切换页面
├── L10n.swift                   # 国际化文案入口
├── Localizable.xcstrings        # 日语、简体中文和英文翻译
└── Assets.xcassets              # 图片、颜色和 App 图标资源
```

## 后续学习路线

1. 增加目标体重设置页面。
2. 使用图表展示体重变化趋势。
3. 使用 iCloud 或服务器同步数据。
4. 增加单元测试和 UI 测试。
