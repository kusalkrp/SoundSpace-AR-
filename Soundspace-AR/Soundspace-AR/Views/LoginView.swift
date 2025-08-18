// LoginView.swift
// Soundspace-AR
//
// Created by Kusal on 2025-08-04.
//


// LoginView.swift
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    // Login state
    @State private var email = ""
    @State private var password = ""
    @State private var rememberMe = false
    @State private var isLoggingIn = false
    // Shared
    @State private var showingAlert = false
    @FocusState private var focusedField: Field?
    // Pager control: 0 = Login, 1 = Sign Up
    @State private var selectedAuthPage = 0
    
    // Inline Sign Up state
    @State private var suUsername = ""
    @State private var suEmail = ""
    @State private var suPassword = ""
    @State private var suConfirmPassword = ""
    @State private var suRememberMe = false
    @State private var isSigningUp = false

    enum Field {
        case email, password
        case suUsername, suEmail, suPassword, suConfirm
    }

    var body: some View {
        ZStack {
            backgroundGradient
            
            VStack(spacing: 0) {
                titleSection
                authCard
            }
        }
        .alert("Authentication", isPresented: $showingAlert) {
            Button("OK") {}
        } message: {
            Text(authManager.authenticationError ?? "Unknown error")
        }
        .onSubmit(handleSubmit)
        .toolbar {
            toolbarContent
        }
    }

    // MARK: - Main Sections
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
    
    private var titleSection: some View {
        VStack {
            Spacer()
            Text("SoundSpace AR")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Spacer()
        }
    }
    
    private var authCard: some View {
        VStack(spacing: 20) {
            authToggleButtons
            authTabView
        }
        .padding(.vertical, 32)
        .padding(.horizontal, 24)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 20)
    }
    
    private var authToggleButtons: some View {
        HStack(spacing: 0) {
            loginToggleButton
            signupToggleButton
        }
        .padding(4)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(26)
    }
    
    private var loginToggleButton: some View {
        Button(action: switchToLogin) {
            Text("Login")
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(loginButtonTextColor)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(loginButtonBackground)
                .cornerRadius(22)
        }
    }
    
    private var signupToggleButton: some View {
        Button(action: switchToSignup) {
            Text("Sign Up")
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(signupButtonTextColor)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(signupButtonBackground)
                .cornerRadius(22)
        }
    }
    
    private var authTabView: some View {
        TabView(selection: $selectedAuthPage) {
            loginForm.tag(0)
            signupForm.tag(1)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(maxWidth: .infinity)
        .frame(height: 340)
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button("Login", action: switchToLogin)
            Button("Sign Up", action: switchToSignup)
        }
    }

    // MARK: - Computed Properties
    private var loginButtonTextColor: Color {
        selectedAuthPage == 0 ? .white : .gray
    }
    
    private var signupButtonTextColor: Color {
        selectedAuthPage == 1 ? .white : .gray
    }
    
    @ViewBuilder
    private var loginButtonBackground: some View {
        if selectedAuthPage == 0 {
            blueGradient
        } else {
            Color.clear
        }
    }
    
    @ViewBuilder
    private var signupButtonBackground: some View {
        if selectedAuthPage == 1 {
            blueGradient
        } else {
            Color.clear
        }
    }

    // MARK: - Actions
    private func switchToLogin() {
        withAnimation(.easeInOut) { selectedAuthPage = 0 }
    }
    
    private func switchToSignup() {
        withAnimation(.easeInOut) { selectedAuthPage = 1 }
    }
    
    private func handleSubmit() {
        switch focusedField {
        case .email: focusedField = .password
        case .password: performLogin()
        case .suUsername: focusedField = .suEmail
        case .suEmail: focusedField = .suPassword
        case .suPassword: focusedField = .suConfirm
        case .suConfirm: performSignup()
        case .none: break
        }
    }

    // MARK: - Subviews
    private var loginForm: some View {
        VStack(spacing: 16) {
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .focused($focusedField, equals: .email)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .disableAutocorrection(true)
                .textContentType(.emailAddress)
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .focused($focusedField, equals: .password)
                .textContentType(.password)
            
            HStack {
                Button(action: { rememberMe.toggle() }) {
                    HStack {
                        Image(systemName: rememberMe ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(rememberMe ? .blue : .gray)
                        Text("Remember me")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                Spacer()
            }
            
            Button(action: { performLogin() }) {
                Text("Login")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(blueGradient)
                    .cornerRadius(25)
            }
            .disabled(isLoggingIn || email.isEmpty || password.isEmpty)

            if authManager.biometricType != .none {
                Button(action: { authManager.authenticateWithBiometrics() }) {
                    Text("Use FaceID to login")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            // Inline link to switch to Sign Up
            HStack {
                Text("Don't have an account?")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Button("Sign up") {
                    withAnimation(.easeInOut) { selectedAuthPage = 1 }
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            Spacer(minLength: 0)
        }
        .padding(.top, 4)
    }

    private var signupForm: some View {
        VStack(spacing: 16) {
            TextField("Username", text: $suUsername)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .focused($focusedField, equals: .suUsername)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .textContentType(.username)
            
            TextField("Email", text: $suEmail)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .focused($focusedField, equals: .suEmail)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .disableAutocorrection(true)
                .textContentType(.emailAddress)
            
            SecureField("Password", text: $suPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .focused($focusedField, equals: .suPassword)
                .textContentType(.newPassword)
            
            SecureField("Confirm password", text: $suConfirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .focused($focusedField, equals: .suConfirm)
                .textContentType(.newPassword)
            
            HStack {
                Button(action: { suRememberMe.toggle() }) {
                    HStack {
                        Image(systemName: suRememberMe ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(suRememberMe ? .blue : .gray)
                        Text("Remember me")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                Spacer()
            }
            
            Button(action: { performSignup() }) {
                Text("Sign Up")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(blueGradient)
                    .cornerRadius(25)
            }
            .disabled(isSigningUp || !isSignupValid)
            
            // Inline link to switch to Login
            HStack {
                Text("Already have an account?")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Button("Sign in") {
                    withAnimation(.easeInOut) { selectedAuthPage = 0 }
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            Spacer(minLength: 0)
        }
        .padding(.top, 4)
    }

    // MARK: - Helpers
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

    private var isSignupValid: Bool {
        !suUsername.isEmpty && !suEmail.isEmpty && !suPassword.isEmpty && !suConfirmPassword.isEmpty && suPassword == suConfirmPassword && suPassword.count >= 6
    }

    private func performLogin() {
        guard !email.isEmpty, !password.isEmpty else {
            authManager.authenticationError = "Please fill in all fields"
            showingAlert = true
            return
        }
        isLoggingIn = true
        focusedField = nil
        Task {
            await MainActor.run {
                if authManager.login(email: email, password: password) {
                    // success
                } else {
                    showingAlert = true
                }
                isLoggingIn = false
            }
        }
    }

    private func performSignup() {
        guard isSignupValid else {
            if suPassword != suConfirmPassword {
                authManager.authenticationError = "Passwords don't match"
            } else if suPassword.count < 6 {
                authManager.authenticationError = "Password must be at least 6 characters"
            } else {
                authManager.authenticationError = "Please fill in all fields"
            }
            showingAlert = true
            return
        }
        isSigningUp = true
        focusedField = nil
        Task {
            await MainActor.run {
                if authManager.signup(username: suUsername, email: suEmail, password: suPassword) {
                    // After success, switch to login page and prefill email
                    selectedAuthPage = 0
                    email = suEmail
                    password = ""
                } else {
                    showingAlert = true
                }
                isSigningUp = false
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthenticationManager())
}
