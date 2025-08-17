// RoomType.swift
// Soundspace-AR
//
// Created by Kusal on 2025-08-04.
//

import Foundation

enum RoomType: String, CaseIterable, Identifiable {
    case livingRoom = "Living Room"
    case bedroom = "Bedroom"
    case office = "Office"
    case diningRoom = "Dining Room"
    case basement = "Basement"
    case garage = "Garage"
    case hall = "Hall"
    
    var id: String { rawValue }
    
    var displayName: String {
        return rawValue
    }
    
    var icon: String {
        switch self {
        case .livingRoom:
            return "sofa.fill"
        case .bedroom:
            return "bed.double.fill"
        case .office:
            return "desktopcomputer"
        case .diningRoom:
            return "table.furniture.fill"
        case .basement:
            return "stairs"
        case .garage:
            return "car.garage"
        case .hall:
            return "house.fill"
        }
    }
    
    var imageName: String {
        switch self {
        case .livingRoom:
            return "sofa.fill"
        case .bedroom:
            return "bed.double.fill"
        case .office:
            return "desktopcomputer"
        case .diningRoom:
            return "table.furniture.fill"
        case .basement:
            return "stairs"
        case .garage:
            return "car.garage"
        case .hall:
            return "house.fill"
        }
    }
    
    var description: String {
        switch self {
        case .livingRoom:
            return "Main entertainment space with seating area"
        case .bedroom:
            return "Personal sleeping and relaxation space"
        case .office:
            return "Work or study environment"
        case .diningRoom:
            return "Formal dining and gathering space"
        case .basement:
            return "Lower level entertainment or storage area"
        case .garage:
            return "Vehicle storage or workshop space"
        case .hall:
            return "Large open area for gatherings"
        }
    }
    
    var acousticCharacteristics: String {
        switch self {
        case .livingRoom:
            return "Open space with soft furnishings"
        case .bedroom:
            return "Intimate space with sound absorption"
        case .office:
            return "Focused environment with minimal echo"
        case .diningRoom:
            return "Formal space with hard surfaces"
        case .basement:
            return "Concrete walls with unique acoustics"
        case .garage:
            return "Large open space with hard surfaces"
        case .hall:
            return "Large space with potential for echo"
        }
    }
}
