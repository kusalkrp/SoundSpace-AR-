//
//  ContentView.swift
//  Soundspace-AR
//
//  Created by Kusal on 2025-08-04.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            if !hasSeenOnboarding {
                OnboardingView()
            } else if authManager.isAuthenticated {
                MainTabView()
            } else {
                NavigationStack {
                    LoginView()
                        .navigationTitle("")
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            // Enhanced scene phase handling for better app lifecycle management
            switch newPhase {
            case .active:
                // App became active - refresh data if needed
                Task {
                    await authManager.refreshAuthenticationStatus()
                }
            case .background:
                // App moved to background - save context
                try? viewContext.save()
            case .inactive:
                // App became inactive
                break
            @unknown default:
                break
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(AuthenticationManager())
        .environmentObject(SpeakerDatabaseManager(context: PersistenceController.preview.container.viewContext))
}
