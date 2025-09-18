// NotificationManager.swift
// Soundspace-AR
//

import Foundation
import UserNotifications
import UIKit

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var notificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: "NotificationsEnabled")
            if !notificationsEnabled {
                cancelAllNotifications()
            }
        }
    }
    
    private init() {
        self.notificationsEnabled = UserDefaults.standard.bool(forKey: "NotificationsEnabled")
        setupNotificationCategories()
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("Notification permission granted")
                    self?.notificationsEnabled = true
                } else if let error = error {
                    print("Failed to request notification authorization: \(error)")
                    self?.notificationsEnabled = false
                }
            }
        }
    }
    
    private func setupNotificationCategories() {
        let calibrationAction = UNNotificationAction(
            identifier: "CALIBRATE_NOW",
            title: "Calibrate Now",
            options: .foreground
        )
        
        let dismissAction = UNNotificationAction(
            identifier: "DISMISS",
            title: "Later",
            options: []
        )
        
        let calibrationCategory = UNNotificationCategory(
            identifier: "CALIBRATION_REMINDER",
            actions: [calibrationAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )
        
        let setupCategory = UNNotificationCategory(
            identifier: "SETUP_COMPLETE",
            actions: [],
            intentIdentifiers: [],
            options: []
        )
        
        let reviewCategory = UNNotificationCategory(
            identifier: "REVIEW_REMINDER",
            actions: [],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([
            calibrationCategory,
            setupCategory,
            reviewCategory
        ])
    }
    
    func scheduleCalibrationReminder(days: Int) {
        guard notificationsEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Time for Speaker Calibration"
        content.body = "It's been a while since you calibrated your speakers. Open SoundSpace AR to check your setup."
        content.sound = .default
        content.categoryIdentifier = "CALIBRATION_REMINDER"
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(60 * 60 * 24 * days),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "calibration_reminder_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule calibration reminder: \(error)")
            } else {
                print("Calibration reminder scheduled for \(days) days from now")
            }
        }
    }
    
    func scheduleSetupCompletionNotification() {
        guard notificationsEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Speaker Setup Complete!"
        content.body = "Your speaker layout has been saved. Remember to calibrate your system with test tones for best results."
        content.sound = .default
        content.categoryIdentifier = "SETUP_COMPLETE"
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 5,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "setup_complete_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule setup completion notification: \(error)")
            }
        }
    }
    
    func scheduleReviewReminder(for speaker: String, days: Int = 7) {
        guard notificationsEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "How's Your Speaker Setup?"
        content.body = "Share your experience with \(speaker) in the community. Your review helps others!"
        content.sound = .default
        content.categoryIdentifier = "REVIEW_REMINDER"
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(60 * 60 * 24 * days),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "review_reminder_\(speaker)_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule review reminder: \(error)")
            } else {
                print("Review reminder scheduled for \(speaker) in \(days) days")
            }
        }
    }
    
    func scheduleWeeklyTips() {
        guard notificationsEnabled else { return }
        
        let tips = [
            "Try adjusting your speaker toe-in angle for better stereo imaging.",
            "Room acoustics matter! Consider adding soft furnishings to reduce reflections.",
            "The 'rule of thirds' can help optimize your listening position.",
            "Keep your speakers away from walls to minimize bass buildup.",
            "Regular calibration ensures optimal sound quality over time."
        ]
        
        for (index, tip) in tips.enumerated() {
            let content = UNMutableNotificationContent()
            content.title = "SoundSpace AR Tip"
            content.body = tip
            content.sound = .default
            content.categoryIdentifier = "WEEKLY_TIP"
            content.badge = 1
            
            // Schedule tips weekly, starting from next week
            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: TimeInterval(60 * 60 * 24 * 7 * (index + 1)),
                repeats: false
            )
            
            let request = UNNotificationRequest(
                identifier: "weekly_tip_\(index)_\(Date().timeIntervalSince1970)",
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Failed to schedule weekly tip \(index): \(error)")
                }
            }
        }
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func cancelNotification(withIdentifier identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func getPendingNotifications(completion: @escaping ([UNNotificationRequest]) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: completion)
    }
    
    func checkAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }
}
