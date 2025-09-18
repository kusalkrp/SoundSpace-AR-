import SwiftUI

struct SaveLayoutView: View {
    @State private var layoutName: String = "My Layout 1"
    @State private var selectedRoomType: String = "Living Room"
    @State private var selectedSpeakerSystem: String = "7.1"
    @State private var saveAsDefault: Bool = true
    @State private var saveARAnchors: Bool = true
    
    @Environment(\.dismiss) private var dismiss
    
    let roomTypes = ["Living Room", "Bedroom", "Office / Study", "Custom Room"]
    let speakerSystems = ["2.1", "5.1", "7.1"]
    
    var body: some View {
        ZStack {
            // Blue gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.4, green: 0.5, blue: 1.0),
                    Color(red: 0.3, green: 0.4, blue: 0.9)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerSection
                
                // Content card
                contentCard
            }
        }
        .navigationBarHidden(true)
    }
    
    private var headerSection: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text("Save Layout")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.top, 60)
            
            Spacer()
        }
        .frame(height: 200)
    }
    
    private var contentCard: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(spacing: 24) {
                // Layout Name Section
                layoutNameSection
                
                // Room Type Section
                roomTypeSection
                
                // Speaker System Section
                speakerSystemSection
                
                // Toggle Options
                toggleOptionsSection
                
                // Action Buttons
                actionButtonsSection
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 32)
            .background(Color.white)
            .cornerRadius(32)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
            .padding(.horizontal, 16)
            .padding(.bottom, 80)
        }
    }
    
    private var layoutNameSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Layout Name")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            TextField("Enter layout name", text: $layoutName)
                .textFieldStyle(CustomTextFieldStyle())
        }
    }
    
    private var roomTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Room Type")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Menu {
                ForEach(roomTypes, id: \.self) { roomType in
                    Button(roomType) {
                        selectedRoomType = roomType
                    }
                }
            } label: {
                HStack {
                    Text(selectedRoomType)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }
    
    private var speakerSystemSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Speaker System Type")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Menu {
                ForEach(speakerSystems, id: \.self) { system in
                    Button(system) {
                        selectedSpeakerSystem = system
                    }
                }
            } label: {
                HStack {
                    Text(selectedSpeakerSystem)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }
    
    private var toggleOptionsSection: some View {
        VStack(spacing: 16) {
            // Save as default layout toggle
            HStack {
                Text("Save as default layout")
                    .font(.body)
                    .foregroundColor(.primary)
                Spacer()
                Toggle("", isOn: $saveAsDefault)
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
            }
            
            // Save AR Anchors toggle
            HStack {
                Text("Save AR Anchors")
                    .font(.body)
                    .foregroundColor(.primary)
                Spacer()
                Toggle("", isOn: $saveARAnchors)
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
            }
        }
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            // Save button
            Button(action: {
                // Handle save action
                dismiss()
            }) {
                Text("Save")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(16)
            }
            
            // Cancel button
            Button(action: {
                dismiss()
            }) {
                Text("Cancel")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray)
                    .cornerRadius(16)
            }
        }
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
    }
}

#Preview {
    SaveLayoutView()
}