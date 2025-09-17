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
    @State private var alertTitle = "Authentication"
    @State private var alertMessage = ""
    @State private var showingForgotPassword = false
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
    
    // Validation states
    @State private var showValidationHints = false

    enum Field: CaseIterable {
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
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("OK") {}
        } message: {
            Text(alertMessage)
        }
        .sheet(isPresented: $showingForgotPassword) {
            ForgotPasswordView(authManager: authManager)
        }
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
        .frame(height: 450)
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
        withAnimation(.easeInOut) { 
            selectedAuthPage = 0 
            focusedField = nil // Clear focus when switching
        }
    }
    
    private func switchToSignup() {
        withAnimation(.easeInOut) { 
            selectedAuthPage = 1 
            focusedField = nil // Clear focus when switching
        }
    }

    // MARK: - Subviews
    private var loginForm: some View {
        VStack(spacing: 16) {
            TextField("Email", text: $email)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .focused($focusedField, equals: .email)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .disableAutocorrection(true)
                .textContentType(.emailAddress)
                .onSubmit {
                    focusedField = .password
                }
            
            SecureField("Password", text: $password)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .focused($focusedField, equals: .password)
                .textContentType(.password)
                .onSubmit {
                    focusedField = nil
                    performLogin()
                }
            
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
            
            // Forgot Password link
            HStack {
                Spacer()
                Button("Forgot Password?") {
                    showingForgotPassword = true
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            
            Button(action: handleLogin) {
                Text("Login")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .disabled(isLoggingIn || email.isEmpty || password.isEmpty)
            
            // Face ID login button
            if authManager.biometricType == .faceID {
                Button(action: {
                    performFaceIDLogin()
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "faceid")
                            .font(.system(size: 20))
                            .foregroundColor(.blue)
                        Text("Login with Face ID")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.blue)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                    )
                }
                .padding(.top, 8)
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
        VStack(spacing: 12) {
            TextField("Username", text: $suUsername)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .focused($focusedField, equals: .suUsername)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .textContentType(.username)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(showValidationHints && suUsername.isEmpty ? Color.red.opacity(0.5) : Color.clear, lineWidth: 1)
                )
                .onSubmit {
                    focusedField = .suEmail
                }
            
            // Always reserve space for validation hint to prevent layout shifts
            Text(showValidationHints && suUsername.isEmpty ? "Username is required" : "")
                .font(.caption)
                .foregroundColor(.red)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .opacity(showValidationHints && suUsername.isEmpty ? 1 : 0)
                .frame(height: showValidationHints && suUsername.isEmpty ? nil : 16)
            
            TextField("Email", text: $suEmail)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .focused($focusedField, equals: .suEmail)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .disableAutocorrection(true)
                .textContentType(.emailAddress)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(showValidationHints && (suEmail.isEmpty || !isValidEmail(suEmail)) ? Color.red.opacity(0.5) : Color.clear, lineWidth: 1)
                )
                .onSubmit {
                    focusedField = .suPassword
                }
            
            // Always reserve space for validation hint to prevent layout shifts
            Text(showValidationHints && suEmail.isEmpty ? "Email is required" : 
                 (showValidationHints && !suEmail.isEmpty && !isValidEmail(suEmail) ? "Please enter a valid email address" : ""))
                .font(.caption)
                .foregroundColor(.red)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .opacity(showValidationHints && (suEmail.isEmpty || (!suEmail.isEmpty && !isValidEmail(suEmail))) ? 1 : 0)
                .frame(height: showValidationHints && (suEmail.isEmpty || (!suEmail.isEmpty && !isValidEmail(suEmail))) ? nil : 16)
            
            SecureField("Password", text: $suPassword)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .focused($focusedField, equals: .suPassword)
                .textContentType(.newPassword)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(showValidationHints && (suPassword.isEmpty || suPassword.count < 6) ? Color.red.opacity(0.5) : Color.clear, lineWidth: 1)
                )
                .onSubmit {
                    focusedField = .suConfirm
                }
            
            // Always reserve space for validation hint to prevent layout shifts
            Text(showValidationHints && suPassword.isEmpty ? "Password is required" : 
                 (showValidationHints && !suPassword.isEmpty && suPassword.count < 6 ? "Password must be at least 6 characters" : ""))
                .font(.caption)
                .foregroundColor(.red)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .opacity(showValidationHints && (suPassword.isEmpty || (!suPassword.isEmpty && suPassword.count < 6)) ? 1 : 0)
                .frame(height: showValidationHints && (suPassword.isEmpty || (!suPassword.isEmpty && suPassword.count < 6)) ? nil : 16)
            
            SecureField("Confirm password", text: $suConfirmPassword)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .focused($focusedField, equals: .suConfirm)
                .textContentType(.newPassword)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(showValidationHints && (suConfirmPassword.isEmpty || suPassword != suConfirmPassword) ? Color.red.opacity(0.5) : Color.clear, lineWidth: 1)
                )
                .onSubmit {
                    focusedField = nil
                    showValidationHints = true
                    performSignup()
                }
            
            // Always reserve space for validation hint to prevent layout shifts
            Text(showValidationHints && suConfirmPassword.isEmpty ? "Please confirm your password" : 
                 (showValidationHints && !suConfirmPassword.isEmpty && suPassword != suConfirmPassword ? "Passwords don't match" : ""))
                .font(.caption)
                .foregroundColor(.red)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .opacity(showValidationHints && (suConfirmPassword.isEmpty || (!suConfirmPassword.isEmpty && suPassword != suConfirmPassword)) ? 1 : 0)
                .frame(height: showValidationHints && (suConfirmPassword.isEmpty || (!suConfirmPassword.isEmpty && suPassword != suConfirmPassword)) ? nil : 16)
            
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
            
            Button(action: { 
                showValidationHints = true
                performSignup() 
            }) {
                Text(isSigningUp ? "Creating Account..." : "Sign Up")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(isSignupValid ? AnyView(blueGradient) : AnyView(Color.gray))
                    .cornerRadius(25)
            }
            .disabled(isSigningUp)
            
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
        !suUsername.isEmpty && !suEmail.isEmpty && isValidEmail(suEmail) && !suPassword.isEmpty && !suConfirmPassword.isEmpty && suPassword == suConfirmPassword && suPassword.count >= 6
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func handleLogin() {
        performLogin()
    }

    private func performLogin() {
        guard !email.isEmpty, !password.isEmpty else {
            alertTitle = "Login Error"
            alertMessage = "Please fill in all fields"
            showingAlert = true
            return
        }
        isLoggingIn = true
        focusedField = nil
        Task {
            await MainActor.run {
                if authManager.login(email: email, password: password) {
                    // Store credentials for Face ID if biometric auth is available
                    if authManager.biometricType != .none {
                        UserDefaults.standard.set(email, forKey: "faceIDEmail")
                        UserDefaults.standard.set(password, forKey: "faceIDPassword_\(email)")
                        UserDefaults.standard.set(true, forKey: "faceIDEnabled_\(email)")
                    }
                } else {
                    alertTitle = "Login Error"
                    alertMessage = authManager.authenticationError ?? "Login failed"
                    showingAlert = true
                }
                isLoggingIn = false
            }
        }
    }

    private func performSignup() {
        print("DEBUG: performSignup called")
        print("DEBUG: isSignupValid = \(isSignupValid)")
        print("DEBUG: suUsername = '\(suUsername)', suEmail = '\(suEmail)', suPassword.count = \(suPassword.count), suConfirmPassword.count = \(suConfirmPassword.count)")
        
        guard isSignupValid else {
            print("DEBUG: Form validation failed - showing hints")
            showValidationHints = true
            return
        }
        
        print("DEBUG: Starting signup process")
        showValidationHints = false // Hide hints on successful validation
        isSigningUp = true
        focusedField = nil
        Task {
            await MainActor.run {
                print("DEBUG: Calling authManager.signup")
                if authManager.signup(username: suUsername, email: suEmail, password: suPassword) {
                    print("DEBUG: Signup successful")
                    // Store credentials for Face ID if biometric auth is available
                    if authManager.biometricType != .none {
                        UserDefaults.standard.set(suEmail, forKey: "faceIDEmail")
                        UserDefaults.standard.set(suPassword, forKey: "faceIDPassword_\(suEmail)")
                        UserDefaults.standard.set(true, forKey: "faceIDEnabled_\(suEmail)")
                    }
                    // Show success message
                    alertTitle = "Success!"
                    alertMessage = "Account created successfully! You can now log in."
                    showingAlert = true
                    
                    // After success, switch to login page and prefill email
                    selectedAuthPage = 0
                    email = suEmail
                    password = ""
                } else {
                    print("DEBUG: Signup failed with error: \(authManager.authenticationError ?? "Unknown error")")
                    alertTitle = "Signup Error"
                    alertMessage = authManager.authenticationError ?? "Signup failed"
                    showingAlert = true
                }
                isSigningUp = false
            }
        }
    }

    private func performFaceIDLogin() {
        isLoggingIn = true
        
        authManager.authenticateWithFaceID { success, error in
            DispatchQueue.main.async {
                self.isLoggingIn = false
                
                if success {
                    // Check if we have stored Face ID credentials
                    if let storedEmail = UserDefaults.standard.string(forKey: "faceIDEmail"),
                       let storedPassword = UserDefaults.standard.string(forKey: "faceIDPassword_\(storedEmail)") {
                        // Use stored credentials for automatic login
                        self.email = storedEmail
                        self.password = storedPassword
                        self.performLogin()
                    } else {
                        // Face ID successful but no stored credentials - prompt user to login manually
                        self.alertTitle = "Face ID"
                        self.alertMessage = "Face ID successful! Please enter your password to complete login."
                        self.showingAlert = true
                    }
                } else {
                    self.alertTitle = "Face ID Error"
                    self.alertMessage = error ?? "Face ID authentication failed."
                    self.showingAlert = true
                }
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthenticationManager())
}
