// RoomDetectionResultsView.swift
// Soundspace-AR
//


import SwiftUI

struct RoomDetectionResultsView: View {
    let roomType: RoomType?
    let recommendedSystem: AudioSystemType?
    let confidence: Float
    let roomDimensions: RoomDimensions?
    
    @Environment(\.dismiss) private var dismiss
    @State private var showingARSetup = false
    
    /// The main body of the RoomDetectionResultsView, displaying analysis results and actions.
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Results Header
                    resultsHeader
                    
                    // Room Dimensions (if available from AR scanning)
                    if let dimensions = roomDimensions {
                        roomDimensionsCard(dimensions)
                    }
                    
                    // Room Type Result
                    if let roomType = roomType {
                        roomTypeCard(roomType)
                    }
                    
                    // Recommended System
                    if let recommendedSystem = recommendedSystem {
                        recommendedSystemCard(recommendedSystem)
                    }
                    
                    // Confidence Indicator
                    confidenceSection
                    
                    // Action Buttons
                    actionButtons
                    
                    // Additional Tips
                    tipsSection
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
            .navigationTitle("Room Analysis")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingARSetup) {
            NavigationView {
                SetupView()
            }
        }
    }
    
    /// Header section displaying the analysis completion status.
    private var resultsHeader: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("Room Analysis Complete")
                .font(.title)
                .fontWeight(.bold)
            
            Text("AI has analyzed your room and provides these recommendations")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    /// Creates a card displaying room dimensions if available.
    private func roomDimensionsCard(_ dimensions: RoomDimensions) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Precise Room Dimensions", systemImage: "ruler.fill")
                .font(.headline)
                .foregroundColor(.purple)
            
            HStack(spacing: 16) {
                DimensionCard(label: "Length", value: dimensions.length, unit: "m")
                DimensionCard(label: "Width", value: dimensions.width, unit: "m")
                DimensionCard(label: "Height", value: dimensions.height, unit: "m")
            }
            
            HStack(spacing: 16) {
                DimensionCard(label: "Area", value: dimensions.area, unit: "m²")
                DimensionCard(label: "Volume", value: dimensions.volume, unit: "m³")
            }
            
            Text("Measured using AR technology for high accuracy")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    /// Creates a card displaying the detected room type.
    private func roomTypeCard(_ roomType: RoomType) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Detected Room Type", systemImage: "house.fill")
                .font(.headline)
                .foregroundColor(.blue)
            
            HStack {
                Image(systemName: roomType.imageName)
                    .font(.largeTitle)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(roomType.rawValue)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(roomType.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    /// Creates a card displaying the recommended audio system.
    private func recommendedSystemCard(_ system: AudioSystemType) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Recommended Audio System", systemImage: "speaker.wave.3.fill")
                .font(.headline)
                .foregroundColor(.orange)
            
            HStack {
                Image(systemName: system.imageName)
                    .font(.largeTitle)
                    .foregroundColor(.orange)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(system.rawValue)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(system.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("\(system.speakerCount) speakers total")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    /// Section displaying the analysis confidence level with a progress bar.
    private var confidenceSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Analysis Confidence")
                .font(.headline)
            
            HStack {
                Text("Confidence Level:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int(confidence * 100))%")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(confidenceColor)
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(confidenceColor)
                        .frame(width: max(0, min(geometry.size.width, geometry.size.width * CGFloat(safeConfidence))), height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
            
            Text(confidenceDescription)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    /// Action buttons for starting AR setup, retaking photo, or manual setup.
    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Start AR Setup button
            Button(action: {
                showingARSetup = true
            }) {
                HStack {
                    Image(systemName: "viewfinder")
                    Text("Start AR Setup with These Settings")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .font(.headline)
            }
            
            HStack(spacing: 12) {
                // Retake Photo button
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "camera.fill")
                        Text("Retake Photo")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .foregroundColor(.primary)
                    .cornerRadius(12)
                }
                
                // Manual Setup button
                NavigationLink(destination: SetupView()) {
                    HStack {
                        Image(systemName: "slider.horizontal.3")
                        Text("Manual Setup")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .foregroundColor(.primary)
                    .cornerRadius(12)
                }
            }
        }
    }
    
    /// Section providing optimization tips based on room type.
    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Optimization Tips")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                if let roomType = roomType {
                    switch roomType {
                    case .bedroom:
                        TipRow(
                            icon: "bed.double.fill",
                            text: "Consider nearfield speakers for close listening"
                        )
                        TipRow(
                            icon: "speaker.wave.2.fill",
                            text: "2.1 system is ideal for smaller spaces"
                        )
                        
                    case .livingRoom:
                        TipRow(
                            icon: "sofa.fill",
                            text: "5.1 surround provides immersive experience"
                        )
                        TipRow(
                            icon: "triangle.fill",
                            text: "Form equilateral triangle with front speakers"
                        )
                        
                    case .hall:
                        TipRow(
                            icon: "house.fill",
                            text: "7.1 system maximizes large space potential"
                        )
                        TipRow(
                            icon: "arrow.up.and.down.and.arrow.left.and.right",
                            text: "Consider acoustic treatment for large rooms"
                        )
                        
                    case .office:
                        TipRow(
                            icon: "desktopcomputer",
                            text: "Near-field monitors work best for work environments"
                        )
                        TipRow(
                            icon: "speaker.wave.1.fill",
                            text: "2.1 system provides focused audio without distraction"
                        )
                        
                    case .diningRoom:
                        TipRow(
                            icon: "table.furniture.fill",
                            text: "Ceiling speakers can provide ambient audio"
                        )
                        TipRow(
                            icon: "speaker.wave.2.fill",
                            text: "Background music setup works well here"
                        )
                        
                    case .basement:
                        TipRow(
                            icon: "stairs",
                            text: "Concrete walls may require acoustic treatment"
                        )
                        TipRow(
                            icon: "speaker.wave.3.fill",
                            text: "Great space for home theater setup"
                        )
                        
                    case .garage:
                        TipRow(
                            icon: "car.garage",
                            text: "Weather-resistant speakers recommended"
                        )
                        TipRow(
                            icon: "speaker.2.fill",
                            text: "Simple stereo setup often sufficient"
                        )
                    }
                }
                
                TipRow(
                    icon: "ruler.fill",
                    text: "Use AR to ensure proper speaker distances"
                )
                
                TipRow(
                    icon: "ear.fill",
                    text: "Test different positions and trust your ears"
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    /// Computed color for the confidence indicator based on confidence level.
    private var confidenceColor: Color {
        if safeConfidence >= 0.8 {
            return .green
        } else if safeConfidence >= 0.6 {
            return .orange
        } else {
            return .red
        }
    }
    
    /// Safely clamps the confidence value between 0 and 1.
    private var safeConfidence: Float {
        guard confidence.isFinite, confidence >= 0 else { return 0 }
        return min(max(confidence, 0), 1)
    }
    
    /// Provides a description of the confidence level.
    private var confidenceDescription: String {
        if safeConfidence >= 0.8 {
            return "High confidence - Recommendation is highly reliable"
        } else if safeConfidence >= 0.6 {
            return "Medium confidence - Good recommendation with some uncertainty"
        } else {
            return "Low confidence - Consider manual setup or retake photo"
        }
    }
}

struct DimensionCard: View {
    let label: String
    let value: Float
    let unit: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(String(format: "%.1f", value))
                .font(.title3)
                .fontWeight(.bold)
            
            Text(unit)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.white)
        .cornerRadius(8)
    }
}

struct TipRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

struct RoomDetectionResultsView_Previews: PreviewProvider {
    static var previews: some View {
        RoomDetectionResultsView(
            roomType: .livingRoom,
            recommendedSystem: .system5_1,
            confidence: 0.85,
            roomDimensions: nil
        )
    }
}
