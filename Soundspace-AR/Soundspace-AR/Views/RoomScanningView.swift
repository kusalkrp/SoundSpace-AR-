// RoomScanningView.swift
// Soundspace-AR
//


import SwiftUI
import ARKit
import VisionKit
import RealityKit

struct RoomScanningView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var roomScanner = RoomScanner()
    @State private var showingResults = false
    @State private var scannedDimensions: RoomDimensions?
    @State private var isScanning = false
    @State private var scanProgress: Float = 0.0
    @State private var instructions: String = "Point your camera at the room and move around to scan"
    @State private var showingTips = false

    var body: some View {
        ZStack {
            // AR View
            RoomScanARViewContainer(roomScanner: roomScanner)
                .ignoresSafeArea()

            // Overlay UI
            VStack {
                // Top controls
                HStack {
                    Button("Cancel") {
                        roomScanner.stopScanning()
                        dismiss()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(8)

                    Spacer()
                    
                    // Tips button
                    Button(action: {
                        showingTips.toggle()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "lightbulb.fill")
                            Text("Tips")
                        }
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.orange.opacity(0.8))
                        .cornerRadius(20)
                    }

                    if isScanning {
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Scanning Progress")
                                .font(.caption)
                                .foregroundColor(.white)
                            Text("\(Int(scanProgress * 100))%")
                                .font(.headline)
                                .foregroundColor(.green)
                        }
                        .padding(8)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(8)
                    }
                }
                .padding()

                // Tips tile - positioned below top controls
                if showingTips {
                    ScanningTipsView()
                        .padding(.horizontal)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }

                Spacer()

                // Instructions and controls
                VStack(spacing: 20) {
                    // Instructions
                    VStack(spacing: 8) {
                        Text(instructions)
                            .font(.headline)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)

                        if let dimensions = scannedDimensions {
                            VStack(spacing: 4) {
                                Text("Room Dimensions Detected:")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                                Text("\(String(format: "%.1f", dimensions.length))m × \(String(format: "%.1f", dimensions.width))m × \(String(format: "%.1f", dimensions.height))m")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                                Text("Area: \(String(format: "%.1f", dimensions.area)) m²")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(12)

                    // Control buttons
                    HStack(spacing: 16) {
                        if !isScanning {
                            Button(action: startScanning) {
                                HStack {
                                    Image(systemName: "camera.viewfinder")
                                    Text("Start Scan")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .font(.headline)
                            }
                        } else {
                            Button(action: stopScanning) {
                                HStack {
                                    Image(systemName: "stop.fill")
                                    Text("Stop Scan")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .font(.headline)
                            }
                        }

                        if scannedDimensions != nil {
                            Button(action: finishScanning) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Use Results")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .font(.headline)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showingTips)
        .onAppear {
            roomScanner.onDimensionsUpdated = { dimensions in
                self.scannedDimensions = dimensions
            }
            roomScanner.onProgressUpdated = { progress in
                self.scanProgress = progress
            }
            roomScanner.onInstructionsUpdated = { instruction in
                self.instructions = instruction
            }
        }
        .sheet(isPresented: $showingResults) {
            RoomDetectionResultsView(
                roomType: scannedDimensions?.roomType ?? .livingRoom,
                recommendedSystem: scannedDimensions?.recommendedSystem ?? .system5_1,
                confidence: scannedDimensions?.confidence ?? 0.5,
                roomDimensions: scannedDimensions
            )
        }
    }

    private func startScanning() {
        isScanning = true
        roomScanner.startScanning()
        instructions = "Move your device slowly around the room to capture all surfaces"
    }

    private func stopScanning() {
        isScanning = false
        roomScanner.stopScanning()
        instructions = "Scan complete! Review dimensions above"
    }

    private func finishScanning() {
        showingResults = true
    }
}

// MARK: - Room Dimensions Model
struct RoomDimensions {
    let length: Float
    let width: Float
    let height: Float
    let area: Float
    let volume: Float
    let confidence: Float

    var roomType: RoomType {
        // Determine room type based on dimensions
        let area = self.area

        if area < 15 {
            return .bedroom
        } else if area < 30 {
            return .office
        } else if area < 50 {
            return .livingRoom
        } else if area < 100 {
            return .diningRoom
        } else {
            return .hall
        }
    }

    var recommendedSystem: AudioSystemType {
        switch roomType {
        case .bedroom, .office:
            return .system2_1
        case .livingRoom, .diningRoom:
            return .system5_1
        case .hall, .basement:
            return .system7_1
        case .garage:
            return .system2_1
        }
    }
}

// MARK: - Room Scan AR View Container
struct RoomScanARViewContainer: UIViewRepresentable {
    let roomScanner: RoomScanner

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        roomScanner.setupARView(arView)
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        // Update if needed
    }
}

// MARK: - Room Scanner
class RoomScanner: NSObject, ObservableObject, ARSessionDelegate {
    private var arView: ARView?
    private var isScanning = false
    private var scannedPoints: [SIMD3<Float>] = []
    private var roomBounds = RoomBounds()
    private var detectedPlanes: [UUID: ARPlaneAnchor] = [:]
    private var scanStartTime: Date?
    private var lastUpdateTime: Date = Date()

    // Callbacks
    var onDimensionsUpdated: ((RoomDimensions) -> Void)?
    var onProgressUpdated: ((Float) -> Void)?
    var onInstructionsUpdated: ((String) -> Void)?

    func setupARView(_ arView: ARView) {
        self.arView = arView

        // Configure AR session
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        
        arView.session.delegate = self
        arView.session.run(configuration)
    }

    func startScanning() {
        isScanning = true
        scanStartTime = Date()
        scannedPoints.removeAll()
        roomBounds = RoomBounds()
        detectedPlanes.removeAll()
    }

    func stopScanning() {
        isScanning = false
        calculateRoomDimensions()
    }

    private func calculateRoomDimensions() {
        guard !detectedPlanes.isEmpty else { return }
        
        // Calculate room dimensions from detected planes
        var minX: Float = .greatestFiniteMagnitude
        var maxX: Float = -.greatestFiniteMagnitude
        var minY: Float = .greatestFiniteMagnitude
        var maxY: Float = -.greatestFiniteMagnitude
        var minZ: Float = .greatestFiniteMagnitude
        var maxZ: Float = -.greatestFiniteMagnitude
        
        for (_, plane) in detectedPlanes {
            let transform = plane.transform
            let position = SIMD3<Float>(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
            
            minX = min(minX, position.x)
            maxX = max(maxX, position.x)
            minY = min(minY, position.y)
            maxY = max(maxY, position.y)
            minZ = min(minZ, position.z)
            maxZ = max(maxZ, position.z)
        }
        
        let length = abs(maxX - minX)
        let width = abs(maxZ - minZ)
        let height = abs(maxY - minY)
        let area = length * width
        let volume = area * height
        
        let dimensions = RoomDimensions(
            length: length,
            width: width,
            height: height,
            area: area,
            volume: volume,
            confidence: 0.8
        )
        
        DispatchQueue.main.async {
            self.onDimensionsUpdated?(dimensions)
        }
    }

    // MARK: - ARSessionDelegate
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                detectedPlanes[anchor.identifier] = planeAnchor
                
                if isScanning {
                    updateProgress()
                }
            }
        }
    }

    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                detectedPlanes[anchor.identifier] = planeAnchor
                
                if isScanning {
                    updateProgress()
                }
            }
        }
    }

    private func updateProgress() {
        let horizontalPlanes = detectedPlanes.values.filter { $0.alignment == .horizontal }.count
        let verticalPlanes = detectedPlanes.values.filter { $0.alignment == .vertical }.count
        
        // Progress based on detected planes (need at least 1 horizontal and 4 vertical for a complete room)
        let progress = min(Float(horizontalPlanes + verticalPlanes) / 5.0, 1.0)
        
        DispatchQueue.main.async {
            self.onProgressUpdated?(progress)
            
            if progress < 0.3 {
                self.onInstructionsUpdated?("Move around to detect walls and floor")
            } else if progress < 0.7 {
                self.onInstructionsUpdated?("Keep scanning - detecting room surfaces")
            } else {
                self.onInstructionsUpdated?("Room scan complete! You can stop scanning now")
            }
        }
    }
}

// MARK: - Room Bounds Helper
struct RoomBounds {
    var minX: Float = .greatestFiniteMagnitude
    var maxX: Float = -.greatestFiniteMagnitude
    var minY: Float = .greatestFiniteMagnitude
    var maxY: Float = -.greatestFiniteMagnitude
    var minZ: Float = .greatestFiniteMagnitude
    var maxZ: Float = -.greatestFiniteMagnitude
    
    mutating func update(with point: SIMD3<Float>) {
        minX = min(minX, point.x)
        maxX = max(maxX, point.x)
        minY = min(minY, point.y)
        maxY = max(maxY, point.y)
        minZ = min(minZ, point.z)
        maxZ = max(maxZ, point.z)
    }
}

struct RoomScanningView_Previews: PreviewProvider {
    static var previews: some View {
        RoomScanningView()
    }
}

// MARK: - Scanning Tips View
struct ScanningTipsView: View {
    @State private var currentTipIndex = 0
    @State private var timer: Timer?
    
    private let tips = [
        TipItem(
            icon: "move.3d",
            title: "Move Slowly",
            description: "Walk around the room slowly to capture all surfaces clearly"
        ),
        TipItem(
            icon: "light.max",
            title: "Good Lighting",
            description: "Ensure the room is well-lit for better AR tracking"
        ),
        TipItem(
            icon: "rectangle.stack",
            title: "Scan All Walls",
            description: "Point your camera at each wall, floor, and ceiling"
        ),
        TipItem(
            icon: "arrow.clockwise",
            title: "Multiple Angles",
            description: "Scan corners and edges from different angles"
        ),
        TipItem(
            icon: "hand.raised.fill",
            title: "Hold Steady",
            description: "Keep your device steady when scanning surfaces"
        ),
        TipItem(
            icon: "exclamationmark.triangle",
            title: "Avoid Obstacles",
            description: "Move furniture or objects that might block surfaces"
        )
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.orange)
                Text("Scanning Tips")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(currentTipIndex + 1)/\(tips.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Current tip
            HStack(spacing: 12) {
                Image(systemName: tips[currentTipIndex].icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(tips[currentTipIndex].title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(tips[currentTipIndex].description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
            }
            
            // Tip navigation dots
            HStack(spacing: 8) {
                ForEach(0..<tips.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentTipIndex ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .onTapGesture {
                            currentTipIndex = index
                            restartTimer()
                        }
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                currentTipIndex = (currentTipIndex + 1) % tips.count
            }
        }
    }
    
    private func restartTimer() {
        timer?.invalidate()
        startTimer()
    }
}

// MARK: - Tip Item Model
struct TipItem {
    let icon: String
    let title: String
    let description: String
}
