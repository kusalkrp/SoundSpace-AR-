//
//  Soundspace_ARApp.swift
//  Soundspace-AR
//
//  Created by Kusal on 2025-08-04.
//
// Soundspace_ARApp.swift

import SwiftUI
import CoreData

@main
struct Soundspace_ARApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var authManager = AuthenticationManager(viewContext: PersistenceController.shared.container.viewContext)
    @StateObject private var speakerDB = SpeakerDatabaseManager(context: PersistenceController.shared.container.viewContext)

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(authManager)
                .environmentObject(speakerDB)
        }
        .backgroundTask(.appRefresh("com.soundspace.refresh")) {
            // Background app refresh for iOS 18.6
            await refreshSpeakerDatabase()
        }
    }
    
    @MainActor
    private func refreshSpeakerDatabase() async {
        // Refresh speaker database in background
        let context = persistenceController.container.viewContext
        let speakerDB = SpeakerDatabaseManager(context: context)
        await speakerDB.refreshFeaturedSpeakers()
    }
}
