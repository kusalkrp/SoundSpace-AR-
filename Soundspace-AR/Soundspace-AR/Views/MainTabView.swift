// MainTabView.swift
// Soundspace-AR
//
// Created by Kusal on 2025-08-04.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home/Dashboard Tab
            DashboardView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            // AR Setup Tab
            NavigationView {
                SetupView()
            }
            .tabItem {
                Label("AR Setup", systemImage: "viewfinder")
            }
            .tag(1)
            
            // Speaker Community Tab
            NavigationView {
                SpeakerCommunityView()
            }
            .tabItem {
                Label("Speakers", systemImage: "speaker.3.fill")
            }
            .tag(2)
            
            // Saved Layouts Tab
            SavedLayoutsView()
                .tabItem {
                    Label("Layouts", systemImage: "square.stack.3d.up.fill")
                }
                .tag(3)
            
            // Settings Tab
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(4)
        }
        .accentColor(.blue)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(AuthenticationManager())
            .environmentObject(SpeakerDatabaseManager(context: PersistenceController.preview.container.viewContext))
    }
}
