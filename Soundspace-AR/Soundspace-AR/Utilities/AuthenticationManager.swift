// AuthenticationManager.swift
// Soundspace-AR
//
// Created by Kusal on 2025-08-04.
//



// AuthenticationManager.swift
import Foundation
import SwiftUI
import CoreData
import CryptoKit
import LocalAuthentication

@MainActor
class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: NSManagedObject?
    @Published var authenticationError: String?

    private var viewContext: NSManagedObjectContext?
    
    init() { }
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        checkCurrentUser()
    }

    func setContext(_ context: NSManagedObjectContext) {
        self.viewContext = context
        checkCurrentUser()
    }

    private func checkCurrentUser() {
        guard let context = viewContext else { return }

        let request = NSFetchRequest<NSManagedObject>(entityName: "User")
        request.predicate = NSPredicate(format: "isLoggedIn == YES")
        request.fetchLimit = 1

        do {
            let users = try context.fetch(request)
            if let user = users.first {
                currentUser = user
                isAuthenticated = true
            }
        } catch {
            print("Error checking current user: \(error)")
        }
    }

    func signup(username: String, email: String, password: String) -> Bool {
        guard let context = viewContext else { return false }

        let request = NSFetchRequest<NSManagedObject>(entityName: "User")
        request.predicate = NSPredicate(format: "email == %@", email)

        do {
            let existingUsers = try context.fetch(request)
            if !existingUsers.isEmpty {
                authenticationError = "User already exists"
                return false
            }
        } catch {
            authenticationError = "Error checking user"
            return false
        }

        guard let entity = NSEntityDescription.entity(forEntityName: "User", in: context) else {
            authenticationError = "Entity not found"
            return false
        }

        let newUser = NSManagedObject(entity: entity, insertInto: context)
        newUser.setValue(username, forKey: "username")
        newUser.setValue(email, forKey: "email")
        newUser.setValue(hashPassword(password), forKey: "password")
        newUser.setValue(true, forKey: "isLoggedIn")

        do {
            try context.save()
            currentUser = newUser
            isAuthenticated = true
            return true
        } catch {
            authenticationError = "Failed to save user"
            return false
        }
    }

    func login(email: String, password: String) -> Bool {
        guard let context = viewContext else { return false }

        let request = NSFetchRequest<NSManagedObject>(entityName: "User")
        request.predicate = NSPredicate(format: "email == %@", email)
        request.fetchLimit = 1

        do {
            let users = try context.fetch(request)
            guard let user = users.first,
                  let storedPassword = user.value(forKey: "password") as? String else {
                authenticationError = "Invalid credentials"
                return false
            }

            if storedPassword == hashPassword(password) {
                user.setValue(true, forKey: "isLoggedIn")
                try context.save()
                currentUser = user
                isAuthenticated = true
                return true
            } else {
                authenticationError = "Invalid credentials"
                return false
            }
        } catch {
            authenticationError = "Login failed"
            return false
        }
    }

    func logout() {
        guard let context = viewContext, let user = currentUser else { return }

        user.setValue(false, forKey: "isLoggedIn")

        do {
            try context.save()
        } catch {
            print("Error updating logout: \(error)")
        }

        currentUser = nil
        isAuthenticated = false
    }

    func authenticateWithBiometrics() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate to access SoundSpace AR"

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, _ in
                DispatchQueue.main.async {
                    if success {
                        self.checkCurrentUser()
                    } else {
                        self.authenticationError = "Biometric authentication failed"
                    }
                }
            }
        } else {
            authenticationError = "Biometric authentication not available"
        }
    }

    func resetPassword(email: String, completion: @escaping (Bool, String) -> Void) {
        guard let context = viewContext else {
            completion(false, "Database error")
            return
        }

        let request = NSFetchRequest<NSManagedObject>(entityName: "User")
        request.predicate = NSPredicate(format: "email == %@", email)
        request.fetchLimit = 1

        do {
            let users = try context.fetch(request)
            guard let user = users.first else {
                completion(false, "No account found with that email address")
                return
            }
            
            // Generate a temporary password
            let tempPassword = generateTemporaryPassword()
            user.setValue(hashPassword(tempPassword), forKey: "password")
            
            try context.save()
            
            // In a real app, send this password to the user's email
            completion(true, "A temporary password has been generated: \(tempPassword)")
        } catch {
            completion(false, "Failed to reset password")
        }
    }
    
    private func generateTemporaryPassword() -> String {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let length = 8
        
        return String((0..<length).map { _ in
            characters.randomElement()!
        })
    }

    private func hashPassword(_ password: String) -> String {
        let inputData = Data(password.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }

    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    var biometricType: LABiometryType {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        return context.biometryType
    }
}
