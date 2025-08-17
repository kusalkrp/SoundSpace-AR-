// SpeakerCommunityView.swift
// Soundspace-AR
//
// Created by Assistant on 2025-08-17.
//

import SwiftUI
import CoreData

struct SpeakerCommunityView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var authManager: AuthenticationManager
    
    @State private var searchText = ""
    @State private var selectedCategory: SpeakerCategory?
    @State private var selectedPriceRange: PriceRange?
    @State private var showingFilters = false
    @State private var showingAddReview = false
    @State private var selectedSpeaker: SpeakerModel?
    @State private var speakerDB: SpeakerDatabaseManager?
    
    var filteredSpeakers: [SpeakerModel] {
        speakerDB?.searchSpeakers(
            query: searchText,
            category: selectedCategory,
            priceRange: selectedPriceRange
        ) ?? []
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search and Filter Bar
            searchAndFilterBar
            
            // Content
            if filteredSpeakers.isEmpty && speakerDB != nil {
                emptyStateView
            } else {
                speakersList
            }
        }
        .navigationTitle("Speaker Community")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Filters") {
                    showingFilters = true
                }
            }
        }
        .sheet(isPresented: $showingFilters) {
            FilterSheet(
                selectedCategory: $selectedCategory,
                selectedPriceRange: $selectedPriceRange
            )
        }
        .sheet(item: $selectedSpeaker) { speaker in
            NavigationView {
                SpeakerDetailView(speaker: speaker)
            }
        }
        .onAppear {
            if speakerDB == nil {
                speakerDB = SpeakerDatabaseManager(context: viewContext)
            }
        }
        .refreshable {
            speakerDB?.fetchData()
        }
    }
    
    private var searchAndFilterBar: some View {
        VStack(spacing: 12) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search speakers, brands...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                if !searchText.isEmpty {
                    Button("Clear") {
                        searchText = ""
                    }
                    .foregroundColor(.blue)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            // Active Filters
            if selectedCategory != nil || selectedPriceRange != nil {
                activeFiltersView
            }
        }
        .padding()
    }
    
    private var activeFiltersView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                if let category = selectedCategory {
                    FilterChip(
                        title: category.rawValue,
                        onRemove: { selectedCategory = nil }
                    )
                }
                
                if let priceRange = selectedPriceRange {
                    FilterChip(
                        title: priceRange.rawValue,
                        onRemove: { selectedPriceRange = nil }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "speaker.slash")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No speakers found")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Try adjusting your search or filters")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button("Clear Filters") {
                searchText = ""
                selectedCategory = nil
                selectedPriceRange = nil
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var speakersList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(speakerDB?.speakerBrands ?? [], id: \.id) { brand in
                    let brandSpeakers = filteredSpeakers.filter { $0.brand == brand }
                    
                    if !brandSpeakers.isEmpty {
                        BrandSection(brand: brand, speakers: brandSpeakers) { speaker in
                            selectedSpeaker = speaker
                        }
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - Supporting Views

struct FilterSheet: View {
    @Binding var selectedCategory: SpeakerCategory?
    @Binding var selectedPriceRange: PriceRange?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 24) {
                // Category Filter
                VStack(alignment: .leading, spacing: 12) {
                    Text("Category")
                        .font(.headline)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 8) {
                        ForEach(SpeakerCategory.allCases) { category in
                            Button(action: {
                                selectedCategory = selectedCategory == category ? nil : category
                            }) {
                                HStack {
                                    Image(systemName: category.icon)
                                    Text(category.rawValue)
                                        .font(.subheadline)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(selectedCategory == category ? Color.blue : Color(.systemGray6))
                                .foregroundColor(selectedCategory == category ? .white : .primary)
                                .cornerRadius(8)
                            }
                        }
                    }
                }
                
                // Price Range Filter
                VStack(alignment: .leading, spacing: 12) {
                    Text("Price Range")
                        .font(.headline)
                    
                    VStack(spacing: 8) {
                        ForEach(PriceRange.allCases) { priceRange in
                            Button(action: {
                                selectedPriceRange = selectedPriceRange == priceRange ? nil : priceRange
                            }) {
                                HStack {
                                    Circle()
                                        .fill(priceRange.color)
                                        .frame(width: 12, height: 12)
                                    
                                    Text(priceRange.rawValue)
                                        .font(.subheadline)
                                    
                                    Spacer()
                                    
                                    if selectedPriceRange == priceRange {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Clear All") {
                        selectedCategory = nil
                        selectedPriceRange = nil
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FilterChip: View {
    let title: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
            
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.caption)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.blue)
        .foregroundColor(.white)
        .cornerRadius(16)
    }
}

struct BrandSection: View {
    let brand: SpeakerBrand
    let speakers: [SpeakerModel]
    let onSpeakerTap: (SpeakerModel) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Brand Header
            HStack {
                Text(brand.name ?? "Unknown Brand")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("\(speakers.count) models")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Speaker Cards
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(speakers, id: \.id) { speaker in
                    SpeakerCard(speaker: speaker) {
                        onSpeakerTap(speaker)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct SpeakerCard: View {
    let speaker: SpeakerModel
    let onTap: () -> Void
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.managedObjectContext) private var viewContext
    
    var isInWishlist: Bool {
        guard let user = authManager.currentUser as? User else { return false }
        
        let request: NSFetchRequest<WishlistItem> = WishlistItem.fetchRequest()
        request.predicate = NSPredicate(format: "speakerModel == %@ AND user == %@", speaker, user)
        
        do {
            let count = try viewContext.count(for: request)
            return count > 0
        } catch {
            return false
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // Speaker Image Placeholder
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray5))
                    .frame(height: 120)
                    .overlay(
                        VStack {
                            Image(systemName: "speaker.3")
                                .font(.title)
                                .foregroundColor(.secondary)
                            
                            if let type = speaker.type {
                                Text(type)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    )
                
                // Speaker Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(speaker.name ?? "Unknown Speaker")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(2)
                    
                    if let modelNumber = speaker.modelNumber {
                        Text(modelNumber)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Rating
                    HStack(spacing: 4) {
                        ForEach(0..<Int(speaker.averageRating), id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(.yellow)
                        }
                        
                        Text(String(format: "%.1f", speaker.averageRating))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("(\(speaker.reviewCount))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Price Range
                    if let priceRange = speaker.priceRange,
                       let range = PriceRange(rawValue: priceRange) {
                        Text(range.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(range.color)
                    }
                }
                
                // Wishlist Button
                HStack {
                    Spacer()
                    
                    Button(action: toggleWishlist) {
                        Image(systemName: isInWishlist ? "heart.fill" : "heart")
                            .foregroundColor(isInWishlist ? .red : .secondary)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func toggleWishlist() {
        guard let user = authManager.currentUser as? User else { return }
        
        if isInWishlist {
            let request: NSFetchRequest<WishlistItem> = WishlistItem.fetchRequest()
            request.predicate = NSPredicate(format: "speakerModel == %@ AND user == %@", speaker, user)
            
            do {
                let items = try viewContext.fetch(request)
                for item in items {
                    viewContext.delete(item)
                }
                try viewContext.save()
            } catch {
                print("Error removing from wishlist: \(error)")
            }
        } else {
            let wishlistItem = WishlistItem(context: viewContext)
            wishlistItem.id = UUID()
            wishlistItem.addedAt = Date()
            wishlistItem.speakerModel = speaker
            wishlistItem.user = user
            
            do {
                try viewContext.save()
            } catch {
                print("Error adding to wishlist: \(error)")
            }
        }
    }
}

struct SpeakerCommunityView_Previews: PreviewProvider {
    static var previews: some View {
        let authManager = AuthenticationManager()
        
        return NavigationView {
            SpeakerCommunityView()
        }
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(authManager)
    }
}
