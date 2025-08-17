// DashboardView.swift
// Soundspace-AR
//
// Created by Assistant on 2025-08-17.
//

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
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Welcome Header
                    headerSection
                    
                    // Quick Action Cards
                    quickActionsSection
                    
                    // Stats Section
                    statsSection
                    
                    // Recent Activity
                    recentActivitySection
                    
                    // Featured Speakers
                    featuredSpeakersSection
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
            .navigationTitle("SoundSpace AR")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await refreshData()
            }
        }
        .onAppear {
            loadUserData()
        }
        .sheet(isPresented: $showingARSetup) {
            NavigationView {
                ARSpeakerPlacementView(
                    roomType: .livingRoom,
                    audioSystem: .system5_1
                )
            }
        }
        .sheet(isPresented: $showingMLRoomDetection) {
            NavigationView {
                MLRoomDetectionView()
            }
        }
    }
    
    @MainActor
    private func refreshData() async {
        await speakerDB.refreshFeaturedSpeakers()
        loadUserData()
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Welcome back,")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    Text(username)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                // Profile/Notification button
                Button(action: {}) {
                    Image(systemName: "bell")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
            }
            
            Text("Ready to optimize your audio setup?")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.headline)
                .padding(.horizontal)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                // Start AR Setup
                ActionCard(
                    title: "Start AR Setup",
                    subtitle: "Place speakers in your room",
                    icon: "viewfinder",
                    color: .blue
                ) {
                    showingARSetup = true
                }
                
                // ML Room Detection
                ActionCard(
                    title: "Smart Room Scan",
                    subtitle: "AI-powered room analysis",
                    icon: "camera.viewfinder",
                    color: .green
                ) {
                    showingMLRoomDetection = true
                }
                
                // Browse Speakers
                NavigationLink(destination: SpeakerCommunityView()) {
                    ActionCardContent(
                        title: "Browse Speakers",
                        subtitle: "Discover & review speakers",
                        icon: "speaker.3",
                        color: .orange
                    )
                }
                
                // Saved Layouts
                NavigationLink(destination: SavedLayoutsView()) {
                    ActionCardContent(
                        title: "My Layouts",
                        subtitle: "\(savedLayoutsCount) saved setups",
                        icon: "square.grid.3x3",
                        color: .purple
                    )
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Stats")
                .font(.headline)
                .padding(.horizontal)
            
            HStack(spacing: 16) {
                StatCard(
                    title: "Layouts",
                    value: "\(savedLayoutsCount)",
                    icon: "square.stack.3d.up.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "Reviews",
                    value: "\(speakerDB.recentReviews.count)",
                    icon: "star.fill",
                    color: .yellow
                )
                
                StatCard(
                    title: "Wishlist",
                    value: "5", // This would be calculated from actual wishlist
                    icon: "heart.fill",
                    color: .red
                )
            }
            .padding(.horizontal)
        }
    }
    
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Activity")
                    .font(.headline)
                
                Spacer()
                
                NavigationLink("See All", destination: SavedLayoutsView())
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            .padding(.horizontal)
            
            if speakerDB.recentReviews.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "clock")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("No recent activity")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                VStack(spacing: 8) {
                    ForEach(Array(speakerDB.recentReviews.prefix(3)), id: \.id) { review in
                        ActivityRow(review: review)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var featuredSpeakersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Featured Speakers")
                    .font(.headline)
                
                Spacer()
                
                NavigationLink("Browse All", destination: SpeakerCommunityView())
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(Array(speakerDB.featuredSpeakers.prefix(5)), id: \.id) { speaker in
                        NavigationLink(destination: SpeakerDetailView(speaker: speaker)) {
                            FeaturedSpeakerCard(speaker: speaker)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private func loadUserData() {
        if let user = authManager.currentUser,
           let name = user.value(forKey: "username") as? String {
            username = name
        }
        
        // Load saved layouts count
        let request: NSFetchRequest<SavedLayout> = SavedLayout.fetchRequest()
        if let user = authManager.currentUser {
            request.predicate = NSPredicate(format: "user == %@", user)
        }
        
        do {
            savedLayoutsCount = try viewContext.count(for: request)
        } catch {
            print("Error loading saved layouts count: \(error)")
        }
    }
}

// MARK: - Supporting Views

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

struct FeaturedSpeakerCard: View {
    let speaker: SpeakerModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Placeholder image
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

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        let authManager = AuthenticationManager()
        let context = PersistenceController.preview.container.viewContext
        let speakerDB = SpeakerDatabaseManager(context: context)
        
        return DashboardView()
            .environment(\.managedObjectContext, context)
            .environmentObject(authManager)
            .environmentObject(speakerDB)
    }
}
