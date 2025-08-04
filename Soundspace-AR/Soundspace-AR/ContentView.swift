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

    var body: some View {
        Group {
            if !hasSeenOnboarding {
                OnboardingView()
            } else if authManager.isAuthenticated {
                MainTabView()
            } else {
                LoginView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(AuthenticationManager())
    }
}
