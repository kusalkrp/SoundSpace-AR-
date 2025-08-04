// SetupView.swift
// Soundspace-AR
//
// Created by Kusal on 2025-08-04.
//

import SwiftUI

struct SetupView: View {
    @State private var selectedRoomType: RoomType?
    @State private var selectedAudioSystem: AudioSystemType?
    @State private var navigateToARView = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Header
                Text("Speaker Setup")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                Text("Select your room type and audio system")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)
                
                // Room Type Selection
                Text("Room Type")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(RoomType.allCases) { roomType in
                            RoomTypeCard(
                                roomType: roomType,
                                isSelected: selectedRoomType == roomType
                            )
                            .onTapGesture {
                                selectedRoomType = roomType
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 20)
                
                // Audio System Selection
                Text("Audio System")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(AudioSystemType.allCases) { systemType in
                            AudioSystemCard(
                                systemType: systemType,
                                isSelected: selectedAudioSystem == systemType
                            )
                            .onTapGesture {
                                selectedAudioSystem = systemType
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Continue Button
                NavigationLink(destination: ARSpeakerPlacementView(roomType: selectedRoomType ?? .livingRoom, audioSystem: selectedAudioSystem ?? .system5_1), isActive: $navigateToARView) {
                    Button(action: {
                        if selectedRoomType != nil && selectedAudioSystem != nil {
                            navigateToARView = true
                        }
                    }) {
                        Text("Start AR Placement")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                (selectedRoomType != nil && selectedAudioSystem != nil) ?
                                    Color.blue : Color.gray
                            )
                            .cornerRadius(10)
                    }
                    .disabled(selectedRoomType == nil || selectedAudioSystem == nil)
                    .padding()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct RoomTypeCard: View {
    let roomType: RoomType
    let isSelected: Bool
    
    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(isSelected ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                    .frame(width: 150, height: 120)
                
                Image(systemName: "house.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            
            Text(roomType.rawValue)
                .font(.headline)
                .foregroundColor(isSelected ? .blue : .primary)
            
            Text(roomType.description)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .frame(width: 140)
        }
        .padding(.vertical, 5)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
    }
}

struct AudioSystemCard: View {
    let systemType: AudioSystemType
    let isSelected: Bool
    
    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(isSelected ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                    .frame(width: 150, height: 120)
                
                Image(systemName: "speaker.wave.3.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            
            Text(systemType.rawValue)
                .font(.headline)
                .foregroundColor(isSelected ? .blue : .primary)
            
            Text("\(systemType.speakerCount) Speakers")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 5)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
    }
}

struct SetupView_Previews: PreviewProvider {
    static var previews: some View {
        SetupView()
    }
}
