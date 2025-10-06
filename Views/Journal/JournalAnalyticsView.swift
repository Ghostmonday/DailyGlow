//
//  JournalAnalyticsView.swift
//  DailyGlow
//
//  Comprehensive analytics and insights for journal entries
//

import SwiftUI
import Charts

struct JournalAnalyticsView: View {
    @EnvironmentObject var storageManager: StorageManager
    @Environment(\.dismiss) var dismiss
    @State private var selectedTimeframe: Timeframe = .month
    @State private var selectedChartType: ChartType = .mood
    
    enum Timeframe: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case threeMonths = "3 Months"
        case year = "Year"
        case all = "All Time"
        
        var days: Int {
            switch self {
            case .week: return 7
            case .month: return 30
            case .threeMonths: return 90
            case .year: return 365
            case .all: return Int.max
            }
        }
    }
    
    enum ChartType: String, CaseIterable {
        case mood = "Mood Trends"
        case frequency = "Entry Frequency"
        case gratitude = "Gratitude Count"
        case wordCloud = "Common Words"
        
        var icon: String {
            switch self {
            case .mood: return "heart.text.square"
            case .frequency: return "calendar"
            case .gratitude: return "heart.fill"
            case .wordCloud: return "cloud.fill"
            }
        }
    }
    
    // MARK: - Computed Properties
    private var filteredEntries: [JournalEntry] {
        let cutoffDate = selectedTimeframe == .all ? Date.distantPast :
        Calendar.current.date(byAdding: .day, value: -selectedTimeframe.days, to: Date()) ?? Date()
        
        return storageManager.journalEntries.filter { $0.date >= cutoffDate }
            .sorted { $0.date < $1.date }
    }
    
    private var moodData: [MoodDataPoint] {
        let groupedByDay = Dictionary(grouping: filteredEntries) { entry in
            Calendar.current.startOfDay(for: entry.date)
        }
        
        return groupedByDay.map { date, entries in
            let moods = entries.map { $0.mood }
            let averageMoodValue = moods.map { moodValue($0) }.reduce(0, +) / Double(moods.count)
            return MoodDataPoint(date: date, value: averageMoodValue, mood: dominantMood(from: moods))
        }.sorted { $0.date < $1.date }
    }
    
    private var frequencyData: [FrequencyDataPoint] {
        let groupedByDay = Dictionary(grouping: filteredEntries) { entry in
            Calendar.current.startOfDay(for: entry.date)
        }
        
        let allDates = generateDateRange()
        
        return allDates.map { date in
            FrequencyDataPoint(date: date, count: groupedByDay[date]?.count ?? 0)
        }
    }
    
    private var gratitudeData: [GratitudeDataPoint] {
        filteredEntries.map { entry in
            GratitudeDataPoint(date: entry.date, count: entry.gratitude.count)
        }
    }
    
    private var wordFrequency: [(word: String, count: Int)] {
        let allWords = filteredEntries.flatMap { entry in
            entry.content.lowercased()
                .components(separatedBy: .whitespacesAndNewlines)
                .filter { $0.count > 4 } // Only words with more than 4 characters
        }
        
        let wordCounts = Dictionary(allWords.map { ($0, 1) }, uniquingKeysWith: +)
        return wordCounts.sorted { $0.value > $1.value }.prefix(20).map { ($0.key, $0.value) }
    }
    
    private var insights: [Insight] {
        var insights: [Insight] = []
        
        // Most common mood
        if let mostCommon = mostCommonMood() {
            insights.append(Insight(
                icon: mostCommon.icon,
                title: "Dominant Mood",
                value: mostCommon.rawValue.capitalized,
                color: mostCommon.color
            ))
        }
        
        // Average entries per week
        let weeksCount = max(1, filteredEntries.count / 7)
        let avgPerWeek = filteredEntries.count / weeksCount
        insights.append(Insight(
            icon: "calendar.badge.plus",
            title: "Avg per Week",
            value: "\(avgPerWeek) entries",
            color: .blue
        ))
        
        // Total gratitude items
        let totalGratitude = filteredEntries.flatMap { $0.gratitude }.count
        insights.append(Insight(
            icon: "heart.fill",
            title: "Gratitude Items",
            value: "\(totalGratitude)",
            color: .pink
        ))
        
        // Longest streak
        let longestStreak = calculateLongestStreak()
        insights.append(Insight(
            icon: "flame.fill",
            title: "Longest Streak",
            value: "\(longestStreak) days",
            color: .orange
        ))
        
        return insights
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: GradientTheme.getGradient(for: .night),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Content
                ScrollView {
                    VStack(spacing: 24) {
                        // Timeframe selector
                        timeframeSelector
                        
                        // Key insights
                        insightsGrid
                        
                        // Chart type selector
                        chartTypeSelector
                        
                        // Main chart
                        mainChart
                        
                        // Additional stats
                        additionalStats
                    }
                    .padding()
                }
            }
            .navigationTitle("Journal Analytics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
    
    // MARK: - Timeframe Selector
    private var timeframeSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(Timeframe.allCases, id: \.self) { timeframe in
                    Button {
                        withAnimation {
                            selectedTimeframe = timeframe
                        }
                    } label: {
                        Text(timeframe.rawValue)
                            .font(Typography.small)
                            .foregroundColor(selectedTimeframe == timeframe ? .white : .white.opacity(0.7))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(selectedTimeframe == timeframe ?
                                          Color.purple.opacity(0.5) : Color.white.opacity(0.1))
                            )
                    }
                }
            }
        }
    }
    
    // MARK: - Insights Grid
    private var insightsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            ForEach(insights, id: \.title) { insight in
                InsightCard(insight: insight)
            }
        }
    }
    
    // MARK: - Chart Type Selector
    private var chartTypeSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(ChartType.allCases, id: \.self) { type in
                    Button {
                        withAnimation {
                            selectedChartType = type
                        }
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: type.icon)
                                .font(.title2)
                                .foregroundColor(selectedChartType == type ? .white : .white.opacity(0.6))
                            
                            Text(type.rawValue)
                                .font(Typography.tiny)
                                .foregroundColor(selectedChartType == type ? .white : .white.opacity(0.6))
                        }
                        .frame(width: 80, height: 80)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(selectedChartType == type ?
                                      Color.purple.opacity(0.3) : Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(selectedChartType == type ?
                                                Color.purple.opacity(0.5) : Color.white.opacity(0.2),
                                                lineWidth: 1)
                                )
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Main Chart
    @ViewBuilder
    private var mainChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(selectedChartType.rawValue)
                .font(Typography.h3)
                .foregroundColor(.white)
            
            switch selectedChartType {
            case .mood:
                moodChart
            case .frequency:
                frequencyChart
            case .gratitude:
                gratitudeChart
            case .wordCloud:
                wordCloudView
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private var moodChart: some View {
        Chart(moodData) { dataPoint in
            LineMark(
                x: .value("Date", dataPoint.date),
                y: .value("Mood", dataPoint.value)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [.purple, .pink],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
            
            AreaMark(
                x: .value("Date", dataPoint.date),
                y: .value("Mood", dataPoint.value)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [.purple.opacity(0.3), .pink.opacity(0.1)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .frame(height: 200)
        .chartYScale(domain: 0...5)
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: selectedTimeframe == .week ? 1 : 7)) { _ in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                    .foregroundStyle(Color.white.opacity(0.1))
                AxisTick(stroke: StrokeStyle(lineWidth: 0.5))
                    .foregroundStyle(Color.white.opacity(0.3))
                AxisValueLabel()
                    .foregroundStyle(Color.white.opacity(0.6))
            }
        }
        .chartYAxis {
            AxisMarks { _ in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                    .foregroundStyle(Color.white.opacity(0.1))
                AxisTick(stroke: StrokeStyle(lineWidth: 0.5))
                    .foregroundStyle(Color.white.opacity(0.3))
                AxisValueLabel()
                    .foregroundStyle(Color.white.opacity(0.6))
            }
        }
    }
    
    private var frequencyChart: some View {
        Chart(frequencyData) { dataPoint in
            BarMark(
                x: .value("Date", dataPoint.date),
                y: .value("Count", dataPoint.count)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [.blue, .cyan],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(4)
        }
        .frame(height: 200)
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: selectedTimeframe == .week ? 1 : 7)) { _ in
                AxisValueLabel()
                    .foregroundStyle(Color.white.opacity(0.6))
            }
        }
        .chartYAxis {
            AxisMarks { _ in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                    .foregroundStyle(Color.white.opacity(0.1))
                AxisValueLabel()
                    .foregroundStyle(Color.white.opacity(0.6))
            }
        }
    }
    
    private var gratitudeChart: some View {
        Chart(gratitudeData) { dataPoint in
            PointMark(
                x: .value("Date", dataPoint.date),
                y: .value("Count", dataPoint.count)
            )
            .foregroundStyle(Color.pink)
            .symbolSize(100)
            
            LineMark(
                x: .value("Date", dataPoint.date),
                y: .value("Count", dataPoint.count)
            )
            .foregroundStyle(Color.pink.opacity(0.5))
            .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round, dash: [5, 3]))
        }
        .frame(height: 200)
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: selectedTimeframe == .week ? 1 : 7)) { _ in
                AxisValueLabel()
                    .foregroundStyle(Color.white.opacity(0.6))
            }
        }
        .chartYAxis {
            AxisMarks { _ in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                    .foregroundStyle(Color.white.opacity(0.1))
                AxisValueLabel()
                    .foregroundStyle(Color.white.opacity(0.6))
            }
        }
    }
    
    private var wordCloudView: some View {
        ScrollView {
            WrappingHStack(wordFrequency) { word in
                Text(word.word)
                    .font(.system(size: CGFloat(10 + word.count * 2)))
                    .foregroundColor(Color(
                        hue: Double.random(in: 0...1),
                        saturation: 0.7,
                        brightness: 0.9
                    ))
                    .padding(4)
            }
            .frame(height: 200)
        }
    }
    
    // MARK: - Additional Stats
    private var additionalStats: some View {
        VStack(spacing: 16) {
            Text("Detailed Statistics")
                .font(Typography.h3)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                StatRow(label: "Total Entries", value: "\(filteredEntries.count)")
                StatRow(label: "Average Word Count", value: "\(averageWordCount())")
                StatRow(label: "Most Active Day", value: mostActiveDay() ?? "N/A")
                StatRow(label: "Most Active Time", value: mostActiveTime() ?? "N/A")
                StatRow(label: "Unique Tags", value: "\(uniqueTags().count)")
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
            )
        }
    }
    
    // MARK: - Helper Methods
    private func moodValue(_ mood: Mood) -> Double {
        switch mood {
        case .energized: return 5
        case .motivated: return 4.5
        case .grateful: return 4
        case .calm: return 3.5
        case .focused: return 3
        case .peaceful: return 2.5
        }
    }
    
    private func dominantMood(from moods: [Mood]) -> Mood {
        let moodCounts = Dictionary(moods.map { ($0, 1) }, uniquingKeysWith: +)
        return moodCounts.max { $0.value < $1.value }?.key ?? .calm
    }
    
    private func mostCommonMood() -> Mood? {
        let allMoods = filteredEntries.map { $0.mood }
        let moodCounts = Dictionary(allMoods.map { ($0, 1) }, uniquingKeysWith: +)
        return moodCounts.max { $0.value < $1.value }?.key
    }
    
    private func generateDateRange() -> [Date] {
        guard !filteredEntries.isEmpty else { return [] }
        
        let startDate = filteredEntries.first?.date ?? Date()
        let endDate = Date()
        var dates: [Date] = []
        var currentDate = startDate
        
        while currentDate <= endDate {
            dates.append(Calendar.current.startOfDay(for: currentDate))
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return dates
    }
    
    private func calculateLongestStreak() -> Int {
        let sortedDates = filteredEntries.map { Calendar.current.startOfDay(for: $0.date) }
            .sorted()
        
        guard !sortedDates.isEmpty else { return 0 }
        
        var longestStreak = 1
        var currentStreak = 1
        
        for i in 1..<sortedDates.count {
            let dayDiff = Calendar.current.dateComponents([.day], from: sortedDates[i-1], to: sortedDates[i]).day ?? 0
            
            if dayDiff == 1 {
                currentStreak += 1
                longestStreak = max(longestStreak, currentStreak)
            } else if dayDiff > 1 {
                currentStreak = 1
            }
        }
        
        return longestStreak
    }
    
    private func averageWordCount() -> Int {
        guard !filteredEntries.isEmpty else { return 0 }
        let totalWords = filteredEntries.reduce(0) { sum, entry in
            sum + entry.content.split(separator: " ").count
        }
        return totalWords / filteredEntries.count
    }
    
    private func mostActiveDay() -> String? {
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEEE"
        
        let dayGroups = Dictionary(grouping: filteredEntries) { entry in
            dayFormatter.string(from: entry.date)
        }
        
        return dayGroups.max { $0.value.count < $1.value.count }?.key
    }
    
    private func mostActiveTime() -> String? {
        let hourGroups = Dictionary(grouping: filteredEntries) { entry in
            Calendar.current.component(.hour, from: entry.date)
        }
        
        if let mostActiveHour = hourGroups.max(by: { $0.value.count < $1.value.count })?.key {
            return "\(mostActiveHour):00 - \(mostActiveHour + 1):00"
        }
        return nil
    }
    
    private func uniqueTags() -> Set<String> {
        Set(filteredEntries.flatMap { $0.tags })
    }
}

// MARK: - Supporting Types
struct MoodDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
    let mood: Mood
}

struct FrequencyDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
}

struct GratitudeDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
}

struct Insight {
    let icon: String
    let title: String
    let value: String
    let color: Color
}

struct InsightCard: View {
    let insight: Insight
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: insight.icon)
                .font(.title2)
                .foregroundColor(insight.color)
            
            Text(insight.value)
                .font(Typography.body)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text(insight.title)
                .font(Typography.tiny)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(insight.color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct StatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(Typography.small)
                .foregroundColor(.white.opacity(0.7))
            
            Spacer()
            
            Text(value)
                .font(Typography.small)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
    }
}

// MARK: - Wrapping HStack
struct WrappingHStack<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    let data: Data
    let content: (Data.Element) -> Content
    
    @State private var totalHeight = CGFloat.zero
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                self.generateContent(in: geometry)
            }
        }
        .frame(height: totalHeight)
    }
    
    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        
        return ZStack(alignment: .topLeading) {
            ForEach(Array(data), id: \.self) { item in
                content(item)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 4)
                    .alignmentGuide(.leading, computeValue: { d in
                        if abs(width - d.width) > geometry.size.width {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if item == data.last {
                            width = 0
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { d in
                        let result = height
                        if item == data.last {
                            height = 0
                        }
                        return result
                    })
            }
        }
        .background(viewHeightReader($totalHeight))
    }
    
    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}

// MARK: - Preview
#Preview {
    JournalAnalyticsView()
        .environmentObject(StorageManager.shared)
}
