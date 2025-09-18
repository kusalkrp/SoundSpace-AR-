// HelpAboutView.swift
// Soundspace-AR
//

import SwiftUI

struct HelpAboutView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    @State private var showingUserGuide = false
    
    enum HelpTab: Int, CaseIterable {
        case help, about
        
        var title: String {
            switch self {
            case .help: return "Help"
            case .about: return "About"
            }
        }
        
        var icon: String {
            switch self {
            case .help: return "questionmark.circle"
            case .about: return "info.circle"
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Blue gradient background to match app theme
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
                headerSection
                contentCard
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingUserGuide) {
            UserGuideView()
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Spacer()
            Text("Help & About")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 52)
            Spacer()
        }
        .frame(height: 180)
    }
    
    private var contentCard: some View {
        VStack(spacing: 0) {
            // Tab selector
            tabSelector
            
            // Content based on selected tab
            ScrollView {
                Group {
                    switch HelpTab(rawValue: selectedTab) {
                    case .help:
                        helpContent
                    case .about:
                        aboutContent
                    default:
                        helpContent
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            
            // Fixed back button at bottom
            VStack {
                backButton
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 36, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
    
    private var tabSelector: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(HelpTab.allCases, id: \.rawValue) { tab in
                    Button(action: {
                        selectedTab = tab.rawValue
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 20))
                            
                            Text(tab.title)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(selectedTab == tab.rawValue ? Color.blue.opacity(0.1) : Color.clear)
                        .foregroundColor(selectedTab == tab.rawValue ? .blue : .secondary)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // Separator line
            Divider()
                .padding(.horizontal, 20)
        }
    }
    
    private var helpContent: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Interactive Tutorial Section
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "play.circle")
                        .foregroundColor(.blue)
                        .font(.title2)
                    Text("Interactive Tutorial")
                        .font(.headline)
                        .fontWeight(.bold)
                }
                
                Button(action: {
                    showingUserGuide = true
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Take the Complete Tutorial")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                            
                            Text("Step-by-step walkthrough with animations and interactive demos")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "arrow.right.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title2)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                }
            }
            
            // Getting Started Section
            helpSection(
                title: "Getting Started",
                icon: "play.circle",
                items: [
                    HelpItem(
                        title: "Room Scanning",
                        description: "Use your device's camera to scan your room. Move slowly and capture all walls and furniture for accurate room detection."
                    ),
                    HelpItem(
                        title: "Speaker Placement",
                        description: "Follow the AR guides to position your speakers optimally. The app will suggest the best locations based on your room's acoustics."
                    ),
                    HelpItem(
                        title: "Calibration",
                        description: "Run audio calibration tests to fine-tune your speaker setup for the best sound quality in your specific room."
                    )
                ]
            )
            
            // Features Section
            helpSection(
                title: "Key Features",
                icon: "star.circle",
                items: [
                    HelpItem(
                        title: "AR Visualization",
                        description: "See your speaker placement in real-time using augmented reality technology."
                    ),
                    HelpItem(
                        title: "Community Reviews",
                        description: "Share your setup and read reviews from other users with similar speakers and rooms."
                    ),
                    HelpItem(
                        title: "Smart Recommendations",
                        description: "Get personalized speaker system suggestions based on your room size and layout."
                    ),
                    HelpItem(
                        title: "Layout Saving",
                        description: "Save multiple speaker configurations and switch between them easily."
                    )
                ]
            )
            
            // Troubleshooting Section
            helpSection(
                title: "Troubleshooting",
                icon: "wrench.and.screwdriver",
                items: [
                    HelpItem(
                        title: "AR Tracking Issues",
                        description: "Ensure good lighting and move your device slowly. Restart the app if tracking becomes unstable."
                    ),
                    HelpItem(
                        title: "Room Not Detected",
                        description: "Make sure you're scanning all walls and corners. The room should be well-lit with clear boundaries."
                    ),
                    HelpItem(
                        title: "Audio Calibration Problems",
                        description: "Check that your speakers are properly connected and the volume is at a moderate level."
                    )
                ]
            )
            
            // Contact Section
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "envelope.circle")
                        .foregroundColor(.blue)
                        .font(.title2)
                    Text("Need More Help?")
                        .font(.headline)
                        .fontWeight(.bold)
                }
                
                Text("If you're still experiencing issues, please contact our support team:")
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 8) {
                    Button(action: {
                        if let url = URL(string: "mailto:support@soundspacear.com") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundColor(.blue)
                            Text("support@soundspacear.com")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Button(action: {
                        if let url = URL(string: "https://soundspacear.com/help") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "globe")
                                .foregroundColor(.blue)
                            Text("Online Help Center")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding(.leading)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    private var aboutContent: some View {
        VStack(alignment: .leading, spacing: 24) {
            // App Info Section
            VStack(spacing: 16) {
                // App Icon and Name
                VStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.4, green: 0.5, blue: 1.0),
                                Color(red: 0.3, green: 0.4, blue: 0.9)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "speaker.3")
                                .font(.system(size: 40, weight: .medium))
                                .foregroundColor(.white)
                        )
                    
                    VStack(spacing: 4) {
                        Text("SoundSpace AR")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Version 1.0.0")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
            }
            
            // Description Section
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                        .font(.title2)
                    Text("About This App")
                        .font(.headline)
                        .fontWeight(.bold)
                }
                
                Text("SoundSpace AR is the ultimate tool for optimizing your audio setup using cutting-edge augmented reality technology. Whether you're a music enthusiast, audiophile, or just want better sound in your home, our app helps you achieve the perfect speaker placement.")
                    .foregroundColor(.secondary)
                    .lineSpacing(2)
            }
            
            // Features Section
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "star.circle")
                        .foregroundColor(.blue)
                        .font(.title2)
                    Text("What Makes Us Special")
                        .font(.headline)
                        .fontWeight(.bold)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    featureRow(icon: "viewfinder", text: "Advanced AR room scanning and analysis")
                    featureRow(icon: "speaker.wave.3", text: "AI-powered speaker placement optimization")
                    featureRow(icon: "person.3", text: "Community-driven reviews and recommendations")
                    featureRow(icon: "chart.line.uptrend.xyaxis", text: "Real-time acoustic analysis and calibration")
                    featureRow(icon: "square.and.arrow.down", text: "Save and share your perfect setups")
                }
            }
            
            // Team Section
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "person.3.circle")
                        .foregroundColor(.blue)
                        .font(.title2)
                    Text("Development Team")
                        .font(.headline)
                        .fontWeight(.bold)
                }
                
                Text("Created with passion by audio enthusiasts who understand the importance of perfect sound reproduction. Our team combines expertise in acoustics, AR technology, and user experience design.")
                    .foregroundColor(.secondary)
                    .lineSpacing(2)
            }
            
            // Legal Section
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "doc.text.circle")
                        .foregroundColor(.blue)
                        .font(.title2)
                    Text("Legal Information")
                        .font(.headline)
                        .fontWeight(.bold)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Button(action: {
                        if let url = URL(string: "https://soundspacear.com/privacy") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "hand.raised")
                                .foregroundColor(.blue)
                            Text("Privacy Policy")
                                .foregroundColor(.blue)
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.blue)
                                .font(.caption)
                        }
                    }
                    
                    Button(action: {
                        if let url = URL(string: "https://soundspacear.com/terms") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(.blue)
                            Text("Terms of Service")
                                .foregroundColor(.blue)
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.blue)
                                .font(.caption)
                        }
                    }
                    
                    Button(action: {
                        if let url = URL(string: "https://soundspacear.com/licenses") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "books.vertical")
                                .foregroundColor(.blue)
                            Text("Open Source Licenses")
                                .foregroundColor(.blue)
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.blue)
                                .font(.caption)
                        }
                    }
                }
            }
            
            // Copyright
            VStack(spacing: 8) {
                Text("© 2025 SoundSpace AR Team")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                
                Text("Made with ❤️ for audio enthusiasts everywhere")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.top)
        }
    }
    
    private func helpSection(title: String, icon: String, items: [HelpItem]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .font(.title2)
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(items, id: \.title) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text(item.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineSpacing(1)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
        }
    }
    
    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.system(size: 16))
                .frame(width: 20)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var backButton: some View {
        Button(action: {
            dismiss()
        }) {
            Text("Back")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(LinearGradient(colors: [Color.blue.opacity(0.95), Color.blue.opacity(0.8)], startPoint: .top, endPoint: .bottom))
                )
        }
    }
}

// Helper struct for help items
struct HelpItem {
    let title: String
    let description: String
}

#Preview {
    HelpAboutView()
}
