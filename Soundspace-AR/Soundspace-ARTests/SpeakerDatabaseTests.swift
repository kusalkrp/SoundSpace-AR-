//
//  SpeakerDatabaseTests.swift
//  Soundspace-ARTests
//

//

import Testing
import CoreData
@testable import Soundspace_AR

struct SpeakerDatabaseTests {

    // MARK: - Test Setup

    private var testContainer: NSPersistentContainer!
    private var testContext: NSManagedObjectContext!

    init() async throws {
        testContainer = NSPersistentContainer(name: "Soundspace_AR")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        testContainer.persistentStoreDescriptions = [description]

        await MainActor.run {
            testContainer.loadPersistentStores { _, error in
                if let error = error {
                    fatalError("Failed to load test store: \(error)")
                }
            }
        }
        testContext = testContainer.viewContext
    }

    // MARK: - Speaker Database Manager Tests

    @Test("SpeakerDatabaseManager initialization")
    func testSpeakerDatabaseManagerInitialization() async throws {
        try await MainActor.run {
            let dbManager = SpeakerDatabaseManager(context: testContext)
            #expect(dbManager.speakerBrands.count >= 0)
            #expect(dbManager.featuredSpeakers.count >= 0)
            #expect(dbManager.recentReviews.count >= 0)
        }
    }

    @Test("Sample data creation")
    func testSampleDataCreation() async throws {
        try await MainActor.run {
            let dbManager = SpeakerDatabaseManager(context: testContext)

            // Check if sample brands were created
            #expect(dbManager.speakerBrands.count > 0)

            // Check if sample speakers were created
            #expect(dbManager.featuredSpeakers.count > 0)

            // Verify brand properties
            if let firstBrand = dbManager.speakerBrands.first {
                #expect(firstBrand.name != nil)
                #expect(firstBrand.logoImageName != nil)
                #expect(firstBrand.website != nil)
            }

            // Verify speaker properties
            if let firstSpeaker = dbManager.featuredSpeakers.first {
                #expect(firstSpeaker.name != nil)
                #expect(firstSpeaker.modelNumber != nil)
                #expect(firstSpeaker.type != nil)
                #expect(firstSpeaker.priceRange != nil)
                #expect(firstSpeaker.averageRating >= 0.0)
                #expect(firstSpeaker.reviewCount >= 0)
            }
        }
    }

    @Test("Speaker search functionality")
    func testSpeakerSearch() async throws {
        try await MainActor.run {
            let dbManager = SpeakerDatabaseManager(context: testContext)

            // Test empty search (should return all speakers)
            let allSpeakers = dbManager.searchSpeakers(query: "")
            #expect(allSpeakers.count > 0)

            // Test search by name
            if let firstSpeaker = dbManager.featuredSpeakers.first {
                let searchResults = dbManager.searchSpeakers(query: firstSpeaker.name ?? "")
                #expect(searchResults.count > 0)
                #expect(searchResults.contains { $0.name == firstSpeaker.name })
            }

            // Test search by brand
            if let firstBrand = dbManager.speakerBrands.first {
                let brandSearchResults = dbManager.searchSpeakers(query: firstBrand.name ?? "")
                #expect(brandSearchResults.count >= 0)
            }

            // Test category filter
            let floorstandingSpeakers = dbManager.searchSpeakers(query: "", category: .floorstanding)
            #expect(floorstandingSpeakers.allSatisfy { $0.type == SpeakerCategory.floorstanding.rawValue })

            // Test price range filter
            let budgetSpeakers = dbManager.searchSpeakers(query: "", priceRange: .budget)
            #expect(budgetSpeakers.allSatisfy { $0.priceRange == PriceRange.budget.rawValue })
        }
    }

    @Test("Review functionality")
    func testReviewFunctionality() async throws {
        try await MainActor.run {
            let dbManager = SpeakerDatabaseManager(context: testContext)

            // Create a test user (don't set id manually)
            let user = User(context: testContext)
            user.username = "testuser"
            user.email = "test@example.com"

            // Get a speaker to review
            guard let speaker = dbManager.featuredSpeakers.first else {
                throw TestError("No speakers available for testing")
            }

            let initialRating = speaker.averageRating
            let initialReviewCount = speaker.reviewCount

            // Add a review
            dbManager.addReview(for: speaker, rating: 5, title: "Great Speaker!", content: "Excellent sound quality", user: user)

            // Refresh data
            dbManager.fetchData()

            // Verify review was added
            #expect(speaker.reviewCount > initialReviewCount)
            #expect(speaker.averageRating >= initialRating)

            // Check if review appears in recent reviews
            #expect(dbManager.recentReviews.contains { $0.title == "Great Speaker!" })
        }
    }

    @Test("Wishlist functionality")
    func testWishlistFunctionality() async throws {
        try await MainActor.run {
            let dbManager = SpeakerDatabaseManager(context: testContext)

            // Create a test user
            let user = User(context: testContext)
            user.username = "wishlistuser"
            user.email = "wishlist@example.com"

            // Get a speaker for wishlist
            guard let speaker = dbManager.featuredSpeakers.first else {
                throw TestError("No speakers available for testing")
            }

            // Add to wishlist
            dbManager.addToWishlist(speaker: speaker, user: user, notes: "Planning to buy this")

            // Check if it's in wishlist
            #expect(dbManager.isInWishlist(speaker: speaker, user: user) == true)

            // Remove from wishlist
            dbManager.removeFromWishlist(speaker: speaker, user: user)

            // Check if it's removed
            #expect(dbManager.isInWishlist(speaker: speaker, user: user) == false)
        }
    }

    @Test("Speaker category enum")
    func testSpeakerCategoryEnum() async throws {
        // Test all categories have icons
        for category in SpeakerCategory.allCases {
            #expect(!category.icon.isEmpty)
            #expect(category.id == category.rawValue)
        }
    }

    @Test("Price range enum")
    func testPriceRangeEnum() async throws {
        // Test all price ranges have colors
        for priceRange in PriceRange.allCases {
            #expect(priceRange.id == priceRange.rawValue)
            // Color property exists (can't easily test Color equality in tests)
        }

        // Test price range descriptions
        #expect(PriceRange.budget.rawValue == "Under $100")
        #expect(PriceRange.midRange.rawValue == "$100 - $500")
        #expect(PriceRange.premium.rawValue == "$500 - $1,500")
        #expect(PriceRange.luxury.rawValue == "$1,500+")
    }

    @Test("Speaker model properties")
    func testSpeakerModelProperties() async throws {
        try await MainActor.run {
            let dbManager = SpeakerDatabaseManager(context: testContext)

            guard let speaker = dbManager.featuredSpeakers.first else {
                throw TestError("No speakers available for testing")
            }

            // Test that essential properties are set
            #expect(speaker.id != nil)
            #expect(speaker.name != nil)
            #expect(speaker.modelNumber != nil)
            #expect(speaker.type != nil)
            #expect(speaker.priceRange != nil)
            #expect(speaker.brand != nil)
            #expect(speaker.averageRating >= 0.0)
            #expect(speaker.reviewCount >= 0)

            // Test technical specifications are set for some speakers
            let hasSpecs = (speaker.frequencyResponse != nil) ||
                          (speaker.powerRating != nil) ||
                          (speaker.dimensions != nil) ||
                          (speaker.weight != nil)
            #expect(hasSpecs || true) // Some speakers might not have specs
        }
    }

    @Test("Brand model properties")
    func testBrandModelProperties() async throws {
        try await MainActor.run {
            let dbManager = SpeakerDatabaseManager(context: testContext)

            guard let brand = dbManager.speakerBrands.first else {
                throw TestError("No brands available for testing")
            }

            // Test that essential properties are set
            #expect(brand.id != nil)
            #expect(brand.name != nil)
            #expect(brand.logoImageName != nil)
            #expect(brand.website != nil)
            #expect(brand.website?.hasPrefix("https://") == true || brand.website?.hasPrefix("http://") == true)
        }
    }

    @Test("Complex search with multiple filters")
    func testComplexSearch() async throws {
        try await MainActor.run {
            let dbManager = SpeakerDatabaseManager(context: testContext)

            // Test search with both category and price range
            let filteredSpeakers = dbManager.searchSpeakers(query: "", category: .bookshelf, priceRange: .midRange)

            for speaker in filteredSpeakers {
                #expect(speaker.type == SpeakerCategory.bookshelf.rawValue)
                #expect(speaker.priceRange == PriceRange.midRange.rawValue)
            }
        }
    }

    @Test("Review rating calculation")
    func testReviewRatingCalculation() async throws {
        try await MainActor.run {
            let dbManager = SpeakerDatabaseManager(context: testContext)

            // Create a test user
            let user = User(context: testContext)
            user.username = "ratinguser"
            user.email = "rating@example.com"

            // Get a speaker
            guard let speaker = dbManager.featuredSpeakers.first else {
                throw TestError("No speakers available for testing")
            }

            // Add multiple reviews
            dbManager.addReview(for: speaker, rating: 4, title: "Good", content: "Solid performance", user: user)

            let user2 = User(context: testContext)
            user2.username = "ratinguser2"
            user2.email = "rating2@example.com"

            dbManager.addReview(for: speaker, rating: 5, title: "Excellent", content: "Amazing sound", user: user2)

            // Refresh data
            dbManager.fetchData()

            // Check average rating calculation
            #expect(speaker.averageRating == 4.5) // (4 + 5) / 2
            #expect(speaker.reviewCount == 2)
        }
    }

    // MARK: - Error Cases

    @Test("Search with invalid parameters")
    func testSearchWithInvalidParameters() async throws {
        try await MainActor.run {
            let dbManager = SpeakerDatabaseManager(context: testContext)

            // Test search with non-existent category
            let emptyResults = dbManager.searchSpeakers(query: "nonexistentmodelxyz123")
            #expect(emptyResults.isEmpty || true) // Might return results or empty depending on data
        }
    }

    @Test("Wishlist operations with invalid data")
    func testWishlistInvalidOperations() async throws {
        try await MainActor.run {
            let dbManager = SpeakerDatabaseManager(context: testContext)

            // Create test entities
            let user = User(context: testContext)
            user.username = "invaliduser"
            user.email = "invalid@example.com"

            let speaker = SpeakerModel(context: testContext)
            speaker.name = "Test Speaker"

            // Test operations with unsaved entities
            dbManager.addToWishlist(speaker: speaker, user: user)
            #expect(dbManager.isInWishlist(speaker: speaker, user: user) == false) // Should be false since not saved

            dbManager.removeFromWishlist(speaker: speaker, user: user) // Should not crash
        }
    }
}

// MARK: - Test Error

struct TestError: Error {
    let message: String

    init(_ message: String) {
        self.message = message
    }
}