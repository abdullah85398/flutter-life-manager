# Firebase Setup Completion Guide

## ✅ What Has Been Completed

### 1. Android Configuration
- ✅ Updated `android/build.gradle.kts` with Google Services plugin
- ✅ Updated `android/app/build.gradle.kts` with:
  - Google Services plugin application
  - Firebase BoM and dependencies (Auth, Firestore, Analytics)
- ✅ Created placeholder `android/app/google-services.json`

### 2. iOS Configuration
- ✅ Created placeholder `ios/Runner/GoogleService-Info.plist`

### 3. Flutter App Configuration
- ✅ Updated `lib/main.dart` to initialize Firebase
- ✅ Firebase dependencies already installed in `pubspec.yaml`

### 4. CI/CD Setup
- ✅ Created GitHub Actions workflows for Flutter and Firebase Functions
- ✅ Created basic Cloud Functions structure with TypeScript

## 🔧 What You Need to Do

### Step 1: Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter your project name (e.g., "Life Manager App")
4. Enable Google Analytics (recommended)
5. Complete project creation

### Step 2: Configure Authentication
1. In Firebase Console, go to "Authentication" → "Sign-in method"
2. Enable the following providers:
   - **Email/Password** (for basic auth)
   - **Google** (for social login)
   - **Anonymous** (optional, for guest users)

### Step 3: Configure Firestore Database
1. Go to "Firestore Database" → "Create database"
2. Choose "Start in test mode" (we'll configure security rules later)
3. Select your preferred location

### Step 4: Download Configuration Files

#### For Android:
1. Go to Project Settings → General → Your apps
2. Click on Android app or "Add app" if not exists
3. Register app with package name: `com.example.flutter_app`
4. Download `google-services.json`
5. Replace the placeholder file at `android/app/google-services.json`

#### For iOS:
1. In Project Settings → General → Your apps
2. Click on iOS app or "Add app" if not exists
3. Register app with bundle ID: `com.example.flutterApp`
4. Download `GoogleService-Info.plist`
5. Replace the placeholder file at `ios/Runner/GoogleService-Info.plist`

### Step 5: Configure Firestore Security Rules
Replace the default rules with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Allow access to user's subcollections
      match /{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    // Public data (if any)
    match /public/{document} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

### Step 6: Test the Setup
1. Run `flutter clean`
2. Run `flutter pub get`
3. Run the app: `flutter run`
4. Try signing up/in to test Firebase Auth
5. Check Firestore console to see if user data is created

## 🚀 Optional Enhancements

### Cloud Functions (Already Set Up)
The project includes a basic Cloud Functions setup in the `functions/` directory:
- TypeScript configuration
- Basic user creation trigger
- GitHub Actions deployment workflow

To deploy:
1. Install Firebase CLI: `npm install -g firebase-tools`
2. Login: `firebase login`
3. Deploy: `firebase deploy --only functions`

### Analytics
Firebase Analytics is already configured and will start collecting data automatically.

### Crashlytics (Optional)
To add crash reporting:
1. Add to `pubspec.yaml`:
   ```yaml
   firebase_crashlytics: ^3.4.9
   ```
2. Initialize in `main.dart`:
   ```dart
   await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
   ```

## 🔍 Troubleshooting

### Common Issues:
1. **Build errors**: Make sure configuration files are in the correct locations
2. **Auth not working**: Verify SHA-1 fingerprints are added to Firebase project
3. **Firestore permission denied**: Check security rules and user authentication

### Getting SHA-1 Fingerprint:
```bash
# For debug builds
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# For release builds (when you have a release keystore)
keytool -list -v -keystore /path/to/your/keystore.jks -alias your-alias
```

## 📱 Next Steps
Once Firebase is configured:
1. Test user registration and login
2. Verify Firestore data creation
3. Test goal creation and management
4. Configure push notifications (optional)
5. Set up analytics events (optional)

---

**Note**: This setup provides a solid foundation for the LifeManager app with user authentication, data storage, and cloud functions ready for deployment.