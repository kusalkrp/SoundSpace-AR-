// SpeakerDatabase.swift
// Soundspace-AR
//

import Foundation
import CoreData
import SwiftUI

// MARK: - Speaker Community Models

enum SpeakerCategory: String, CaseIterable, Identifiable {
    case floorstanding = "Floorstanding"
    case bookshelf = "Bookshelf"
    case center = "Center Channel"
    case subwoofer = "Subwoofer"
    case surround = "Surround"
    case soundbar = "Soundbar"
    case inWall = "In-Wall"
    case inCeiling = "In-Ceiling"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .floorstanding: return "speaker.3"
        case .bookshelf: return "hifispeaker"
        case .center: return "speaker.wave.2"
        case .subwoofer: return "speaker.fill"
        case .surround: return "dot.radiowaves.left.and.right"
        case .soundbar: return "rectangle.3.group"
        case .inWall: return "rectangle.inset.filled"
        case .inCeiling: return "circle.hexagongrid"
        }
    }
}

enum PriceRange: String, CaseIterable, Identifiable {
    case budget = "Under $100"
    case midRange = "$100 - $500"
    case premium = "$500 - $1,500"
    case luxury = "$1,500+"
    
    var id: String { rawValue }
    
    var color: Color {
        switch self {
        case .budget: return .green
        case .midRange: return .blue
        case .premium: return .orange
        case .luxury: return .purple
        }
    }
}

// MARK: - Core Data Helper Classes

@MainActor
class SpeakerDatabaseManager: ObservableObject {
    private let viewContext: NSManagedObjectContext
    
    @Published var speakerBrands: [SpeakerBrand] = []
    @Published var featuredSpeakers: [SpeakerModel] = []
    @Published var recentReviews: [SpeakerReview] = []
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        loadInitialData()
        fetchData()
    }
    
    func fetchData() {
        fetchSpeakerBrands()
        fetchFeaturedSpeakers()
        fetchRecentReviews()
    }
    
    private func fetchSpeakerBrands() {
        let request: NSFetchRequest<SpeakerBrand> = SpeakerBrand.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \SpeakerBrand.name, ascending: true)]
        
        do {
            speakerBrands = try viewContext.fetch(request)
        } catch {
            print("Error fetching speaker brands: \(error)")
        }
    }
    
    private func fetchFeaturedSpeakers() {
        let request: NSFetchRequest<SpeakerModel> = SpeakerModel.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \SpeakerModel.averageRating, ascending: false)]
        request.fetchLimit = 10
        
        do {
            featuredSpeakers = try viewContext.fetch(request)
        } catch {
            print("Error fetching featured speakers: \(error)")
        }
    }
    
    private func fetchRecentReviews() {
        let request: NSFetchRequest<SpeakerReview> = SpeakerReview.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \SpeakerReview.createdAt, ascending: false)]
        request.fetchLimit = 10
        
        do {
            recentReviews = try viewContext.fetch(request)
        } catch {
            print("Error fetching recent reviews: \(error)")
        }
    }
    
    // Load initial sample data
    private func loadInitialData() {
        // Check if we already have data
        let brandRequest: NSFetchRequest<SpeakerBrand> = SpeakerBrand.fetchRequest()
        
        do {
            let existingBrands = try viewContext.fetch(brandRequest)
            if !existingBrands.isEmpty {
                return // Data already exists
            }
        } catch {
            print("Error checking existing data: \(error)")
        }
        
        // Create sample brands and speakers
        createSampleData()
    }
    
    private func createSampleData() {
        // Popular speaker brands
        let brandsData = [
            ("Klipsch", "klipsch_logo"),
            ("KEF", "kef_logo"),
            ("Bowers & Wilkins", "bw_logo"),
            ("Sony", "sony_logo"),
            ("Yamaha", "yamaha_logo"),
            ("JBL", "jbl_logo"),
            ("Polk Audio", "polk_logo"),
            ("Definitive Technology", "deftech_logo")
        ]
        
        var createdBrands: [SpeakerBrand] = []
        
        for (name, logo) in brandsData {
            let brand = SpeakerBrand(context: viewContext)
            brand.id = UUID()
            brand.name = name
            brand.logoImageName = logo
            brand.website = "https://\(name.lowercased().replacingOccurrences(of: " ", with: "")).com"
            createdBrands.append(brand)
        }
        
        // Create sample speaker models for each brand
        createSampleSpeakers(for: createdBrands)
        
        do {
            try viewContext.save()
        } catch {
            print("Error saving sample data: \(error)")
        }
    }
    
    private func createSampleSpeakers(for brands: [SpeakerBrand]) {
        let speakerData = [
            // Klipsch
            ("Reference Premiere RP-8000F", "RP-8000F", SpeakerCategory.floorstanding, PriceRange.premium),
            ("Reference R-51M", "R-51M", SpeakerCategory.bookshelf, PriceRange.midRange),
            ("Reference Premiere RP-500C", "RP-500C", SpeakerCategory.center, PriceRange.premium),
            
            // KEF
            ("LS50 Meta", "LS50M", SpeakerCategory.bookshelf, PriceRange.luxury),
            ("Q150", "Q150", SpeakerCategory.bookshelf, PriceRange.midRange),
            ("Q650C", "Q650C", SpeakerCategory.center, PriceRange.premium),
            
            // Sony
            ("SS-CS5", "SSCS5", SpeakerCategory.floorstanding, PriceRange.budget),
            ("SS-CS3", "SSCS3", SpeakerCategory.bookshelf, PriceRange.budget),
        ]
        
        for (index, data) in speakerData.enumerated() {
            let speaker = SpeakerModel(context: viewContext)
            speaker.id = UUID()
            speaker.name = data.0
            speaker.modelNumber = data.1
            speaker.type = data.2.rawValue
            speaker.priceRange = data.3.rawValue
            speaker.brand = brands[index % brands.count]
            speaker.averageRating = Float.random(in: 3.5...5.0)
            speaker.reviewCount = Int32.random(in: 5...50)
            
            // Add some technical specs
            switch data.2 {
            case .floorstanding:
                speaker.frequencyResponse = "32Hz - 25kHz"
                speaker.powerRating = "150W RMS"
                speaker.dimensions = "39.4\" H x 9.5\" W x 15.7\" D"
                speaker.weight = "52.9 lbs"
            case .bookshelf:
                speaker.frequencyResponse = "47Hz - 24kHz"
                speaker.powerRating = "85W RMS"
                speaker.dimensions = "13.9\" H x 7.9\" W x 12.9\" D"
                speaker.weight = "17.6 lbs"
            case .center:
                speaker.frequencyResponse = "45Hz - 25kHz"
                speaker.powerRating = "125W RMS"
                speaker.dimensions = "8.0\" H x 25.0\" W x 14.5\" D"
                speaker.weight = "23.4 lbs"
            default:
                break
            }
        }
    }
    
    // MARK: - Public Methods
    
    func addReview(for speaker: SpeakerModel, rating: Int, title: String, content: String, user: User) {
        let review = SpeakerReview(context: viewContext)
        review.id = UUID()
        review.rating = Int16(rating)
        review.title = title
        review.content = content
        review.createdAt = Date()
        review.speakerModel = speaker
        review.user = user
        
        // Update speaker's average rating
        updateSpeakerRating(speaker)
        
        do {
            try viewContext.save()
            fetchData() // Refresh data
        } catch {
            print("Error saving review: \(error)")
        }
    }
    
    func addToWishlist(speaker: SpeakerModel, user: User, notes: String? = nil) {
        let wishlistItem = WishlistItem(context: viewContext)
        wishlistItem.id = UUID()
        wishlistItem.addedAt = Date()
        wishlistItem.notes = notes
        wishlistItem.speakerModel = speaker
        wishlistItem.user = user
        
        do {
            try viewContext.save()
        } catch {
            print("Error adding to wishlist: \(error)")
        }
    }
    
    func removeFromWishlist(speaker: SpeakerModel, user: User) {
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
    }
    
    func isInWishlist(speaker: SpeakerModel, user: User) -> Bool {
        let request: NSFetchRequest<WishlistItem> = WishlistItem.fetchRequest()
        request.predicate = NSPredicate(format: "speakerModel == %@ AND user == %@", speaker, user)
        
        do {
            let count = try viewContext.count(for: request)
            return count > 0
        } catch {
            return false
        }
    }
    
    private func updateSpeakerRating(_ speaker: SpeakerModel) {
        guard let reviews = speaker.reviews as? Set<SpeakerReview> else { return }
        
        let totalRating = reviews.reduce(0) { $0 + Int($1.rating) }
        let averageRating = Float(totalRating) / Float(reviews.count)
        
        speaker.averageRating = averageRating
        speaker.reviewCount = Int32(reviews.count)
    }
    
    func searchSpeakers(query: String, category: SpeakerCategory? = nil, priceRange: PriceRange? = nil) -> [SpeakerModel] {
        let request: NSFetchRequest<SpeakerModel> = SpeakerModel.fetchRequest()
        
        var predicates: [NSPredicate] = []
        
        // Text search
        if !query.isEmpty {
            let textPredicate = NSPredicate(format: "name CONTAINS[cd] %@ OR modelNumber CONTAINS[cd] %@ OR brand.name CONTAINS[cd] %@", query, query, query)
            predicates.append(textPredicate)
        }
        
        // Category filter
        if let category = category {
            let categoryPredicate = NSPredicate(format: "type == %@", category.rawValue)
            predicates.append(categoryPredicate)
        }
        
        // Price range filter
        if let priceRange = priceRange {
            let pricePredicate = NSPredicate(format: "priceRange == %@", priceRange.rawValue)
            predicates.append(pricePredicate)
        }
        
        if !predicates.isEmpty {
            request.predicate = NSCompoundPredicate(type: .and, subpredicates: predicates)
        }
        
        request.sortDescriptors = [NSSortDescriptor(keyPath: \SpeakerModel.averageRating, ascending: false)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error searching speakers: \(error)")
            return []
        }
    }
    
    //  Background refresh functionality
    func refreshFeaturedSpeakers() async {
        await MainActor.run {
            fetchFeaturedSpeakers()
            fetchRecentReviews()
        }
    }
}
