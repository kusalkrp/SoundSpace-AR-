// Speaker.swift
// Soundspace-AR
//
// Created by Kusal on 2025-08-04.
//

import Foundation
import RealityKit
import ARKit

enum SpeakerType: String, Codable {
    case frontLeft = "Front Left"
    case frontRight = "Front Right"
    case center = "Center"
    case surroundLeft = "Surround Left"
    case surroundRight = "Surround Right"
    case rearLeft = "Rear Left"
    case rearRight = "Rear Right"
    case subwoofer = "Subwoofer"
    
    var description: String {
        switch self {
        case .frontLeft, .frontRight:
            return "Position at ear level, forming an equilateral triangle with the listener."
        case .center:
            return "Position at ear level, directly in front of the listener."
        case .surroundLeft, .surroundRight:
            return "Position slightly above ear level, to the sides of the listener."
        case .rearLeft, .rearRight:
            return "Position slightly above ear level, behind the listener."
        case .subwoofer:
            return "Position on the floor. Can be placed anywhere in the room, preferably in a corner for bass enhancement."
        }
    }
    
    var idealAngle: Float? {
        switch self {
        case .frontLeft: return -30 // 30 degrees left
        case .frontRight: return 30 // 30 degrees right
        case .center: return 0
        case .surroundLeft: return -90 // 90 degrees left
        case .surroundRight: return 90 // 90 degrees right
        case .rearLeft: return -150 // 150 degrees left
        case .rearRight: return 150 // 150 degrees right
        case .subwoofer: return nil // Can be placed anywhere
        }
    }
}

class Speaker: Identifiable, Codable, Equatable {
    let id: UUID
    let type: SpeakerType
    var position: SIMD3<Float>
    var anchorID: UInt64?  // Changed from UUID? to UInt64? to match Entity.id type
    
    init(type: SpeakerType, position: SIMD3<Float> = SIMD3<Float>(0, 0, 0)) {
        self.id = UUID()
        self.type = type
        self.position = position
    }
    
    // Implement Equatable protocol
    static func == (lhs: Speaker, rhs: Speaker) -> Bool {
        return lhs.id == rhs.id
    }
}
