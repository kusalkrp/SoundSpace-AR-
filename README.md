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

## � Codebase Structure

### Project Organization
```
Soundspace-AR/
├── Soundspace-AR/
│   ├── ContentView.swift              # Main content view (legacy)
│   ├── Persistence.swift              # Core Data setup and preview data
│   ├── Soundspace_ARApp.swift         # App entry point with environment objects
│   ├── Assets.xcassets/               # App icons and assets
│   ├── Models/
│   │   ├── AudioSystemType.swift      # Audio system configurations (2.1, 5.1, 7.1)
│   │   ├── RoomType.swift             # Room type definitions with icons
│   │   ├── Speaker.swift              # Speaker model with positions and types
│   │   └── SpeakerDatabase.swift      # Speaker database management
│   ├── Utilities/
│   │   ├── AuthenticationManager.swift    # User auth and biometric support
│   │   ├── NotificationManager.swift      # Local notifications
│   │   ├── RoomAnalysisHeuristics.swift   # Room analysis algorithms
│   │   └── SpeakerLayoutEngine.swift      # Speaker placement calculations
│   ├── Views/
│   │   ├── RootView.swift              # Root navigation with auth routing
│   │   ├── MainTabView.swift           # Custom tab bar navigation
│   │   ├── DashboardView.swift         # Home screen with quick actions
│   │   ├── ARSpeakerPlacementView.swift # AR speaker placement interface
│   │   ├── MLRoomDetectionView.swift   # AI-powered room analysis
│   │   ├── SpeakerCommunityView.swift  # Speaker database browser
│   │   ├── SpeakerDetailView.swift     # Detailed speaker information
│   │   ├── SavedLayoutsView.swift      # Saved speaker configurations
│   │   ├── SettingsView.swift          # App settings and preferences
│   │   ├── LoginView.swift             # User login interface
│   │   ├── SignupView.swift            # User registration
│   │   ├── OnboardingView.swift        # First-time user introduction
│   │   ├── RoomScanningView.swift      # AR room scanning
│   │   ├── RoomDetectionResultsView.swift # Analysis results display
│   │   ├── SaveLayoutView.swift        # Save speaker layout
│   │   ├── AddReviewView.swift         # Add speaker review
│   │   ├── SpeakerDetailView.swift     # Speaker details and reviews
│   │   ├── ChangePasswordView.swift    # Password change interface
│   │   ├── ForgotPasswordView.swift    # Password recovery
│   │   ├── HelpAboutView.swift         # Help and about information
│   │   ├── UserGuideView.swift         # User guide and tutorials
│   │   └── SplashScreen.swift          # App launch splash screen
│   └── Soundspace_AR.xcdatamodeld/     # Core Data model definitions
├── Soundspace-AR.xcodeproj/            # Xcode project files
├── Soundspace-ARTests/                 # Unit test suite
└── Soundspace-ARUITests/               # UI test suite
```

### Key Components Overview

#### Core Architecture
- **MVVM Pattern**: Clean separation with ViewModels for business logic
- **Environment Objects**: Shared state management across the app
- **Core Data**: Local persistence with relationships between entities
- **SwiftUI Navigation**: Programmatic navigation with custom transitions

#### AR Integration
- **ARKit**: World tracking and plane detection for speaker placement
- **RealityKit**: 3D speaker models and scene management
- **Scene Understanding**: Room geometry analysis for optimal placement

#### AI/ML Features
- **Vision Framework**: Image analysis for room type classification
- **Core ML**: Machine learning models for room detection
- **AVFoundation**: Camera capture and processing for room analysis

#### Authentication System
- **Local Authentication**: Biometric support (Face ID/Touch ID)
- **Secure Storage**: Password hashing and secure data handling
- **User Profiles**: Personalized experience with saved preferences

### Data Flow Architecture

#### User Authentication Flow
```
App Launch → SplashScreen → RootView → Auth Check → MainTabView or OnboardingView
```

#### AR Setup Flow
```
Dashboard → Room Selection → Audio System Selection → AR Placement → Save Layout
```

#### Speaker Database Flow
```
Community Tab → Browse Speakers → Filter/Search → Speaker Details → Reviews/Wishlist
```

### Testing Strategy

#### Unit Tests (`Soundspace-ARTests/`)
- **SpeakerDatabaseTests**: Database operations and data integrity
- **AuthenticationTests**: Login/signup and biometric flows
- **LayoutEngineTests**: Speaker placement calculations
- **PersistenceTests**: Core Data operations

#### UI Tests (`Soundspace-ARUITests/`)
- **UserFlows**: Complete user journey testing
- **ARInteractions**: AR placement and interaction testing
- **CommunityFeatures**: Speaker browsing and review workflows

### Build Configuration

#### Xcode Requirements
- **Xcode 15.0+**: Required for SwiftUI and ARKit features
- **iOS 16.0+**: Minimum deployment target
- **Swift 5.9+**: Language version for modern Swift features

#### Build Settings
- **Enable ARKit**: Required for AR features
- **Camera Usage**: Privacy permissions for room detection
- **Core Data**: Automatic code generation for entities
- **SwiftUI Previews**: Preview support with sample data

#### Dependencies
- **No External Dependencies**: Pure Apple frameworks
- **System Frameworks**: ARKit, RealityKit, CoreML, Vision, AVFoundation
- **Local Packages**: All functionality built with native iOS APIs

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


## 🤝 Contributing

Deliverables:

- SwiftUI and UIKit integration
- Core Data management
- ARKit implementation
- Camera and ML integration
- Authentication systems
- Complex UI/UX design

