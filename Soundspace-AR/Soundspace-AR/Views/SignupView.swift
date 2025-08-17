// SignupView.swift
// Soundspace-AR
//
// Created by Kusal on 2025-08-04.
//

import SwiftUI

struct SignupView: View {
    @ObservedObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    @State private var agreedToTerms = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case username, email, password, confirmPassword
    }
    
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
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Header
                        VStack(spacing: 20) {
                            HStack {
                                Button("Cancel") {
                                    dismiss()
                                }
                                .foregroundColor(.blue)
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            Image(systemName: "person.badge.plus")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 60)
                                .foregroundColor(.white)
                            
                            Text("Create Account")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Join SoundSpace AR today")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        // Signup Form
                        VStack(spacing: 20) {
                            // Username Field
                            HStack {
                                Image(systemName: "person")
                                    .foregroundColor(.gray)
                                    .frame(width: 20)
                                
                                TextField("Username", text: $username)
                                    .textContentType(.username)
                                    .autocapitalization(.none)
                                    .foregroundColor(.white)
                                    .focused($focusedField, equals: .username)
                                    .disableAutocorrection(true)
                            }
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                            
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
                                    .focused($focusedField, equals: .email)
                                    .disableAutocorrection(true)
                            }
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                            
                            // Password Field
                            HStack {
                                Image(systemName: "lock")
                                    .foregroundColor(.gray)
                                    .frame(width: 20)
                                
                                SecureField("Password", text: $password)
                                    .textContentType(.newPassword)
                                    .foregroundColor(.white)
                                    .focused($focusedField, equals: .password)
                            }
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                            
                            // Confirm Password Field
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.gray)
                                    .frame(width: 20)
                                
                                SecureField("Confirm Password", text: $confirmPassword)
                                    .textContentType(.newPassword)
                                    .foregroundColor(.white)
                                    .focused($focusedField, equals: .confirmPassword)
                            }
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                            
                            // Password Requirements
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Password Requirements:")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                HStack {
                                    Image(systemName: password.count >= 6 ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(password.count >= 6 ? .green : .gray)
                                    Text("At least 6 characters")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Spacer()
                                }
                                
                                HStack {
                                    Image(systemName: password == confirmPassword && !confirmPassword.isEmpty ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(password == confirmPassword && !confirmPassword.isEmpty ? .green : .gray)
                                    Text("Passwords match")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Spacer()
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // Terms and Conditions
                            HStack {
                                Button(action: {
                                    agreedToTerms.toggle()
                                }) {
                                    Image(systemName: agreedToTerms ? "checkmark.square.fill" : "square")
                                        .foregroundColor(agreedToTerms ? .blue : .gray)
                                }
                                
                                Text("I agree to the Terms of Service and Privacy Policy")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                
                                Spacer()
                            }
                        }
                        .padding(.horizontal, 40)
                        
                        // Sign Up Button
                        Button(action: signUp) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                }
                                
                                Text("Create Account")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isValidForm ? Color.blue : Color.gray)
                            .cornerRadius(10)
                        }
                        .disabled(!isValidForm || isLoading)
                        .padding(.horizontal, 40)
                        
                        // Already have account link
                        HStack {
                            Text("Already have an account?")
                                .foregroundColor(.gray)
                            
                            Button("Sign In") {
                                dismiss()
                            }
                            .foregroundColor(.blue)
                            .fontWeight(.semibold)
                        }
                        .padding(.top, 10)
                        
                        Spacer(minLength: 100)
                    }
                }
                .scrollDismissesKeyboard(.interactively)
            }
        }
        .alert("Sign Up", isPresented: $showingAlert) {
            Button("OK") {
                if alertMessage.contains("successfully") {
                    dismiss()
                }
            }
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
                if isValidForm {
                    signUp()
                }
            case .none:
                break
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
    
    private var isValidForm: Bool {
        !username.isEmpty &&
        !email.isEmpty &&
        password.count >= 6 &&
        password == confirmPassword &&
        agreedToTerms
    }
    
    private func signUp() {
        isLoading = true
        
        let success = authManager.signup(username: username, email: email, password: password)
        
        isLoading = false
        if success {
            alertMessage = "Account created successfully!"
        } else {
            alertMessage = authManager.authenticationError ?? "Failed to create account"
        }
        showingAlert = true
    }
}

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView(authManager: AuthenticationManager())
    }
}
