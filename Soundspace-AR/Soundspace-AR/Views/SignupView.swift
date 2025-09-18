// SignupView.swift
// Soundspace-AR
//

// Dedicated signup interface with form validation and biometric setup


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
    @State private var showingFaceIDSetup = false
    @State private var signupSuccessful = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case username, email, password, confirmPassword
    }
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            VStack(spacing: 0) {
                VStack {
                    Spacer()

                    Text("SoundSpace AR")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Spacer()
                }

                VStack(spacing: 24) {
                    HStack(spacing: 0) {
                        loginToggleButton
                        signUpToggleButton
                    }
                    .padding(4)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(26)

                    VStack(spacing: 16) {
                        TextField("Username", text: $username)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .focused($focusedField, equals: .username)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .textContentType(.username)

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
                            .textContentType(.newPassword)

                        SecureField("Confirm password", text: $confirmPassword)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .focused($focusedField, equals: .confirmPassword)
                            .textContentType(.newPassword)

                        HStack {
                            rememberMeButton
                            Spacer()
                        }
                    }

                    mainSignUpButton
                    
                    // Show Face ID setup option after successful account creation
                    if signupSuccessful && authManager.biometricType == .faceID {
                        VStack(spacing: 16) {
                            Text("Enable Face ID")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text("Use Face ID for quick and secure login")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Button(action: {
                                setupFaceID()
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "faceid")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                    Text("Enable Face ID")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.blue.opacity(0.8),
                                            Color.blue.opacity(0.6)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                            }
                            .disabled(isLoading)
                            
                            Button(action: {
                                // Skip Face ID setup and continue
                                dismiss()
                            }) {
                                Text("Skip for now")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.blue)
                            }
                            .padding(.top, 8)
                            .disabled(isLoading)
                            
                            if isLoading {
                                ProgressView("Setting up Face ID...")
                                    .padding(.top, 10)
                            }
                        }
                        .padding(.vertical, 20)
                        .padding(.horizontal, 16)
                        .background(Color.blue.opacity(0.05))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                        )
                        .padding(.horizontal, 8)
                    }
                    
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
    
    // MARK: - View Components
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
                    signupSuccessful = true
                    // Don't dismiss immediately, show Face ID option first
                } else {
                    alertMessage = authManager.authenticationError ?? "Signup failed"
                    showingAlert = true
                }
                isLoading = false
            }
        }
    }
    
    private func setupFaceID() {
        isLoading = true
        
        authManager.authenticateWithFaceID { success, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if success {
                    // Store that Face ID is enabled for this user
                    UserDefaults.standard.set(true, forKey: "faceIDEnabled_\(self.email)")
                    UserDefaults.standard.set(self.email, forKey: "faceIDEmail")
                    UserDefaults.standard.set(self.password, forKey: "faceIDPassword_\(self.email)")
                    
                    self.alertMessage = "Face ID enabled successfully! You can now use Face ID to login."
                    self.showingAlert = true
                    
                    // Dismiss after showing success message
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        self.dismiss()
                    }
                } else {
                    self.alertMessage = error ?? "Face ID setup failed. You can enable it later in settings."
                    self.showingAlert = true
                    
                    // Still dismiss after error, but with a shorter delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self.dismiss()
                    }
                }
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
