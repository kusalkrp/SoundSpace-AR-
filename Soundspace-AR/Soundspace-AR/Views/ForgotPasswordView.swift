// ForgotPasswordView.swift
// Soundspace-AR
//
// Created by Kusal on 2025-08-04.
//

import SwiftUI

struct ForgotPasswordView: View {
    @ObservedObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var email = ""
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Blue gradient background (same as DashboardView)
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.4, green: 0.5, blue: 1.0),
                        Color(red: 0.3, green: 0.4, blue: 0.9)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack {
                    Spacer(minLength: 32)
                    // Main white tile
                    VStack(spacing: 32) {
                        // Header
                        VStack(spacing: 20) {
                            Image(systemName: "key.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 60)
                                .foregroundColor(.blue)
                            Text("Reset Password")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.black)
                            Text("Enter your email address and we'll generate a temporary password for you")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 16)
                        }
                        // Email Field
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundColor(.gray)
                                .frame(width: 20)
                            TextField("Email", text: $email)
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .foregroundColor(.black)
                                .disableAutocorrection(true)
                        }
                        .padding()
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        .padding(.horizontal, 8)
                        // Reset Button
                        Button(action: resetPassword) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                }
                                Text("Reset Password")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(email.isEmpty ? Color.gray : Color.blue)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                        }
                        .disabled(email.isEmpty || isLoading)
                        .padding(.horizontal, 8)
                        // Info text
                        VStack(spacing: 10) {
                            Text("Note: This is a demo app")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("In a real app, the temporary password would be sent to your email")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 8)
                        }
                    }
                    .padding(.vertical, 32)
                    .padding(.horizontal, 30) // Increased horizontal padding for left/right sides
                    .background(Color.white)
                    .cornerRadius(32)
                    .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 6)
                    .frame(maxWidth: 360)
                    Spacer(minLength: 32)
                }
                .frame(maxHeight: .infinity)
            }
            .navigationTitle("Reset Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("OK") {
                if alertTitle == "Password Reset" {
                    dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func resetPassword() {
        isLoading = true
        
        authManager.resetPassword(email: email) { success, message in
            DispatchQueue.main.async {
                isLoading = false
                alertTitle = success ? "Password Reset" : "Error"
                alertMessage = message
                showingAlert = true
            }
        }
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        let persistenceController = PersistenceController.preview
        let authManager = AuthenticationManager(viewContext: persistenceController.container.viewContext)
        return ForgotPasswordView(authManager: authManager)
    }
}
