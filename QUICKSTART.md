# SoundSpace AR - Quick Start Guide

## 🚀 Running the App

### Step 1: Open in Xcode
1. Navigate to your project directory
2. Open `Soundspace-AR.xcodeproj`
3. Select your iPhone/iPad as the target device (AR requires physical device)

### Step 2: Build and Run
1. Click the Play button or press `Cmd + R`
2. Allow camera permissions when prompted
3. The app will launch with the splash screen

### Step 3: First Experience
1. **Splash Screen**: 2-second loading screen
2. **Onboarding**: Swipe through introduction screens
3. **Sign Up**: Create your account with email/password
4. **Dashboard**: Explore the main hub with quick actions

## 🏠 Key App Flows

### Authentication Flow
```
Splash Screen → Onboarding → Sign Up/Login → Biometric Setup (optional) → Dashboard
```

### AR Speaker Setup Flow
```
Dashboard → "Start AR Setup" → Room Selection → System Selection → AR Placement → Save Layout
```

### Smart Room Detection Flow
```
Dashboard → "Smart Room Scan" → Method Selection → AI Analysis or AR Scanning → Results → AR Setup
```

### Speaker Community Flow
```
Dashboard → "Browse Speakers" → Search/Filter → Speaker Details → Add Review/Wishlist
```

## 📱 Testing Features

### Core Features to Test
1. **Authentication**
   - Sign up with new account (email validation included)
   - Login with existing account
   - Test biometric authentication (Face ID/Touch ID if available)
   - Password change and reset functionality

2. **AR Setup**
   - Select different room types (Living Room, Bedroom, Office, etc.)
   - Choose audio systems (2.1, 5.1, 7.1)
   - Launch AR view and place speakers with tap gestures
   - Save and load speaker layouts

3. **Smart Room Detection**
   - AI-powered room analysis using Vision framework
   - Camera-based room type detection
   - ML recommendations for audio systems
   - AR scanning alternative method

4. **Speaker Community**
   - Browse speaker database with sample brands (KEF, Klipsch, Sony, etc.)
   - Search for specific brands/models
   - Add reviews and ratings with photos
   - Add/remove from wishlist
   - View detailed speaker specifications

### Preview Mode Testing
All views support SwiftUI previews for quick testing:
1. Open any View file in Xcode
2. Click "Resume" in the preview panel
3. Interact with the preview to test UI components

## 🛠 Customization

### Adding Sample Data
The app automatically creates sample data on first run:
- Sample speaker brands (Klipsch, KEF, Sony, Yamaha, JBL, etc.)
- Speaker models with ratings and reviews
- User accounts for testing

### Modifying Speaker Database
Edit `SpeakerDatabaseManager` in `Models/SpeakerDatabase.swift` to:
- Add more speaker brands
- Create additional speaker models
- Modify sample reviews and ratings

### Customizing UI
Key UI components in:
- `DashboardView.swift`: Main home screen with quick actions
- `SpeakerCommunityView.swift`: Speaker browser with search/filter
- `SetupView.swift`: Room and system selection
- `ARSpeakerPlacementView.swift`: AR placement interface
- `MLRoomDetectionView.swift`: AI room analysis

## 🐛 Troubleshooting

### Common Issues

**AR Not Working**
- Ensure you're running on a physical device (iPhone 6s or newer)
- Check camera permissions in Settings → Privacy → Camera
- ARKit requires good lighting conditions and stable device
- Try restarting the device if AR tracking fails

**Core Data Errors**
- Clear app data: Settings → General → iPhone Storage → SoundSpace AR → Delete App
- Restart the app to recreate sample data
- Check that all Core Data entities are properly configured in `.xcdatamodeld`

**Preview Not Loading**
- Clean build folder: Xcode → Product → Clean Build Folder (Cmd + Shift + K)
- Restart Xcode if previews become unresponsive
- Check that all environment objects are properly initialized in previews

**Biometric Authentication Issues**
- Ensure Face ID/Touch ID is set up on your device
- Check Settings → Face ID & Passcode (or Touch ID & Passcode)
- App will fall back to password authentication if biometrics fail

**ML Room Detection Not Working**
- Requires iOS 16.0+ for Vision classification
- Camera permissions must be granted
- Works best in well-lit environments
- Falls back to default recommendations if ML unavailable

### Debug Tips
1. Use Xcode's debugging tools for Core Data issues
2. Check console output for error messages (View → Debug Area → Activate Console)
3. Test AR features in well-lit environments with stable WiFi
4. Use device logs for authentication issues

## 📊 Data Structure Overview

### Core Data Entities
```
User (authentication and profile)
├── SavedLayout (user's saved speaker configurations)
├── SpeakerReview (user's speaker reviews)
└── WishlistItem (user's wishlist)

SpeakerBrand (speaker manufacturers)
└── SpeakerModel (individual speaker models)
    ├── SpeakerReview (reviews for this model)
    └── WishlistItem (wishlist entries for this model)
```

### Key Managers
- `AuthenticationManager`: Handles login/signup/biometrics with SHA256 password hashing
- `SpeakerDatabaseManager`: Manages speaker data and community features
- `CameraManager`: Controls camera for room detection
- `RoomDetector`: ML-based room analysis using Vision framework
- `SpeakerLayoutEngine`: Calculates optimal speaker positions
- `ARViewModel`: Manages AR scene and speaker placement

## 🎯 Feature Demonstrations

### For Coursework Assessment

**iOS Framework Integration**
- SwiftUI for modern declarative UI with MVVM architecture
- Core Data for local persistence with complex entity relationships
- ARKit + RealityKit for augmented reality speaker placement
- LocalAuthentication for biometric support (Face ID/Touch ID)
- AVFoundation + Vision for camera access and ML analysis
- CryptoKit for secure password hashing

**Advanced Features**
- Machine Learning room detection with Vision framework
- Real-time AR interaction with gesture recognition
- Complex Core Data relationships and data management
- Photo handling and storage in Core Data
- Biometric authentication with fallback to password
- Custom SwiftUI components and animations

**Code Quality**
- MVVM architecture with clear separation of concerns
- Reusable components and environment objects
- Comprehensive error handling and user feedback
- Accessibility support and proper UI states
- Unit tests for data operations and business logic
- UI tests for complete user flows
- SwiftUI previews for all major views

**Testing Coverage**
- Unit tests for database operations and authentication
- UI tests for user flows and AR interactions
- Preview support for rapid UI development
- Error handling tests for edge cases

## 🔧 Build Configuration

### Required Permissions (Info.plist)
```xml
<key>NSCameraUsageDescription</key>
<string>Camera access required for AR speaker placement and room analysis</string>

<key>NSFaceIDUsageDescription</key>
<string>Face ID provides secure and convenient authentication</string>

<key>NSMicrophoneUsageDescription</key>
<string>Microphone access for audio system testing (future feature)</string>
```

### Deployment Target
- iOS 16.0 minimum (required for Vision framework features)
- ARKit 4.0+ features for enhanced AR capabilities
- Compatible with iPhone 6s and newer, iPad (5th gen) and newer

## 📈 Performance Notes

### Optimization Features
- Lazy loading of speaker data with pagination
- Efficient Core Data queries with proper indexing
- Image compression for photos and speaker images
- Background processing for ML analysis
- Memory-efficient AR session management
- Optimized SwiftUI view updates

### Memory Management
- Proper disposal of AR sessions and anchors
- Image data optimization and caching
- Core Data memory efficient queries with batching
- SwiftUI view lifecycle management

## 🎉 Success Metrics

After running the app, you should see:
- ✅ Smooth onboarding experience with biometric setup
- ✅ Functional authentication system with secure password hashing
- ✅ Working AR speaker placement with real-time positioning
- ✅ AI-powered room detection with ML recommendations
- ✅ Comprehensive speaker database with user reviews
- ✅ Persistent data storage with Core Data relationships
- ✅ Community review system with photo uploads
- ✅ Custom tab navigation and smooth transitions


**Ready to explore? Start with the Dashboard and try each feature!** 🎧📱
   - Browse speaker database
   - Search for specific brands/models
   - Add reviews and ratings
   - Add/remove from wishlist

4. **Smart Features**
   - Use ML room detection
   - View AI recommendations
   - Save and load layouts

### Preview Mode Testing
All views support SwiftUI previews for quick testing:
1. Open any View file in Xcode
2. Click "Resume" in the preview panel
3. Interact with the preview to test UI components

## 🛠 Customization

### Adding Sample Data
The app automatically creates sample data on first run:
- Sample speaker brands (KEF, Klipsch, Sony, etc.)
- Speaker models with ratings and reviews
- User accounts for testing

### Modifying Speaker Database
Edit `SpeakerDatabase.swift` to:
- Add more speaker brands
- Create additional speaker models
- Modify sample reviews and ratings

### Customizing UI
Key UI components in:
- `DashboardView.swift`: Main home screen
- `SpeakerCommunityView.swift`: Speaker browser
- `SetupView.swift`: Room and system selection

## 🐛 Troubleshooting

### Common Issues

**AR Not Working**
- Ensure you're running on a physical device
- Check camera permissions in Settings
- ARKit requires good lighting conditions

**Core Data Errors**
- Clear app data: Delete app and reinstall
- Check that all Core Data entities are properly configured

**Preview Not Loading**
- Clean build folder: `Cmd + Shift + K`
- Restart Xcode if previews become unresponsive

### Debug Tips
1. Use Xcode's debugging tools for Core Data issues
2. Check console output for error messages
3. Test AR features in well-lit environments

## 📊 Data Structure Overview

### Core Data Entities
```
User (authentication and profile)
├── SavedLayout (user's saved speaker configurations)
├── SpeakerReview (user's speaker reviews)
└── WishlistItem (user's wishlist)

SpeakerBrand (speaker manufacturers)
└── SpeakerModel (individual speaker models)
    ├── SpeakerReview (reviews for this model)
    └── WishlistItem (wishlist entries for this model)
```

### Key Managers
- `AuthenticationManager`: Handles login/signup/biometrics
- `SpeakerDatabaseManager`: Manages speaker data and community features
- `CameraManager`: Controls camera for room detection
- `RoomDetector`: ML-based room analysis

## 🎯 Feature Demonstrations

### For Coursework Assessment

**iOS Framework Integration**
- SwiftUI for modern UI
- Core Data for local persistence
- ARKit for augmented reality
- LocalAuthentication for biometrics
- AVFoundation for camera access

**Advanced Features**
- Machine Learning room detection
- Complex Core Data relationships
- Photo handling and storage
- Real-time AR interaction

**Code Quality**
- MVVM architecture
- Reusable components
- Comprehensive error handling
- Accessibility support

**Testing Coverage**
- Unit tests for data operations
- UI tests for user flows
- SwiftUI previews for all views

## 🔧 Build Configuration

### Required Permissions (Info.plist)
```xml
<key>NSCameraUsageDescription</key>
<string>Camera access required for AR speaker placement and room analysis</string>

<key>NSFaceIDUsageDescription</key>
<string>Face ID provides secure and convenient authentication</string>
```

### Deployment Target
- iOS 16.0 minimum
- ARKit 4.0+ features
- Compatible with iPhone 6s and newer

## 📈 Performance Notes

### Optimization Features
- Lazy loading of speaker data
- Efficient Core Data queries
- Image compression for photos
- Background processing for ML analysis

### Memory Management
- Proper disposal of AR sessions
- Image data optimization
- Core Data memory efficient queries

## 🎉 Success Metrics

After running the app, you should see:
- ✅ Smooth onboarding experience
- ✅ Functional authentication system
- ✅ Working AR speaker placement
- ✅ Comprehensive speaker database
- ✅ ML-powered room detection
- ✅ Persistent data storage
- ✅ Community review system


