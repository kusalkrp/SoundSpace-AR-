// ARSpeakerPlacementView.swift
// Soundspace-AR
//
// Created by Kusal on 2025-08-04.
//

import SwiftUI
import ARKit
import RealityKit
import CoreData

struct ARSpeakerPlacementView: View {
    let roomType: RoomType
    let audioSystem: AudioSystemType
    let savedLayout: SavedLayout?
    
    @StateObject private var viewModel = ARViewModel()
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showSpeakerInfo: Speaker.SpeakerPosition?
    @State private var showSaveDialog = false
    @State private var layoutName = ""
    @State private var isTrackingQualityGood = true
    @State private var worldTrackingState: String = "Normal"
    
    var body: some View {
        ZStack {
            // AR View
            ARViewContainer(viewModel: viewModel)
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    viewModel.setupAR(roomType: roomType, audioSystem: audioSystem)
                }
            
            // Top controls
            VStack {
                HStack {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(8)
                    
                    Spacer()
                    
                    Button("Save Layout") {
                        showSaveDialog = true
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(8)
                }
                .padding()
                
                Spacer()
                
                // Bottom controls
                HStack {
                    Button("Check Distance") {
                        viewModel.checkDistance()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(8)
                    
                    Spacer()
                    
                    Button("Sound Waves") {
                        viewModel.toggleVisualizeSound()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(8)
                }
                .padding()
            }
        }
        .alert("Save Layout", isPresented: $showSaveDialog) {
            TextField("Layout Name", text: $layoutName)
                .autocapitalization(.words)
                .disableAutocorrection(false)
            Button("Cancel", role: .cancel) {
                layoutName = ""
            }
            Button("Save") {
                viewModel.saveLayout(name: layoutName, viewContext: viewContext, roomType: roomType, audioSystem: audioSystem)
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Enter a name for this speaker layout")
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    @ObservedObject var viewModel: ARViewModel
    
    func makeUIView(context: Context) -> ARView {
        return viewModel.arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
}

class ARViewModel: ObservableObject {
    let arView = ARView(frame: .zero)
    var speakers: [Speaker] = []
    var anchors: [AnchorEntity] = []
    
    @Published var showingDistanceResults = false
    @Published var isDistanceBalanced = false
    @Published var isSoundVisualized = false
    
    func setupAR(roomType: RoomType, audioSystem: AudioSystemType) {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        arView.session.run(configuration)
        
        // Create speakers based on audio system
        createSpeakers(for: audioSystem)
        
        // Set up gesture recognizers
        arView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
    }
    
    private func createSpeakers(for audioSystem: AudioSystemType) {
        speakers = audioSystem.speakers
        
        for (index, speaker) in speakers.enumerated() {
            let anchor = AnchorEntity(world: SIMD3<Float>(0, 0, -1.5 - Float(index) * 0.5))
            
            // Create speaker model
            let mesh = MeshResource.generateBox(size: 0.1)
            let material = SimpleMaterial(color: .blue, isMetallic: false)
            let modelEntity = ModelEntity(mesh: mesh, materials: [material])
            
            anchor.addChild(modelEntity)
            arView.scene.addAnchor(anchor)
            anchors.append(anchor)
        }
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: arView)
        let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)
        
        if let firstResult = results.first, let nextAnchor = anchors.first {
            // Extract translation from the 4x4 matrix using the fourth column
            let worldTransform = firstResult.worldTransform
            let translation = SIMD3<Float>(worldTransform.columns.3.x, worldTransform.columns.3.y, worldTransform.columns.3.z)
            nextAnchor.transform.translation = translation
        }
    }
    
    func checkDistance() {
        showingDistanceResults = true
        isDistanceBalanced = true // Simplified for now
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showingDistanceResults = false
        }
    }
    
    func toggleVisualizeSound() {
        isSoundVisualized.toggle()
    }
    
    func saveLayout(name: String, viewContext: NSManagedObjectContext, roomType: RoomType, audioSystem: AudioSystemType) {
        let layout = SavedLayout(context: viewContext)
        layout.id = UUID()
        layout.name = name
        layout.roomType = roomType.rawValue
        layout.audioSystemType = audioSystem.rawValue
        layout.createdAt = Date()
        
        do {
            try viewContext.save()
        } catch {
            print("Error saving layout: \(error)")
        }
    }
}

struct ARSpeakerPlacementView_Previews: PreviewProvider {
    static var previews: some View {
        ARSpeakerPlacementView(
            roomType: .livingRoom,
            audioSystem: .system5_1,
            savedLayout: nil
        )
    }
}
