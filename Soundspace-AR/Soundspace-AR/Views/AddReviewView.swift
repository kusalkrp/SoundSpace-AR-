// AddReviewView.swift
// Soundspace-AR
//


import SwiftUI
import PhotosUI
import CoreData

struct AddReviewView: View {
    let speaker: SpeakerModel
    
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var speakerDB: SpeakerDatabaseManager
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var rating: Int = 5
    @State private var reviewTitle = ""
    @State private var reviewContent = ""
    @State private var roomSize = ""
    @State private var systemType = ""
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var setupPhotos: [UIImage] = []
    @State private var showingImagePicker = false
    
    let roomSizes = ["Small (< 150 sq ft)", "Medium (150-300 sq ft)", "Large (300-500 sq ft)", "Extra Large (> 500 sq ft)"]
    let systemTypes = ["2.1 System", "5.1 System", "7.1 System", "Stereo", "Other"]
    
    var isFormValid: Bool {
        !reviewTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !reviewContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        rating > 0
    }
    
    var body: some View {
        ZStack {
            // Background gradient
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
  
                headerSection
                
                // Main content card
                contentCard
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .photosPicker(isPresented: $showingImagePicker, selection: $selectedPhotos, maxSelectionCount: 5, matching: .images)
        .onChange(of: selectedPhotos) { _, newItems in
            loadSelectedPhotos(newItems)
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 20) {
            // Top spacing
            Spacer()
            
            // Navigation buttons
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .medium))
                
                Spacer()
                
                Text("Add Review")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("Post") {
                    submitReview()
                }
                .disabled(!isFormValid)
                .foregroundColor(isFormValid ? .white : .white.opacity(0.5))
                .font(.system(size: 16, weight: .semibold))
            }
            .padding(.horizontal, 20)
            .padding(.top, 0)
            
            Spacer()
        }
        .frame(height: 100)
    }
    
    private var contentCard: some View {
        VStack(spacing: 0) {
            Spacer()
            // White card container
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Speaker Info Header
                        speakerInfoHeader
                        
                        // Rating Section
                        ratingSection
                        
                        // Review Title
                        reviewTitleSection
                        
                        // Review Content
                        reviewContentSection
                        
                        // Setup Info
                        setupInfoSection
                        
                        // Photo Upload
                        photoUploadSection
                        
                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 32)
                    .padding(.bottom, 0)
                }
                backButtonSection
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
            }
            .background(Color.white)
            .cornerRadius(32)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
            .padding(.horizontal, 16)
            .padding(.bottom, 0)
        }
    }
    
    private var speakerInfoHeader: some View {
        HStack {
            // Speaker placeholder image
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray5))
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "speaker.3")
                        .foregroundColor(.secondary)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(speaker.brand?.name ?? "Unknown Brand")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(speaker.name ?? "Unknown Speaker")
                    .font(.headline)
                    .fontWeight(.medium)
                
                if let modelNumber = speaker.modelNumber {
                    Text(modelNumber)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var ratingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Overall Rating")
                .font(.headline)
            
            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { index in
                    Button(action: {
                        rating = index
                    }) {
                        Image(systemName: index <= rating ? "star.fill" : "star")
                            .foregroundColor(index <= rating ? .yellow : .gray)
                            .font(.title2)
                    }
                }
                
                Spacer()
                
                Text(ratingDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var reviewTitleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Review Title")
                .font(.headline)
            
            TextField("Summarize your experience", text: $reviewTitle)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.sentences)
                .disableAutocorrection(false)
        }
    }
    
    private var reviewContentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your Review")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Tell others about your experience with this speaker")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                TextEditor(text: $reviewContent)
                    .frame(minHeight: 120)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
        }
    }
    
    private var setupInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Setup Information")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                // Room Size
                VStack(alignment: .leading, spacing: 8) {
                    Text("Room Size")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Picker("Room Size", selection: $roomSize) {
                        Text("Select room size").tag("")
                        ForEach(roomSizes, id: \.self) { size in
                            Text(size).tag(size)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // System Type
                VStack(alignment: .leading, spacing: 8) {
                    Text("Audio System")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Picker("System Type", selection: $systemType) {
                        Text("Select system type").tag("")
                        ForEach(systemTypes, id: \.self) { system in
                            Text(system).tag(system)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    private var photoUploadSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Setup Photos (Optional)")
                .font(.headline)
            
            Text("Share photos of your speaker setup to help others")
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Photo grid
            if !setupPhotos.isEmpty {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 8) {
                    ForEach(Array(setupPhotos.enumerated()), id: \.offset) { element in
                        let (index, image) = element
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            
                            Button(action: {
                                setupPhotos.remove(at: index)
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                                    .background(Color.white, in: Circle())
                            }
                            .offset(x: 8, y: -8)
                        }
                    }
                    
                    if setupPhotos.count < 5 {
                        addPhotoButton
                    }
                }
            } else {
                addPhotoButton
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    private var addPhotoButton: some View {
        Button(action: {
            showingImagePicker = true
        }) {
            VStack(spacing: 8) {
                Image(systemName: "camera.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Text("Add Photos")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            .frame(width: 80, height: 80)
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }
    
    private var ratingDescription: String {
        switch rating {
        case 1: return "Poor"
        case 2: return "Fair"
        case 3: return "Good"
        case 4: return "Very Good"
        case 5: return "Excellent"
        default: return ""
        }
    }
    
    private func loadSelectedPhotos(_ items: [PhotosPickerItem]) {
        for item in items {
            item.loadTransferable(type: Data.self) { (result: Result<Data?, Error>) in
                switch result {
                case .success(let data):
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            setupPhotos.append(image)
                        }
                    }
                case .failure(let error):
                    print("Error loading photo: \(error)")
                }
            }
        }
        selectedPhotos.removeAll()
    }
    
    private func submitReview() {
        guard let user = authManager.currentUser as? User else { return }
        
        // Convert photos to data for storage
        let photoData = setupPhotos.compactMap { $0.jpegData(compressionQuality: 0.7) }
        
        speakerDB.addReview(
            for: speaker,
            rating: rating,
            title: reviewTitle.trimmingCharacters(in: .whitespacesAndNewlines),
            content: reviewContent.trimmingCharacters(in: .whitespacesAndNewlines),
            user: user
        )
        
        // Update the review with additional info
        let request = NSFetchRequest<SpeakerReview>(entityName: "SpeakerReview")
        request.predicate = NSPredicate(format: "user == %@ AND speakerModel == %@", user, speaker)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \SpeakerReview.createdAt, ascending: false)]
        request.fetchLimit = 1
        
        do {
            let reviews = try viewContext.fetch(request)
            if let latestReview = reviews.first {
                latestReview.roomSize = roomSize.isEmpty ? nil : roomSize
                latestReview.systemType = systemType.isEmpty ? nil : systemType
                
                if !photoData.isEmpty {
                    latestReview.setupPhotos = NSArray(array: photoData)
                }
                
                try viewContext.save()
            }
        } catch {
            print("Error updating review: \(error)")
        }
        
        dismiss()
    }
    
    private var backButtonSection: some View {
        Button(action: { dismiss() }) {
            Text("Back")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(16)
        }
        .padding(.top, 16)
    }
}

struct AddReviewView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let speaker = SpeakerModel(context: context)
        speaker.name = "Sample Speaker"
        
        return AddReviewView(speaker: speaker)
            .environment(\.managedObjectContext, context)
            .environmentObject(AuthenticationManager())
            .environmentObject(SpeakerDatabaseManager(context: context))
    }
}
