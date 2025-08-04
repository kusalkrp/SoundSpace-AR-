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
    
    @StateObject private var viewModel = ARViewModel()
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showSpeakerInfo: Speaker?
    @State private var showSaveDialog = false
    @State private var layoutName = ""
    
    var body: some View {
        ZStack {
            // AR View
            ARViewContainer(viewModel: viewModel)
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    viewModel.setupAR(roomType: roomType, audioSystem: audioSystem)
                    
                    // Add notification observer for speaker selection
                    NotificationCenter.default.addObserver(
                        forName: Notification.Name("SpeakerSelected"),
                        object: nil,
                        queue: .main
                    ) { notification in
                        if let speaker = notification.object as? Speaker {
                            showSpeakerInfo = speaker
                        }
                    }
                }
                .onDisappear {
                    // Remove observer when view disappears
                    NotificationCenter.default.removeObserver(
                        self,
                        name: Notification.Name("SpeakerSelected"),
                        object: nil
                    )
                }
            
            // Info panel when speaker is selected
            if let speaker = showSpeakerInfo {
                VStack {
                    Spacer()
                    
                    SpeakerInfoPanel(speaker: speaker) {
                        showSpeakerInfo = nil
                    }
                    .transition(.move(edge: .bottom))
                    .padding(.bottom, 60)
                }
                .animation(.spring(), value: showSpeakerInfo?.id)
            }
            
            // Top controls
            VStack {
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        showSaveDialog = true
                    }) {
                        Image(systemName: "square.and.arrow.down")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                }
                .padding()
                
                Spacer()
                
                // Bottom controls
                HStack {
                    Button(action: {
                        viewModel.checkDistance()
                    }) {
                        VStack {
                            Image(systemName: "ruler")
                                .font(.title2)
                            Text("Check Distance")
                                .font(.caption)
                        }
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(10)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.toggleVisualizeSound()
                    }) {
                        VStack {
                            Image(systemName: "waveform")
                                .font(.title2)
                            Text("Sound Waves")
                                .font(.caption)
                        }
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(10)
                    }
                }
                .padding()
            }
            
            // Distance checker results
            if viewModel.showingDistanceResults {
                VStack {
                    Spacer().frame(height: 120)
                    
                    HStack {
                        Spacer()
                        
                        VStack(alignment: .leading) {
                            Text("Distance Check")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            if viewModel.isDistanceBalanced {
                                Label("Speakers are properly balanced", systemImage: "checkmark.circle")
                                    .foregroundColor(.green)
                            } else {
                                Label("Speakers are unbalanced", systemImage: "xmark.circle")
                                    .foregroundColor(.red)
                                
                                Text("Adjust speaker positions until distances are equal")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding()
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(10)
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
                .transition(.opacity)
                .animation(.easeInOut, value: viewModel.showingDistanceResults)
            }
        }
        .alert("Save Layout", isPresented: $showSaveDialog) {
            TextField("Layout Name", text: $layoutName)
            
            Button("Cancel", role: .cancel) {
                layoutName = ""
            }
            
            Button("Save") {
                viewModel.roomType = roomType
                viewModel.audioSystemType = audioSystem
                viewModel.saveLayout(name: layoutName, viewContext: viewContext)
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

struct SpeakerInfoPanel: View {
    let speaker: Speaker
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(speaker.type.rawValue)
                    .font(.headline)
                
                Spacer()
                
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
            .padding(.bottom, 2)
            
            Text(speaker.type.description)
                .font(.body)
                .foregroundColor(.secondary)
            
            if let angle = speaker.type.idealAngle {
                Text("Ideal Angle: \(Int(angle))°")
                    .font(.caption)
                    .padding(.top, 5)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
}

class ARViewModel: ObservableObject {
    let arView = ARView(frame: .zero)
    var speakers: [Speaker] = []
    var anchors: [AnchorEntity] = []
    
    @Published var showingDistanceResults = false
    @Published var isDistanceBalanced = false
    @Published var isSoundVisualized = false
    
    var roomType: RoomType?
    var audioSystemType: AudioSystemType?
    
    func setupAR(roomType: RoomType, audioSystem: AudioSystemType) {
        // Configure AR session
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        arView.session.run(configuration)
        
        // Set up tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        arView.addGestureRecognizer(tapGesture)
        
        // Create speaker layout based on audio system type
        createSpeakers(for: audioSystem)
    }
    
    func createSpeakers(for systemType: AudioSystemType) {
        speakers = []
        
        // Create appropriate speakers based on system type
        switch systemType {
        case .system2_1:
            speakers = [
                Speaker(type: .frontLeft),
                Speaker(type: .frontRight),
                Speaker(type: .subwoofer)
            ]
        case .system5_1:
            speakers = [
                Speaker(type: .frontLeft),
                Speaker(type: .center),
                Speaker(type: .frontRight),
                Speaker(type: .surroundLeft),
                Speaker(type: .surroundRight),
                Speaker(type: .subwoofer)
            ]
        case .system7_1:
            speakers = [
                Speaker(type: .frontLeft),
                Speaker(type: .center),
                Speaker(type: .frontRight),
                Speaker(type: .surroundLeft),
                Speaker(type: .surroundRight),
                Speaker(type: .rearLeft),
                Speaker(type: .rearRight),
                Speaker(type: .subwoofer)
            ]
        }
        
        // Place speakers in AR space once plane is detected
        DispatchQueue.main.async {
            self.placeVirtualSpeakers()
        }
    }
    
    func placeVirtualSpeakers() {
        // Clear existing anchors
        for anchor in anchors {
            arView.scene.removeAnchor(anchor)
        }
        anchors.removeAll()
        
        // Create an anchor entity positioned at the center of the detected plane
        guard let centerAnchor = createCenterAnchor() else { return }
        arView.scene.addAnchor(centerAnchor)
        anchors.append(centerAnchor)
        
        // Calculate positions around the center based on ideal speaker layout
        let radius: Float = 1.5 // 1.5 meters from center
        
        for speaker in speakers {
            // Create a speaker entity
            let speakerEntity = createSpeakerEntity(for: speaker)
            
            // Position speaker around center based on its type
            if let angle = speaker.type.idealAngle {
                // Convert angle to radians
                let radians = angle * .pi / 180
                
                // Calculate position (x, y, z)
                let x = radius * sin(radians)
                let z = -radius * cos(radians)
                
                // Set height based on speaker type
                var y: Float = 0
                if speaker.type == .subwoofer {
                    y = 0 // On the floor
                } else if speaker.type == .center {
                    y = 0.8 // Center channel at mid-height
                } else {
                    y = 1.0 // Most speakers at ear level
                }
                
                // Update speaker position
                speaker.position = SIMD3<Float>(x, y, z)
                speakerEntity.position = speaker.position
                
                // Create an anchor for this speaker
                let speakerAnchor = AnchorEntity()
                speakerAnchor.addChild(speakerEntity)
                centerAnchor.addChild(speakerAnchor)
                
                // Store anchor ID
                speaker.anchorID = speakerAnchor.id
            } else {
                // For subwoofer with no specific angle
                let speakerAnchor = AnchorEntity()
                speakerAnchor.addChild(speakerEntity)
                speakerEntity.position = SIMD3<Float>(0.5, 0, 0.5) // Default position for subwoofer
                speaker.position = speakerEntity.position
                centerAnchor.addChild(speakerAnchor)
                speaker.anchorID = speakerAnchor.id
            }
        }
    }
    
    func createCenterAnchor() -> AnchorEntity? {
        // Find a horizontal plane to place our content
        guard let query = arView.makeRaycastQuery(
            from: arView.center,
            allowing: .estimatedPlane,
            alignment: .horizontal
        ) else {
            return nil
        }
        
        guard let result = arView.session.raycast(query).first else {
            return nil
        }
        
        // Create an anchor at the raycast result
        let anchor = AnchorEntity(world: result.worldTransform)
        
        // Create a center marker (optional)
        let centerMarker = ModelEntity(
            mesh: MeshResource.generateSphere(radius: 0.05),
            materials: [SimpleMaterial(color: .blue, isMetallic: false)]
        )
        centerMarker.position = SIMD3<Float>(0, 0.05, 0)
        anchor.addChild(centerMarker)
        
        return anchor
    }
    
    func createSpeakerEntity(for speaker: Speaker) -> Entity {
        // Create different visuals based on speaker type
        let mesh: MeshResource
        let color: UIColor
        
        switch speaker.type {
        case .subwoofer:
            mesh = MeshResource.generateBox(size: 0.3)
            color = .systemOrange
        case .center:
            mesh = MeshResource.generateBox(width: 0.4, height: 0.15, depth: 0.15)
            color = .systemGreen
        default:
            mesh = MeshResource.generateBox(width: 0.15, height: 0.3, depth: 0.15)
            color = .systemBlue
        }
        
        let material = SimpleMaterial(color: color.withAlphaComponent(0.8), isMetallic: false)
        let entity = ModelEntity(mesh: mesh, materials: [material])
        
        // Add text label
        let textMesh = MeshResource.generateText(
            speaker.type.rawValue,
            extrusionDepth: 0.01,
            font: .systemFont(ofSize: 0.1),
            containerFrame: CGRect(x: 0, y: 0, width: 0.3, height: 0.1),
            alignment: .center,
            lineBreakMode: .byTruncatingTail
        )
        
        let textMaterial = SimpleMaterial(color: .white, isMetallic: false)
        let textEntity = ModelEntity(mesh: textMesh, materials: [textMaterial])
        
        // Position text above speaker
        textEntity.position = SIMD3<Float>(0, 0.2, 0)
        entity.addChild(textEntity)
        
        return entity
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: arView)
        
        // Perform hit test against speaker entities
        if let result = arView.entity(at: location) as? ModelEntity {
            // Find the speaker associated with this entity
            for speaker in speakers {
                if let anchorID = speaker.anchorID,
                   let anchor = arView.scene.findEntity(id: anchorID) {
                    if anchor.children.contains(where: { $0 === result }) {
                        // Publish the selected speaker to show info
                        NotificationCenter.default.post(
                            name: Notification.Name("SpeakerSelected"),
                            object: speaker
                        )
                        break
                    }
                }
            }
        }
    }
    
    func checkDistance() {
        // Show distance check UI
        showingDistanceResults = true
        
        // Get front left and front right speakers
        guard let frontLeft = speakers.first(where: { $0.type == .frontLeft }),
              let frontRight = speakers.first(where: { $0.type == .frontRight }) else {
            return
        }
        
        // Calculate listener position (assumed to be at origin)
        let listenerPosition = SIMD3<Float>(0, 0, 0)
        
        // Calculate distances from listener to each speaker
        let distanceToLeftSpeaker = distance(frontLeft.position, listenerPosition)
        let distanceToRightSpeaker = distance(frontRight.position, listenerPosition)
        
        // Check if distances are approximately equal (within 10% tolerance)
        let tolerance: Float = 0.1
        let difference = abs(distanceToLeftSpeaker - distanceToRightSpeaker)
        let averageDistance = (distanceToLeftSpeaker + distanceToRightSpeaker) / 2
        
        isDistanceBalanced = difference < (averageDistance * tolerance)
        
        // Hide results after a few seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            withAnimation {
                self.showingDistanceResults = false
            }
        }
    }
    
    func toggleVisualizeSound() {
        isSoundVisualized.toggle()
        
        if isSoundVisualized {
            // Add sound wave animations to each speaker
            for speaker in speakers {
                if let anchorID = speaker.anchorID,
                   let anchor = arView.scene.findEntity(id: anchorID) {
                    addSoundWaveEffect(to: anchor)
                }
            }
        } else {
            // Remove sound wave animations
            for speaker in speakers {
                if let anchorID = speaker.anchorID,
                   let anchor = arView.scene.findEntity(id: anchorID) {
                    removeSoundWaveEffect(from: anchor)
                }
            }
        }
    }
    
    // Custom component to store timer data
    class AnimationComponent: Component {
        var timer: Timer?
        
        init(timer: Timer? = nil) {
            self.timer = timer
        }
    }
    
    func addSoundWaveEffect(to entity: Entity) {
        // Create a sphere that will expand to visualize sound waves
        let wave = ModelEntity(
            mesh: MeshResource.generateSphere(radius: 0.05),
            materials: [SimpleMaterial(color: UIColor.blue.withAlphaComponent(0.3), isMetallic: false)]
        )
        
        wave.name = "soundWave"
        entity.addChild(wave)
        
        // Set initial scale
        wave.transform.scale = SIMD3<Float>(1, 1, 1)
        
        // Create a repeating animation using a timer
        let timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak wave] timer in
            guard let wave = wave else {
                timer.invalidate()
                return
            }
            
            // If scale reaches 10, reset to 1
            if wave.transform.scale.x >= 10 {
                wave.transform.scale = SIMD3<Float>(1, 1, 1)
            } else {
                // Otherwise, increase scale gradually
                let newScale = wave.transform.scale.x + 0.2
                wave.transform.scale = SIMD3<Float>(newScale, newScale, newScale)
            }
        }
        
        // Store the timer in a custom component
        wave.components.set(AnimationComponent(timer: timer))
    }
    
    func removeSoundWaveEffect(from entity: Entity) {
        // Find and remove all sound wave entities
        entity.children.forEach { child in
            if child.name == "soundWave" {
                // Stop animation timer if it exists
                if let animationComponent = child.components[AnimationComponent.self],
                   let timer = animationComponent.timer {
                    timer.invalidate()
                }
                child.removeFromParent()
            }
        }
    }
    
    func saveLayout(name: String, viewContext: NSManagedObjectContext) {
        // Create new layout configuration directly using NSEntityDescription
        let newLayout = NSEntityDescription.insertNewObject(forEntityName: "LayoutConfiguration", into: viewContext)
        
        // Set properties using key-value coding
        newLayout.setValue(name, forKey: "name")
        newLayout.setValue(Date(), forKey: "timestamp")
        newLayout.setValue(roomType?.rawValue, forKey: "roomType")
        newLayout.setValue(audioSystemType?.rawValue, forKey: "systemType")
        
        // Encode speaker data to store in Core Data
        let speakerDataArray = speakers.map { speaker -> [String: Any] in
            return [
                "id": speaker.id.uuidString,
                "type": speaker.type.rawValue,
                "x": speaker.position.x,
                "y": speaker.position.y,
                "z": speaker.position.z
            ]
        }
        
        // Convert to JSON data
        do {
            let encodedData = try JSONSerialization.data(withJSONObject: speakerDataArray, options: [])
            newLayout.setValue(encodedData, forKey: "speakersData")
            
            // Save to Core Data
            try viewContext.save()
            print("Successfully saved layout: \(name) with \(speakers.count) speakers")
        } catch {
            print("Failed to save layout: \(error)")
        }
    }
}

#Preview {
    ARSpeakerPlacementView(roomType: .livingRoom, audioSystem: .system5_1)
}
