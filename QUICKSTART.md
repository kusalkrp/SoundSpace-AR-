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
1. **Onboarding**: Swipe through introduction screens
2. **Sign Up**: Create your account with email/password
3. **Dashboard**: Explore the main hub with quick actions

## 🏠 Key App Flows

### AR Speaker Setup Flow
```
Dashboard → "Start AR Setup" → Room Selection → System Selection → AR Placement → Save Layout
```

### Smart Room Detection Flow
```
Dashboard → "Smart Room Scan" → Camera Analysis → AI Recommendations → AR Setup
```

### Speaker Community Flow
```
Dashboard → "Browse Speakers" → Search/Filter → Speaker Details → Add Review/Wishlist
```

## 📱 Testing Features

### Core Features to Test
1. **Authentication**
   - Sign up with new account
   - Login with existing account
   - Test biometric authentication (if available)

2. **AR Setup**
   - Select different room types (Living Room, Bedroom, Hall)
   - Choose audio systems (2.1, 5.1, 7.1)
   - Launch AR view and place speakers

3. **Speaker Community**
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

The app demonstrates a complete iOS ecosystem integration with modern frameworks and advanced features suitable for coursework evaluation.

---

**Ready to explore? Start with the Dashboard and try each feature!** 🎧📱
