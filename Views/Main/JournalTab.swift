//
//  JournalTab.swift
//  DailyGlow
//
//  Tab for journaling, gratitude tracking, and mood history
//

import SwiftUI
import Charts

struct JournalTab: View {
    // MARK: - Environment
    @EnvironmentObject var storageManager: StorageManager
    @StateObject private var hapticManager = HapticManager.shared
    
    // MARK: - State
    @State private var showingNewEntry = false
    @State private var selectedEntry: JournalEntry?
    @State private var searchText = ""
    @State private var selectedTimeframe: Timeframe = .week
    @State private var selectedMoodFilter: Mood?
    @State private var showingAnalytics = false
    
    // MARK: - Enums
    enum Timeframe: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
        case all = "All Time"
        
        var days: Int {
            switch self {
            case .week: return 7
            case .month: return 30
            case .year: return 365
            case .all: return Int.max
            }
        }
    }
    
    // MARK: - Computed Properties
    private var filteredEntries: [JournalEntry] {
        var entries = storageManager.journalEntries
        
        // Apply search filter
        if !searchText.isEmpty {
            entries = entries.filter { entry in
                entry.content.localizedCaseInsensitiveContains(searchText) ||
                entry.gratitude.joined(separator: " ").localizedCaseInsensitiveContains(searchText) ||
                entry.tags.joined(separator: " ").localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply mood filter
        if let mood = selectedMoodFilter {
            entries = entries.filter { $0.mood == mood }
        }
        
        // Apply timeframe filter
        if selectedTimeframe != .all {
            let cutoffDate = Calendar.current.date(byAdding: .day, value: -selectedTimeframe.days, to: Date()) ?? Date()
            entries = entries.filter { $0.date >= cutoffDate }
        }
        
        return entries
    }
    
    private var moodData: [(mood: Mood, count: Int)] {
        let moodCounts = Dictionary(grouping: filteredEntries, by: { $0.mood })
            .mapValues { $0.count }
        
        return Mood.allCases.map { mood in
            (mood: mood, count: moodCounts[mood] ?? 0)
        }
    }
    
    private var streakData: Int {
        // Calculate journaling streak
        let sortedEntries = storageManager.journalEntries.sorted { $0.date > $1.date }
        var streak = 0
        var lastDate = Date()
        
        for entry in sortedEntries {
            let daysDiff = Calendar.current.dateComponents([.day], from: entry.date, to: lastDate).day ?? 0
            if daysDiff <= 1 {
                streak += 1
                lastDate = entry.date
            } else {
                break
            }
        }
        
        return streak
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
                    VStack(spacing: 20) {
                        // Stats overview
                        statsOverview
                            .padding(.horizontal, 20)
                        
                        // Mood chart
                        if !storageManager.journalEntries.isEmpty {
                            moodChart
                                .padding(.horizontal, 20)
                        }
                        
                        // Search and filters
                        searchAndFilters
                            .padding(.horizontal, 20)
                        
                        // Journal entries
                        if filteredEntries.isEmpty {
                            emptyStateView
                                .padding(.top, 40)
                        } else {
                            entriesList
                                .padding(.horizontal, 20)
                        }
                    }
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("Journal")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingNewEntry = true
                        HapticManager.shared.impact(.light)
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.white)
                    }
                }
            }
        }
        .sheet(isPresented: $showingNewEntry) {
            NewJournalEntryView()
                .environmentObject(storageManager)
        }
        .sheet(item: $selectedEntry) { entry in
            JournalEntryDetailView(entry: entry)
                .environmentObject(storageManager)
        }
        .sheet(isPresented: $showingAnalytics) {
            JournalAnalyticsView()
                .environmentObject(storageManager)
        }
    }
    
    // MARK: - Stats Overview
    private var statsOverview: some View {
        HStack(spacing: 12) {
            StatCard(
                title: "Entries",
                value: "\(storageManager.journalEntries.count)",
                icon: "book.fill",
                color: .purple
            )
            
            StatCard(
                title: "Streak",
                value: "\(streakData)",
                icon: "flame.fill",
                color: .orange
            )
            
            StatCard(
                title: "Gratitude",
                value: "\(storageManager.journalEntries.flatMap { $0.gratitude }.count)",
                icon: "heart.fill",
                color: .pink
            )
        }
    }
    
    // MARK: - Mood Chart
    private var moodChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Mood Tracker")
                    .font(Typography.h3)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button {
                    showingAnalytics = true
                } label: {
                    Text("View All")
                        .font(Typography.small)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            // Mood distribution
            HStack(spacing: 8) {
                ForEach(moodData, id: \.mood) { data in
                    VStack(spacing: 6) {
                        // Bar
                        RoundedRectangle(cornerRadius: 4)
                            .fill(data.mood.color)
                            .frame(width: 40, height: CGFloat(data.count) * 10 + 20)
                            .overlay(
                                Text("\(data.count)")
                                    .font(Typography.tiny)
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                            )
                        
                        // Icon
                        Image(systemName: data.mood.icon)
                            .font(.caption)
                            .foregroundColor(data.mood.color)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 120)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
            )
        }
    }
    
    // MARK: - Search and Filters
    private var searchAndFilters: some View {
        VStack(spacing: 12) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.5))
                
                TextField("Search entries...", text: $searchText)
                    .foregroundColor(.white)
                    .autocapitalization(.none)
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
            )
            
            // Filters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    // Timeframe filters
                    ForEach(Timeframe.allCases, id: \.self) { timeframe in
                        JournalFilterChip(
                            title: timeframe.rawValue,
                            isSelected: selectedTimeframe == timeframe
                        ) {
                            withAnimation {
                                selectedTimeframe = timeframe
                            }
                        }
                    }
                    
                    Divider()
                        .frame(height: 20)
                        .background(Color.white.opacity(0.3))
                    
                    // Mood filters
                    ForEach(Mood.allCases, id: \.self) { mood in
                        JournalFilterChip(
                            title: mood.rawValue.capitalized,
                            icon: mood.icon,
                            color: mood.color,
                            isSelected: selectedMoodFilter == mood
                        ) {
                            withAnimation {
                                selectedMoodFilter = selectedMoodFilter == mood ? nil : mood
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Entries List
    private var entriesList: some View {
        VStack(spacing: 12) {
            ForEach(filteredEntries) { entry in
                JournalEntryCard(entry: entry) {
                    selectedEntry = entry
                }
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.closed")
                .font(.system(size: 80))
                .foregroundColor(.white.opacity(0.3))
            
            VStack(spacing: 8) {
                Text("Start Your Journal")
                    .font(Typography.h2)
                    .foregroundColor(.white)
                
                Text("Record your thoughts, track your mood, and practice gratitude")
                    .font(Typography.body)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            CustomButton(
                title: "Write First Entry",
                style: .primary,
                icon: "pencil"
            ) {
                showingNewEntry = true
            }
            .frame(maxWidth: 200)
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(Typography.h3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(Typography.tiny)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
}

// MARK: - Filter Chip
private struct JournalFilterChip: View {
    let title: String
    var icon: String? = nil
    var color: Color = .white
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                Text(title)
                    .font(Typography.tiny)
            }
            .foregroundColor(isSelected ? .white : color.opacity(0.8))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? color.opacity(0.3) : Color.white.opacity(0.1))
                    .overlay(
                        Capsule()
                            .stroke(color.opacity(isSelected ? 0.6 : 0.3), lineWidth: 1)
                    )
            )
        }
    }
}

// MARK: - Journal Entry Card
struct JournalEntryCard: View {
    let entry: JournalEntry
    let onTap: () -> Void
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    // Date
                    Text(dateFormatter.string(from: entry.date))
                        .font(Typography.small)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    // Mood
                    HStack(spacing: 4) {
                        Image(systemName: entry.mood.icon)
                        Text(entry.mood.rawValue.capitalized)
                    }
                    .font(Typography.tiny)
                    .foregroundColor(entry.mood.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(entry.mood.color.opacity(0.2))
                    )
                }
                
                // Content preview
                Text(entry.content)
                    .font(Typography.body)
                    .foregroundColor(.white)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                
                // Gratitude
                if !entry.gratitude.isEmpty {
                    HStack {
                        Image(systemName: "heart.fill")
                            .font(.caption)
                            .foregroundColor(.pink)
                        
                        Text("Grateful for \(entry.gratitude.count) thing\(entry.gratitude.count == 1 ? "" : "s")")
                            .font(Typography.tiny)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                // Tags
                if !entry.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(entry.tags, id: \.self) { tag in
                                Text("#\(tag)")
                                    .font(Typography.tiny)
                                    .foregroundColor(.white.opacity(0.6))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(Color.white.opacity(0.1))
                                    )
                            }
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
            )
        }
    }
}

// MARK: - New Journal Entry View
struct NewJournalEntryView: View {
    @EnvironmentObject var storageManager: StorageManager
    @Environment(\.dismiss) var dismiss
    
    @State private var content = ""
    @State private var selectedMood: Mood = .calm
    @State private var gratitudeItems: [String] = ["", "", ""]
    @State private var tags: [String] = []
    @State private var newTag = ""
    @State private var showingSaveConfirmation = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: GradientTheme.getGradient(for: selectedMood),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Content
                ScrollView {
                    VStack(spacing: 24) {
                        // Mood selector
                        VStack(alignment: .leading, spacing: 12) {
                            Text("How are you feeling?")
                                .font(Typography.h3)
                                .foregroundColor(.white)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(Mood.allCases, id: \.self) { mood in
                                        JournalMoodButton(
                                            mood: mood,
                                            isSelected: selectedMood == mood
                                        ) {
                                            withAnimation {
                                                selectedMood = mood
                                            }
                                            HapticManager.shared.selection()
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Journal entry
                        VStack(alignment: .leading, spacing: 12) {
                            Text("What's on your mind?")
                                .font(Typography.h3)
                                .foregroundColor(.white)
                            
                            TextEditor(text: $content)
                                .font(Typography.body)
                                .foregroundColor(.black)
                                .scrollContentBackground(.hidden)
                                .padding(12)
                                .background(Color.white)
                                .cornerRadius(16)
                                .frame(minHeight: 150)
                        }
                        
                        // Gratitude
                        VStack(alignment: .leading, spacing: 12) {
                            Text("What are you grateful for?")
                                .font(Typography.h3)
                                .foregroundColor(.white)
                            
                            ForEach(0..<3) { index in
                                HStack {
                                    Image(systemName: "heart.fill")
                                        .foregroundColor(.pink)
                                        .frame(width: 30)
                                    
                                    TextField("I'm grateful for...", text: $gratitudeItems[index])
                                        .font(Typography.body)
                                        .foregroundColor(.black)
                                        .padding(12)
                                        .background(Color.white)
                                        .cornerRadius(12)
                                }
                            }
                        }
                        
                        // Tags
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Tags")
                                .font(Typography.h3)
                                .foregroundColor(.white)
                            
                            // Existing tags
                            if !tags.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(tags, id: \.self) { tag in
                                            HStack(spacing: 4) {
                                                Text("#\(tag)")
                                                    .font(Typography.small)
                                                
                                                Button {
                                                    tags.removeAll { $0 == tag }
                                                } label: {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .font(.caption)
                                                }
                                            }
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(
                                                Capsule()
                                                    .fill(Color.white.opacity(0.2))
                                            )
                                        }
                                    }
                                }
                            }
                            
                            // Add new tag
                            HStack {
                                TextField("Add a tag...", text: $newTag)
                                    .font(Typography.body)
                                    .foregroundColor(.black)
                                    .padding(12)
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .onSubmit {
                                        if !newTag.isEmpty {
                                            tags.append(newTag)
                                            newTag = ""
                                        }
                                    }
                                
                                Button {
                                    if !newTag.isEmpty {
                                        tags.append(newTag)
                                        newTag = ""
                                    }
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                    .padding(24)
                }
            }
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveEntry()
                    }
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                    .disabled(content.isEmpty)
                }
            }
        }
        .alert("Entry Saved!", isPresented: $showingSaveConfirmation) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your journal entry has been saved successfully.")
        }
    }
    
    private func saveEntry() {
        let entry = JournalEntry(
            content: content,
            mood: selectedMood,
            gratitude: gratitudeItems.filter { !$0.isEmpty },
            tags: tags
        )
        
        storageManager.addJournalEntry(entry)
        HapticManager.shared.notification(.success)
        showingSaveConfirmation = true
    }
}

// MARK: - Mood Button
private struct JournalMoodButton: View {
    let mood: Mood
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: mood.icon)
                    .font(.title2)
                    .foregroundColor(mood.color)
                
                Text(mood.rawValue.capitalized)
                    .font(Typography.small)
                    .foregroundColor(.white)
            }
            .frame(width: 80, height: 80)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? mood.color.opacity(0.3) : .ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(mood.color.opacity(isSelected ? 0.8 : 0.3), lineWidth: 2)
                    )
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
        }
    }
}

// MARK: - Journal Entry Detail View
struct JournalEntryDetailView: View {
    let entry: JournalEntry
    @EnvironmentObject var storageManager: StorageManager
    @Environment(\.dismiss) var dismiss
    @State private var showingDeleteConfirmation = false
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: GradientTheme.getGradient(for: entry.mood),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Date and mood
                        VStack(alignment: .leading, spacing: 12) {
                            Text(dateFormatter.string(from: entry.date))
                                .font(Typography.h3)
                                .foregroundColor(.white)
                            
                            HStack(spacing: 12) {
                                Label(entry.mood.rawValue.capitalized, systemImage: entry.mood.icon)
                                    .font(Typography.body)
                                    .foregroundColor(entry.mood.color)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(entry.mood.color.opacity(0.3))
                                    )
                                
                                Text(timeFormatter.string(from: entry.date))
                                    .font(Typography.small)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                        
                        // Content
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Entry")
                                .font(Typography.caption)
                                .foregroundColor(.white.opacity(0.7))
                                .textCase(.uppercase)
                            
                            Text(entry.content)
                                .font(Typography.body)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(.ultraThinMaterial)
                                )
                        }
                        
                        // Gratitude
                        if !entry.gratitude.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Gratitude")
                                    .font(Typography.caption)
                                    .foregroundColor(.white.opacity(0.7))
                                    .textCase(.uppercase)
                                
                                ForEach(entry.gratitude, id: \.self) { item in
                                    HStack(spacing: 12) {
                                        Image(systemName: "heart.fill")
                                            .foregroundColor(.pink)
                                        
                                        Text(item)
                                            .font(Typography.body)
                                            .foregroundColor(.white)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(.ultraThinMaterial)
                                    )
                                }
                            }
                        }
                        
                        // Tags
                        if !entry.tags.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Tags")
                                    .font(Typography.caption)
                                    .foregroundColor(.white.opacity(0.7))
                                    .textCase(.uppercase)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(entry.tags, id: \.self) { tag in
                                            Text("#\(tag)")
                                                .font(Typography.small)
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(
                                                    Capsule()
                                                        .fill(Color.white.opacity(0.2))
                                                )
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingDeleteConfirmation = true
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .confirmationDialog("Delete Entry?", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                storageManager.deleteJournalEntry(entry)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
    }
}

// MARK: - Preview
#Preview {
    JournalTab()
        .environmentObject(StorageManager.shared)
}