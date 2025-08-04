// SettingsView.swift
// Soundspace-AR
//
// Created by Kusal on 2025-08-04.
//

import SwiftUI
import LocalAuthentication

struct SettingsView: View {
    @AppStorage("useBiometricAuth") private var useBiometricAuth = false
    @AppStorage("usePersistentARAnchoring") private var usePersistentARAnchoring = false
    @AppStorage("showOnboarding") private var showOnboarding = true
    
    @State private var showResetConfirmation = false
    @State private var biometricType: String = "Face ID"
    @State private var showOnboardingScreen = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("App Settings")) {
                    Toggle(isOn: $useBiometricAuth) {
                        Label(biometricType, systemImage: biometricType == "Face ID" ? "faceid" : "touchid")
                    }
                    .onChange(of: useBiometricAuth) { newValue in
                        if newValue {
                            authenticateUser()
                        }
                    }
                    
                    Toggle(isOn: $usePersistentARAnchoring) {
                        Label("Persistent AR Anchoring", systemImage: "arkit")
                    }
                }
                
                Section(header: Text("Help & Support")) {
                    Button(action: {
                        showOnboardingScreen = true
                    }) {
                        Label("Tutorial", systemImage: "book")
                    }
                    
                    Link(destination: URL(string: "https://soundspacear.com/support")!) {
                        Label("Help Center", systemImage: "questionmark.circle")
                    }
                    
                    Link(destination: URL(string: "https://soundspacear.com/privacy")!) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                    }
                }
                
                Section(header: Text("App Information")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text("2025.08.001")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Data")) {
                    Button(action: {
                        showResetConfirmation = true
                    }) {
                        Label("Reset All Data", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                checkBiometricType()
            }
            .alert("Reset All Data", isPresented: $showResetConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    resetAllData()
                }
            } message: {
                Text("Are you sure you want to reset all data? This will delete all saved layouts and preferences.")
            }
            .sheet(isPresented: $showOnboardingScreen) {
                TutorialView(showsDismissButton: true)
            }
        }
    }
    
    private func checkBiometricType() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            biometricType = context.biometryType == .faceID ? "Face ID" : "Touch ID"
        } else {
            biometricType = "Biometric Auth"
            useBiometricAuth = false
        }
    }
    
    private func authenticateUser() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Authenticate to enable biometric security") { success, error in
                DispatchQueue.main.async {
                    if !success {
                        useBiometricAuth = false
                    }
                }
            }
        } else {
            useBiometricAuth = false
        }
    }
    
    private func resetAllData() {
        // Reset user defaults
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            if key != "showOnboarding" { // Keep onboarding setting
                defaults.removeObject(forKey: key)
            }
        }
        
        // Reset Core Data
        // In a real app, we would need to implement proper Core Data reset logic
        
        // Reset UI state
        useBiometricAuth = false
        usePersistentARAnchoring = false
    }
}

struct TutorialView: View {
    @State private var currentPage = 0
    let showsDismissButton: Bool
    @Environment(\.dismiss) private var dismiss
    
    var pages = [
        OnboardingPage(
            title: "Welcome to SoundSpace AR",
            description: "The AR-powered speaker positioning assistant for perfect audio setups.",
            imageName: "speaker.wave.3.fill",
            imageBackground: .blue
        ),
        OnboardingPage(
            title: "Choose Your Setup",
            description: "Select your room type and audio system configuration.",
            imageName: "square.grid.2x2.fill",
            imageBackground: .orange
        ),
        OnboardingPage(
            title: "AR Placement",
            description: "Use augmented reality to see exactly where to place your speakers.",
            imageName: "arkit",
            imageBackground: .purple
        ),
        OnboardingPage(
            title: "Save & Share",
            description: "Save your layouts and share them with others.",
            imageName: "square.and.arrow.up.fill",
            imageBackground: .green
        )
    ]
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                if showsDismissButton {
                    HStack {
                        Spacer()
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.headline)
                                .padding()
                                .foregroundColor(.white)
                        }
                    }
                }
                
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count) { index in
                        VStack(spacing: 20) {
                            ZStack {
                                Circle()
                                    .fill(pages[index].imageBackground.opacity(0.8))
                                    .frame(width: 200, height: 200)
                                
                                Image(systemName: pages[index].imageName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.white)
                            }
                            .padding(.bottom, 40)
                            
                            Text(pages[index].title)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text(pages[index].description)
                                .font(.body)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                                .padding(.bottom, 20)
                            
                            if index == pages.count - 1 {
                                Button(action: {
                                    UserDefaults.standard.set(false, forKey: "showOnboarding")
                                    dismiss()
                                }) {
                                    Text("Get Started")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.blue)
                                        .cornerRadius(10)
                                        .padding(.horizontal, 40)
                                }
                                .padding(.top, 20)
                            }
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            }
        }
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let imageName: String
    let imageBackground: Color
}

#Preview {
    SettingsView()
}
