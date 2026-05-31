//
//  RiceWeightApp.swift
//  RiceWeight
//
//  Created by 谭文韬 on 2026/5/31.
//

// 导入 SwiftUI 框架，才能使用 App、Scene、WindowGroup 和 View。
import SwiftUI

/// `@main` 标记 App 的程序入口。
/// iOS 启动应用时会先创建这个类型，再根据 `body` 中声明的场景构建界面。
@main
// `struct` 用于声明一个结构体；冒号后的 `App` 表示它遵守 SwiftUI 的 App 协议。
struct RiceWeightApp: App {
    // App 协议要求提供 `body`。`some Scene` 表示这里会返回某一种场景。
    var body: some Scene {
        /// `WindowGroup` 表示应用的窗口内容。iPhone 通常只有一个窗口，
        /// 但这种写法也能自然支持 iPad 和 macOS 上的多窗口场景。
        WindowGroup {
            // 创建首页视图。SwiftUI 会把它显示在窗口中。
            ContentView()
        }
    }
}
