# RiceWeight AI 协作说明

## 项目定位

RiceWeight 是一个用于学习 iOS、Swift 和 SwiftUI 的体重记录 Demo。

这个项目以教学为主要目标，不会直接投入生产环境。协助开发时，请优先保证代码容易阅读、容易解释，并让学习者能够逐步理解每一次修改。不要默认套用生产项目中的复杂架构。

## 开始工作前

开始处理任务前，请先阅读：

1. `README.md`
2. 与本次任务相关的 Swift 文件
3. 如果新增或修改用户可见文案，再阅读 `RiceWeight/L10n.swift` 和 `RiceWeight/Localizable.xcstrings`

不要覆盖工作区中已有但与当前任务无关的修改。

## 当前功能

- 展示当前体重
- 展示固定目标体重
- 计算距离目标还差多少
- 新增体重记录
- 查看并左滑删除历史记录
- 支持日语、简体中文和英文
- 在设置页中选择语言，并在重新启动 App 后生效
- 根据用户地区格式化日期和数字
- 使用 SwiftData 将体重记录保存在 App 本地数据库中

## 当前限制

这些限制是刻意保留的后续学习内容，不必主动修复：

- 目标体重暂时固定为 `75.0 kg`
- 卸载 App 后，本地数据库会被删除，暂时没有云端同步
- 暂时没有图表
- 暂时没有单元测试和 UI 测试

## 主要文件

- `RiceWeight/RiceWeightApp.swift`：App 入口、Locale 注入和 SwiftData 容器
- `RiceWeight/WeightRecord.swift`：SwiftData 体重记录模型
- `RiceWeight/ContentView.swift`：首页、数据库查询、新增和删除逻辑
- `RiceWeight/AddWeightRecordView.swift`：新增记录弹窗和闭包回传
- `RiceWeight/SettingsView.swift`：语言设置页面
- `RiceWeight/AppLanguage.swift`：支持语言、UserDefaults 和 Bundle
- `RiceWeight/L10n.swift`：本地化文案访问入口
- `RiceWeight/Localizable.xcstrings`：日语、简体中文和英文翻译资源

## 开发原则

1. 延续现有 SwiftUI 写法，每次只引入少量新概念。
2. 优先选择直观、容易逐行解释的实现。
3. 不要为了“生产级”而过度设计。
4. 除非任务明确要求，否则不要引入第三方依赖、复杂分层、依赖注入、Repository、Protocol 抽象、网络层或通用工具类。
5. 不要顺手重构与任务无关的代码。
6. 保留现有面向初学者的中文注释风格。
7. 新增注释时，重点解释 Swift 语法、SwiftUI 数据流和设计原因。避免机械地逐行复述代码。
8. 如果需求较大，请拆成适合学习的较小步骤，并先完成当前明确要求的部分。

## 国际化规则

页面中不要直接硬编码用户可见文案。

新增文案时：

1. 在 `RiceWeight/L10n.swift` 中增加语义明确的 key 访问入口。
2. 在 `RiceWeight/Localizable.xcstrings` 中补充日语、简体中文和英文翻译。
3. 延续当前默认语言为日语的设定，除非任务明确要求修改。

## 验证原则

修改代码后，尽可能运行可用的 Xcode 构建检查。

如果由于本机环境、签名或 Simulator 配置无法完成验证，请明确说明原因，不要假装已经验证成功。

## 回复方式

默认使用简体中文回复。

完成任务后，请简要说明：

1. 修改了哪些文件
2. 新增或改变了什么行为
3. 本次涉及哪些 Swift 或 SwiftUI 知识点
4. 是否完成构建或其他验证

解释应面向正在学习 SwiftUI 的开发者，清楚但不过度展开。
