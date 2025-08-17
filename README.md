# SoundSpace AR - Speaker Positioning Assistant

A comprehensive iOS app that uses augmented reality to help users set up surround sound systems with a community-driven speaker database.

## 🎯 Features

### Core Features
- **AR Speaker Placement**: Visualize optimal speaker positions in your room using ARKit
- **Multiple Audio Systems**: Support for 2.1, 5.1, and 7.1 surround sound configurations
- **Room Type Detection**: Optimize placement for Living Room, Bedroom, or Hall setups
- **Save & Load Layouts**: Store your speaker configurations with Core Data

### Community Features
- **Speaker Database**: Browse and search thousands of speaker models
- **User Reviews**: Rate and review speakers with photos and detailed feedback
- **Wishlist**: Save speakers you're considering purchasing
- **Brand Comparison**: Compare speakers across different brands and price ranges

### AI-Powered Features
- **Smart Room Analysis**: Use ML to analyze room size and recommend optimal audio systems
- **Camera-Based Detection**: Automatically detect room type and dimensions
- **Intelligent Recommendations**: Get personalized speaker suggestions based on room analysis

### Authentication & Data
- **Local Authentication**: Secure login with biometric support (Face ID/Touch ID)
- **Core Data Storage**: All data stored locally, no external dependencies
- **User Profiles**: Personalized experience with saved preferences

## 🛠 Technical Implementation

### Frameworks Used
- **SwiftUI**: Modern declarative UI framework
- **ARKit**: Augmented reality speaker placement
- **Core Data**: Local data persistence
- **Core ML**: Room analysis and classification
- **LocalAuthentication**: Biometric authentication
- **AVFoundation**: Camera access for room detection
- **Vision**: Image analysis for room classification

### Architecture
- **MVVM Pattern**: Clean separation of concerns
- **Core Data Models**: User, SpeakerBrand, SpeakerModel, SpeakerReview, SavedLayout, WishlistItem
- **Environment Objects**: Shared state management across views
- **Modular Design**: Reusable components and views

## 📱 App Flow

### Authentication Flow
1. **Splash Screen** → Auto-navigation to auth
2. **Login/Signup** → User registration and authentication
3. **Biometric Setup** → Optional Face ID/Touch ID configuration

### Main App Flow
1. **Dashboard** → Central hub with quick actions and stats
2. **AR Setup** → Room and system selection
3. **Smart Room Scan** → AI-powered room analysis (optional)
4. **AR Placement** → Real-time speaker positioning in AR
5. **Save Layout** → Store configuration for future use

### Community Flow
1. **Browse Speakers** → Explore speaker database
2. **Speaker Details** → Detailed specifications and reviews
3. **Add Review** → Rate and review with photos
4. **Wishlist Management** → Save favorite speakers

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0+
- iOS 16.0+
- Device with ARKit support (iPhone 6s/SE or newer)
- Camera permissions for room detection

### Installation
1. Clone the repository
2. Open `Soundspace-AR.xcodeproj` in Xcode
3. Build and run on a physical device (AR features require real device)

### First Run Setup
1. Complete onboarding flow
2. Create user account or login
3. Allow camera and AR permissions
4. Explore the dashboard and features

## 📊 Core Data Schema

### User Entity
- `username`: String
- `email`: String (unique)
- `password`: String (hashed)
- `isLoggedIn`: Boolean
- `biometricEnabled`: Boolean
- `createdAt`: Date

### SpeakerModel Entity
- `name`: String
- `modelNumber`: String
- `type`: String (category)
- `priceRange`: String
- `averageRating`: Float
- `reviewCount`: Int32
- `brand`: Relationship to SpeakerBrand

### SpeakerReview Entity
- `title`: String
- `content`: String
- `rating`: Int16 (1-5)
- `setupPhotos`: Transformable (photos array)
- `roomSize`: String
- `systemType`: String

## 🎨 UI Components

### Reusable Components
- **ActionCard**: Quick action buttons with icons
- **SpeakerCard**: Speaker display with rating and wishlist
- **ReviewCard**: User review with rating stars
- **FilterChip**: Removable filter tags
- **StatCard**: Dashboard statistics display

### Views Hierarchy
- **ContentView**: Root view with authentication routing
- **MainTabView**: Tab-based navigation
- **DashboardView**: Home screen with quick actions
- **SetupView**: Room and system configuration
- **ARSpeakerPlacementView**: AR placement interface
- **SpeakerCommunityView**: Speaker database browser
- **SpeakerDetailView**: Detailed speaker information

## 🔧 Configuration

### Camera Permissions
Add to Info.plist:
```xml
<key>NSCameraUsageDescription</key>
<string>Camera access is required for room analysis and AR speaker placement</string>
```

### ARKit Configuration
```xml
<key>NSCameraUsageDescription</key>
<string>AR features require camera access to place virtual speakers in your room</string>
```

## 🧪 Testing

### Unit Tests
- Speaker database operations
- Core Data persistence
- Authentication flows
- AR placement calculations

### UI Tests
- Complete user flows
- AR interaction testing
- Community features testing

### Preview Support
All views include SwiftUI previews with sample data for easy development and testing.

## 📱 Device Compatibility

### Supported Devices
- iPhone 6s and newer
- iPad (5th generation) and newer
- iPad Pro (all models)
- iPad Air (2nd generation) and newer
- iPad mini (4th generation) and newer

### iOS Requirements
- iOS 16.0 minimum
- ARKit 4.0+ for enhanced features
- 64-bit processor required

## 🔐 Privacy & Security

### Data Privacy
- All user data stored locally
- No external servers or third-party analytics
- Biometric data never leaves device
- User photos stored securely in Core Data

### Security Features
- Password hashing with SHA256
- Biometric authentication support
- Secure Core Data storage
- Local-only data processing

## 🚀 Future Enhancements

### Planned Features
- **Real-time Audio Analysis**: Measure room acoustics
- **3D Room Mapping**: Enhanced AR room scanning
- **Social Sharing**: Share layouts with friends
- **Professional Consultation**: Connect with audio experts
- **Price Tracking**: Monitor speaker price changes
- **AR Persistence**: Remember speaker positions across sessions

### Technical Improvements
- **Core ML Models**: Enhanced room classification
- **CloudKit Sync**: Optional cloud backup
- **Widget Support**: Quick access from home screen
- **Siri Shortcuts**: Voice commands for common actions

## 📄 License

This project is created for educational purposes. Speaker brand names and images are property of their respective owners.

## 🤝 Contributing

This is a coursework project demonstrating iOS development skills including:
- SwiftUI and UIKit integration
- Core Data management
- ARKit implementation
- Camera and ML integration
- Authentication systems
- Complex UI/UX design

---

Built with ❤️ using Swift and SwiftUI
– Speaker Positioning Assistant
