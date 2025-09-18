// SettingsView.swift
// Soundspace-AR
//

// User profile and app settings interface with security and notification controls


import SwiftUI
import LocalAuthentication

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @StateObject private var notificationManager = NotificationManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var useBiometricAuth: Bool = true
    @State private var remindersEnabled: Bool = true
    @State private var useARAnchoring: Bool = true
    @State private var showingEditProfile: Bool = false
    @State private var showingChangePassword: Bool = false
    @State private var showingHelpAbout: Bool = false

    // MARK: - User Data Accessors
    private var username: String {
        authManager.currentUser?.value(forKey: "username") as? String ?? "Unknown User"
    }

    private var email: String {
        authManager.currentUser?.value(forKey: "email") as? String ?? "No Email"
    }

    var body: some View {
        ZStack {
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
                headerSection
                contentCard
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingChangePassword) {
            ChangePasswordView()
                .environmentObject(authManager)
        }
        .sheet(isPresented: $showingHelpAbout) {
            HelpAboutView()
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Spacer()
            Text("Profile Settings")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 52)
            Spacer()
        }
        .frame(height: 180)
    }
    
    private var contentCard: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    profileSection
                    accountInformationSection
                    securitySection
                    otherSection

                    Spacer(minLength: 80)
                }
                .padding(.horizontal, 20)
                .padding(.top, 28)
                .padding(.bottom, 16)
            }

            VStack {
                backButton
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 36, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
    
    private var profileSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 88, height: 88)
                Image(systemName: "person.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.gray)
                Circle()
                    .fill(Color.blue)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Image(systemName: "pencil")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    )
                    .offset(x: 30, y: 30)
            }
        }
    }
    
    private var accountInformationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Account Information")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
            
            infoTile(label: "Username", value: username)
            infoTile(label: "Email", value: email)
        }
    }
    
    private var securitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Security")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
            
            tileRow {
                Text("Change PIN")
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.system(size: 14, weight: .semibold))
            }
            .onTapGesture { /* change PIN */ }

            tileRow {
                Text("Change Password")
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.system(size: 14, weight: .semibold))
            }
            .onTapGesture {
                showingChangePassword = true
            }

            tileRow {
                Text("FaceID")
                Spacer()
                Toggle("", isOn: $useBiometricAuth)
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
            }
        }
    }
    
    private var otherSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Other")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
            
            tileRow {
                (Text("Help ") + Text("?").foregroundColor(.red) + Text(" / About"))
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.system(size: 14, weight: .semibold))
            }
            .onTapGesture {
                showingHelpAbout = true
            }

            tileRow {
                HStack(spacing: 8) {
                    Image(systemName: "bell")
                        .foregroundColor(.blue)
                        .font(.system(size: 16))
                    Text("Push Notifications")
                }
                Spacer()
                Toggle("", isOn: $notificationManager.notificationsEnabled)
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                    .onChange(of: notificationManager.notificationsEnabled) { _, newValue in
                        if newValue {
                            notificationManager.requestAuthorization()
                            notificationManager.scheduleWeeklyTips()
                        }
                    }
            }

            tileRow {
                Text("Reminders & Calibration Tips")
                Spacer()
                Toggle("", isOn: $remindersEnabled)
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
            }

            tileRow {
                Text("Use AR Anchoring")
                Spacer()
                Toggle("", isOn: $useARAnchoring)
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
            }
            
            Button(action: {
                authManager.logout()
                dismiss()
            }) {
                HStack {
                    Text("Logout")
                        .foregroundColor(.red)
                    Spacer()
                    Image(systemName: "arrow.right.square")
                        .foregroundColor(.red)
                        .font(.system(size: 14, weight: .semibold))
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 16)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
    }


    private func infoTile(label: String, value: String) -> some View {
        tileRow {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .foregroundColor(Color.gray)
        }
    }

    private func tileRow<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        HStack { content() }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(Color(.systemGray6))
            .cornerRadius(12)
    }
    
    private var backButton: some View {
        Button(action: {
            dismiss()
        }) {
            Text("Back")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(LinearGradient(colors: [Color.blue.opacity(0.95), Color.blue.opacity(0.8)], startPoint: .top, endPoint: .bottom))
                )
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthenticationManager())
}
