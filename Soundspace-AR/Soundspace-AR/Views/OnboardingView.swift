// OnboardingView.swift
// Soundspace-AR
//


import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showingUserGuide = false
    @State private var showingLogin = false
    
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
                // Welcome title section - takes up most of the screen
                VStack {
                    Spacer()
                    
                    VStack(spacing: 8) {
                        Text("Welcome to")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        Text("SoundSpace AR")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                }
                
                // Main content card - positioned at bottom
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        Text("Your Sound")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        
                        Text("Setup Companion")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                    }
                    
                    Text("Let's get started by configuring your room and sound system. This helps us optimize the AR speaker layout for your space and audio needs")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 20)
                        .lineSpacing(4)
                    
                    VStack(spacing: 12) {
                        // Start Interactive Tutorial Button
                        Button(action: {
                            showingUserGuide = true
                        }) {
                            HStack {
                                Image(systemName: "play.circle.fill")
                                    .font(.title3)
                                Text("Start Interactive Tutorial")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.4, green: 0.5, blue: 1.0),
                                        Color(red: 0.3, green: 0.4, blue: 0.9)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(28)
                        }
                        .padding(.horizontal, 20)
                        
                        // Skip Tutorial Button
                        Button(action: {
                            showingLogin = true
                        }) {
                            Text("Skip Tutorial & Get Started")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.gray)
                                .underline()
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, 8)
                }
                .padding(.vertical, 32)
                .padding(.horizontal, 24)
                .background(Color.white)
                .cornerRadius(24)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 20)
            }
        }
        .sheet(isPresented: $showingUserGuide) {
            UserGuideView()
                .onDisappear {
                    showingLogin = true
                }
        }
        .fullScreenCover(isPresented: $showingLogin) {
            LoginView()
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
