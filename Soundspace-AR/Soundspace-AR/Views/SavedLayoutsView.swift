// SavedLayoutsView.swift
// Soundspace-AR
//
// Created by Kusal on 2025-08-04.
//

import SwiftUI
import CoreData

struct SavedLayoutsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Saved Layouts")
                    .font(.largeTitle)
                    .padding()
                
                Text("Your saved speaker layouts will appear here")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
                
                Spacer()
                
                Image(systemName: "square.stack.3d.up.slash")
                    .font(.system(size: 60))
                    .foregroundColor(.secondary)
                    .padding()
                
                Text("No Saved Layouts")
                    .font(.headline)
                    .padding(.bottom, 5)
                
                Text("Create and save speaker layouts to see them here.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
            }
            .navigationTitle("Saved Layouts")
        }
    }
}

#Preview {
    SavedLayoutsView()
}
