// OnboardingView.swift
// Soundspace-AR
//
// Created by Kusal on 2025-08-04.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    var body: some View {
        TabView {
            onboardingPage(
                title: "Welcome to SoundSpace AR",
                description: "Design your perfect audio environment in augmented reality",
                imageName: "speaker.wave.3",
                systemImage: true
            )
            
            onboardingPage(
                title: "Place Speakers Virtually",
                description: "Position speakers in your room using AR technology",
                imageName: "arkit",
                systemImage: true
            )
            
            onboardingPage(
                title: "Save Your Layouts",
                description: "Save and recall your favorite speaker arrangements",
                imageName: "square.and.arrow.down",
                systemImage: true
            )
            
            VStack(spacing: 20) {
                Text("Ready to Begin?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Button(action: {
                    hasSeenOnboarding = true
                }) {
                    Text("Get Started")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .tabViewStyle(PageTabViewStyle())
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
    }
    
    private func onboardingPage(title: String, description: String, imageName: String, systemImage: Bool = false) -> some View {
        VStack(spacing: 20) {
            if systemImage {
                Image(systemName: imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .foregroundColor(.blue)
            } else {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
            }
            
            Text(title)
                .font(.title)
                .fontWeight(.bold)
            
            Text(description)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
