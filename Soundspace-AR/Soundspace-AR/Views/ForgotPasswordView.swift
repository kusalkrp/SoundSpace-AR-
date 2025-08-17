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
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.black, Color.blue.opacity(0.3)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    // Header
                    VStack(spacing: 20) {
                        Image(systemName: "key.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                            .foregroundColor(.white)
                        
                        Text("Reset Password")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Enter your email address and we'll generate a temporary password for you")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
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
                            .foregroundColor(.white)
                            .disableAutocorrection(true)
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal, 40)
                    
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
                        .cornerRadius(10)
                    }
                    .disabled(email.isEmpty || isLoading)
                    .padding(.horizontal, 40)
                    
                    Spacer()
                    
                    // Info text
                    VStack(spacing: 10) {
                        Text("Note: This is a demo app")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Text("In a real app, the temporary password would be sent to your email")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    
                    Spacer()
                }
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
