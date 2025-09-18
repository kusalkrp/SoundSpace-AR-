// DashboardView.swift
// Soundspace-AR
//
// Main dashboard view displaying AR setup options, room detection,
// and saved layouts with user-specific data

import SwiftUI
import CoreData

struct DashboardView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var speakerDB: SpeakerDatabaseManager
    @Environment(\.managedObjectContext) private var viewContext

    @State private var showingARSetup = false
    @State private var showingMLRoomDetection = false
    @State private var savedLayoutsCount = 0
    @State private var username = "User"
    @State private var showingProfile = false

    var body: some View {
        ZStack {
            backgroundGradient

            VStack(spacing: 0) {
                headerSection

                ScrollView {
                    VStack(spacing: 24) {
                        dashboardPanel
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                    .frame(maxHeight: .infinity, alignment: .top)
                }
            }
        }
        .onAppear {
            loadUserData()
        }
        .sheet(isPresented: $showingARSetup) {
            NavigationView {
                SetupView()
            }
        }
        .sheet(isPresented: $showingMLRoomDetection) {
            NavigationView {
                MLRoomDetectionView()
            }
        }
        .sheet(isPresented: $showingProfile) {
            SettingsView()
        }
    }

    /// Main dashboard content panel with AR setup and secondary options
    private var dashboardPanel: some View {
        VStack(spacing: 32) {
            mainARSetupCard
            HStack(spacing: 20) {
                roomDetectionCard
                savedLayoutsCard
            }
        }
        .padding(.top, 32)
        .padding(.horizontal, 24)
        .padding(.bottom, 32)
        .background(Color.white)
        .cornerRadius(32)
        .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 6)
        .frame(maxHeight: .infinity, alignment: .top)
    }

    /// Refresh dashboard data from remote sources
    @MainActor
    private func refreshData() async {
        await speakerDB.refreshFeaturedSpeakers()
        loadUserData()
    }

    // MARK: - UI Components

    /// Blue gradient background for the dashboard
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.4, green: 0.5, blue: 1.0),
                Color(red: 0.3, green: 0.4, blue: 0.9)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    /// Header section with title and profile button
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Dashboard")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("Manage all things")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }

            Spacer()

            Button(action: {
                showingProfile = true
            }) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }

    /// Primary AR setup card with visual speaker illustration
    private var mainARSetupCard: some View {
        Button(action: {
            showingARSetup = true
        }) {
            VStack(spacing: 32) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Start ")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.black)
                        + Text("AR")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.blue)

                        Spacer()
                    }

                    HStack {
                        Text("Setup")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.black)
                        Spacer()
                    }
                }

                arSetupIllustration
            }
            .padding(.vertical, 32)
            .padding(.horizontal, 24)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(PlainButtonStyle())
    }

    /// Visual illustration of speaker setup with left/center/right speakers
    private var arSetupIllustration: some View {
        VStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 180, height: 8)

            HStack(spacing: 30) {
                VStack {
                    Circle()
                        .fill(Color.cyan.opacity(0.3))
                        .frame(width: 35, height: 35)
                        .overlay(
                            Circle()
                                .fill(Color.cyan.opacity(0.6))
                                .frame(width: 25, height: 25)
                                .overlay(
                                    Circle()
                                        .fill(Color.cyan)
                                        .frame(width: 15, height: 15)
                                )
                        )
                    Rectangle()
                        .fill(Color.gray.opacity(0.4))
                        .frame(width: 3, height: 15)
                    Rectangle()
                        .fill(Color.gray.opacity(0.6))
                        .frame(width: 12, height: 4)
                }

                VStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.7))
                        .frame(width: 50, height: 30)
                        .overlay(
                            Text("TV")
                                .font(.system(size: 8, weight: .medium))
                                .foregroundColor(.white)
                        )
                    Rectangle()
                        .fill(Color.gray.opacity(0.5))
                        .frame(width: 6, height: 12)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.gray.opacity(0.8))
                        .frame(width: 35, height: 6)
                }

                VStack {
                    Circle()
                        .fill(Color.cyan.opacity(0.3))
                        .frame(width: 35, height: 35)
                        .overlay(
                            Circle()
                                .fill(Color.cyan.opacity(0.6))
                                .frame(width: 25, height: 25)
                                .overlay(
                                    Circle()
                                        .fill(Color.cyan)
                                        .frame(width: 15, height: 15)
                                )
                        )
                    Rectangle()
                        .fill(Color.gray.opacity(0.4))
                        .frame(width: 3, height: 15)
                    Rectangle()
                        .fill(Color.gray.opacity(0.6))
                        .frame(width: 12, height: 4)
                }
            }
        }
    }

    /// Container for secondary option cards
    private var bottomCardsContainer: some View {
        VStack(spacing: 0) {
            HStack(spacing: 20) {
                roomDetectionCard
                savedLayoutsCard
            }
            .padding(.all, 24)
        }
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }

    /// Card for ML-powered room detection feature
    private var roomDetectionCard: some View {
        Button(action: {
            showingMLRoomDetection = true
        }) {
            VStack(spacing: 12) {
                Image(systemName: "viewfinder.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.blue)

                VStack(spacing: 4) {
                    Text("Room")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)

                    Text("Detection")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(PlainButtonStyle())
    }

    /// Card for accessing saved speaker layouts
    private var savedLayoutsCard: some View {
        Button(action: {
            // TODO: Navigate to Saved Layouts view
        }) {
            VStack(spacing: 12) {
                Image(systemName: "square.stack.3d.up.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.blue)

                VStack(spacing: 4) {
                    Text("Saved")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)

                    Text("Layouts")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(PlainButtonStyle())
    }

    /// Load user-specific data including username and saved layouts count
    private func loadUserData() {
        // Safely handle Core Data operations
        guard let user = authManager.currentUser else {
            username = "User"
            savedLayoutsCount = 0
            return
        }

        if let name = user.value(forKey: "username") as? String {
            username = name
        }

        // Load saved layouts count with error handling
        let request: NSFetchRequest<SavedLayout> = SavedLayout.fetchRequest()
        request.predicate = NSPredicate(format: "user == %@", user)

        do {
            savedLayoutsCount = try viewContext.count(for: request)
        } catch {
            print("Error loading saved layouts count: \(error)")
            savedLayoutsCount = 0
        }
    }
}

// MARK: - Supporting Views

/// Reusable action card component for dashboard actions
struct ActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ActionCardContent(title: title, subtitle: subtitle, icon: icon, color: color)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Content view for action cards with icon, title, and subtitle
struct ActionCardContent: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)

                Spacer()
            }

            Text(title)
                .font(.headline)
                .foregroundColor(.primary)

            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

/// Statistics display card component
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

/// Row component for displaying user activity/review information
struct ActivityRow: View {
    let review: SpeakerReview

    var body: some View {
        HStack {
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)

            VStack(alignment: .leading, spacing: 2) {
                Text("Reviewed \(review.speakerModel?.name ?? "Unknown Speaker")")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(review.title ?? "")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Text(review.createdAt?.formatted(.relative(presentation: .numeric)) ?? "")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

/// Card component for displaying featured speakers
struct FeaturedSpeakerCard: View {
    let speaker: SpeakerModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Speaker image placeholder
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray5))
                .frame(width: 120, height: 80)
                .overlay(
                    Image(systemName: "speaker.3")
                        .font(.title)
                        .foregroundColor(.secondary)
                )

            Text(speaker.brand?.name ?? "Unknown")
                .font(.caption)
                .foregroundColor(.secondary)

            Text(speaker.name ?? "Unknown Speaker")
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(2)

            HStack {
                ForEach(0..<Int(speaker.averageRating), id: \.self) { _ in
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                }

                Text(String(format: "%.1f", speaker.averageRating))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 120)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    DashboardView()
        .environmentObject(AuthenticationManager())
        .environmentObject(SpeakerDatabaseManager(context: PersistenceController.preview.container.viewContext))
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
