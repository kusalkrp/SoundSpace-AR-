// SpeakerDetailView.swift
// Soundspace-AR
//
// Created by Assistant on 2025-08-17.
//

import SwiftUI
import CoreData

struct SpeakerDetailView: View {
    let speaker: SpeakerModel
    
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var speakerDB: SpeakerDatabaseManager
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingReviewSheet = false
    @State private var showingImageGallery = false
    
    @FetchRequest private var reviews: FetchedResults<SpeakerReview>
    
    init(speaker: SpeakerModel) {
        self.speaker = speaker
        self._reviews = FetchRequest(
            entity: SpeakerReview.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \SpeakerReview.createdAt, ascending: false)],
            predicate: NSPredicate(format: "speakerModel == %@", speaker)
        )
    }
    
    var isInWishlist: Bool {
        guard let user = authManager.currentUser as? User else { return false }
        return speakerDB.isInWishlist(speaker: speaker, user: user)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Hero Section
                heroSection
                
                // Specifications
                specificationsSection
                
                // Reviews Summary
                reviewsSummarySection
                
                // Reviews List
                reviewsListSection
                
                Spacer(minLength: 100)
            }
            .padding()
        }
        .navigationTitle(speaker.name ?? "Speaker")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    // Wishlist Button
                    Button(action: toggleWishlist) {
                        Image(systemName: isInWishlist ? "heart.fill" : "heart")
                            .foregroundColor(isInWishlist ? .red : .primary)
                    }
                    
                    // Share Button
                    Button(action: shareSpeker) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
        .sheet(isPresented: $showingReviewSheet) {
            NavigationView {
                AddReviewView(speaker: speaker)
            }
        }
    }
    
    private var heroSection: some View {
        VStack(spacing: 16) {
            // Speaker Image
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray5))
                .frame(height: 200)
                .overlay(
                    VStack {
                        Image(systemName: "speaker.3")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        
                        Text(speaker.type ?? "Speaker")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                )
                .onTapGesture {
                    showingImageGallery = true
                }
            
            // Basic Info
            VStack(alignment: .leading, spacing: 8) {
                Text(speaker.brand?.name ?? "Unknown Brand")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(speaker.name ?? "Unknown Speaker")
                    .font(.title)
                    .fontWeight(.bold)
                
                if let modelNumber = speaker.modelNumber {
                    Text("Model: \(modelNumber)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Rating
                HStack(spacing: 8) {
                    HStack(spacing: 2) {
                        ForEach(0..<5) { index in
                            Image(systemName: index < Int(speaker.averageRating) ? "star.fill" : "star")
                                .foregroundColor(.yellow)
                                .font(.subheadline)
                        }
                    }
                    
                    Text(String(format: "%.1f", speaker.averageRating))
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text("(\(speaker.reviewCount) reviews)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Price Range
                if let priceRange = speaker.priceRange,
                   let range = PriceRange(rawValue: priceRange) {
                    Text(range.rawValue)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(range.color)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Action Buttons
            HStack(spacing: 16) {
                Button("Add Review") {
                    showingReviewSheet = true
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                
                Button(isInWishlist ? "Remove from Wishlist" : "Add to Wishlist") {
                    toggleWishlist()
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    private var specificationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Specifications")
                .font(.headline)
            
            VStack(spacing: 8) {
                if let frequency = speaker.frequencyResponse {
                    SpecRow(title: "Frequency Response", value: frequency)
                }
                
                if let power = speaker.powerRating {
                    SpecRow(title: "Power Rating", value: power)
                }
                
                if let dimensions = speaker.dimensions {
                    SpecRow(title: "Dimensions", value: dimensions)
                }
                
                if let weight = speaker.weight {
                    SpecRow(title: "Weight", value: weight)
                }
                
                if let type = speaker.type {
                    SpecRow(title: "Type", value: type)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    private var reviewsSummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Reviews")
                    .font(.headline)
                
                Spacer()
                
                Button("Write Review") {
                    showingReviewSheet = true
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            
            if !reviews.isEmpty {
                // Rating Breakdown
                VStack(spacing: 8) {
                    ForEach(Array(1...5).reversed(), id: \.self) { rating in
                        RatingBreakdownRow(
                            rating: rating,
                            count: reviews.filter { $0.rating == rating }.count,
                            total: reviews.count
                        )
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
    }
    
    private var reviewsListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if reviews.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "star")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    
                    Text("No reviews yet")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Be the first to review this speaker!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button("Write First Review") {
                        showingReviewSheet = true
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ForEach(Array(reviews.prefix(10)), id: \.id) { review in
                    ReviewCard(review: review)
                }
                
                if reviews.count > 10 {
                    Button("View All \(reviews.count) Reviews") {
                        // Navigate to full reviews list
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
        }
    }
    
    private func toggleWishlist() {
        guard let user = authManager.currentUser as? User else { return }
        
        if isInWishlist {
            speakerDB.removeFromWishlist(speaker: speaker, user: user)
        } else {
            speakerDB.addToWishlist(speaker: speaker, user: user)
        }
    }
    
    private func shareSpeker() {
        // Implement sharing functionality
        let shareText = "Check out this speaker: \(speaker.name ?? "Unknown") by \(speaker.brand?.name ?? "Unknown")"
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
}

// MARK: - Supporting Views

struct SpecRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

struct RatingBreakdownRow: View {
    let rating: Int
    let count: Int
    let total: Int
    
    private var percentage: Double {
        guard total > 0, count >= 0 else { return 0 }
        let result = Double(count) / Double(total)
        return result.isFinite ? result : 0
    }
    
    var body: some View {
        HStack(spacing: 8) {
            // Star rating
            HStack(spacing: 2) {
                ForEach(0..<rating, id: \.self) { _ in
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                }
            }
            .frame(width: 60, alignment: .leading)
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 4)
                    
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * percentage, height: 4)
                }
            }
            .frame(height: 4)
            
            // Count
            Text("\(count)")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 30, alignment: .trailing)
        }
    }
}

struct ReviewCard: View {
    let review: SpeakerReview
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(review.user?.value(forKey: "username") as? String ?? "Anonymous")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(review.createdAt?.formatted(.dateTime.day().month().year()) ?? "")
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
            
            // Review content
            VStack(alignment: .leading, spacing: 4) {
                if let title = review.title, !title.isEmpty {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                if let content = review.content, !content.isEmpty {
                    Text(content)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            // System info
            if let roomSize = review.roomSize, let systemType = review.systemType {
                HStack {
                    Label(roomSize, systemImage: "house")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Label(systemType, systemImage: "speaker.wave.3")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct SpeakerDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let speaker = SpeakerModel(context: context)
        speaker.name = "Sample Speaker"
        speaker.averageRating = 4.5
        speaker.reviewCount = 23
        
        return NavigationView {
            SpeakerDetailView(speaker: speaker)
        }
        .environment(\.managedObjectContext, context)
        .environmentObject(AuthenticationManager())
        .environmentObject(SpeakerDatabaseManager(context: context))
    }
}
