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
    
    var body: some View {
        ZStack {
            // Camera Preview
            CameraPreviewView(session: cameraManager.session)
                .ignoresSafeArea()
            
            // Overlay UI
            VStack {
                // Top controls
                HStack {
                    Button("Cancel") {
                        dismiss()
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
                    }
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(12)
                    .padding()
                }
            }
        }
        .onAppear {
            cameraManager.startSession()
            roomDetector.onObjectsDetected = { objects in
                self.detectedObjects = objects
            }
        }
        .onDisappear {
            cameraManager.stopSession()
        }
        .sheet(isPresented: $showingResults) {
            RoomDetectionResultsView(
                roomType: detectedRoomType ?? .livingRoom,
                recommendedSystem: recommendedSystem ?? .system5_1,
                confidence: confidence
            )
        }
    }
    
    private func startAnalysis() {
        isAnalyzing = true
        roomDetector.startDetection(with: cameraManager.session)
        
        // Simulate analysis completion after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            completeAnalysis()
        }
    }
    
    private func completeAnalysis() {
        isAnalyzing = false
        
        // Mock results for now
        detectedRoomType = .livingRoom
        recommendedSystem = .system5_1
        confidence = 0.85
        
        showingResults = true
    }
}

// MARK: - Camera Manager

class CameraManager: ObservableObject {
    let session = AVCaptureSession()
    private var videoOutput = AVCaptureVideoDataOutput()
    
    func startSession() {
        guard let camera = AVCaptureDevice.default(for: .video) else { return }
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            
            if session.canAddInput(input) {
                session.addInput(input)
            }
            
            if session.canAddOutput(videoOutput) {
                session.addOutput(videoOutput)
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                self.session.startRunning()
            }
        } catch {
            print("Error setting up camera: \(error)")
        }
    }
    
    func stopSession() {
        session.stopRunning()
    }
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

class RoomDetector: NSObject, ObservableObject {
    var onObjectsDetected: (([String]) -> Void)?
    
    func startDetection(with session: AVCaptureSession) {
        // Mock implementation - in a real app, this would use Core ML
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.onObjectsDetected?(["Sofa", "TV", "Coffee Table"])
        }
    }
}

struct MLRoomDetectionView_Previews: PreviewProvider {
    static var previews: some View {
        MLRoomDetectionView()
    }
}
