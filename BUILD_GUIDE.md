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

### For Community Features
- **Simulator Compatible**: Speaker database, reviews, authentication
- **Core Data**: Works in both simulator and device
- **UI Testing**: All community features work in simulator

## Build Settings

### Info.plist Requirements
```xml
<key>NSCameraUsageDescription</key>
<string>Camera access required for AR speaker placement and room analysis</string>

<key>NSFaceIDUsageDescription</key>
<string>Face ID provides secure authentication</string>
```

### Deployment Target
- iOS 16.0 minimum
- ARKit requires iOS 11.0+, but advanced features need 16.0+
- SwiftUI features optimized for iOS 16.0+

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
- Ensure all entities are defined in .xcdatamodeld
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

The app is now configured to work reliably in both simulator (for community features) and device (for AR features) with proper preview support.
