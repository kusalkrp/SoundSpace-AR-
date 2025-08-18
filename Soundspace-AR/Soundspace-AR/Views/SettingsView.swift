// SettingsView.swift
// Soundspace-AR
//
// Created by Kusal on 2025-08-04.
//

import SwiftUI
import LocalAuthentication

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var username: String = "Aryan Shirk"
    @State private var email: String = "aryan.shirk2@gmail.com"
    @State private var useBiometricAuth: Bool = true
    @State private var remindersEnabled: Bool = true
    @State private var useARAnchoring: Bool = true
    @State private var showingEditProfile: Bool = false
    
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
                // Header
                headerSection
                
                // Content card
                contentCard
            }
        }
        .navigationBarHidden(true)
    }
    
    private var headerSection: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text("Profile Settings")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.top, 60)
            
            Spacer()
        }
        .frame(height: 200)
    }
    
    private var contentCard: some View {
        VStack(spacing: 0) {
            Spacer()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Section
                    profileSection
                    
                    // Account Information Section
                    accountInformationSection
                    
                    // Security Section
                    securitySection
                    
                    // Other Section
                    otherSection
                    
                    Spacer(minLength: 20)
                    
                    // Back button
                    backButton
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 32)
            }
            .background(Color.white)
            .cornerRadius(32)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
            .padding(.horizontal, 16)
            .padding(.bottom, 80)
        }
    }
    
    private var profileSection: some View {
        VStack(spacing: 16) {
            // Profile picture
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                // Placeholder profile image or actual image
                Image(systemName: "person.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.gray)
                
                // Blue checkmark badge
                Circle()
                    .fill(Color.blue)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    )
                    .offset(x: 28, y: 28)
            }
        }
    }
    
    private var accountInformationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Account Information")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            // Username field
            settingsField(
                label: "Username",
                value: username,
                isEditable: false
            )
            
            // Email field
            settingsField(
                label: "Email",
                value: email,
                isEditable: false
            )
        }
    }
    
    private var securitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Security")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            // Change PIN
            settingsRow(
                title: "Change PIN",
                hasChevron: true,
                action: {
                    // Handle change PIN
                }
            )
            
            // Change Password
            settingsRow(
                title: "Change Password",
                hasChevron: true,
                action: {
                    // Handle change password
                }
            )
            
            // FaceID toggle
            HStack {
                Text("FaceID")
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Toggle("", isOn: $useBiometricAuth)
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
            }
            .padding(.vertical, 4)
        }
    }
    
    private var otherSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Other")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            // Help / About
            settingsRow(
                title: "Help ? / About",
                hasChevron: true,
                action: {
                    // Handle help/about
                }
            )
            
            // Reminders & Calibration Tips toggle
            HStack {
                Text("Reminders & Calibration Tips")
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Toggle("", isOn: $remindersEnabled)
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
            }
            .padding(.vertical, 4)
            
            // Use AR Anchoring toggle
            HStack {
                Text("Use AR Anchoring")
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Toggle("", isOn: $useARAnchoring)
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
            }
            .padding(.vertical, 4)
        }
    }
    
    private func settingsField(label: String, value: String, isEditable: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                Text(value)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
    }
    
    private func settingsRow(title: String, hasChevron: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if hasChevron {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var backButton: some View {
        Button(action: {
            // Handle back navigation
        }) {
            Text("Back")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(16)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthenticationManager())
}
