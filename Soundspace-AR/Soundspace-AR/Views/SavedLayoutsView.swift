// SavedLayoutsView.swift
// Soundspace-AR
//


import SwiftUI
import CoreData

struct SavedLayoutsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \SavedLayout.createdAt, ascending: false)],
        animation: .default
    ) private var layouts: FetchedResults<SavedLayout>
    
    @State private var showingAR = false
    @State private var selectedLayout: SavedLayout? = nil
    
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
                // Header
                headerSection
                
                // Content card
                contentCard
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingAR) {
            if let selected = selectedLayout {
                ARSpeakerPlacementView(
                    roomType: RoomType.livingRoom,
                    audioSystem: AudioSystemType.system5_1,
                    savedLayout: selected
                )
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text("Saved Layouts")
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
            
            VStack(spacing: 16) {
                if layouts.isEmpty {
                    emptyStateView
                } else {
                    layoutsList
                }
                
                Spacer()
                
                // Back button
                backButton
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 32)
            .background(Color.white)
            .cornerRadius(32)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
            .padding(.horizontal, 16)
            .padding(.bottom, 30)
        }
    }
    
    private var layoutsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(layouts, id: \.objectID) { layout in
                    layoutCard(for: layout)
                }
            }
        }
    }
    
    private func layoutCard(for layout: SavedLayout) -> some View {
        HStack(spacing: 16) {
            // Speaker system icon
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.1))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "speaker.3.fill")
                        .font(.title3)
                        .foregroundColor(.blue)
                )
            
            // Layout info
            VStack(alignment: .leading, spacing: 4) {
                Text(layout.name ?? "My Layout 1")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Room type · \(layout.roomType ?? "Living Room")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Speaker Type · \(layout.audioSystemType ?? "7.1")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Action buttons
            HStack(spacing: 12) {
                // Edit button
                Button(action: {
                    // Handle edit action
                }) {
                    Image(systemName: "pencil")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
                
                // Delete button
                Button(action: {
                    deleteLayout(layout)
                }) {
                    Image(systemName: "trash")
                        .font(.title3)
                        .foregroundColor(.red)
                }
            }
        }
        .padding(16)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
        .onTapGesture {
            selectedLayout = layout
            showingAR = true
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.stack.3d.up")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No Saved Layouts")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Create your first layout by setting up speakers in AR mode")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
    }
    
    private var backButton: some View {
        Button(action: {
            // Handle back navigation
        }) {
            Text("Back")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(16)
        }
    }
    
    private func deleteLayout(_ layout: SavedLayout) {
        withAnimation {
            viewContext.delete(layout)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

#Preview {
    SavedLayoutsView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
