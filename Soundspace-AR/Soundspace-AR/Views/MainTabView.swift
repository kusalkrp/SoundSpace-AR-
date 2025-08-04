// MainTabView.swift
// Soundspace-AR
//
// Created by Kusal on 2025-08-04.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        TabView {
            SetupView()
                .tabItem {
                    Label("Setup", systemImage: "speaker.wave.3.fill")
                }
            
            SavedLayoutsView()
                .tabItem {
                    Label("Saved", systemImage: "square.stack.3d.up.fill")
                }
                
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .accentColor(.blue)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView().environmentObject(AuthenticationManager())
    }
}
