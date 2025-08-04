// NotificationManager.swift
// Soundspace-AR
//
// Created by Kusal on 2025-08-04.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Failed to request notification authorization: \(error)")
            }
        }
    }
    
    func scheduleCalibrationReminder(days: Int) {
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Time for Speaker Calibration"
        content.body = "It's been a while since you calibrated your speakers. Open SoundSpace AR to check your setup."
        content.sound = .default
        content.categoryIdentifier = "CALIBRATION_REMINDER"
        
        // Create trigger
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(60 * 60 * 24 * days), // days in seconds
            repeats: false
        )
        
        // Create request
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        // Add request to notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            } else {
                print("Calibration reminder scheduled for \(days) days from now")
            }
        }
    }
    
    func scheduleSetupCompletionNotification() {
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Speaker Setup Complete!"
        content.body = "Your speaker layout has been saved. Remember to calibrate your system with test tones for best results."
        content.sound = .default
        content.categoryIdentifier = "SETUP_COMPLETE"
        
        // Create trigger (5 seconds from now)
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 5,
            repeats: false
        )
        
        // Create request
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        // Add request to notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}