# Build and Preview Troubleshooting Guide

## Preview Error Resolution

The "CancellationError" in Xcode previews is typically caused by:

### 1. Environment Object Dependencies
- Some views depend on `@EnvironmentObject` instances
- Previews need these objects to be properly initialized
- Fixed by creating instances in preview providers

### 2. Core Data Context Issues
- Views using `@Environment(\.managedObjectContext)` need valid context
- Use `PersistenceController.preview` for previews
- Ensure all Core Data entities are properly defined

### 3. StateObject Initialization
- `@StateObject` with complex initializers can cause preview issues
- Move complex initialization to `onAppear` for better preview support
- Use conditional initialization in views

## Quick Fixes Applied

### MainTabView
- Removed `@StateObject` for `SpeakerDatabaseManager`
- Create instance from environment context instead
- Simplified preview initialization

### DashboardView
- Made `speakerDB` optional and initialize on appear
- Added nil checks for speaker data access
- Safer preview environment

### SpeakerCommunityView
- Optional speaker database initialization
- Nil-safe data access throughout
- Simplified environment object dependencies

### Core Data Previews
- Use `PersistenceController.preview` consistently
- Create sample data for meaningful previews
- Proper entity relationship setup

## Running on Device vs Simulator

### For AR Features
- **Physical Device Required**: ARKit doesn't work in simulator
- **Camera Access**: Real device needed for ML room detection
- **Performance**: AR features perform better on device
- **Supported Devices**: iPhone 6s+, iPad (5th gen)+, iPad Pro all models

### For Community Features
- **Simulator Compatible**: Speaker database, reviews, authentication
- **Core Data**: Works in both simulator and device
- **UI Testing**: All community features work in simulator
- **Limitations**: No camera/ML features in simulator

## Build Settings

### Info.plist Requirements
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
- SwiftUI features optimized for iOS 16.0+
- Compatible with iPhone 6s and newer

## Preview Testing Strategy

### 1. Individual View Previews
- Test each view in isolation
- Use mock data for complex dependencies
- Verify UI layout and interactions

### 2. Navigation Flow Testing
- Test navigation between views
- Verify sheet presentations
- Check tab navigation

### 3. Data Integration Testing
- Test Core Data operations on device
- Verify authentication flows
- Test AR features on physical device

## Common Issues and Solutions

### Preview Won't Load
```swift
// Instead of this:
@StateObject private var manager = ComplexManager()

// Use this:
@State private var manager: ComplexManager?

// Initialize in onAppear:
.onAppear {
    if manager == nil {
        manager = ComplexManager()
    }
}
```

### Environment Object Missing
```swift
// In preview:
struct MyView_Previews: PreviewProvider {
    static var previews: some View {
        MyView()
            .environmentObject(AuthenticationManager())
            .environment(\.managedObjectContext,
                         PersistenceController.preview.container.viewContext)
    }
}
```

### Core Data Entity Issues
- Ensure all entities are defined in `.xcdatamodeld`
- Check relationships are properly configured
- Verify NSManagedObject subclasses are generated

## Testing Checklist

### Before Submitting
- [ ] All views have working previews
- [ ] App builds without warnings
- [ ] Core Data model is valid
- [ ] Authentication flow works
- [ ] AR features tested on device
- [ ] Community features work in simulator
- [ ] No force unwraps in production code
- [ ] Error handling implemented

### Performance Verification
- [ ] Smooth scrolling in speaker lists
- [ ] Fast Core Data queries
- [ ] Responsive AR placement
- [ ] Quick authentication
- [ ] Efficient image handling

## Advanced Troubleshooting

### AR Session Issues
**Problem**: AR tracking is unstable or fails to start
**Solutions**:
- Ensure good lighting conditions
- Hold device steady during initialization
- Check for magnetic interference (move away from magnets)
- Restart device if AR session fails repeatedly
- Verify device compatibility (iPhone 6s or newer required)

### Core Data Migration Issues
**Problem**: App crashes on launch with Core Data errors
**Solutions**:
- Delete and reinstall app to reset database
- Check `.xcdatamodeld` for entity configuration issues
- Verify all relationships are properly defined
- Use lightweight migration for model changes

### Authentication Problems
**Problem**: Biometric authentication fails or password login doesn't work
**Solutions**:
- Verify Face ID/Touch ID is properly set up in device settings
- Check that passwords are hashed correctly (SHA256)
- Ensure email validation is working
- Test with different user accounts

### ML Room Detection Issues
**Problem**: Room analysis fails or gives poor results
**Solutions**:
- Ensure iOS 16.0+ for Vision framework support
- Grant camera permissions
- Test in well-lit environments
- Check that Vision classification is available on device
- Verify fallback to default recommendations works

### Memory Issues
**Problem**: App crashes due to memory pressure
**Solutions**:
- Monitor AR session memory usage
- Implement proper image compression
- Use lazy loading for large datasets
- Dispose of unused AR anchors and entities
- Optimize Core Data fetch requests

## Build Optimization Tips

### Reducing Build Time
- Use incremental builds when possible
- Clean build folder regularly: `Cmd + Shift + K`
- Close unused Xcode projects
- Use SwiftUI previews sparingly during development
- Disable unnecessary build phases

### Improving Performance
- Profile with Instruments for memory leaks
- Use Core Data batch operations for large datasets
- Implement image caching for speaker photos
- Optimize AR rendering with proper anchor management
- Use background queues for heavy computations

## Xcode Configuration

### Recommended Settings
- **Swift Language Version**: 5.9
- **Build Configuration**: Debug/Release
- **Deployment Target**: iOS 18.0
- **Device Orientation**: Portrait
- **Status Bar Style**: Default

### Development Tools
- **Xcode 15.0+**: Required for iOS 16 features
- **Command Line Tools**: Latest version
- **Simulator**: iPhone 14/iPad Pro for testing
- **Physical Device**: iPhone/iPad for AR testing



