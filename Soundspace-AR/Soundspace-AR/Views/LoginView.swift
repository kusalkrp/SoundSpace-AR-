// LoginView.swift
// Soundspace-AR
//
// Created by Kusal on 2025-08-04.
//


// LoginView.swift
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var email = ""
    @State private var password = ""
    @State private var showingAlert = false
    @State private var showingSignup = false
    @State private var isLoggingIn = false
    @FocusState private var focusedField: Field?

    enum Field {
        case email, password
    }

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 30) {
                        VStack(spacing: 16) {
                            Image(systemName: "waveform.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.white)
                                .symbolEffect(.pulse)

                            Text("SoundSpace AR")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            Text("Welcome Back")
                                .font(.title2)
                                .foregroundColor(.white.opacity(0.8))
                        }

                        VStack(spacing: 20) {
                            HStack {
                                Image(systemName: "envelope")
                                    .foregroundColor(.white.opacity(0.7))
                                    .frame(width: 20)

                                TextField("Email", text: $email)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .foregroundColor(.white)
                                    .focused($focusedField, equals: .email)
                                    .autocapitalization(.none)
                                    .keyboardType(.emailAddress)
                                    .disableAutocorrection(true)
                                    .textContentType(.emailAddress)
                            }
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(12)

                            HStack {
                                Image(systemName: "lock")
                                    .foregroundColor(.white.opacity(0.7))
                                    .frame(width: 20)

                                SecureField("Password", text: $password)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .foregroundColor(.white)
                                    .focused($focusedField, equals: .password)
                                    .textContentType(.password)
                            }
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)

                        VStack(spacing: 15) {
                            Button("Sign In") {
                                performLogin()
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(Color.black.opacity(0.2))
                            .cornerRadius(12)
                            .padding(.horizontal)
                            .disabled(isLoggingIn || email.isEmpty || password.isEmpty)

                            if authManager.biometricType != .none {
                                Button(action: {
                                    authManager.authenticateWithBiometrics()
                                }) {
                                    HStack {
                                        Image(systemName: biometricIcon)
                                        Text("Use \(biometricText)")
                                    }
                                }
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, minHeight: 45)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(12)
                                .padding(.horizontal)
                            }
                        }

                        HStack {
                            Text("Don't have an account?")
                                .foregroundColor(.white.opacity(0.8))
                            Button("Sign Up") {
                                showingSignup = true
                            }
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                        }

                        Spacer(minLength: 100)
                    }
                    .padding()
                }
                .scrollDismissesKeyboard(.interactively)
            }
        }
        .alert("Login Error", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(authManager.authenticationError ?? "Unknown error")
        }
        .sheet(isPresented: $showingSignup) {
            SignupView(authManager: authManager)
        }
        .onSubmit {
            if focusedField == .email {
                focusedField = .password
            } else if focusedField == .password {
                performLogin()
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    focusedField = nil
                }
            }
        }
    }
    
    // iOS 18.6 - Computed properties for biometric UI
    private var biometricText: String {
        switch authManager.biometricType {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        default:
            return "Biometric"
        }
    }
    
    private var biometricIcon: String {
        switch authManager.biometricType {
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        default:
            return "person.fill.checkmark"
        }
    }

    private func performLogin() {
        guard !email.isEmpty, !password.isEmpty else {
            authManager.authenticationError = "Please fill in all fields"
            showingAlert = true
            return
        }
        
        // iOS 18.6 - Enhanced login with loading state
        isLoggingIn = true
        focusedField = nil // Dismiss keyboard
        
        Task {
            await MainActor.run {
                if authManager.login(email: email, password: password) {
                    // Login successful
                } else {
                    showingAlert = true
                }
                isLoggingIn = false
            }
        }
    }
}
