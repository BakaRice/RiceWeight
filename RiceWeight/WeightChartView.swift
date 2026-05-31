//
//  WeightChartView.swift
//  RiceWeight
//
//  Created by Codex on 2026/5/31.
//

// 导入 SwiftUI，才能使用 View、VStack 和 Text 等界面组件。
import SwiftUI

// 导入 SwiftData，才能使用 @Query 从本地数据库读取体重记录。
import SwiftData

// 导入 Charts，才能使用 Chart、LineMark、PointMark 和 RuleMark 绘制图表。
import Charts

/// 体重趋势页面：使用折线图展示体重随时间发生的变化。
struct WeightChartView: View {
    /// 从父视图读取当前语言环境，让目标体重的小数格式和首页保持一致。
    @Environment(\.locale) private var locale

    /// 图表页面只展示没有被软删除的记录。
    /// 首页为了优先展示最新记录，使用倒序排列；图表为了从左向右表示时间变化，使用正序排列。
    @Query(
        filter: #Predicate<WeightRecord> { $0.deletedAt == nil },
        sort: \WeightRecord.measuredAt
    )
    private var records: [WeightRecord]

    /// 第一版继续使用固定目标体重，避免一次引入太多新概念。
    private let targetWeight = 75.0

    var body: some View {
        Group {
            // 没有记录时不展示空白图表，而是告诉用户需要先新增体重记录。
            if records.isEmpty {
                ContentUnavailableView(
                    L10n.chartEmpty,
                    systemImage: "chart.xyaxis.line"
                )
            } else {
                // `Chart` 是 Charts 框架提供的图表容器。
                // 容器内部可以组合不同种类的 Mark，每个 Mark 描述图表中的一种视觉元素。
                Chart {
                    // `RuleMark` 绘制一条水平参考线，帮助我们比较记录值和目标值。
                    RuleMark(y: .value(L10n.chartTarget, targetWeight))
                        .foregroundStyle(.orange)
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                        .annotation(position: .top, alignment: .leading) {
                            Text("\(L10n.chartTarget): \(formattedWeight(targetWeight))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                    // `ForEach` 为每一条数据库记录创建一组图表标记。
                    ForEach(records) { record in
                        // `LineMark` 用折线连接不同日期的体重。
                        // `unit: .day` 表示横轴只关心日期，不区分具体时分秒。
                        LineMark(
                            x: .value(L10n.date, record.measuredAt, unit: .day),
                            y: .value(L10n.weight, record.weight)
                        )

                        // `PointMark` 标出每一次记录。
                        // 只有一条记录时折线无法连接其他点，但这个圆点仍然可以正常展示。
                        PointMark(
                            x: .value(L10n.date, record.measuredAt, unit: .day),
                            y: .value(L10n.weight, record.weight)
                        )
                    }
                }
                // 横轴按照天生成刻度，并且只展示月和日。
                // 这样视觉上更符合“每天记录一次体重”的数据含义。
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) {
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: .dateTime.month().day())
                    }
                }
                // 为纵轴补充单位，帮助读图时理解数字代表公斤数。
                .chartYAxisLabel(L10n.kilogramShort)
                .padding()
            }
        }
        .navigationTitle(L10n.chartTitle)
    }

    /// 将体重数字格式化为固定保留一位小数的文字。
    private func formattedWeight(_ weight: Double) -> String {
        let number = weight.formatted(
            .number
                .precision(.fractionLength(1))
                .locale(locale)
        )

        return "\(number) \(L10n.kilogramShort)"
    }
}
