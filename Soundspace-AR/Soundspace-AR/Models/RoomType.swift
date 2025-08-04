// RoomType.swift
// Soundspace-AR
//
// Created by Kusal on 2025-08-04.
//

import Foundation

enum RoomType: String, CaseIterable, Identifiable {
    case livingRoom = "Living Room"
    case bedroom = "Bedroom"
    case hall = "Hall"
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .livingRoom:
            return "A typical living room setup for home theater experience."
        case .bedroom:
            return "Audio setup optimized for bedroom listening."
        case .hall:
            return "Large space audio configuration for halls and open areas."
        }
    }
    
    var imageName: String {
        switch self {
        case .livingRoom: return "livingroom"
        case .bedroom: return "bedroom"
        case .hall: return "hall"
        }
    }
}