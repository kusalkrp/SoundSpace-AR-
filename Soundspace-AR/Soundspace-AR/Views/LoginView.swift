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

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 30) {
                    VStack(spacing: 16) {
                        Image(systemName: "waveform.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.white)

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

                        if authManager.biometricType != .none {
                            Button("Use Biometric") {
                                authManager.authenticateWithBiometrics()
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

                    Spacer()
                }
                .padding()
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
    }

    private func performLogin() {
        guard !email.isEmpty, !password.isEmpty else {
            authManager.authenticationError = "Please fill in all fields"
            showingAlert = true
            return
        }

        if authManager.login(email: email, password: password) {
            // Login successful
        } else {
            showingAlert = true
        }
    }
}
