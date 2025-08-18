// SignupView.swift
// Soundspace-AR
//
// Created by Kusal on 2025-08-04.
//

import SwiftUI

struct SignupView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var rememberMe = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    @State private var isSignUpMode = true
    @FocusState private var focusedField: Field?
    
    enum Field {
        case username, email, password, confirmPassword
    }
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            VStack(spacing: 0) {
                // Title section at top
                VStack {
                    Spacer()
                    
                    Text("SoundSpace AR")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                
                // White card at bottom
                VStack(spacing: 24) {
                    // Toggle between Login and Sign Up
                    HStack(spacing: 0) {
                        loginToggleButton
                        signUpToggleButton
                    }
                    .padding(4)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(26)
                    
                    VStack(spacing: 16) {
                        // Username field
                        TextField("Username", text: $username)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .focused($focusedField, equals: .username)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .textContentType(.username)
                        
                        // Email field
                        TextField("Email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .focused($focusedField, equals: .email)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .disableAutocorrection(true)
                            .textContentType(.emailAddress)
                        
                        // Password field
                        SecureField("Password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .focused($focusedField, equals: .password)
                            .textContentType(.newPassword)
                        
                        // Confirm Password field
                        SecureField("Confirm password", text: $confirmPassword)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .focused($focusedField, equals: .confirmPassword)
                            .textContentType(.newPassword)
                        
                        // Remember me
                        HStack {
                            rememberMeButton
                            Spacer()
                        }
                    }
                    
                    // Sign Up button
                    mainSignUpButton
                    
                    // Add FaceID option
                    if authManager.biometricType != .none {
                        Button(action: {
                            // Handle FaceID setup after signup
                        }) {
                            Text("Add FaceID")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // Sign in link
                    HStack {
                        Text("Already have an account?")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Button("Sign in") {
                            dismiss()
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    }
                }
                .padding(.vertical, 32)
                .padding(.horizontal, 24)
                .background(Color.white)
                .cornerRadius(24)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 20)
            }
        }
        .alert("Signup Error", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .onSubmit {
            switch focusedField {
            case .username:
                focusedField = .email
            case .email:
                focusedField = .password
            case .password:
                focusedField = .confirmPassword
            case .confirmPassword:
                performSignup()
            case .none:
                break
            }
        }
    }
    
    // Computed properties to break up complex expressions
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.4, green: 0.5, blue: 1.0),
                Color(red: 0.3, green: 0.4, blue: 0.9)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    private var loginToggleButton: some View {
        Button(action: {
            dismiss()
        }) {
            Text("Login")
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(!isSignUpMode ? .white : .gray)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
        }
    }
    
    private var signUpToggleButton: some View {
        Button(action: {
            isSignUpMode = true
        }) {
            Text("Sign Up")
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(isSignUpMode ? .white : .gray)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(signUpButtonBackground)
                .cornerRadius(22)
        }
    }
    
    @ViewBuilder
    private var signUpButtonBackground: some View {
        if isSignUpMode {
            blueGradient
        } else {
            Color.clear
        }
    }
    
    private var blueGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.4, green: 0.5, blue: 1.0),
                Color(red: 0.3, green: 0.4, blue: 0.9)
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    private var rememberMeButton: some View {
        Button(action: {
            rememberMe.toggle()
        }) {
            HStack {
                Image(systemName: rememberMe ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(rememberMe ? .blue : .gray)
                Text("Remember me")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
    
    private var mainSignUpButton: some View {
        Button(action: {
            performSignup()
        }) {
            Text("Sign Up")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(blueGradient)
                .cornerRadius(25)
        }
        .disabled(isLoading || !isFormValid)
    }
    
    private var isFormValid: Bool {
        !username.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        !confirmPassword.isEmpty &&
        password == confirmPassword &&
        password.count >= 6
    }
    
    private func performSignup() {
        guard isFormValid else {
            if password != confirmPassword {
                alertMessage = "Passwords don't match"
            } else if password.count < 6 {
                alertMessage = "Password must be at least 6 characters"
            } else {
                alertMessage = "Please fill in all fields"
            }
            showingAlert = true
            return
        }
        
        isLoading = true
        focusedField = nil
        
        Task {
            await MainActor.run {
                if authManager.signup(username: username, email: email, password: password) {
                    dismiss()
                } else {
                    alertMessage = authManager.authenticationError ?? "Signup failed"
                    showingAlert = true
                }
                isLoading = false
            }
        }
    }
}

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView()
            .environmentObject(AuthenticationManager())
    }
}
