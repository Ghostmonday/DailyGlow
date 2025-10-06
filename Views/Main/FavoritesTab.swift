//
//  FavoritesTab.swift
//  DailyGlow
//
//  Tab displaying user's favorite affirmations in a beautiful grid
//

import SwiftUI

struct FavoritesTab: View {
    // MARK: - Environment
    @EnvironmentObject var affirmationService: AffirmationService
    
    // MARK: - State
    @State private var searchText = ""
    @State private var sortOption: SortOption = .dateAdded
    @State private var viewMode: ViewMode = .grid
    @State private var selectedCategory: Category?
    @State private var showingExportSheet = false
    @State private var exportText = ""
    @State private var selectedAffirmation: Affirmation?
    @State private var showingDetail = false
    
    // MARK: - Enums
    enum SortOption: String, CaseIterable {
        case dateAdded = "Date Added"
        case category = "Category"
        case mood = "Mood"
        case alphabetical = "A-Z"
        
        var icon: String {
            switch self {
            case .dateAdded: return "calendar"
            case .category: return "square.grid.2x2"
            case .mood: return "heart"
            case .alphabetical: return "textformat"
            }
        }
    }
    
    enum ViewMode: String, CaseIterable {
        case grid = "Grid"
        case list = "List"
        case card = "Card"
        
        var icon: String {
            switch self {
            case .grid: return "square.grid.2x2"
            case .list: return "list.bullet"
            case .card: return "rectangle.stack"
            }
        }
    }
    
    // MARK: - Computed Properties
    private var filteredFavorites: [Affirmation] {
        var favorites = affirmationService.favoriteAffirmations
        
        // Apply search filter
        if !searchText.isEmpty {
            favorites = favorites.filter { affirmation in
                affirmation.text.localizedCaseInsensitiveContains(searchText) ||
                affirmation.category.displayName.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply category filter
        if let category = selectedCategory {
            favorites = favorites.filter { $0.category == category }
        }
        
        // Apply sorting
        switch sortOption {
        case .dateAdded:
            // Already in order
            break
        case .category:
            favorites.sort { $0.category.displayName < $1.category.displayName }
        case .mood:
            favorites.sort { $0.mood.rawValue < $1.mood.rawValue }
        case .alphabetical:
            favorites.sort { $0.text < $1.text }
        }
        
        return favorites
    }
    
    private var categories: [Category] {
        let allCategories = Set(affirmationService.favoriteAffirmations.map { $0.category })
        return Array(allCategories).sorted { $0.displayName < $1.displayName }
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: GradientTheme.getGradient(for: .evening),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Content
                if affirmationService.favoriteAffirmations.isEmpty {
                    emptyStateView
                } else {
                    VStack(spacing: 0) {
                        // Search and filters
                        headerControls
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                        
                        // Category filter
                        if !categories.isEmpty {
                            categoryFilter
                                .padding(.horizontal, 20)
                                .padding(.top, 12)
                        }
                        
                        // Favorites content
                        ScrollView {
                            contentView
                                .padding(.horizontal, 20)
                                .padding(.vertical, 20)
                        }
                    }
                }
            }
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        // View mode options
                        Section("View Mode") {
                            ForEach(ViewMode.allCases, id: \.self) { mode in
                                Button {
                                    withAnimation {
                                        viewMode = mode
                                    }
                                } label: {
                                    Label(
                                        mode.rawValue,
                                        systemImage: mode.icon
                                    )
                                }
                            }
                        }
                        
                        // Sort options
                        Section("Sort By") {
                            ForEach(SortOption.allCases, id: \.self) { option in
                                Button {
                                    withAnimation {
                                        sortOption = option
                                    }
                                } label: {
                                    Label(
                                        option.rawValue,
                                        systemImage: option.icon
                                    )
                                }
                            }
                        }
                        
                        Divider()
                        
                        // Export action
                        Button {
                            exportFavorites()
                        } label: {
                            Label("Export Favorites", systemImage: "square.and.arrow.up")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle.fill")
                            .font(.title3)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.white)
                    }
                }
            }
        }
        .sheet(isPresented: $showingExportSheet) {
            ShareSheet(items: [exportText])
        }
        .sheet(item: $selectedAffirmation) { affirmation in
            AffirmationDetailSheet(
                affirmation: affirmation,
                isFavorite: affirmationService.isFavorite(affirmation),
                onToggleFavorite: {
                    affirmationService.toggleFavorite(affirmation)
                }
            )
        }
    }
    
    // MARK: - Header Controls
    private var headerControls: some View {
        HStack(spacing: 12) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.5))
                
                TextField("Search favorites...", text: $searchText)
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
            
            // View mode toggle
            Button {
                let modes = ViewMode.allCases
                if let currentIndex = modes.firstIndex(of: viewMode) {
                    let nextIndex = (currentIndex + 1) % modes.count
                    withAnimation {
                        viewMode = modes[nextIndex]
                    }
                    HapticManager.shared.selection()
                }
            } label: {
                Image(systemName: viewMode.icon)
                    .font(.title3)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                    )
            }
        }
    }
    
    // MARK: - Category Filter
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                // All categories
                CategoryChip(
                    title: "All",
                    icon: "square.grid.3x3",
                    color: .white,
                    isSelected: selectedCategory == nil
                ) {
                    withAnimation {
                        selectedCategory = nil
                    }
                }
                
                // Individual categories
                ForEach(categories, id: \.self) { category in
                    CategoryChip(
                        title: category.displayName,
                        icon: category.icon,
                        color: category.color,
                        isSelected: selectedCategory == category
                    ) {
                        withAnimation {
                            selectedCategory = selectedCategory == category ? nil : category
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Content View
    @ViewBuilder
    private var contentView: some View {
        switch viewMode {
        case .grid:
            gridView
        case .list:
            listView
        case .card:
            cardView
        }
    }
    
    private var gridView: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ], spacing: 16) {
            ForEach(filteredFavorites) { affirmation in
                FavoriteGridItem(affirmation: affirmation) {
                    selectedAffirmation = affirmation
                } onToggleFavorite: {
                    affirmationService.toggleFavorite(affirmation)
                }
            }
        }
    }
    
    private var listView: some View {
        VStack(spacing: 12) {
            ForEach(filteredFavorites) { affirmation in
                FavoriteListItem(affirmation: affirmation) {
                    selectedAffirmation = affirmation
                } onToggleFavorite: {
                    affirmationService.toggleFavorite(affirmation)
                }
            }
        }
    }
    
    private var cardView: some View {
        VStack(spacing: 20) {
            ForEach(filteredFavorites) { affirmation in
                FavoriteCardItem(affirmation: affirmation) {
                    selectedAffirmation = affirmation
                } onToggleFavorite: {
                    affirmationService.toggleFavorite(affirmation)
                }
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.slash")
                .font(.system(size: 80))
                .foregroundColor(.white.opacity(0.3))
            
            VStack(spacing: 8) {
                Text("No Favorites Yet")
                    .font(Typography.h2)
                    .foregroundColor(.white)
                
                Text("Swipe right on affirmations or tap the heart to add them to your favorites")
                    .font(Typography.body)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
    }
    
    // MARK: - Helper Methods
    private func exportFavorites() {
        exportText = affirmationService.exportFavorites()
        showingExportSheet = true
    }
}

// MARK: - Grid Item View
struct FavoriteGridItem: View {
    let affirmation: Affirmation
    let onTap: () -> Void
    let onToggleFavorite: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Category badge
                HStack {
                    Image(systemName: affirmation.category.icon)
                        .font(.caption)
                    Text(affirmation.category.displayName)
                        .font(Typography.tiny)
                }
                .foregroundColor(affirmation.category.color)
                
                // Affirmation text
                Text(affirmation.text)
                    .font(Typography.small)
                    .foregroundColor(.white)
                    .lineLimit(4)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                // Bottom row
                HStack {
                    // Mood indicator
                    Image(systemName: affirmation.mood.icon)
                        .font(.caption)
                        .foregroundColor(affirmation.mood.color)
                    
                    Spacer()
                    
                    // Favorite button
                    Button {
                        onToggleFavorite()
                        HapticManager.shared.playFavoriteToggle(isFavorited: false)
                    } label: {
                        Image(systemName: "heart.fill")
                            .font(.body)
                            .foregroundColor(.pink)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 180)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
    }
}

// MARK: - List Item View
struct FavoriteListItem: View {
    let affirmation: Affirmation
    let onTap: () -> Void
    let onToggleFavorite: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Category icon
                Image(systemName: affirmation.category.icon)
                    .font(.title2)
                    .foregroundColor(affirmation.category.color)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(affirmation.category.color.opacity(0.2))
                    )
                
                // Content
                VStack(alignment: .leading, spacing: 6) {
                    Text(affirmation.text)
                        .font(Typography.small)
                        .foregroundColor(.white)
                        .lineLimit(2)
                    
                    HStack(spacing: 8) {
                        Label(affirmation.category.displayName, systemImage: affirmation.category.icon)
                            .font(Typography.tiny)
                            .foregroundColor(.white.opacity(0.6))
                        
                        Text("•")
                            .foregroundColor(.white.opacity(0.4))
                        
                        Label(affirmation.mood.rawValue.capitalized, systemImage: affirmation.mood.icon)
                            .font(Typography.tiny)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                
                Spacer()
                
                // Favorite button
                Button {
                    onToggleFavorite()
                    HapticManager.shared.playFavoriteToggle(isFavorited: false)
                } label: {
                    Image(systemName: "heart.fill")
                        .font(.title3)
                        .foregroundColor(.pink)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
            )
        }
    }
}

// MARK: - Card Item View
struct FavoriteCardItem: View {
    let affirmation: Affirmation
    let onTap: () -> Void
    let onToggleFavorite: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Label(affirmation.category.displayName, systemImage: affirmation.category.icon)
                        .font(Typography.small)
                        .foregroundColor(affirmation.category.color)
                    
                    Spacer()
                    
                    Button {
                        onToggleFavorite()
                        HapticManager.shared.playFavoriteToggle(isFavorited: false)
                    } label: {
                        Image(systemName: "heart.fill")
                            .font(.title3)
                            .foregroundColor(.pink)
                    }
                }
                .padding()
                .background(
                    affirmation.category.color.opacity(0.1)
                )
                
                // Content
                Text(affirmation.text)
                    .font(Typography.body)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 32)
                    .frame(maxWidth: .infinity)
                
                // Footer
                HStack {
                    Label(affirmation.mood.rawValue.capitalized, systemImage: affirmation.mood.icon)
                        .font(Typography.small)
                        .foregroundColor(affirmation.mood.color)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding()
                .background(
                    Color.white.opacity(0.05)
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [
                                affirmation.category.color.opacity(0.3),
                                affirmation.category.color.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
        }
    }
}

// MARK: - Category Chip
struct CategoryChip: View {
    let title: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(Typography.tiny)
            }
            .foregroundColor(isSelected ? .white : color)
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

// MARK: - Detail Sheet
struct AffirmationDetailSheet: View {
    let affirmation: Affirmation
    let isFavorite: Bool
    let onToggleFavorite: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: GradientTheme.getGradient(for: affirmation.mood),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Content
                ScrollView {
                    VStack(spacing: 30) {
                        // Affirmation text
                        Text(affirmation.text)
                            .font(Typography.h2)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                            .padding(.top, 40)
                        
                        // Metadata
                        VStack(spacing: 16) {
                            MetadataRow(
                                icon: affirmation.category.icon,
                                label: "Category",
                                value: affirmation.category.displayName,
                                color: affirmation.category.color
                            )
                            
                            MetadataRow(
                                icon: affirmation.mood.icon,
                                label: "Mood",
                                value: affirmation.mood.rawValue.capitalized,
                                color: affirmation.mood.color
                            )
                        }
                        .padding(.horizontal, 30)
                        
                        // Actions
                        VStack(spacing: 12) {
                            CustomButton(
                                title: isFavorite ? "Remove from Favorites" : "Add to Favorites",
                                style: .primary,
                                icon: isFavorite ? "heart.slash" : "heart.fill"
                            ) {
                                onToggleFavorite()
                                dismiss()
                            }
                            
                            CustomButton(
                                title: "Share",
                                style: .secondary,
                                icon: "square.and.arrow.up"
                            ) {
                                // Share action
                            }
                        }
                        .padding(.horizontal, 30)
                        .padding(.bottom, 40)
                    }
                }
            }
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
}

struct MetadataRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Label(label, systemImage: icon)
                .font(Typography.small)
                .foregroundColor(.white.opacity(0.7))
            
            Spacer()
            
            Text(value)
                .font(Typography.small)
                .fontWeight(.medium)
                .foregroundColor(color)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

// MARK: - Preview
#Preview {
    FavoritesTab()
        .environmentObject(AffirmationService())
}