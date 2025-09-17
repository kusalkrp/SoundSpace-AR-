// UserGuideView.swift
// Soundspace-AR
//
// Created by Assistant on 2025-01-17.
//

import SwiftUI

struct UserGuideView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep = 0
    @State private var isAnimating = false
    @State private var showingSkipAlert = false
    
    let tutorialSteps = TutorialStep.allSteps
    
    var body: some View {
        ZStack {
            // Dynamic background gradient based on current step
            LinearGradient(
                gradient: Gradient(colors: tutorialSteps[currentStep].backgroundColors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.8), value: currentStep)
            
            VStack(spacing: 0) {
                // Progress indicator
                progressIndicator
                
                // Main content
                TabView(selection: $currentStep) {
                    ForEach(0..<tutorialSteps.count, id: \.self) { index in
                        TutorialStepView(
                            step: tutorialSteps[index],
                            isActive: currentStep == index,
                            isAnimating: $isAnimating
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.5), value: currentStep)
                
                // Navigation controls
                navigationControls
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            startAnimation()
        }
        .alert("Skip Tutorial?", isPresented: $showingSkipAlert) {
            Button("Continue Tutorial", role: .cancel) { }
            Button("Skip", role: .destructive) {
                dismiss()
            }
        } message: {
            Text("Are you sure you want to skip the tutorial? You can always access it later from the Help section.")
        }
    }
    
    private var progressIndicator: some View {
        VStack(spacing: 16) {
            HStack {
                Button("Skip") {
                    showingSkipAlert = true
                }
                .foregroundColor(.white.opacity(0.8))
                .font(.subheadline)
                
                Spacer()
                
                Text("Tutorial")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(currentStep + 1)/\(tutorialSteps.count)")
                    .foregroundColor(.white.opacity(0.8))
                    .font(.subheadline)
            }
            .padding(.horizontal, 24)
            .padding(.top, 60)
            
            // Progress bar
            HStack(spacing: 4) {
                ForEach(0..<tutorialSteps.count, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(index <= currentStep ? Color.white : Color.white.opacity(0.3))
                        .frame(height: 4)
                        .frame(maxWidth: .infinity)
                        .animation(.easeInOut(duration: 0.3).delay(Double(index) * 0.1), value: currentStep)
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    private var navigationControls: some View {
        VStack(spacing: 16) {
            // Primary action button
            Button(action: {
                if currentStep < tutorialSteps.count - 1 {
                    nextStep()
                } else {
                    completeTutorial()
                }
            }) {
                HStack {
                    Text(currentStep < tutorialSteps.count - 1 ? "Next" : "Get Started")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    if currentStep < tutorialSteps.count - 1 {
                        Image(systemName: "arrow.right")
                            .font(.headline)
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                )
            }
            .scaleEffect(isAnimating ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: isAnimating)
            
            // Secondary actions
            HStack(spacing: 24) {
                if currentStep > 0 {
                    Button("Previous") {
                        previousStep()
                    }
                    .foregroundColor(.white.opacity(0.8))
                    .font(.subheadline)
                }
                
                Spacer()
                
                if currentStep < tutorialSteps.count - 1 {
                    Button("Skip All") {
                        showingSkipAlert = true
                    }
                    .foregroundColor(.white.opacity(0.6))
                    .font(.caption)
                }
            }
            .padding(.horizontal, 24)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
    }
    
    private func nextStep() {
        withAnimation(.easeInOut(duration: 0.5)) {
            currentStep = min(currentStep + 1, tutorialSteps.count - 1)
        }
        startAnimation()
    }
    
    private func previousStep() {
        withAnimation(.easeInOut(duration: 0.5)) {
            currentStep = max(currentStep - 1, 0)
        }
        startAnimation()
    }
    
    private func startAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isAnimating = true
        }
    }
    
    private func completeTutorial() {
        UserDefaults.standard.set(true, forKey: "HasCompletedTutorial")
        dismiss()
    }
}

// MARK: - Tutorial Step View
struct TutorialStepView: View {
    let step: TutorialStep
    let isActive: Bool
    @Binding var isAnimating: Bool
    @State private var animationOffset: CGFloat = 50
    @State private var animationOpacity: Double = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer(minLength: 20)
                
                // Icon with animation
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 140, height: 140)
                        .scaleEffect(isActive && isAnimating ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
                    
                    Circle()
                        .fill(Color.white.opacity(0.05))
                        .frame(width: 180, height: 180)
                        .scaleEffect(isActive && isAnimating ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: isAnimating)
                    
                    Image(systemName: step.icon)
                        .font(.system(size: 50, weight: .medium))
                        .foregroundColor(.white)
                        .scaleEffect(isActive && isAnimating ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                }
                .offset(y: animationOffset)
                .opacity(animationOpacity)
                
                VStack(spacing: 20) {
                    // Title
                    Text(step.title)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .offset(y: animationOffset)
                        .opacity(animationOpacity)
                    
                    // Description
                    Text(step.description)
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 32)
                        .offset(y: animationOffset)
                        .opacity(animationOpacity)
                    
                    // Features list (if available)
                    if !step.features.isEmpty {
                        VStack(spacing: 12) {
                            ForEach(Array(step.features.enumerated()), id: \.offset) { index, feature in
                                HStack(spacing: 16) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.white)
                                        .font(.title3)
                                    
                                    Text(feature)
                                        .foregroundColor(.white.opacity(0.9))
                                        .font(.subheadline)
                                        .multilineTextAlignment(.leading)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 32)
                                .offset(y: animationOffset)
                                .opacity(animationOpacity)
                                .animation(.easeInOut(duration: 0.8).delay(Double(index) * 0.2), value: isActive)
                            }
                        }
                        .padding(.top, 8)
                    }
                    
                    // Interactive demo (if available)
                    if let demoView = step.demoView {
                        demoView
                            .padding(.horizontal, 32)
                            .offset(y: animationOffset)
                            .opacity(animationOpacity)
                    }
                }
                
                Spacer(minLength: 40)
            }
        }
        .onAppear {
            if isActive {
                animateIn()
            }
        }
        .onChange(of: isActive) { _, newValue in
            if newValue {
                animateIn()
            }
        }
    }
    
    private func animateIn() {
        animationOffset = 50
        animationOpacity = 0
        
        withAnimation(.easeOut(duration: 0.8)) {
            animationOffset = 0
            animationOpacity = 1
        }
    }
}

// MARK: - Tutorial Step Model
struct TutorialStep {
    let title: String
    let description: String
    let icon: String
    let features: [String]
    let backgroundColors: [Color]
    let demoView: AnyView?
    
    init(title: String, description: String, icon: String, features: [String] = [], backgroundColors: [Color], demoView: AnyView? = nil) {
        self.title = title
        self.description = description
        self.icon = icon
        self.features = features
        self.backgroundColors = backgroundColors
        self.demoView = demoView
    }
    
    static let allSteps: [TutorialStep] = [
        // Welcome
        TutorialStep(
            title: "Welcome to SoundSpace AR",
            description: "Transform your home audio experience with the power of augmented reality. Get perfect speaker placement every time.",
            icon: "speaker.wave.3",
            features: [
                "AR-powered room scanning",
                "Intelligent speaker placement",
                "Community reviews and tips",
                "Professional calibration tools"
            ],
            backgroundColors: [
                Color(red: 0.4, green: 0.5, blue: 1.0),
                Color(red: 0.3, green: 0.4, blue: 0.9)
            ]
        ),
        
        // Room Scanning
        TutorialStep(
            title: "Scan Your Room",
            description: "Use your device's camera to create a detailed 3D map of your space. Move slowly and capture all walls and furniture.",
            icon: "viewfinder",
            features: [
                "Automatic room detection",
                "Furniture recognition",
                "Acoustic analysis",
                "3D room mapping"
            ],
            backgroundColors: [
                Color(red: 0.2, green: 0.7, blue: 0.9),
                Color(red: 0.1, green: 0.5, blue: 0.8)
            ],
            demoView: AnyView(RoomScanningDemoView())
        ),
        
        // Speaker Placement
        TutorialStep(
            title: "Smart Placement",
            description: "Our AI analyzes your room and suggests optimal speaker positions for the best sound quality in your unique space.",
            icon: "arrow.up.and.down.and.arrow.left.and.right",
            features: [
                "AI-powered recommendations",
                "Real-time AR visualization",
                "Multiple system types",
                "Acoustic optimization"
            ],
            backgroundColors: [
                Color(red: 0.9, green: 0.4, blue: 0.6),
                Color(red: 0.8, green: 0.2, blue: 0.4)
            ],
            demoView: AnyView(SpeakerPlacementDemoView())
        ),
        
        // Calibration
        TutorialStep(
            title: "Perfect Calibration",
            description: "Fine-tune your audio setup with professional calibration tools. Test frequencies and adjust for optimal sound.",
            icon: "slider.horizontal.3",
            features: [
                "Frequency response testing",
                "Volume balancing",
                "Distance measurements",
                "Real-time adjustments"
            ],
            backgroundColors: [
                Color(red: 0.6, green: 0.8, blue: 0.3),
                Color(red: 0.4, green: 0.6, blue: 0.2)
            ],
            demoView: AnyView(CalibrationDemoView())
        ),
        
        // Community
        TutorialStep(
            title: "Join the Community",
            description: "Share your setups, read reviews, and learn from audio enthusiasts worldwide. Get inspired by real user experiences.",
            icon: "person.3",
            features: [
                "Speaker reviews and ratings",
                "Setup photo sharing",
                "Expert recommendations",
                "Q&A discussions"
            ],
            backgroundColors: [
                Color(red: 0.8, green: 0.3, blue: 0.9),
                Color(red: 0.6, green: 0.2, blue: 0.7)
            ]
        ),
        
        // Save & Share
        TutorialStep(
            title: "Save Your Setup",
            description: "Save multiple speaker configurations and easily switch between them. Share your perfect setups with friends.",
            icon: "square.and.arrow.down.on.square",
            features: [
                "Multiple layout saving",
                "Quick switching",
                "Export configurations",
                "Backup to cloud"
            ],
            backgroundColors: [
                Color(red: 0.9, green: 0.6, blue: 0.2),
                Color(red: 0.8, green: 0.4, blue: 0.1)
            ]
        ),
        
        // Ready to Start
        TutorialStep(
            title: "You're Ready!",
            description: "You now know everything you need to create the perfect audio setup. Let's get started with your first room scan!",
            icon: "checkmark.circle",
            features: [
                "Tap 'Get Started' to begin",
                "Access Help anytime from Settings",
                "Join our community for tips",
                "Enjoy perfect sound!"
            ],
            backgroundColors: [
                Color(red: 0.2, green: 0.8, blue: 0.6),
                Color(red: 0.1, green: 0.6, blue: 0.4)
            ]
        )
    ]
}

// MARK: - Demo Views
struct RoomScanningDemoView: View {
    @State private var scanProgress: Double = 0
    @State private var isScanning = false
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 120)
                
                VStack(spacing: 8) {
                    Image(systemName: "camera.viewfinder")
                        .font(.title)
                        .foregroundColor(.white)
                        .scaleEffect(isScanning ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isScanning)
                    
                    Text("Scanning...")
                        .foregroundColor(.white.opacity(0.8))
                        .font(.caption)
                    
                    ProgressView(value: scanProgress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .white))
                        .frame(width: 100)
                }
            }
        }
        .onAppear {
            startScanningDemo()
        }
    }
    
    private func startScanningDemo() {
        isScanning = true
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            scanProgress += 0.02
            if scanProgress >= 1.0 {
                scanProgress = 0
            }
        }
    }
}

struct SpeakerPlacementDemoView: View {
    @State private var speakerPositions: [CGPoint] = []
    @State private var animationIndex = 0
    
    let optimalPositions: [CGPoint] = [
        CGPoint(x: 50, y: 60),
        CGPoint(x: 250, y: 60),
        CGPoint(x: 150, y: 120)
    ]
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
                .frame(height: 140)
            
            // Room outline
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white.opacity(0.5), lineWidth: 2)
                .frame(width: 280, height: 120)
            
            // Speaker positions
            ForEach(0..<speakerPositions.count, id: \.self) { index in
                VStack(spacing: 4) {
                    Image(systemName: "speaker.3")
                        .font(.title3)
                        .foregroundColor(.white)
                    
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 30, height: 30)
                }
                .position(speakerPositions[index])
                .scaleEffect(1.2)
                .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(Double(index) * 0.3), value: speakerPositions)
            }
        }
        .onAppear {
            startPlacementDemo()
        }
    }
    
    private func startPlacementDemo() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if animationIndex < optimalPositions.count {
                speakerPositions.append(optimalPositions[animationIndex])
                animationIndex += 1
            } else {
                // Reset animation
                speakerPositions.removeAll()
                animationIndex = 0
            }
        }
    }
}

struct CalibrationDemoView: View {
    @State private var frequency: Double = 440
    @State private var isPlaying = false
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 100)
                
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "speaker.wave.1")
                        Image(systemName: "speaker.wave.2")
                        Image(systemName: "speaker.wave.3")
                    }
                    .font(.title2)
                    .foregroundColor(.white)
                    .scaleEffect(isPlaying ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: isPlaying)
                    
                    Text("\(Int(frequency)) Hz")
                        .foregroundColor(.white)
                        .font(.headline)
                    
                    Slider(value: $frequency, in: 20...20000)
                        .accentColor(.white)
                        .frame(width: 120)
                }
            }
        }
        .onAppear {
            startCalibrationDemo()
        }
    }
    
    private func startCalibrationDemo() {
        isPlaying = true
        
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 1.5)) {
                frequency = Double.random(in: 100...2000)
            }
        }
    }
}

#Preview {
    UserGuideView()
}