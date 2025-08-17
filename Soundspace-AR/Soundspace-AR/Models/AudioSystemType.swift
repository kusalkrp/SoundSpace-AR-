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
    
    var displayName: String {
        return rawValue
    }
    
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
    
    var icon: String {
        switch self {
        case .system2_1: return "speaker.2"
        case .system5_1: return "speaker.3"
        case .system7_1: return "hifispeaker.2"
        }
    }
    
    var speakers: [Speaker] {
        switch self {
        case .system2_1:
            return [
                Speaker(type: .main, position: .frontLeft),
                Speaker(type: .main, position: .frontRight),
                Speaker(type: .subwoofer, position: .subwoofer)
            ]
        case .system5_1:
            return [
                Speaker(type: .main, position: .frontLeft),
                Speaker(type: .main, position: .frontRight),
                Speaker(type: .center, position: .center),
                Speaker(type: .surround, position: .rearLeft),
                Speaker(type: .surround, position: .rearRight),
                Speaker(type: .subwoofer, position: .subwoofer)
            ]
        case .system7_1:
            return [
                Speaker(type: .main, position: .frontLeft),
                Speaker(type: .main, position: .frontRight),
                Speaker(type: .center, position: .center),
                Speaker(type: .side, position: .sideLeft),
                Speaker(type: .side, position: .sideRight),
                Speaker(type: .rear, position: .rearLeft),
                Speaker(type: .rear, position: .rearRight),
                Speaker(type: .subwoofer, position: .subwoofer)
            ]
        }
    }
}
