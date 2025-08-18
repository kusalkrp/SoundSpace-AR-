// MainTabView.swift
// Soundspace-AR
//
// Created by Kusal on 2025-08-04.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.managedObjectContext) private var viewContext
    
    // Custom tab selection
    @State private var selected: Tab = .home
    
    enum Tab: Int, CaseIterable, Identifiable {
        case home, room, layouts, settings
        var id: Int { rawValue }
        var title: String {
            switch self {
            case .home: return "Home"
            case .room: return "Room"
            case .layouts: return "Layouts"
            case .settings: return "Settings"
            }
        }
        var icon: String {
            switch self {
            case .home: return "house"
            case .room: return "camera.viewfinder"
            case .layouts: return "square.stack.3d.up"
            case .settings: return "gearshape"
            }
        }
        var activeIcon: String {
            switch self {
            case .home: return "house.fill"
            case .room: return "camera.viewfinder"
            case .layouts: return "square.stack.3d.up.fill"
            case .settings: return "gearshape.fill"
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Content under the custom tab bar
            Group {
                switch selected {
                case .home:
                    DashboardView()
                case .room:
                    NavigationView { MLRoomDetectionView() }
                case .layouts:
                    SavedLayoutsView()
                case .settings:
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom pill tab bar
            VStack { 
                Spacer()
                customTabBar
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            .ignoresSafeArea(.keyboard)
        }
    }
    
    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases) { tab in
                Button(action: { 
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) { 
                        selected = tab 
                    } 
                }) {
                    VStack(spacing: 4) {
                        ZStack {
                            // Background circle with smooth animation
                            if selected == tab {
                                Circle()
                                    .fill(Color.blue.opacity(0.15))
                                    .frame(width: 40, height: 40)
                                    .scaleEffect(selected == tab ? 1.0 : 0.8)
                                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: selected)
                            }
                            
                            // Icon with improved animation
                            Image(systemName: selected == tab ? tab.activeIcon : tab.icon)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(selected == tab ? .blue : .gray)
                                .scaleEffect(selected == tab ? 1.1 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selected)
                        }
                        
                        // Text with improved typography
                        Text(tab.title)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(selected == tab ? .blue : .secondary)
                            .opacity(selected == tab ? 1.0 : 0.8)
                            .animation(.easeInOut(duration: 0.2), value: selected)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .contentShape(Rectangle())
                }
                .buttonStyle(TabButtonStyle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 8)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
}

// Custom button style for tab items
struct TabButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
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
