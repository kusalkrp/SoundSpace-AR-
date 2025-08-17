// Speaker.swift
// Soundspace-AR
//
// Created by Kusal on 2025-08-04.
//

import Foundation

struct Speaker: Identifiable {
    let id = UUID()
    let type: SpeakerType
    let position: SpeakerPosition
    let name: String
    
    enum SpeakerType: String, CaseIterable {
        case main = "Main"
        case center = "Center"
        case surround = "Surround"
        case subwoofer = "Subwoofer"
        case side = "Side"
        case rear = "Rear"
    }
    
    enum SpeakerPosition: String, CaseIterable {
        case frontLeft = "Front Left"
        case frontRight = "Front Right"
        case center = "Center"
        case sideLeft = "Side Left"
        case sideRight = "Side Right"
        case rearLeft = "Rear Left"
        case rearRight = "Rear Right"
        case subwoofer = "Subwoofer"
    }
    
    init(type: SpeakerType, position: SpeakerPosition) {
        self.type = type
        self.position = position
        self.name = position.rawValue
    }
}
