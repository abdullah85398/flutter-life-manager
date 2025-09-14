# Firebase Setup Guide for LifeManager App

## Current Status
- ✅ Firebase dependencies added to pubspec.yaml
- ✅ Firebase services implemented (auth_service.dart, firestore_service.dart, firebase_service.dart)
- ❌ Firebase project not created
- ❌ Configuration files missing (google-services.json, GoogleService-Info.plist)
- ❌ Firebase initialization commented out in main.dart

## Steps to Complete Firebase Setup

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter project name: `lifemanager-app` (or your preferred name)
4. Enable Google Analytics (recommended)
5. Choose or create a Google Analytics account
6. Click "Create project"

### 2. Register Android App
1. In Firebase Console, click "Add app" and select Android
2. Enter Android package name: `com.example.flutterApp` (from AndroidManifest.xml)
3. Enter app nickname: `LifeManager Android`
4. Leave SHA-1 empty for now (can add later for release)
5. Click "Register app"
6. Download `google-services.json`
7. Place the file in: `android/app/google-services.json`

### 3. Register iOS App
1. In Firebase Console, click "Add app" and select iOS
2. Enter iOS bundle ID: `com.example.flutterApp` (from Runner project)
3. Enter app nickname: `LifeManager iOS`
4. Leave App Store ID empty for now
5. Click "Register app"
6. Download `GoogleService-Info.plist`
7. Place the file in: `ios/Runner/GoogleService-Info.plist`

### 4. Update Android Configuration
Add to `android/app/build.gradle.kts` (after plugins block):
```kotlin
apply(plugin = "com.google.gms.google-services")
```

Add to `android/build.gradle.kts` (in dependencies block):
```kotlin
classpath("com.google.gms:google-services:4.4.0")
```

### 5. Update iOS Configuration
1. Open `ios/Runner.xcworkspace` in Xcode
2. Right-click on `Runner` in the project navigator
3. Select "Add Files to Runner"
4. Navigate to `ios/Runner/GoogleService-Info.plist`
5. Make sure "Copy items if needed" is checked
6. Make sure "Runner" target is selected
7. Click "Add"

### 6. Enable Firebase Services
1. In Firebase Console, go to "Authentication"
2. Click "Get started"
3. Go to "Sign-in method" tab
4. Enable "Email/Password" and "Google" providers
5. For Google sign-in, add your SHA-1 fingerprint (for release builds)

6. Go to "Firestore Database"
7. Click "Create database"
8. Choose "Start in test mode" (for development)
9. Select a location close to your users
10. Click "Done"

### 7. Update main.dart
Uncomment Firebase initialization in `main.dart`:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const LifeManagerApp());
}
```

### 8. Generate Firebase Options
Run the following command to generate Firebase configuration:
```bash
flutterfire configure
```

This will:
- Create `lib/firebase_options.dart`
- Update configuration files
- Set up Firebase for all platforms

## Testing Firebase Setup

### Test Authentication
1. Run the app: `flutter run`
2. Try to sign up with email/password
3. Check Firebase Console > Authentication > Users
4. Verify user appears in the list

### Test Firestore
1. Create a goal in the app
2. Check Firebase Console > Firestore Database
3. Verify data appears in the `goals` collection

## Troubleshooting

### Common Issues
1. **Build errors**: Run `flutter clean && flutter pub get`
2. **iOS build issues**: Delete `ios/Podfile.lock` and run `cd ios && pod install`
3. **Android build issues**: Check `android/app/build.gradle.kts` has correct configuration
4. **Firebase not initialized**: Ensure `Firebase.initializeApp()` is called before `runApp()`

### Debug Commands
```bash
# Check Flutter setup
flutter doctor

# Clean and rebuild
flutter clean
flutter pub get
flutter run

# Check Firebase configuration
flutterfire configure --project=your-project-id
```

## Security Rules (Production)

Before going to production, update Firestore security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Goals are user-specific
    match /goals/{goalId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
    
    // Time logs are user-specific
    match /timeLogs/{logId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
  }
}
```