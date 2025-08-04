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
    @StateObject private var authManager = AuthenticationManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(authManager)
                .onAppear {
                    authManager.setContext(persistenceController.container.viewContext)
                }
        }
    }
}
