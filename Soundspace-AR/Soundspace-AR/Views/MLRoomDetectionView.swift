// MLRoomDetectionView.swift
// Soundspace-AR
//
// Created by Assistant on 2025-08-17.
//

import SwiftUI
import AVFoundation
import Vision
import CoreML

struct MLRoomDetectionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var cameraManager = CameraManager()
    @StateObject private var roomDetector = RoomDetector()
    
    @State private var isAnalyzing = false
    @State private var showingResults = false
    @State private var detectedRoomType: RoomType?
    @State private var recommendedSystem: AudioSystemType?
    @State private var confidence: Float = 0.0
    @State private var detectedObjects: [String] = []
    @State private var classificationSupported: Bool = true
    @State private var showingMethodSelection = true
    @State private var selectedMethod: DetectionMethod = .aiAnalysis
    
    enum DetectionMethod {
        case aiAnalysis
        case arScanning
    }
    
    var body: some View {
        ZStack {
            if showingMethodSelection {
                methodSelectionView
            } else if selectedMethod == .arScanning {
                RoomScanningView()
            } else {
                aiAnalysisView
            }
        }
        .onAppear {
            classificationSupported = roomDetector.supportsClassification
        }
    }
    
    private var methodSelectionView: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.4, green: 0.5, blue: 1.0),
                    Color(red: 0.3, green: 0.4, blue: 0.9)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                    
                    Text("Room Analysis")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Choose your preferred method to analyze your room")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                
                // Method options
                VStack(spacing: 20) {
                    // AI Analysis Option
                    MethodCard(
                        title: "AI Analysis",
                        subtitle: "Quick analysis using camera and AI",
                        description: "Fast room detection with AI-powered recommendations",
                        icon: "brain.head.profile",
                        features: ["Quick results", "AI-powered detection", "Scene analysis"],
                        isSelected: selectedMethod == .aiAnalysis
                    ) {
                        selectedMethod = .aiAnalysis
                        showingMethodSelection = false
                    }
                    
                    // AR Scanning Option
                    MethodCard(
                        title: "AR Scanning",
                        subtitle: "Precise 3D measurement with AR",
                        description: "Accurate room dimensions using AR technology",
                        icon: "ruler.fill",
                        features: ["Precise measurements", "3D room mapping", "AR visualization"],
                        isSelected: selectedMethod == .arScanning
                    ) {
                        selectedMethod = .arScanning
                        showingMethodSelection = false
                    }
                }
                
                // Cancel button
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.white.opacity(0.8))
                .padding(.top, 20)
            }
            .padding(.horizontal, 24)
        }
    }
    
    private var aiAnalysisView: some View {
        ZStack {
            // Camera Preview
            CameraPreviewView(session: cameraManager.session)
                .ignoresSafeArea()
            
            // Overlay UI
            VStack {
                // Top controls
                HStack {
                    Button("Back") {
                        showingMethodSelection = true
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(8)
                    
                    Spacer()
                    
                    if !detectedObjects.isEmpty {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Objects Detected:")
                                .font(.caption)
                                .foregroundColor(.white)
                            ForEach(detectedObjects.prefix(3), id: \.self) { object in
                                Text(object)
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        .padding(8)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(8)
                    }
                }
                .padding()
                
                Spacer()
                
                // Instructions
                if !isAnalyzing && !showingResults {
                    VStack(spacing: 16) {
                        VStack(spacing: 8) {
                            Text("AI Room Analysis")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Point your camera around the room to detect its type and recommend the best audio setup")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                            if !classificationSupported {
                                Text("Live Vision classification not available on this iOS version or device. You can still continue and we'll provide a default recommendation.")
                                    .font(.caption)
                                    .foregroundColor(.yellow)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(12)
                        
                        Button("Start Analysis") {
                            startAnalysis()
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(12)

                        if !classificationSupported {
                            Button("Show Default Recommendation") {
                                // Emit a default lightweight result when classification unsupported
                                detectedRoomType = .livingRoom
                                recommendedSystem = .system5_1
                                confidence = 0.25
                                showingResults = true
                            }
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.orange)
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                }
                
                // Analysis in progress
                if isAnalyzing {
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                        
                        Text("Analyzing room...")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("Keep moving your camera around the room")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))

                        Button("Finish Now") {
                            roomDetector.forceEmitResultNow()
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(12)
                    .padding()
                }
            }
        }
        .onAppear {
            cameraManager.startSession(delegate: roomDetector)
            roomDetector.onObjectsDetected = { objects in
                self.detectedObjects = objects
            }
            roomDetector.onAnalysisResult = { result in
                self.detectedRoomType = result.roomType
                self.recommendedSystem = result.recommendedSystem
                self.confidence = result.confidence
                self.showingResults = true
                self.isAnalyzing = false
            }
        }
        .onDisappear {
            cameraManager.stopSession()
        }
        .sheet(isPresented: $showingResults) {
            RoomDetectionResultsView(
                roomType: detectedRoomType ?? .livingRoom,
                recommendedSystem: recommendedSystem ?? .system5_1,
                confidence: confidence,
                roomDimensions: nil
            )
        }
    }
    
    private func startAnalysis() {
        isAnalyzing = true
        roomDetector.startLiveAnalysis()
    }
    
    private func completeAnalysis() {
        // Deprecated: now handled by Vision callback
    }
}

// MARK: - Method Selection Card
struct MethodCard: View {
    let title: String
    let subtitle: String
    let description: String
    let icon: String
    let features: [String]
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(isSelected ? Color.white : Color.white.opacity(0.2))
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: icon)
                            .font(.system(size: 24))
                            .foregroundColor(isSelected ? Color.blue : Color.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.green)
                    }
                }
                
                // Description
                Text(description)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.leading)
                
                // Features
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(features, id: \.self) { feature in
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12))
                                .foregroundColor(.green)
                            
                            Text(feature)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.white.opacity(0.2) : Color.black.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.white.opacity(0.5) : Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Camera Manager

class CameraManager: ObservableObject {
    let session = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    
    func startSession(delegate: AVCaptureVideoDataOutputSampleBufferDelegate) {
        guard session.inputs.isEmpty else { return }
        session.beginConfiguration()
        session.sessionPreset = .high
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            session.commitConfiguration(); return
        }
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if session.canAddInput(input) { session.addInput(input) }
            videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
            videoOutput.alwaysDiscardsLateVideoFrames = true
            let queue = DispatchQueue(label: "camera.sample.buffer")
            videoOutput.setSampleBufferDelegate(delegate, queue: queue)
            if session.canAddOutput(videoOutput) { session.addOutput(videoOutput) }
            if let connection = videoOutput.connection(with: .video) {
                if #available(iOS 17.0, *) {
                    // 90° rotation = portrait (device held upright)
                    if connection.isVideoRotationAngleSupported(90) {
                        connection.videoRotationAngle = 90
                    }
                } else if connection.isVideoOrientationSupported {
                    connection.videoOrientation = .portrait
                }
            }
            session.commitConfiguration()
            DispatchQueue.global(qos: .userInitiated).async { self.session.startRunning() }
        } catch {
            session.commitConfiguration()
            print("Camera setup error: \(error)")
        }
    }
    
    func stopSession() { session.stopRunning() }
}

// MARK: - Camera Preview

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        DispatchQueue.main.async {
            previewLayer.frame = view.bounds
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let layer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            DispatchQueue.main.async {
                layer.frame = uiView.bounds
            }
        }
    }
}

// MARK: - Room Detector

class RoomDetector: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    // Callbacks
    var onObjectsDetected: (([String]) -> Void)?
    var onAnalysisResult: ((RoomAnalysisHeuristics.Result) -> Void)?
    
    // Vision
    private let sequenceHandler = VNSequenceRequestHandler()
    private var classificationRequests: [VNRequest] = []
    // Removed object observation storage (VNRecognizeObjectsRequest unavailable in current SDK)
    private var sceneLabelScores: [String: Float] = [:]
    private var frameCounter = 0
    private let inferenceInterval = 5 // analyze every Nth frame
    private var isLive = false
    private var lastResultTimestamp = Date(timeIntervalSince1970: 0)
    private let resultCooldown: TimeInterval = 2.0
    private var pseudoObjects: [String] = []
    private let smoothingFactor: Float = 0.8 // exponential moving average smoothing
    
    // Basic area estimation (coarse) via motion extent accumulation
    private var minX: Float =  .greatestFiniteMagnitude
    private var maxX: Float = -.greatestFiniteMagnitude
    private var minZ: Float =  .greatestFiniteMagnitude
    private var maxZ: Float = -.greatestFiniteMagnitude
    
    override init() {
        super.init()
        prepareRequests()
    }
    
    func startLiveAnalysis() { isLive = true }
    func stop() { isLive = false }
    
    private func prepareRequests() {
        // Scene classification (built-in). Object recognition request omitted because VNRecognizeObjectsRequest
        // isn't available in this SDK / deployment target.
        if #available(iOS 16.0, *) {
            let sceneRequest = VNClassifyImageRequest()
            classificationRequests = [sceneRequest]
        } else {
            classificationRequests = [] // Fallback: no Vision classification available
        }
    }

    var supportsClassification: Bool { !classificationRequests.isEmpty }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard isLive else { return }
        frameCounter += 1
        if frameCounter % inferenceInterval != 0 { return }
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        if !classificationRequests.isEmpty {
            do {
                try sequenceHandler.perform(classificationRequests, on: pixelBuffer)
                processRequests()
            } catch { print("Vision error: \(error)") }
        }
    }
    
    private func processRequests() {
        // scene-only fallback: object labels not available in this configuration
        var newSceneLabels: [(String, Float)] = []
        for request in classificationRequests {
            if let sceneReq = request as? VNClassifyImageRequest, let results = sceneReq.results { // VNClassificationObservation
                for r in results.prefix(5) {
                    let prev = sceneLabelScores[r.identifier] ?? Float(r.confidence)
                    // Exponential moving average smoothing
                    sceneLabelScores[r.identifier] = prev * smoothingFactor + Float(r.confidence) * (1 - smoothingFactor)
                    newSceneLabels.append((r.identifier, Float(r.confidence)))
                }
            }
        }
        // Derive pseudo "objects" from top scene label tokens (very weak fallback) for heuristics.
        let tokenObjects = newSceneLabels.flatMap { $0.0.split(separator: " ") }.map { String($0.lowercased()) }
        if !tokenObjects.isEmpty {
            pseudoObjects = Array(Set(tokenObjects.prefix(8)))
            DispatchQueue.main.async { self.onObjectsDetected?(Array(self.pseudoObjects.prefix(5))) }
        }
        maybeEmitFinalResult()
    }
    
    private func aggregateTopObjects(limit: Int) -> [String] { Array(pseudoObjects.prefix(limit)) }
    private func topSceneLabels(limit: Int) -> [(String, Float)] {
        return sceneLabelScores.sorted { $0.value > $1.value }.prefix(limit).map { ($0.key, $0.value) }
    }
    
    private func maybeEmitFinalResult(force: Bool = false) {
        let now = Date()
        if !force {
            guard now.timeIntervalSince(lastResultTimestamp) > resultCooldown else { return }
        }
        let objects = aggregateTopObjects(limit: 8)
        let scenes = topSceneLabels(limit: 5)
        let area = estimatedArea()
        let result = RoomAnalysisHeuristics.combine(sceneLabels: scenes, objectLabels: objects, floorAreaM2: area)
        lastResultTimestamp = now
        DispatchQueue.main.async { self.onAnalysisResult?(result) }
    }

    func forceEmitResultNow() { maybeEmitFinalResult(force: true) }
    
    // Naive area estimate from accumulated camera translation extents (placeholder until AR fusion added)
    private func estimatedArea() -> Float? {
        let dx = maxX - minX
        let dz = maxZ - minZ
        guard dx.isFinite, dz.isFinite, dx > 0, dz > 0 else { return nil }
        return dx * dz
    }
}

struct MLRoomDetectionView_Previews: PreviewProvider {
    static var previews: some View {
        MLRoomDetectionView()
    }
}
