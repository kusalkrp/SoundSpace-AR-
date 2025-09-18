// Speaker.swift
// Soundspace-AR
//


import Foundation
import RealityKit
import ARKit

enum SpeakerType: String, Codable {
    case main = "Main"
    case center = "Center"
    case surround = "Surround"
    case side = "Side"
    case rear = "Rear"
    case subwoofer = "Subwoofer"
    
    var description: String {
        switch self {
        case .main:
            return "Main front speakers for primary audio"
        case .center:
            return "Center channel for dialogue and vocals"
        case .surround:
            return "Surround speakers for ambient effects"
        case .side:
            return "Side speakers for wide soundstage"
        case .rear:
            return "Rear speakers for immersive surround"
        case .subwoofer:
            return "Low-frequency effects and bass"
        }
    }
}

class Speaker: Identifiable, Codable, Equatable {
    enum SpeakerPosition: String, Codable, CaseIterable, Identifiable {
        case frontLeft = "Front Left"
        case frontRight = "Front Right"
        case center = "Center"
        case sideLeft = "Side Left"
        case sideRight = "Side Right"
        case rearLeft = "Rear Left"
        case rearRight = "Rear Right"
        case subwoofer = "Subwoofer"
        
        var id: String { rawValue }
        
        var description: String {
            switch self {
            case .frontLeft, .frontRight:
                return "Position at ear level, forming an equilateral triangle with the listener."
            case .center:
                return "Position at ear level, directly in front of the listener."
            case .sideLeft, .sideRight:
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
            case .sideLeft: return -90 // 90 degrees left
            case .sideRight: return 90 // 90 degrees right
            case .rearLeft: return -150 // 150 degrees left
            case .rearRight: return 150 // 150 degrees right
            case .subwoofer: return nil // Can be placed anywhere
            }
        }
    }
    
    let id: UUID
    let type: SpeakerType
    let position: SpeakerPosition
    var worldPosition: SIMD3<Float>
    var anchorID: UInt64?
    
    init(type: SpeakerType, position: SpeakerPosition, worldPosition: SIMD3<Float> = SIMD3<Float>(0, 0, 0)) {
        self.id = UUID()
        self.type = type
        self.position = position
        self.worldPosition = worldPosition
    }
    
    // Implement Equatable protocol
    static func == (lhs: Speaker, rhs: Speaker) -> Bool {
        return lhs.id == rhs.id
    }
}
