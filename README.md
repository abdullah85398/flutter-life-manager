# Flutter LifeManager

A comprehensive Flutter-based life management application with intelligent planning, goal tracking, and time logging capabilities.

## Features

- **Firebase Authentication** - Email/password, Google, and Apple Sign-In
- **Goal & Project Management** - Create, track, and manage personal goals and projects
- **Fixed Commitments** - Set non-negotiable time blocks (sleep, family, etc.)
- **Intelligent Planning** - Real-time realisticness checking with suggestions
- **Time Logging** - Quick-start timers and manual time entry
- **TaskMaster Integration** - AI-powered task management and progress tracking

## Tech Stack

- **Flutter** - Cross-platform mobile development
- **Firebase** - Authentication, Firestore database, Cloud Functions
- **Riverpod** - State management and dependency injection
- **Freezed** - Immutable data classes and union types
- **TaskMaster AI** - Intelligent task planning and progress tracking

## Architecture

- **Clean Architecture** - Separation of concerns with clear layers
- **Feature-based Structure** - Organized by app features
- **Reactive Programming** - Stream-based data flow with Riverpod
- **Offline-first** - Local data persistence with cloud sync

## Project Status

✅ **Completed (4/12 major tasks):**
- Project setup & core dependencies
- Firebase authentication & user profiles
- Fixed commitments UI & data model
- Goals & projects CRUD implementation

🔄 **In Progress:**
- Planner screen & realisticness checking

⏳ **Upcoming:**
- Time logging UI
- Cloud Functions
- Insights & analytics
- Offline sync

## Getting Started

1. **Prerequisites:**
   - Flutter SDK (3.7.2+)
   - Firebase project setup
   - TaskMaster AI configuration

2. **Installation:**
   ```bash
   git clone https://github.com/abdullah85398/flutter-life-manager.git
   cd flutter-life-manager
   flutter pub get
   ```

3. **Firebase Setup:**
   - Follow the Firebase setup guide in `FIREBASE_SETUP_GUIDE.md`
   - Add your configuration files to the appropriate platform directories

4. **Run the app:**
   ```bash
   flutter run
   ```

## Documentation

- [Product Requirements Document](LifeManager_PRD_Serverless_Flutter.md)
- [Firebase Setup Guide](FIREBASE_SETUP_GUIDE.md)
- [TaskMaster Integration](WARP.md)

## Contributing

This is a personal project, but feedback and suggestions are welcome!

## License

Private project - All rights reserved.