// SetupView.swift
// Soundspace-AR
//
// Created by Kusal on 2025-08-04.
//

import SwiftUI

struct SetupView: View {
    @State private var selectedRoomType: RoomType = .livingRoom
    @State private var selectedAudioSystem: AudioSystemType = .system5_1
    @State private var showingARView = false
    @State private var showingMLDetection = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    headerSection
                    
                    // Quick AI Detection
                    aiDetectionSection
                    
                    // Room Type Selection
                    roomTypeSection
                    
                    // Audio System Selection
                    audioSystemSection
                    
                    // Preview Section
                    previewSection
                    
                    // Start AR Button
                    startARButton
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
            .navigationTitle("Setup Your Space")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingARView) {
            ARSpeakerPlacementView(
                roomType: selectedRoomType,
                audioSystem: selectedAudioSystem,
                savedLayout: nil
            )
        }
        .sheet(isPresented: $showingMLDetection) {
            MLRoomDetectionView()
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "speaker.wave.3.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            VStack(spacing: 8) {
                Text("Perfect Speaker Placement")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Use AR to visualize optimal speaker positions in your actual room")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private var aiDetectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Smart Room Detection", systemImage: "camera.viewfinder")
                .font(.headline)
                .foregroundColor(.green)
            
            Text("Let AI analyze your room and recommend the best audio setup")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button(action: {
                showingMLDetection = true
            }) {
                HStack {
                    Image(systemName: "camera.fill")
                    Text("Scan Room with AI")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .foregroundColor(.green)
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private var roomTypeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Room Type")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(RoomType.allCases) { roomType in
                    RoomTypeCard(
                        roomType: roomType,
                        isSelected: selectedRoomType == roomType
                    ) {
                        selectedRoomType = roomType
                    }
                }
            }
        }
    }
    
    private var audioSystemSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Audio System")
                .font(.headline)
            
            VStack(spacing: 12) {
                ForEach(AudioSystemType.allCases) { system in
                    AudioSystemCard(
                        audioSystem: system,
                        isSelected: selectedAudioSystem == system
                    ) {
                        selectedAudioSystem = system
                    }
                }
            }
        }
    }
    
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Setup Preview")
                .font(.headline)
            
            VStack(spacing: 8) {
                HStack {
                    Text("Room:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(selectedRoomType.displayName)
                        .fontWeight(.medium)
                }
                
                HStack {
                    Text("System:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(selectedAudioSystem.displayName)
                        .fontWeight(.medium)
                }
                
                HStack {
                    Text("Speakers:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(selectedAudioSystem.speakerCount) speakers")
                        .fontWeight(.medium)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    private var startARButton: some View {
        Button(action: {
            showingARView = true
        }) {
            HStack {
                Image(systemName: "arkit")
                    .font(.title2)
                Text("Start AR Setup")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .cornerRadius(16)
        }
    }
}

// MARK: - Supporting Views

struct RoomTypeCard: View {
    let roomType: RoomType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: roomType.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .blue)
                
                Text(roomType.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
                    .multilineTextAlignment(.center)
            }
            .frame(height: 80)
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AudioSystemCard: View {
    let audioSystem: AudioSystemType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(audioSystem.displayName)
                        .font(.headline)
                        .foregroundColor(isSelected ? .white : .primary)
                    
                    Text(audioSystem.description)
                        .font(.caption)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                    
                    Text("\(audioSystem.speakerCount) speakers")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(isSelected ? .white : .blue)
                }
                
                Spacer()
                
                Image(systemName: audioSystem.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .blue)
            }
            .padding()
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SetupView_Previews: PreviewProvider {
    static var previews: some View {
        SetupView()
    }
}
