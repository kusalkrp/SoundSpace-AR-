// RootView.swift
// Soundspace-AR

// Root navigation view that handles app initialization and authentication routing

import SwiftUI

struct RootView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showSplash = true

    var body: some View {
        ZStack {
            if showSplash {
                SplashScreen()
                    .onAppear {
                        // Display splash screen for 2 seconds before transitioning
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showSplash = false
                            }
                        }
                    }
            } else {
                // Route based on authentication state
                if authManager.isAuthenticated {
                    MainTabView()
                } else {
                    OnboardingView()
                }
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(AuthenticationManager())
            .environmentObject(SpeakerDatabaseManager(context: PersistenceController.preview.container.viewContext))
    }
}
