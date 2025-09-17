// RootView.swift
// Soundspace-AR
//
// Created by Assistant on 2025-09-17.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var showSplash = true
    
    var body: some View {
        ZStack {
            if showSplash {
                SplashScreen()
                    .onAppear {
                        // Show splash for 2 seconds, then transition to onboarding or auth check
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showSplash = false
                            }
                        }
                    }
            } else {
                // Check if user has seen onboarding
                if !hasSeenOnboarding {
                    // Show onboarding first
                    OnboardingView()
                } else {
                    // Check authentication state after onboarding
                    if authManager.isAuthenticated {
                        // User is authenticated, show main app
                        MainTabView()
                    } else {
                        // User not authenticated, show login/signup
                        LoginView()
                    }
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
