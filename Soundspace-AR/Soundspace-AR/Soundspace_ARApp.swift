// Soundspace_ARApp.swift
// Soundspace-AR
//

// Main application entry point with Core Data and environment setup

import SwiftUI
import CoreData

@main
struct Soundspace_ARApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var authManager = AuthenticationManager(viewContext: PersistenceController.shared.container.viewContext)
    @StateObject private var speakerDB = SpeakerDatabaseManager(context: PersistenceController.shared.container.viewContext)

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(authManager)
                .environmentObject(speakerDB)
        }
        .backgroundTask(.appRefresh("com.soundspace.refresh")) {
            await refreshSpeakerDatabase()
        }
    }

    /// Background refresh task for updating speaker database (iOS 18.6+)
    @MainActor
    private func refreshSpeakerDatabase() async {
        let context = persistenceController.container.viewContext
        let speakerDB = SpeakerDatabaseManager(context: context)
        await speakerDB.refreshFeaturedSpeakers()
    }
}
