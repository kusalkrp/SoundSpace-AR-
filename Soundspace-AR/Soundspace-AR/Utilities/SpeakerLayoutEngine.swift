// SpeakerLayoutEngine.swift
// Soundspace-AR
//
// Generates recommended speaker placement transforms (no measured calibration yet)
// for a given audio system relative to a listener reference transform.
//
// Created 2025-08-18.

import Foundation
import simd

struct SpeakerLayoutEngine {
    struct Placement {
        let position: Speaker.SpeakerPosition
        let transform: simd_float4x4
    }
    
    // Public API
    static func generate(system: AudioSystemType, listener: simd_float4x4?) -> [Placement] {
        // Listener origin default = identity (world origin)
        let listenerTransform = listener ?? matrix_identity_float4x4
        let listenerPosition = listenerTransform.translation
        
        // Base distances (meters)
        let frontRadius: Float = 2.0
        let sideRadius: Float  = 2.0
        let rearRadius: Float  = 2.5
        let subRadius: Float   = 1.5
        
        var placements: [Placement] = []
        
        func makeTransform(offset: SIMD3<Float>) -> simd_float4x4 {
            var t = matrix_identity_float4x4
            t.columns.3 = SIMD4<Float>(listenerPosition + offset, 1)
            return t
        }
        
        func polar(radius: Float, degrees: Float) -> SIMD3<Float> {
            let r = radius
            let rad = degrees * .pi / 180
            // Coordinate system: -Z forward, +X right (ARKit camera space). We assume listener faces -Z.
            let x = sin(rad) * r
            let z = -cos(rad) * r
            return SIMD3<Float>(x, 0, z)
        }
        
        // Mandatory speakers for each system
        switch system {
        case .system2_1:
            placements.append(Placement(position: .frontLeft, transform: makeTransform(offset: polar(radius: frontRadius, degrees: -30))))
            placements.append(Placement(position: .frontRight, transform: makeTransform(offset: polar(radius: frontRadius, degrees: 30))))
            placements.append(Placement(position: .subwoofer, transform: makeTransform(offset: polar(radius: subRadius, degrees: 0))))
        case .system5_1:
            placements.append(Placement(position: .frontLeft, transform: makeTransform(offset: polar(radius: frontRadius, degrees: -30))))
            placements.append(Placement(position: .frontRight, transform: makeTransform(offset: polar(radius: frontRadius, degrees: 30))))
            placements.append(Placement(position: .center, transform: makeTransform(offset: polar(radius: frontRadius, degrees: 0))))
            placements.append(Placement(position: .rearLeft, transform: makeTransform(offset: polar(radius: rearRadius, degrees: -150))))
            placements.append(Placement(position: .rearRight, transform: makeTransform(offset: polar(radius: rearRadius, degrees: 150))))
            placements.append(Placement(position: .subwoofer, transform: makeTransform(offset: polar(radius: subRadius, degrees: 0))))
        case .system7_1:
            placements.append(Placement(position: .frontLeft, transform: makeTransform(offset: polar(radius: frontRadius, degrees: -30))))
            placements.append(Placement(position: .frontRight, transform: makeTransform(offset: polar(radius: frontRadius, degrees: 30))))
            placements.append(Placement(position: .center, transform: makeTransform(offset: polar(radius: frontRadius, degrees: 0))))
            placements.append(Placement(position: .sideLeft, transform: makeTransform(offset: polar(radius: sideRadius, degrees: -90))))
            placements.append(Placement(position: .sideRight, transform: makeTransform(offset: polar(radius: sideRadius, degrees: 90))))
            placements.append(Placement(position: .rearLeft, transform: makeTransform(offset: polar(radius: rearRadius, degrees: -150))))
            placements.append(Placement(position: .rearRight, transform: makeTransform(offset: polar(radius: rearRadius, degrees: 150))))
            placements.append(Placement(position: .subwoofer, transform: makeTransform(offset: polar(radius: subRadius, degrees: 0))))
        }
        return placements
    }
}

// MARK: - Saved Pose Encoding

struct SavedSpeakerPose: Codable {
    let position: String
    let matrix: [Float] // 16 elements column-major
}

extension Array where Element == SavedSpeakerPose {
    func encodedData() -> Data? { try? JSONEncoder().encode(self) }
}

// MARK: - Matrix helpers

extension simd_float4x4 {
    var translation: SIMD3<Float> { SIMD3<Float>(columns.3.x, columns.3.y, columns.3.z) }
    func toArray() -> [Float] {
        [columns.0.x, columns.0.y, columns.0.z, columns.0.w,
         columns.1.x, columns.1.y, columns.1.z, columns.1.w,
         columns.2.x, columns.2.y, columns.2.z, columns.2.w,
         columns.3.x, columns.3.y, columns.3.z, columns.3.w]
    }
}
