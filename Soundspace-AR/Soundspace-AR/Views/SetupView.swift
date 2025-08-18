// SetupView.swift
// Soundspace-AR
//
// Created by Kusal on 2025-08-04.
//

import SwiftUI

struct SetupView: View {
    @State private var currentStep: SetupStep = .roomType
    @State private var selectedRoomType: RoomType = .livingRoom
    @State private var selectedAudioSystem: AudioSystemType = .system5_1
    @State private var showingARView = false
    
    enum SetupStep {
        case roomType
        case speakerType
    }
    
    var body: some View {
        ZStack {
            // Blue gradient background
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
                // Header with title
                headerSection
                
                // Main content card
                contentCard
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingARView) {
            ARSpeakerPlacementView(
                roomType: selectedRoomType,
                audioSystem: selectedAudioSystem,
                savedLayout: nil
            )
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text(currentStep == .roomType ? "Room Type" : "Speakers Type")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.top, 60)
            
            Spacer()
        }
        .frame(height: 200)
    }
    
    private var contentCard: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // White card container with left/right padding
            VStack(spacing: 24) {
                // Illustration and description
                illustrationSection
                
                // Selection section with fixed height
                VStack(spacing: 16) {
                    Text(currentStep == .roomType ? "Select Room Type" : "Select Speakers Type")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Fixed height container for options
                    VStack(spacing: 12) {
                        if currentStep == .roomType {
                            roomTypeOptions
                        } else {
                            speakerTypeOptions
                        }
                    }
                    .frame(height: 240) // Fixed height to keep button position consistent
                }
                
                // Next button
                nextButton
            }
            .padding(.horizontal, 24) // Left/right padding
            .padding(.vertical, 32) // Top/bottom padding
            .background(Color.white)
            .cornerRadius(32) // All corners rounded
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
            .padding(.horizontal, 16) // Additional outer padding for the card itself
            .padding(.bottom, 80) // Increased bottom padding to show blue background
        }
    }
    
    private var illustrationSection: some View {
        VStack(spacing: 16) {
            // Illustration with professional transition
            Group {
                if currentStep == .roomType {
                    roomIllustration
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        ))
                } else {
                    speakerIllustration
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        ))
                }
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0), value: currentStep)
            
            // Description text with smooth transition
            Text(currentStep == .roomType ? 
                 "Choose the room where you'll set up your speakers. This helps us place speakers accurately for the best sound experience based on room size and layout." :
                 "Choose your speaker setup to visualize the ideal placement. We'll adapt the AR layout based on the system you select for accurate positioning and immersive sound.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .animation(.easeInOut(duration: 0.4), value: currentStep)
        }
    }
    
    private var roomIllustration: some View {
        ZStack {
            // Background room
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.brown.opacity(0.3))
                .frame(width: 200, height: 120)
            
            // Walls and windows
            HStack(spacing: 40) {
                // Left window
                Rectangle()
                    .fill(Color.cyan.opacity(0.6))
                    .frame(width: 30, height: 40)
                    .overlay(
                        VStack {
                            Rectangle().frame(height: 2).foregroundColor(.white)
                            Rectangle().frame(height: 2).foregroundColor(.white)
                        }
                    )
                
                // Right window  
                Rectangle()
                    .fill(Color.cyan.opacity(0.6))
                    .frame(width: 30, height: 40)
                    .overlay(
                        VStack {
                            Rectangle().frame(height: 2).foregroundColor(.white)
                            Rectangle().frame(height: 2).foregroundColor(.white)
                        }
                    )
            }
            .offset(y: -30)
            
            // Sofa
            VStack(spacing: 4) {
                // Sofa back
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.purple.opacity(0.8))
                    .frame(width: 80, height: 20)
                
                // Sofa seat
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.purple.opacity(0.6))
                    .frame(width: 80, height: 16)
            }
            .offset(y: 10)
            
            // Side tables
            HStack(spacing: 100) {
                Rectangle()
                    .fill(Color.brown)
                    .frame(width: 16, height: 20)
                
                Rectangle()
                    .fill(Color.brown)
                    .frame(width: 16, height: 20)
            }
            .offset(y: 20)
        }
        .frame(height: 140)
    }
    
    private var speakerIllustration: some View {
        ZStack {
            // Speaker with sound waves
            VStack(spacing: 8) {
                // Main speaker body
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue)
                    .frame(width: 60, height: 80)
                    .overlay(
                        VStack(spacing: 8) {
                            // Tweeter
                            Circle()
                                .fill(Color.white)
                                .frame(width: 16, height: 16)
                            
                            // Woofer
                            Circle()
                                .fill(Color.white)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle()
                                        .stroke(Color.blue, lineWidth: 2)
                                        .frame(width: 20, height: 20)
                                )
                        }
                    )
                
                // Speaker base
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 40, height: 8)
            }
            
            // Sound wave lines
            HStack(spacing: 20) {
                // Left side waves
                VStack(spacing: 6) {
                    soundWaveLine(length: 20)
                    soundWaveLine(length: 30)
                    soundWaveLine(length: 25)
                }
                .offset(x: -60)
                
                Spacer()
                
                // Right side waves
                VStack(spacing: 6) {
                    soundWaveLine(length: 20)
                    soundWaveLine(length: 30)
                    soundWaveLine(length: 25)
                }
                .offset(x: 60)
            }
        }
        .frame(height: 140)
    }
    
    private func soundWaveLine(length: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 1)
            .fill(Color.blue.opacity(0.6))
            .frame(width: length, height: 2)
    }
    
    private var selectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(currentStep == .roomType ? "Select Room Type" : "Select Speakers Type")
                .font(.title2)
                .fontWeight(.bold)
            
            if currentStep == .roomType {
                roomTypeOptions
            } else {
                speakerTypeOptions
            }
        }
    }
    
    private var roomTypeOptions: some View {
        VStack(spacing: 12) {
            roomOption(
                icon: "sofa.fill",
                title: "Living Room",
                subtitle: "Standard family space",
                roomType: .livingRoom
            )
            
            roomOption(
                icon: "bed.double.fill",
                title: "Bedroom",
                subtitle: "Smaller, intimate space",
                roomType: .bedroom
            )
            
            roomOption(
                icon: "desktopcomputer",
                title: "Office / Study",
                subtitle: "Small quiet workspace",
                roomType: .office
            )
            
            roomOption(
                icon: "house.fill",
                title: "Custom Room",
                subtitle: "Let the app determine the size",
                roomType: .hall
            )
        }
    }
    
    private var speakerTypeOptions: some View {
        VStack(spacing: 12) {
            speakerOption(
                icon: "🔊",
                title: "2.1 Setup",
                subtitle: "Two front speakers and one subwoofer — simple stereo with added bass",
                audioSystem: .system2_1
            )
            
            speakerOption(
                icon: "🔊",
                title: "5.1 Setup", 
                subtitle: "Front, center, two surround speakers, and subwoofer",
                audioSystem: .system5_1
            )
            
            speakerOption(
                icon: "🔊",
                title: "7.1 Setup",
                subtitle: "Full surround sound, adds two rear speakers to the 5.1 system",
                audioSystem: .system7_1
            )
        }
    }
    
    private func roomOption(icon: String, title: String, subtitle: String, roomType: RoomType) -> some View {
        Button(action: {
            selectedRoomType = roomType
        }) {
            HStack(spacing: 16) {
                // Icon
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: icon)
                            .foregroundColor(.white)
                            .font(.title3)
                    )
                
                // Text content
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Selection indicator
                Circle()
                    .stroke(selectedRoomType == roomType ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Circle()
                            .fill(selectedRoomType == roomType ? Color.blue : Color.clear)
                            .frame(width: 12, height: 12)
                    )
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func speakerOption(icon: String, title: String, subtitle: String, audioSystem: AudioSystemType) -> some View {
        Button(action: {
            selectedAudioSystem = audioSystem
        }) {
            HStack(spacing: 16) {
                // Icon with speaker graphic
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Text(icon)
                            .font(.title2)
                    )
                
                // Text content
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Selection indicator
                Circle()
                    .stroke(selectedAudioSystem == audioSystem ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Circle()
                            .fill(selectedAudioSystem == audioSystem ? Color.blue : Color.clear)
                            .frame(width: 12, height: 12)
                    )
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var nextButton: some View {
        Button(action: {
            if currentStep == .roomType {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.7, blendDuration: 0.2)) {
                    currentStep = .speakerType
                }
            } else {
                // Add a subtle scale animation before showing AR view
                withAnimation(.easeInOut(duration: 0.2)) {
                    // Button press feedback
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    showingARView = true
                }
            }
        }) {
            HStack(spacing: 8) {
                Text("Next")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Image(systemName: "arrow.right")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.blue)
                    .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
            )
            .scaleEffect(currentStep == .roomType ? 1.0 : 1.0)
        }
        .buttonStyle(NextButtonStyle())
    }
}

// Custom button style for Next button with press animation
struct NextButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// Custom corner radius extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct SetupView_Previews: PreviewProvider {
    static var previews: some View {
        SetupView()
    }
}
