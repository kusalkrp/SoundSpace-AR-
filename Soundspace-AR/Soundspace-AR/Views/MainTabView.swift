// MainTabView.swift
// Soundspace-AR
//

// Main tab-based navigation interface with custom pill-style tab bar


import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.managedObjectContext) private var viewContext
    
    // Custom tab selection
    @State private var selected: Tab = .home
    
    enum Tab: Int, CaseIterable, Identifiable {
        case home, room, community, layouts, settings
        var id: Int { rawValue }
        var title: String {
            switch self {
            case .home: return "Home"
            case .room: return "Room"
            case .community: return "Community"
            case .layouts: return "Layouts"
            case .settings: return "Settings"
            }
        }
        var icon: String {
            switch self {
            case .home: return "house"
            case .room: return "camera.viewfinder"
            case .community: return "person.3"
            case .layouts: return "square.stack.3d.up"
            case .settings: return "gearshape"
            }
        }
        var activeIcon: String {
            switch self {
            case .home: return "house.fill"
            case .room: return "camera.viewfinder"
            case .community: return "person.3.fill"
            case .layouts: return "square.stack.3d.up.fill"
            case .settings: return "gearshape.fill"
            }
        }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.4, green: 0.5, blue: 1.0),
                    Color(red: 0.3, green: 0.4, blue: 0.9)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Group {
                    switch selected {
                    case .home:
                        DashboardView()
                    case .room:
                        NavigationView { MLRoomDetectionView() }
                    case .community:
                        NavigationView { SpeakerCommunityView() }
                    case .layouts:
                        SavedLayoutsView()
                    case .settings:
                        SettingsView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                customTabBar
                    .padding(.bottom, 8)
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
                            if selected == tab {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 40, height: 40)
                                    .shadow(color: Color.blue.opacity(0.15), radius: 8, x: 0, y: 2)
                            }
                            Image(systemName: selected == tab ? tab.activeIcon : tab.icon)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(selected == tab ? Color.blue : Color.gray.opacity(0.7))
                        }
                        Text(tab.title)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(selected == tab ? Color.blue : Color.white.opacity(0.8))
                            .opacity(selected == tab ? 1.0 : 0.8)
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
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(Color.white.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
        )
        .padding(.horizontal, 16)
    }
    }


// MARK: - Supporting Types

// Custom button style providing press feedback for tab items
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
