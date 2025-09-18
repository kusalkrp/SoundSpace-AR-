// SpeakerCommunityView.swift
// Soundspace-AR
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
    @State private var selectedTab = 0
    @State private var showingShareSheet = false
    
    enum CommunityTab: Int, CaseIterable {
        case speakers, placements, layouts, reviews
        
        var title: String {
            switch self {
            case .speakers: return "Speakers"
            case .placements: return "Placements"
            case .layouts: return "Layouts"
            case .reviews: return "Reviews"
            }
        }
        
        var icon: String {
            switch self {
            case .speakers: return "speaker.3"
            case .placements: return "arrow.up.and.down.and.arrow.left.and.right"
            case .layouts: return "square.stack.3d.up"
            case .reviews: return "star"
            }
        }
    }
    
    var filteredSpeakers: [SpeakerModel] {
        speakerDB?.searchSpeakers(
            query: searchText,
            category: selectedCategory,
            priceRange: selectedPriceRange
        ) ?? []
    }
    
    var body: some View {
        ZStack {
            // Background gradient (same as other views)
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.4, green: 0.5, blue: 1.0),
                    Color(red: 0.3, green: 0.4, blue: 0.9)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Single white card container for both tabs and content
                VStack(spacing: 0) {
                    // Tab selector at the top
                    tabSelector
                    
                    // Content based on selected tab
                    Group {
                        switch CommunityTab(rawValue: selectedTab) {
                        case .speakers:
                            speakersContent
                        case .placements:
                            placementsContent
                        case .layouts:
                            layoutsContent
                        case .reviews:
                            reviewsContent
                        default:
                            speakersContent
                        }
                    }
                }
                .background(Color.white)
                .cornerRadius(32)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
        }
        .navigationTitle("Speaker Community")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 32) {
                    Button(action: {
                        showingFilters = true
                    }) {
                        Image(systemName: "line.horizontal.3.decrease.circle")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.blue)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    
                    Button(action: {
                        showingShareSheet = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.blue)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                }
                .padding(.trailing, 8)
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
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet()
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
    
    private var tabSelector: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(CommunityTab.allCases, id: \.rawValue) { tab in
                        Button(action: {
                            selectedTab = tab.rawValue
                        }) {
                            VStack(spacing: 8) {
                                Image(systemName: tab.icon)
                                    .font(.system(size: 20))
                                
                                Text(tab.title)
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .frame(minWidth: 80)
                            .padding(.vertical, 12)
                            .background(selectedTab == tab.rawValue ? Color.blue.opacity(0.1) : Color.clear)
                            .foregroundColor(selectedTab == tab.rawValue ? .blue : .secondary)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
            }
            
            // Separator line
            Divider()
                .padding(.horizontal)
        }
    }
    
    private var speakersContent: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Search and Filter Bar
                searchAndFilterBar
                
                // Content
                if filteredSpeakers.isEmpty && speakerDB != nil {
                    emptyStateView
                } else {
                    speakersList
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 32)
        }
    }
    
    private var placementsContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Community Speaker Placements")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                if let reviews = speakerDB?.recentReviews.filter({
                    guard let photos = $0.setupPhotos as? [Data] else { return false }
                    return !photos.isEmpty
                }) {
                    if reviews.isEmpty {
                        emptyPlacementsView
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(reviews, id: \.id) { review in
                                PlacementCard(review: review)
                            }
                        }
                        .padding(.horizontal)
                    }
                } else {
                    emptyPlacementsView
                }
            }
            .padding(.vertical, 32)
        }
    }
    
    private var layoutsContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Shared Speaker Layouts")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                // Fetch shared layouts from all users
                let layouts = fetchSharedLayouts()
                
                if layouts.isEmpty {
                    emptyLayoutsView
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(layouts, id: \.id) { layout in
                            LayoutCard(layout: layout)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical, 32)
        }
    }
    
    private var reviewsContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Speaker Reviews")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                if let reviews = speakerDB?.recentReviews {
                    if reviews.isEmpty {
                        emptyReviewsView
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(reviews, id: \.id) { review in
                                CommunityReviewCard(review: review)
                            }
                        }
                        .padding(.horizontal)
                    }
                } else {
                    emptyReviewsView
                }
            }
            .padding(.vertical, 32)
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
    }
    
    private var emptyPlacementsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "arrow.up.and.down.and.arrow.left.and.right")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No speaker placements yet")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Be the first to share your speaker setup!")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: 300)
    }
    
    private var emptyLayoutsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.stack.3d.up")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No shared layouts yet")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Share your speaker layouts with the community")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: 300)
    }
    
    private var emptyReviewsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "star")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No reviews yet")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Write the first review for a speaker")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: 300)
    }
    
    private func fetchSharedLayouts() -> [SavedLayout] {
        let request: NSFetchRequest<SavedLayout> = SavedLayout.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \SavedLayout.createdAt, ascending: false)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching shared layouts: \(error)")
            return []
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

// MARK: - Community Card Views

struct PlacementCard: View {
    let review: SpeakerReview
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with user and speaker info
            HStack {
                VStack(alignment: .leading) {
                    Text(review.user?.username ?? "Anonymous")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(review.speakerModel?.name ?? "Unknown Speaker")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if let roomSize = review.roomSize {
                    Text(roomSize)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                }
            }
            
            // Setup photos
            if let photos = review.setupPhotos as? [Data], !photos.isEmpty {
                TabView {
                    ForEach(photos, id: \.self) { photoData in
                        if let uiImage = UIImage(data: photoData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .clipped()
                                .cornerRadius(8)
                        }
                    }
                }
                .frame(height: 200)
                .tabViewStyle(PageTabViewStyle())
            }
            
            // Review content
            if let content = review.content, !content.isEmpty {
                Text(content)
                    .font(.body)
                    .lineLimit(3)
            }
            
            // Rating
            HStack {
                ForEach(0..<Int(review.rating), id: \.self) { _ in
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                }
                
                Text("(\(review.rating)/5)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(review.createdAt?.formatted(.relative(presentation: .named)) ?? "")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct LayoutCard: View {
    let layout: SavedLayout
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading) {
                    Text(layout.name ?? "Unnamed Layout")
                        .font(.headline)
                    
                    Text(layout.user?.username ?? "Anonymous")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(layout.roomType ?? "Unknown Room")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.1))
                        .foregroundColor(.green)
                        .cornerRadius(8)
                    
                    Text(layout.audioSystemType ?? "")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            // Layout visualization placeholder
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray5))
                .frame(height: 150)
                .overlay(
                    VStack {
                        Image(systemName: "square.stack.3d.up")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        
                        Text("Speaker Layout")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if let positions = layout.speakerPositions as? [[String: Any]], !positions.isEmpty {
                            Text("\(positions.count) speakers")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                )
            
            // Timestamp
            HStack {
                Spacer()
                Text(layout.createdAt?.formatted(.relative(presentation: .named)) ?? "")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct CommunityReviewCard: View {
    let review: SpeakerReview
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading) {
                    Text(review.user?.username ?? "Anonymous")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(review.speakerModel?.name ?? "Unknown Speaker")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Rating stars
                HStack(spacing: 2) {
                    ForEach(0..<Int(review.rating), id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                    }
                }
            }
            
            // Review title
            if let title = review.title, !title.isEmpty {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            
            // Review content
            if let content = review.content, !content.isEmpty {
                Text(content)
                    .font(.body)
                    .lineLimit(4)
            }
            
            // Setup details
            HStack {
                if let roomSize = review.roomSize {
                    Label(roomSize, systemImage: "house")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let systemType = review.systemType {
                    Label(systemType, systemImage: "speaker.3")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(review.createdAt?.formatted(.relative(presentation: .named)) ?? "")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct ShareSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedShareType = 0
    
    let shareTypes = ["Speaker Placement", "Layout", "Review"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Share with Community")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Choose what you'd like to share")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                VStack(spacing: 16) {
                    ForEach(0..<shareTypes.count, id: \.self) { index in
                        Button(action: {
                            selectedShareType = index
                            // Here you would navigate to the appropriate sharing view
                            // For now, just dismiss
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: shareIcon(for: index))
                                    .font(.title2)
                                    .frame(width: 40)
                                
                                VStack(alignment: .leading) {
                                    Text(shareTypes[index])
                                        .font(.headline)
                                    
                                    Text(shareDescription(for: index))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func shareIcon(for index: Int) -> String {
        switch index {
        case 0: return "arrow.up.and.down.and.arrow.left.and.right"
        case 1: return "square.stack.3d.up"
        case 2: return "star"
        default: return "square.and.arrow.up"
        }
    }
    
    private func shareDescription(for index: Int) -> String {
        switch index {
        case 0: return "Share photos of your speaker setup"
        case 1: return "Share your saved speaker layouts"
        case 2: return "Write a review for a speaker"
        default: return ""
        }
    }
}
