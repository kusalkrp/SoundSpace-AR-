// AudioSystemType.swift
// Soundspace-AR
//
// Created by Kusal on 2025-08-04.
//

import Foundation

enum AudioSystemType: String, CaseIterable, Identifiable {
    case system2_1 = "2.1 System"
    case system5_1 = "5.1 System" 
    case system7_1 = "7.1 System"
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .system2_1:
            return "Basic setup with left and right speakers plus a subwoofer."
        case .system5_1:
            return "Surround sound with front left/right, center, rear left/right, and a subwoofer."
        case .system7_1:
            return "Enhanced surround with front left/right, center, side left/right, rear left/right, and a subwoofer."
        }
    }
    
    var speakerCount: Int {
        switch self {
        case .system2_1: return 3  // L, R, Sub
        case .system5_1: return 6  // L, R, C, RL, RR, Sub
        case .system7_1: return 8  // L, R, C, SL, SR, RL, RR, Sub
        }
    }
    
    var imageName: String {
        switch self {
        case .system2_1: return "speaker.2.1"
        case .system5_1: return "speaker.5.1" 
        case .system7_1: return "speaker.7.1"
        }
    }
}