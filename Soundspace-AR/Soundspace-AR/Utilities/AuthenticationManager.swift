// AuthenticationManager.swift
// Soundspace-AR
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
        guard let context = viewContext else {
            authenticationError = "Database not available"
            return false
        }

        let request = NSFetchRequest<NSManagedObject>(entityName: "User")
        request.predicate = NSPredicate(format: "email == %@", email)

        do {
            let existingUsers = try context.fetch(request)
            if !existingUsers.isEmpty {
                print("DEBUG: User already exists with email: \(email)")
                authenticationError = "User already exists"
                return false
            }
        } catch {
            print("DEBUG: Error checking existing user: \(error)")
            authenticationError = "Error checking user"
            return false
        }

        guard let entity = NSEntityDescription.entity(forEntityName: "User", in: context) else {
            authenticationError = "Entity not found"
            return false
        }

        let newUser = NSManagedObject(entity: entity, insertInto: context)
        let hashedPassword = hashPassword(password)
        newUser.setValue(username, forKey: "username")
        newUser.setValue(email, forKey: "email")
        newUser.setValue(hashedPassword, forKey: "password")
        newUser.setValue(true, forKey: "isLoggedIn")
        newUser.setValue(Date(), forKey: "createdAt")
        newUser.setValue(false, forKey: "biometricEnabled")
        
        print("DEBUG: Creating user - username: \(username), email: \(email), hashedPassword: \(hashedPassword)")

        do {
            try context.save()
            print("DEBUG: User saved successfully")
            currentUser = newUser
            isAuthenticated = true
            return true
        } catch {
            print("DEBUG: Failed to save user: \(error)")
            authenticationError = "Failed to save user"
            return false
        }
    }

    func login(email: String, password: String) -> Bool {
        guard let context = viewContext else {
            authenticationError = "Database not available"
            return false
        }

        let request = NSFetchRequest<NSManagedObject>(entityName: "User")
        request.predicate = NSPredicate(format: "email == %@", email)
        request.fetchLimit = 1

        do {
            let users = try context.fetch(request)
            print("DEBUG: Found \(users.count) users with email: \(email)")
            
            guard let user = users.first else {
                print("DEBUG: No user found with email: \(email)")
                authenticationError = "Invalid credentials"
                return false
            }
            
            guard let storedPassword = user.value(forKey: "password") as? String else {
                print("DEBUG: No password found for user")
                authenticationError = "Invalid credentials"
                return false
            }
            
            let hashedInputPassword = hashPassword(password)
            print("DEBUG: Stored password: \(storedPassword)")
            print("DEBUG: Input password hash: \(hashedInputPassword)")
            
            if storedPassword == hashedInputPassword {
                print("DEBUG: Password match successful")
                
                // Clean up any invalid SavedLayout entities before setting login status
                cleanupInvalidSavedLayouts(in: context)
                
                user.setValue(true, forKey: "isLoggedIn")
                
                do {
                    try context.save()
                    currentUser = user
                    isAuthenticated = true
                    return true
                } catch {
                    print("DEBUG: Failed to save login state: \(error)")
                    // If save fails, still mark as authenticated since password was correct
                    currentUser = user
                    isAuthenticated = true
                    authenticationError = "Login successful but data sync issue detected"
                    return true
                }
            } else {
                print("DEBUG: Password match failed")
                authenticationError = "Invalid credentials"
                return false
            }
        } catch {
            print("DEBUG: Login failed with error: \(error)")
            authenticationError = "Login failed"
            return false
        }
    }
    
    private func cleanupInvalidSavedLayouts(in context: NSManagedObjectContext) {
        let layoutRequest = NSFetchRequest<NSManagedObject>(entityName: "SavedLayout")
        layoutRequest.predicate = NSPredicate(format: "speakerPositions == nil")
        
        do {
            let invalidLayouts = try context.fetch(layoutRequest)
            print("DEBUG: Found \(invalidLayouts.count) invalid SavedLayout entities")
            
            for layout in invalidLayouts {
                // Either fix the invalid layout or delete it
                if let layoutId = layout.value(forKey: "id") as? String {
                    print("DEBUG: Fixing SavedLayout with ID: \(layoutId)")
                    // Set a default value for speakerPositions to make it valid
                    layout.setValue("[]", forKey: "speakerPositions") // Empty JSON array as default
                } else {
                    print("DEBUG: Deleting invalid SavedLayout without ID")
                    context.delete(layout)
                }
            }
        } catch {
            print("DEBUG: Error cleaning up invalid SavedLayouts: \(error)")
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

    // Face ID Authentication
    func authenticateWithFaceID(completion: @escaping (Bool, String?) -> Void) {
        let context = LAContext()
        var error: NSError?
        let reason = "Authenticate with Face ID to access your account."
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authError in
                DispatchQueue.main.async {
                    if success {
                        completion(true, nil)
                    } else {
                        completion(false, authError?.localizedDescription)
                    }
                }
            }
        } else {
            completion(false, error?.localizedDescription ?? "Face ID not available.")
        }
    }

    func changePassword(currentPassword: String, newPassword: String, completion: @escaping (Bool, String) -> Void) {
        guard let context = viewContext, let user = currentUser else {
            completion(false, "No user logged in")
            return
        }

        guard let storedPassword = user.value(forKey: "password") as? String else {
            completion(false, "Unable to verify current password")
            return
        }

        let hashedCurrentPassword = hashPassword(currentPassword)
        if storedPassword != hashedCurrentPassword {
            completion(false, "Current password is incorrect")
            return
        }

        if newPassword.count < 6 {
            completion(false, "New password must be at least 6 characters")
            return
        }

        user.setValue(hashPassword(newPassword), forKey: "password")

        do {
            try context.save()
            completion(true, "Password changed successfully")
        } catch {
            completion(false, "Failed to update password")
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
    
    func refreshAuthenticationStatus() async {
        // Enhanced authentication status refresh
        guard viewContext != nil else { return }
        
        // Refresh current user status
        await MainActor.run {
            checkCurrentUser()
        }
        
        // Optional: Check if biometric settings changed
        if isAuthenticated && biometricType == .none {
            // Biometrics were disabled - could prompt user
            print("Biometric authentication is no longer available")
        }
    }
}
