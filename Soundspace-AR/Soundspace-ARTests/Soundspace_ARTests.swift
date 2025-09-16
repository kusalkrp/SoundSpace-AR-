//
//  Soundspace_ARTests.swift
//  Soundspace-ARTests
//
//  Created by Kusal on 2025-08-04.
//

import Testing
import CoreData
import LocalAuthentication
import simd
@testable import Soundspace_AR

struct Soundspace_ARTests {

    // MARK: - Test Setup

    private var testContainer: NSPersistentContainer!
    private var testContext: NSManagedObjectContext!

    init() async throws {
        testContainer = NSPersistentContainer(name: "Soundspace_AR")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        testContainer.persistentStoreDescriptions = [description]

        await MainActor.run {
            testContainer.loadPersistentStores { _, error in
                if let error = error {
                    fatalError("Failed to load test store: \(error)")
                }
            }
        }
        testContext = testContainer.viewContext
    }

    // MARK: - AuthenticationManager Tests

    @Test("AuthenticationManager initialization")
    func testAuthenticationManagerInitialization() async throws {
        let authManager = await AuthenticationManager()
        #expect(await authManager.isAuthenticated == false)
        #expect(await authManager.currentUser == nil)
        #expect(await authManager.authenticationError == nil)

        // Test with context
        let authManagerWithContext = await AuthenticationManager(viewContext: testContext)
        #expect(await authManagerWithContext.isAuthenticated == false)
        #expect(await authManagerWithContext.currentUser == nil)
    }

    @Test("User signup with valid credentials")
    func testUserSignupSuccess() async throws {
        let authManager = await AuthenticationManager(viewContext: testContext)

        let username = "testuser"
        let email = "test@example.com"
        let password = "password123"

        let success = await authManager.signup(username: username, email: email, password: password)

        #expect(success == true)
        #expect(await authManager.isAuthenticated == true)
        #expect(await authManager.currentUser != nil)
        #expect(await authManager.authenticationError == nil)

        // Verify user data
        if let user = await authManager.currentUser {
            #expect(user.value(forKey: "username") as? String == username)
            #expect(user.value(forKey: "email") as? String == email)
            #expect(user.value(forKey: "isLoggedIn") as? Bool == true)
            #expect(user.value(forKey: "biometricEnabled") as? Bool == false)
            #expect(user.value(forKey: "createdAt") as? Date != nil)
        }
    }

    @Test("User signup with duplicate email")
    func testUserSignupDuplicateEmail() async throws {
        let authManager = await AuthenticationManager(viewContext: testContext)

        // First signup
        let success1 = await authManager.signup(username: "user1", email: "duplicate@example.com", password: "pass123")
        #expect(success1 == true)

        // Second signup with same email
        let success2 = await authManager.signup(username: "user2", email: "duplicate@example.com", password: "pass456")
        #expect(success2 == false)
        #expect(await authManager.authenticationError == "User already exists")
    }

    @Test("User login with valid credentials")
    func testUserLoginSuccess() async throws {
        let authManager = await AuthenticationManager(viewContext: testContext)

        // First create a user
        let email = "login@example.com"
        let password = "testpass123"
        let signupSuccess = await authManager.signup(username: "testuser", email: email, password: password)
        #expect(signupSuccess == true)

        // Logout to test login
        await authManager.logout()
        #expect(await authManager.isAuthenticated == false)

        // Now login
        let loginSuccess = await authManager.login(email: email, password: password)
        #expect(loginSuccess == true)
        #expect(await authManager.isAuthenticated == true)
        #expect(await authManager.currentUser != nil)
    }

    @Test("User login with invalid credentials")
    func testUserLoginInvalidCredentials() async throws {
        let authManager = await AuthenticationManager(viewContext: testContext)

        // Try to login with non-existent user
        let success = await authManager.login(email: "nonexistent@example.com", password: "wrongpass")
        #expect(success == false)
        #expect(await authManager.isAuthenticated == false)
        #expect(await authManager.authenticationError == "Invalid credentials")
    }

    @Test("User login with wrong password")
    func testUserLoginWrongPassword() async throws {
        let authManager = await AuthenticationManager(viewContext: testContext)

        // Create a user
        let email = "wrongpass@example.com"
        let password = "correctpass"
        let signupSuccess = await authManager.signup(username: "testuser", email: email, password: password)
        #expect(signupSuccess == true)

        await authManager.logout()

        // Try to login with wrong password
        let loginSuccess = await authManager.login(email: email, password: "wrongpass")
        #expect(loginSuccess == false)
        #expect(await authManager.isAuthenticated == false)
        #expect(await authManager.authenticationError == "Invalid credentials")
    }

    @Test("User logout")
    func testUserLogout() async throws {
        let authManager = await AuthenticationManager(viewContext: testContext)

        // Create and login user
        let signupSuccess = await authManager.signup(username: "testuser", email: "logout@example.com", password: "pass123")
        #expect(signupSuccess == true)
        #expect(await authManager.isAuthenticated == true)

        // Logout
        await authManager.logout()
        #expect(await authManager.isAuthenticated == false)
        #expect(await authManager.currentUser == nil)
    }

    @Test("Password change with valid current password")
    func testPasswordChangeSuccess() async throws {
        let authManager = await AuthenticationManager(viewContext: testContext)

        // Create and login user
        let email = "changepass@example.com"
        let oldPassword = "oldpass123"
        let newPassword = "newpass456"

        let signupSuccess = await authManager.signup(username: "testuser", email: email, password: oldPassword)
        #expect(signupSuccess == true)

        // Change password
        var changeResult: (Bool, String)?
        await authManager.changePassword(currentPassword: oldPassword, newPassword: newPassword) { success, message in
            changeResult = (success, message)
        }

        // Wait for async completion
        while changeResult == nil {
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        }

        #expect(changeResult?.0 == true)
        #expect(changeResult?.1 == "Password changed successfully")

        // Verify login with new password works
        await authManager.logout()
        let loginSuccess = await authManager.login(email: email, password: newPassword)
        #expect(loginSuccess == true)
    }

    @Test("Password change with invalid current password")
    func testPasswordChangeInvalidCurrentPassword() async throws {
        let authManager = await AuthenticationManager(viewContext: testContext)

        // Create and login user
        let signupSuccess = await authManager.signup(username: "testuser", email: "invalidcurrent@example.com", password: "correctpass")
        #expect(signupSuccess == true)

        // Try to change password with wrong current password
        var changeResult: (Bool, String)?
        await authManager.changePassword(currentPassword: "wrongpass", newPassword: "newpass123") { success, message in
            changeResult = (success, message)
        }

        while changeResult == nil {
            try await Task.sleep(nanoseconds: 100_000_000)
        }

        #expect(changeResult?.0 == false)
        #expect(changeResult?.1 == "Current password is incorrect")
    }

    @Test("Password change with password too short")
    func testPasswordChangeTooShort() async throws {
        let authManager = await AuthenticationManager(viewContext: testContext)

        // Create and login user
        let signupSuccess = await authManager.signup(username: "testuser", email: "shortpass@example.com", password: "longenoughpass")
        #expect(signupSuccess == true)

        // Try to change to password that's too short
        var changeResult: (Bool, String)?
        await authManager.changePassword(currentPassword: "longenoughpass", newPassword: "123") { success, message in
            changeResult = (success, message)
        }

        while changeResult == nil {
            try await Task.sleep(nanoseconds: 100_000_000)
        }

        #expect(changeResult?.0 == false)
        #expect(changeResult?.1 == "New password must be at least 6 characters")
    }

    @Test("Password reset for existing user")
    func testPasswordResetExistingUser() async throws {
        let authManager = await AuthenticationManager(viewContext: testContext)

        // Create a user
        let email = "reset@example.com"
        let signupSuccess = await authManager.signup(username: "testuser", email: email, password: "oldpass123")
        #expect(signupSuccess == true)
        await authManager.logout()

        // Reset password
        var resetResult: (Bool, String)?
        await authManager.resetPassword(email: email) { success, message in
            resetResult = (success, message)
        }

        while resetResult == nil {
            try await Task.sleep(nanoseconds: 100_000_000)
        }

        #expect(resetResult?.0 == true)
        #expect(resetResult?.1.contains("A temporary password has been generated") == true)

        // Extract temporary password from message
        let message = resetResult?.1 ?? ""
        let tempPassword = message.components(separatedBy: ": ").last ?? ""

        // Verify login with temporary password works
        let loginSuccess = await authManager.login(email: email, password: tempPassword)
        #expect(loginSuccess == true)
    }

    @Test("Password reset for non-existent user")
    func testPasswordResetNonExistentUser() async throws {
        let authManager = await AuthenticationManager(viewContext: testContext)

        var resetResult: (Bool, String)?
        await authManager.resetPassword(email: "nonexistent@example.com") { success, message in
            resetResult = (success, message)
        }

        while resetResult == nil {
            try await Task.sleep(nanoseconds: 100_000_000)
        }

        #expect(resetResult?.0 == false)
        #expect(resetResult?.1 == "No account found with that email address")
    }

    @Test("Email validation")
    func testEmailValidation() async throws {
        let authManager = await AuthenticationManager()

        // Valid emails
        #expect(await authManager.isValidEmail("test@example.com") == true)
        #expect(await authManager.isValidEmail("user.name+tag@example.co.uk") == true)
        #expect(await authManager.isValidEmail("test.email@subdomain.example.com") == true)

        // Invalid emails
        #expect(await authManager.isValidEmail("invalid-email") == false)
        #expect(await authManager.isValidEmail("@example.com") == false)
        #expect(await authManager.isValidEmail("test@") == false)
        #expect(await authManager.isValidEmail("test.example.com") == false)
        #expect(await authManager.isValidEmail("") == false)
    }

    @Test("Password hashing consistency")
    func testPasswordHashing() async throws {
        let authManager = await AuthenticationManager(viewContext: testContext)

        // Test password hashing indirectly through signup and login
        let email = "hash@example.com"
        let password = "testpassword123"

        // Create user
        let signupSuccess = await authManager.signup(username: "testuser", email: email, password: password)
        #expect(signupSuccess == true)

        // Logout
        await authManager.logout()

        // Login with same password should work
        let loginSuccess = await authManager.login(email: email, password: password)
        #expect(loginSuccess == true)

        // Login with different password should fail
        await authManager.logout()
        let wrongLoginSuccess = await authManager.login(email: email, password: "differentpassword")
        #expect(wrongLoginSuccess == false)
    }

    @Test("Biometric type detection")
    func testBiometricType() async throws {
        let authManager = await AuthenticationManager()

        // This will vary based on device/simulator capabilities
        // Just ensure it returns a valid LABiometryType
        let biometricType = await authManager.biometricType
        let validTypes: [LABiometryType] = [.none, .touchID, .faceID]
        #expect(validTypes.contains(biometricType))
    }

    @Test("Authentication status refresh")
    func testAuthenticationStatusRefresh() async throws {
        let authManager = await AuthenticationManager(viewContext: testContext)

        // Create and login user
        let signupSuccess = await authManager.signup(username: "testuser", email: "refresh@example.com", password: "pass123")
        #expect(signupSuccess == true)
        #expect(await authManager.isAuthenticated == true)

        // Refresh status (should maintain authentication)
        await authManager.refreshAuthenticationStatus()
        #expect(await authManager.isAuthenticated == true)
    }

    // MARK: - Speaker Model Tests

    @Test("Speaker initialization")
    func testSpeakerInitialization() async throws {
        let speaker = Speaker(type: .main, position: .frontLeft, worldPosition: SIMD3<Float>(1.0, 2.0, 3.0))

        #expect(speaker.type == .main)
        #expect(speaker.position == .frontLeft)
        #expect(speaker.worldPosition == SIMD3<Float>(1.0, 2.0, 3.0))
        #expect(speaker.id != UUID()) // Should have a valid UUID
        #expect(speaker.anchorID == nil)
    }

    @Test("Speaker equality")
    func testSpeakerEquality() async throws {
        let speaker1 = Speaker(type: .main, position: .frontLeft)
        let speaker2 = Speaker(type: .main, position: .frontLeft)
        let speaker3 = Speaker(type: .center, position: .center)

        #expect(speaker1 == speaker1) // Same instance
        #expect(speaker1 != speaker2) // Different IDs
        #expect(speaker1 != speaker3) // Different properties
    }

    @Test("Speaker position ideal angles")
    func testSpeakerPositionIdealAngles() async throws {
        #expect(Speaker.SpeakerPosition.frontLeft.idealAngle == -30)
        #expect(Speaker.SpeakerPosition.frontRight.idealAngle == 30)
        #expect(Speaker.SpeakerPosition.center.idealAngle == 0)
        #expect(Speaker.SpeakerPosition.sideLeft.idealAngle == -90)
        #expect(Speaker.SpeakerPosition.sideRight.idealAngle == 90)
        #expect(Speaker.SpeakerPosition.rearLeft.idealAngle == -150)
        #expect(Speaker.SpeakerPosition.rearRight.idealAngle == 150)
        #expect(Speaker.SpeakerPosition.subwoofer.idealAngle == nil)
    }

    @Test("Speaker type descriptions")
    func testSpeakerTypeDescriptions() async throws {
        #expect(SpeakerType.main.description == "Main front speakers for primary audio")
        #expect(SpeakerType.center.description == "Center channel for dialogue and vocals")
        #expect(SpeakerType.surround.description == "Surround speakers for ambient effects")
        #expect(SpeakerType.side.description == "Side speakers for wide soundstage")
        #expect(SpeakerType.rear.description == "Rear speakers for immersive surround")
        #expect(SpeakerType.subwoofer.description == "Low-frequency effects and bass")
    }

    // MARK: - Room Analysis Heuristics Tests

    @Test("Room type inference from objects")
    func testRoomTypeInference() async throws {
        // Bedroom detection
        let (bedroomType, bedroomConfidence) = RoomAnalysisHeuristics.inferRoomType(objects: ["bed", "nightstand"])
        #expect(bedroomType == .bedroom)
        #expect(bedroomConfidence == 0.9)

        // Living room detection
        let (livingRoomType, livingRoomConfidence) = RoomAnalysisHeuristics.inferRoomType(objects: ["sofa", "tv", "coffee table"])
        #expect(livingRoomType == .livingRoom)
        #expect(livingRoomConfidence == 0.85)

        // Office detection
        let (officeType, officeConfidence) = RoomAnalysisHeuristics.inferRoomType(objects: ["desk", "computer", "monitor"])
        #expect(officeType == .office)
        #expect(officeConfidence == 0.75)

        // Dining room detection
        let (diningType, diningConfidence) = RoomAnalysisHeuristics.inferRoomType(objects: ["dining table", "chair", "stool"])
        #expect(diningType == .diningRoom)
        #expect(diningConfidence == 0.7)

        // Garage detection
        let (garageType, garageConfidence) = RoomAnalysisHeuristics.inferRoomType(objects: ["car", "automobile"])
        #expect(garageType == .garage)
        #expect(garageConfidence == 0.95)

        // Default case
        let (defaultType, defaultConfidence) = RoomAnalysisHeuristics.inferRoomType(objects: ["random object"])
        #expect(defaultType == .hall)
        #expect(defaultConfidence == 0.4)
    }

    @Test("Room analysis combination")
    func testRoomAnalysisCombination() async throws {
        // Test with scene labels and objects
        let sceneLabels: [(String, Float)] = [("living room", 0.8), ("indoor", 0.6)]
        let objectLabels = ["sofa", "tv"]
        let result = RoomAnalysisHeuristics.combine(sceneLabels: sceneLabels, objectLabels: objectLabels, floorAreaM2: 25.0)

        #expect(result.roomType == .livingRoom)
        #expect(result.recommendedSystem == .system5_1) // Area > 25, so 5.1 for living room
        #expect(result.confidence > 0.0)
        #expect(result.confidence <= 1.0)
    }

    @Test("System recommendation based on room and area")
    func testSystemRecommendation() async throws {
        // Small bedroom
        let smallBedroom = RoomAnalysisHeuristics.combine(sceneLabels: [], objectLabels: ["bed"], floorAreaM2: 15.0)
        #expect(smallBedroom.recommendedSystem == .system2_1)

        // Large bedroom
        let largeBedroom = RoomAnalysisHeuristics.combine(sceneLabels: [], objectLabels: ["bed"], floorAreaM2: 25.0)
        #expect(largeBedroom.recommendedSystem == .system5_1)

        // Small living room
        let smallLivingRoom = RoomAnalysisHeuristics.combine(sceneLabels: [("living room", 0.9)], objectLabels: ["sofa"], floorAreaM2: 20.0)
        #expect(smallLivingRoom.recommendedSystem == .system5_1)

        // Large living room
        let largeLivingRoom = RoomAnalysisHeuristics.combine(sceneLabels: [("living room", 0.9)], objectLabels: ["sofa"], floorAreaM2: 30.0)
        #expect(largeLivingRoom.recommendedSystem == .system7_1)

        // Office (always 2.1)
        let office = RoomAnalysisHeuristics.combine(sceneLabels: [("office", 0.8)], objectLabels: ["desk"], floorAreaM2: 50.0)
        #expect(office.recommendedSystem == .system2_1)
    }

    // MARK: - Speaker Layout Engine Tests

    @Test("Speaker layout generation for 2.1 system")
    func testSpeakerLayout21System() async throws {
        let placements = SpeakerLayoutEngine.generate(system: .system2_1, listener: nil)

        #expect(placements.count == 3)

        let positions = placements.map { $0.position }
        #expect(positions.contains(.frontLeft))
        #expect(positions.contains(.frontRight))
        #expect(positions.contains(.subwoofer))

        // Verify transforms are valid
        for placement in placements {
            let transform = placement.transform
            #expect(transform.columns.3.w == 1.0) // Valid homogeneous coordinate
        }
    }

    @Test("Speaker layout generation for 5.1 system")
    func testSpeakerLayout51System() async throws {
        let placements = SpeakerLayoutEngine.generate(system: .system5_1, listener: nil)

        #expect(placements.count == 6)

        let positions = placements.map { $0.position }
        #expect(positions.contains(.frontLeft))
        #expect(positions.contains(.frontRight))
        #expect(positions.contains(.center))
        #expect(positions.contains(.rearLeft))
        #expect(positions.contains(.rearRight))
        #expect(positions.contains(.subwoofer))
    }

    @Test("Speaker layout generation for 7.1 system")
    func testSpeakerLayout71System() async throws {
        let placements = SpeakerLayoutEngine.generate(system: .system7_1, listener: nil)

        #expect(placements.count == 8)

        let positions = placements.map { $0.position }
        #expect(positions.contains(.frontLeft))
        #expect(positions.contains(.frontRight))
        #expect(positions.contains(.center))
        #expect(positions.contains(.sideLeft))
        #expect(positions.contains(.sideRight))
        #expect(positions.contains(.rearLeft))
        #expect(positions.contains(.rearRight))
        #expect(positions.contains(.subwoofer))
    }

    @Test("Speaker layout with custom listener position")
    func testSpeakerLayoutWithCustomListener() async throws {
        var listenerTransform = matrix_identity_float4x4
        listenerTransform.columns.3 = SIMD4<Float>(5.0, 1.5, -3.0, 1.0) // Custom position

        let placements = SpeakerLayoutEngine.generate(system: .system2_1, listener: listenerTransform)

        #expect(placements.count == 3)

        // All placements should be offset from the custom listener position
        for placement in placements {
            let position = placement.transform.translation
            #expect(position.x >= 3.0) // Should be offset from listener x=5.0
            #expect(position.z <= -1.0) // Should be in front of listener z=-3.0
        }
    }

    @Test("Matrix extension methods")
    func testMatrixExtensions() async throws {
        var transform = matrix_identity_float4x4
        transform.columns.3 = SIMD4<Float>(1.0, 2.0, 3.0, 1.0)

        let translation = transform.translation
        #expect(translation == SIMD3<Float>(1.0, 2.0, 3.0))

        let array = transform.toArray()
        #expect(array.count == 16)
        #expect(array[12] == 1.0) // Translation X
        #expect(array[13] == 2.0) // Translation Y
        #expect(array[14] == 3.0) // Translation Z
        #expect(array[15] == 1.0) // W component
    }

    @Test("Saved speaker pose encoding")
    func testSavedSpeakerPoseEncoding() async throws {
        let pose = SavedSpeakerPose(position: "frontLeft", matrix: [1.0, 0.0, 0.0, 0.0,
                                                                   0.0, 1.0, 0.0, 0.0,
                                                                   0.0, 0.0, 1.0, 0.0,
                                                                   2.0, 1.5, -3.0, 1.0])

        let poses = [pose]
        let data = poses.encodedData()
        #expect(data != nil)

        // Verify we can decode it back
        if let data = data {
            let decoded = try? JSONDecoder().decode([SavedSpeakerPose].self, from: data)
            #expect(decoded?.count == 1)
            #expect(decoded?.first?.position == "frontLeft")
            #expect(decoded?.first?.matrix.count == 16)
        }
    }

    // MARK: - Example Test (keep for reference)

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }
}
