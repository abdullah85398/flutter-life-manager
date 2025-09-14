# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

**LifeManager** is a production-ready Flutter application using Dart SDK ^3.7.2. It's a mobile-first, serverless life and project accountability app with beautiful, artistic UI components. The app helps users plan focused work, track real activity, measure deviation from plans, and receive actionable insights with minimal clicks.

### Key Features (per PRD)
- Goals & Projects management with time allocation
- Fixed Commitments for realistic planning
- Real-time Realisticness Check with visual feedback
- Time Logging with timer and quick-add functionality  
- Follow-up system with manager personas
- Insights & Deviation Analysis
- Paid AI features for planning assistance
- Beautiful, artistic UI with animations and themes

## Development Commands

### Core Flutter Commands
- **Run the app**: `flutter run`
- **Run on specific platform**: `flutter run -d chrome` (web), `flutter run -d windows` (Windows), etc.
- **Hot reload**: Press `r` in the terminal after running the app, or save files in IDE
- **Hot restart**: Press `R` in the terminal after running the app
- **Build for release**: `flutter build apk` (Android), `flutter build ios` (iOS), `flutter build web` (Web)

### Development Tools
- **Install dependencies**: `flutter pub get`
- **Update dependencies**: `flutter pub upgrade`
- **Check for outdated packages**: `flutter pub outdated`
- **Analyze code**: `flutter analyze`
- **Format code**: `dart format .` or `dart format lib/`
- **Run tests**: `flutter test`
- **Run specific test**: `flutter test test/widget_test.dart`
- **Generate code coverage**: `flutter test --coverage`

### Device and Platform Management
- **List available devices**: `flutter devices`
- **Check Flutter setup**: `flutter doctor`
- **Clean build cache**: `flutter clean`

## Code Architecture

### Project Structure
```
lib/
├── main.dart                    # App entry point and root widget
└── src/
    ├── app/                     # App-level configuration
    │   ├── app.dart            # Main app widget with theming
    │   └── main_navigation.dart # Bottom navigation and routing
    ├── features/                # Feature modules
    │   ├── auth/               # Authentication screens and logic
    │   │   └── auth_screen.dart
    │   ├── goals/              # Goals management
    │   │   └── goals_screen.dart
    │   ├── splash/             # Splash screen with animations
    │   │   └── splash_screen.dart
    │   └── time_tracking/      # Time logging features
    ├── models/                  # Data models with Freezed
    │   ├── goal_model.dart
    │   └── user_model.dart
    ├── providers/               # Riverpod state management
    │   ├── auth_provider.dart
    │   └── goal_provider.dart
    ├── services/                # Business logic and API calls
    │   ├── auth_service.dart
    │   ├── firestore_service.dart
    │   └── goal_service.dart
    ├── theme/                   # UI theming and styling
    │   └── theme.dart
    └── widgets/                 # Reusable UI components
        └── custom_text_field.dart

test/
└── widget_test.dart            # Widget tests
```

### Key Technologies
- **Flutter 3.7+** with Dart SDK ^3.7.2
- **Riverpod** for state management
- **Firebase** (Auth, Firestore, Cloud Functions)
- **Freezed** for immutable data models
- **Go Router** for navigation
- **Material 3** design system

## Firebase Integration

### Services
- **Authentication**: Email/password and Google Sign-In
- **Firestore**: NoSQL database for user data, goals, and time logs
- **Cloud Functions**: Server-side logic for analytics and notifications

### Configuration Files
- `android/app/google-services.json` (Android)
- `ios/Runner/GoogleService-Info.plist` (iOS)
- `lib/firebase_options.dart` (Generated configuration)

### Setup Commands
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Configure Firebase for Flutter
flutterfire configure

# Deploy Cloud Functions
cd functions
npm install
npm run build
firebase deploy --only functions
```

## Development Workflow

### Getting Started
1. **Clone and setup**:
   ```bash
   git clone <repository-url>
   cd flutter_app
   flutter pub get
   ```

2. **Firebase setup** (if not done):
   ```bash
   flutterfire configure
   ```

3. **Run the app**:
   ```bash
   flutter run
   ```

### Code Quality
- **Linting**: Uses `flutter_lints` with custom rules in `analysis_options.yaml`
- **Formatting**: Run `dart format .` before committing
- **Testing**: Write widget tests for UI components and unit tests for business logic

### State Management Patterns
- Use **Riverpod providers** for global state
- **StateNotifier** for complex state logic
- **FutureProvider** for async data fetching
- **StreamProvider** for real-time Firebase data

### UI Development Guidelines
- Follow **Material 3** design principles
- Use **custom themes** defined in `src/theme/theme.dart`
- Implement **smooth animations** with Flutter Animate
- Ensure **responsive design** for different screen sizes
- Maintain **accessibility** standards

## Common Tasks

### Adding a New Feature
1. Create feature directory in `lib/src/features/`
2. Add screen widgets, providers, and services
3. Update navigation in `main_navigation.dart`
4. Add tests in `test/` directory

### Adding a New Model
1. Create model file in `lib/src/models/`
2. Use Freezed for immutable data classes
3. Add JSON serialization if needed
4. Update related services and providers

### Debugging Tips
- Use **Flutter Inspector** for widget tree analysis
- Enable **Firebase Debug View** for real-time data
- Use **Riverpod DevTools** for state inspection
- Check **Flutter logs** with `flutter logs`

## Deployment

### Android
```bash
flutter build apk --release
# or for app bundle
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
# Then use Xcode to archive and upload
```

### Web
```bash
flutter build web --release
# Deploy to Firebase Hosting
firebase deploy --only hosting
```

## Troubleshooting

### Common Issues
1. **Build errors**: Run `flutter clean && flutter pub get`
2. **Firebase issues**: Check configuration files and run `flutterfire configure`
3. **State not updating**: Verify Riverpod provider setup
4. **Navigation issues**: Check Go Router configuration

### Performance
- Use **const constructors** where possible
- Implement **lazy loading** for large lists
- Optimize **image assets** and use appropriate formats
- Profile with **Flutter DevTools** performance tab

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Riverpod Documentation](https://riverpod.dev/)
- [Firebase for Flutter](https://firebase.flutter.dev/)
- [Material 3 Design](https://m3.material.io/)
- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)