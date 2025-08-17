//
//  Persistence.swift
//  Soundspace-AR
//
//  Created by Kusal on 2025-08-04.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Create sample user for preview
        let sampleUser = User(context: viewContext)
        sampleUser.username = "John Doe"
        sampleUser.email = "john@example.com"
        sampleUser.password = "hashedpassword"
        sampleUser.isLoggedIn = true
        sampleUser.createdAt = Date()
        sampleUser.biometricEnabled = false
        
        // Create sample speaker brand
        let sampleBrand = SpeakerBrand(context: viewContext)
        sampleBrand.id = UUID()
        sampleBrand.name = "KEF"
        sampleBrand.logoImageName = "kef_logo"
        sampleBrand.website = "https://kef.com"
        
        // Create sample speaker model
        let sampleSpeaker = SpeakerModel(context: viewContext)
        sampleSpeaker.id = UUID()
        sampleSpeaker.name = "LS50 Meta"
        sampleSpeaker.modelNumber = "LS50M"
        sampleSpeaker.type = "Bookshelf"
        sampleSpeaker.priceRange = "$1,500+"
        sampleSpeaker.frequencyResponse = "47Hz - 45kHz"
        sampleSpeaker.powerRating = "100W"
        sampleSpeaker.averageRating = 4.8
        sampleSpeaker.reviewCount = 142
        sampleSpeaker.brand = sampleBrand
        
        // Create sample review
        let sampleReview = SpeakerReview(context: viewContext)
        sampleReview.id = UUID()
        sampleReview.title = "Exceptional Sound Quality"
        sampleReview.content = "These speakers deliver incredible detail and clarity. Perfect for my living room setup."
        sampleReview.rating = 5
        sampleReview.createdAt = Date()
        sampleReview.speakerModel = sampleSpeaker
        sampleReview.user = sampleUser
        
        // Create sample saved layout
        let sampleLayout = SavedLayout(context: viewContext)
        sampleLayout.id = UUID()
        sampleLayout.name = "Living Room 5.1"
        sampleLayout.roomType = "Living Room"
        sampleLayout.audioSystemType = "5.1 Surround"
        sampleLayout.createdAt = Date()
        sampleLayout.speakerPositions = Data() as NSObject // Add empty data to satisfy the required field
        sampleLayout.user = sampleUser
        
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Soundspace_AR")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
