// SavedLayoutsView.swift
// Soundspace-AR
//
// Created by Kusal on 2025-08-04.
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
        List {
            if layouts.isEmpty {
                Section {
                    VStack(spacing: 12) {
                        Image(systemName: "square.stack.3d.up.slash")
                            .font(.system(size: 52))
                            .foregroundColor(.secondary)
                        Text("No Saved Layouts")
                            .font(.headline)
                        Text("Save a layout from the AR view to list it here.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
                }
            } else {
                ForEach(layouts) { layout in
                    Button(action: { selectedLayout = layout; showingAR = true }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(layout.name ?? "Untitled")
                                    .font(.headline)
                                HStack(spacing: 8) {
                                    Text(layout.roomType ?? "")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(layout.audioSystemType ?? "")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                        .padding(4)
                                        .background(Color.blue.opacity(0.12))
                                        .cornerRadius(4)
                                }
                            }
                            Spacer()
                            if let date = layout.createdAt { Text(date, style: .date).font(.caption).foregroundColor(.secondary) }
                        }
                        .contentShape(Rectangle())
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) { delete(layout) } label: { Label("Delete", systemImage: "trash") }
                    }
                }
            }
        }
        .navigationTitle("Saved Layouts")
        .sheet(isPresented: $showingAR, onDismiss: { selectedLayout = nil }) {
            if let selected = selectedLayout,
               let room = RoomType(rawValue: selected.roomType ?? ""),
               let system = AudioSystemType(rawValue: selected.audioSystemType ?? "") {
                NavigationView {
                    ARSpeakerPlacementView(roomType: room, audioSystem: system, savedLayout: selected)
                }
            }
        }
    }
    
    private func delete(_ layout: SavedLayout) {
        viewContext.delete(layout)
        do { try viewContext.save() } catch { print("Delete error: \(error)") }
    }
}

#Preview {
    NavigationView { SavedLayoutsView() }
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
