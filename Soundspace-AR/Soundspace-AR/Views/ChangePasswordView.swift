// ChangePasswordView.swift
// Soundspace-AR
//

import SwiftUI

struct ChangePasswordView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isChanging = false
    @State private var showingAlert = false
    @State private var alertTitle = "Change Password"
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
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
                    headerSection
                    contentCard
                }
            }
            .navigationBarHidden(true)
        }
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("OK") {
                if alertTitle == "Success!" {
                    dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Spacer()
            Text("Change Password")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 52)
            Spacer()
        }
        .frame(height: 180)
    }

    private var contentCard: some View {
        VStack(spacing: 20) {
            VStack(spacing: 16) {
                SecureField("Current Password", text: $currentPassword)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .textContentType(.password)

                SecureField("New Password", text: $newPassword)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .textContentType(.newPassword)

                SecureField("Confirm New Password", text: $confirmPassword)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .textContentType(.newPassword)

                Button(action: changePassword) {
                    Text(isChanging ? "Changing..." : "Change Password")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(isFormValid ? Color.blue : Color.gray)
                        .cornerRadius(12)
                }
                .disabled(isChanging || !isFormValid)
            }
            .padding(.horizontal, 20)
            .padding(.top, 28)

            Spacer()

            // Back button
            VStack {
                Button(action: { dismiss() }) {
                    Text("Cancel")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .fill(LinearGradient(colors: [Color.blue.opacity(0.95), Color.blue.opacity(0.8)], startPoint: .top, endPoint: .bottom))
                        )
                }
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

    private var isFormValid: Bool {
        !currentPassword.isEmpty && !newPassword.isEmpty && !confirmPassword.isEmpty && newPassword == confirmPassword && newPassword.count >= 6
    }

    private func changePassword() {
        guard isFormValid else {
            alertTitle = "Error"
            alertMessage = "Please fill in all fields correctly"
            showingAlert = true
            return
        }

        isChanging = true

        authManager.changePassword(currentPassword: currentPassword, newPassword: newPassword) { success, message in
            DispatchQueue.main.async {
                self.isChanging = false
                if success {
                    self.alertTitle = "Success!"
                    self.alertMessage = message
                } else {
                    self.alertTitle = "Error"
                    self.alertMessage = message
                }
                self.showingAlert = true
            }
        }
    }
}

#Preview {
    ChangePasswordView()
        .environmentObject(AuthenticationManager())
}