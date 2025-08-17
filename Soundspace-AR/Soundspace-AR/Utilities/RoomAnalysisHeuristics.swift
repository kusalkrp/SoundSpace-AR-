// RoomAnalysisHeuristics.swift
// Soundspace-AR
//
// Heuristic mapping from detected Vision objects & scene classifications
// to RoomType and recommended AudioSystemType without custom model training.
//
// Uses built-in VNRecognizeObjectsRequest & VNClassifyImageRequest labels.
//
// Created on 2025-08-18.

import Foundation

struct RoomAnalysisHeuristics {
    struct Result {
        let roomType: RoomType
        let recommendedSystem: AudioSystemType
        let confidence: Float // 0-1 combined
    }
    
    // Synonym clusters for object-based detection.
    private static let sofaWords: Set<String> = ["sofa", "couch", "loveseat"]
    private static let tvWords: Set<String> = ["tv", "television", "monitor", "screen"]
    private static let bedWords: Set<String> = ["bed", "bunk bed"]
    private static let deskWords: Set<String> = ["desk", "workstation", "computer", "laptop"]
    private static let tableWords: Set<String> = ["dining table", "table"]
    private static let chairWords: Set<String> = ["chair", "armchair", "stool"]
    private static let carWords: Set<String> = ["car", "automobile", "vehicle"]
    
    // Map Vision scene / classification labels to RoomType directly.
    private static let sceneLabelMap: [String: RoomType] = [
        "living room": .livingRoom,
        "lounge": .livingRoom,
        "bedroom": .bedroom,
        "office": .office,
        "home office": .office,
        "dining room": .diningRoom,
        "garage": .garage,
        "basement": .basement,
        "hall": .hall
    ]
    
    // Fallback object-based heuristic.
    static func inferRoomType(objects: [String]) -> (RoomType, Float) {
        let lower = objects.map { $0.lowercased() }
        let set = Set(lower)
        
        func containsAny(_ keywords: Set<String>) -> Bool { !set.isDisjoint(with: keywords) }
        
        if containsAny(bedWords) {
            return (.bedroom, 0.9)
        }
        if containsAny(sofaWords) && containsAny(tvWords) {
            return (.livingRoom, 0.85)
        }
        if containsAny(deskWords) && containsAny(tvWords) { // monitor + desk
            return (.office, 0.75)
        }
        if containsAny(tableWords) && containsAny(chairWords) && !containsAny(sofaWords) {
            return (.diningRoom, 0.7)
        }
        if containsAny(carWords) {
            return (.garage, 0.95)
        }
        // Sparse / ambiguous: choose hall as generic large space
        return (.hall, 0.4)
    }
    
    static func combine(sceneLabels: [(String, Float)], objectLabels: [String], floorAreaM2: Float?) -> Result {
        // 1. Scene-based attempt
        var bestScene: (RoomType, Float)? = nil
        for (label, prob) in sceneLabels {
            let l = label.lowercased()
            if let mapped = sceneLabelMap[l], prob > (bestScene?.1 ?? 0) {
                bestScene = (mapped, prob)
            }
        }
        
        // 2. Object heuristic
        let (heuristicRoom, heuristicConfidence) = inferRoomType(objects: objectLabels)
        
        // 3. Merge strategy
        let finalRoom: RoomType
        let sceneWeight: Float = 0.6
        let objectWeight: Float = 0.4
        let combinedConfidence: Float
        if let scene = bestScene, scene.1 >= 0.4 { // modest threshold
            finalRoom = scene.0
            combinedConfidence = min(1.0, scene.1 * sceneWeight + heuristicConfidence * objectWeight)
        } else {
            finalRoom = heuristicRoom
            combinedConfidence = heuristicConfidence * 0.8 // degrade due to no scene support
        }
        
        // 4. System recommendation heuristic using (room, size)
        // Optional area influence: if provided and large, encourage larger system.
        let area = floorAreaM2 ?? 0
        let system: AudioSystemType
        switch finalRoom {
        case .bedroom: system = area > 18 ? .system5_1 : .system2_1
        case .office: system = .system2_1
        case .livingRoom: system = area > 25 ? .system7_1 : .system5_1
        case .diningRoom: system = .system5_1
        case .garage, .hall, .basement: system = area > 35 ? .system7_1 : .system5_1
        }
        
        return Result(roomType: finalRoom, recommendedSystem: system, confidence: combinedConfidence)
    }
}
