# LifeManager — Production-ready PRD (Serverless Flutter + Firebase)

> **Derived from the user's example PRD template.** (source: user-provided example PRD). 

---

## 1. Overview

**Product name:** LifeManager (working)

**One-liner:** A mobile-first, serverless life and project accountability app that helps users plan focused work, track real activity (including travel/eating/family), measure deviation from plans, and receive actionable insights — all with minimal clicks and beautiful, distraction-free UX.

**Target users / personas:** busy professionals, students, freelancers and project leads who want strict-but-kind accountability and data-driven insight into how they spend time.

**Value proposition:** deliver relentless, low-friction accountability and clear deviation analytics while keeping user privacy and minimal manual overhead at the core.

---

## 2. Core features

### 2.1 Goals & Projects

- Create Goals and Projects (A/B/C/D etc.) with planned hours per day and priority. Optionally link Projects to Goals.
- Why: central contract between user intent and measurement.
- UX: choose quick presets or custom hours. Minimal fields: title, planned_hours_per_day, priority, recurrence.

### 2.2 Fixed Commitments

- User sets non-negotiable time blocks (sleep, family, commute, eating). These are used to compute realistic available time.
- Why: produce realisticness checks and prevent overcommit.
- UX: one-screen sliders (8h sleep, 2h family etc.) with example presets (weekday/weekend)

### 2.3 Planner & Realisticness Check

- When the user defines daily planned hours across projects, the app immediately computes `available_minutes` vs `planned_minutes` and shows a Realisticness Meter (Green/Amber/Red) and suggested fixes (Auto-scale, Reschedule, Buffer).
- Real-time arithmetic and suggested redistributions included.

### 2.4 Time Logging & Follow-ups

- Quick-start/stop timer and Quick-add logs (preset categories). End-of-day follow-up prompt (modal) with Done / Partly / Missed options and quick causes (Travel / Family / Friends / Outing / Distraction / Health / Other).
- Follow-ups configurable cadence: once-a-day or multiple periodic checks.
- Strict manager persona modes (Gentle / Neutral / Strict) with different snooze allowances and escalation rules.

### 2.5 Insights & Deviation Analysis

- Per-day and rolling windows (7/30/90 days) with Compliance %, Deviation Index, Focus score, and top causes. Root-cause ranking by excess time in categories.
- Visuals: stacked timeline, donut for time breakdown, trend arrows, and actionable recommendations (reschedule, micro-sessions).

### 2.6 Paid AI features (Generative)

- Smart planning suggestions based on historical data and current commitments
- Automated time block optimization
- Personalized productivity insights and recommendations
- Natural language goal creation and time estimation

---

## 3. Technical Architecture

### 3.1 Frontend (Flutter)

**Framework:** Flutter 3.7+ with Dart SDK ^3.7.2

**State Management:** Riverpod for reactive state management

**Key Dependencies:**
- `flutter_riverpod`: State management
- `firebase_core`, `firebase_auth`, `cloud_firestore`: Backend services
- `google_sign_in`: Authentication
- `freezed`, `json_annotation`: Data models
- `go_router`: Navigation
- `shared_preferences`: Local storage
- `flutter_animate`: Animations

**Architecture Pattern:** Clean Architecture with feature-based folder structure

```
lib/
├── main.dart
└── src/
    ├── app/                 # App-level configuration
    ├── features/            # Feature modules
    │   ├── auth/
    │   ├── goals/
    │   ├── time_tracking/
    │   └── insights/
    ├── models/              # Data models
    ├── providers/           # Riverpod providers
    ├── services/            # Business logic services
    ├── theme/               # UI theming
    └── widgets/             # Reusable UI components
```

### 3.2 Backend (Firebase)

**Authentication:** Firebase Auth with email/password and Google Sign-In

**Database:** Cloud Firestore with the following collections:
- `users`: User profiles and preferences
- `goals`: User goals and projects
- `time_logs`: Time tracking entries
- `fixed_commitments`: Non-negotiable time blocks
- `insights`: Computed analytics and metrics

**Cloud Functions:** TypeScript-based functions for:
- Data aggregation and insights computation
- Scheduled notifications and follow-ups
- AI-powered recommendations (paid features)

**Security:** Firestore security rules ensuring users can only access their own data

### 3.3 Data Models

**User Model:**
```dart
class UserPreferences {
  final String userId;
  final String displayName;
  final String email;
  final ManagerTone managerTone;
  final bool notificationsEnabled;
  final TimeOfDay followUpTime;
}
```

**Goal Model:**
```dart
class Goal {
  final String id;
  final String userId;
  final String title;
  final String description;
  final GoalPriority priority;
  final GoalStatus status;
  final double plannedHoursPerDay;
  final GoalRecurrence recurrence;
  final DateTime createdAt;
  final DateTime? deadline;
}
```

**Time Log Model:**
```dart
class TimeLog {
  final String id;
  final String userId;
  final String goalId;
  final DateTime startTime;
  final DateTime endTime;
  final String category;
  final String? notes;
}
```

---

## 4. User Experience Design

### 4.1 Design Principles

- **Minimal clicks:** Every action should be achievable in 3 taps or less
- **Beautiful & artistic:** Gradient backgrounds, smooth animations, modern Material 3 design
- **Distraction-free:** Clean interfaces with purposeful white space
- **Data-driven:** Visual feedback for all metrics and progress

### 4.2 Key Screens

1. **Splash Screen:** Animated logo with smooth transition
2. **Authentication:** Clean sign-in/sign-up with Google integration
3. **Dashboard:** Overview of today's goals, progress, and quick actions
4. **Goals Management:** Create, edit, and organize goals with visual priority indicators
5. **Time Tracking:** Large start/stop buttons with category quick-add
6. **Insights:** Rich visualizations of productivity patterns and trends
7. **Settings:** User preferences, manager tone, and notification settings

### 4.3 Visual Design

**Color Scheme:** 
- Primary: Deep blue gradient (#1E3A8A to #3B82F6)
- Secondary: Warm accent colors for CTAs
- Background: Subtle gradients with artistic flair
- Text: High contrast for accessibility

**Typography:** 
- Headers: Bold, modern sans-serif
- Body: Clean, readable font with proper line spacing
- Data: Monospace for numbers and metrics

**Animations:**
- Smooth page transitions
- Micro-interactions for button presses
- Progress indicators with easing curves
- Loading states with skeleton screens

---

## 5. Development Phases

### Phase 1: Core MVP (4-6 weeks)
- User authentication (email/password, Google)
- Basic goal creation and management
- Simple time tracking with start/stop timer
- Basic dashboard with today's overview
- Firebase integration and data persistence

### Phase 2: Enhanced Features (3-4 weeks)
- Fixed commitments and realisticness check
- Follow-up system with manager personas
- Basic insights and progress visualization
- Improved UI/UX with animations
- Notification system

### Phase 3: Advanced Analytics (3-4 weeks)
- Comprehensive insights dashboard
- Deviation analysis and root cause identification
- Historical data visualization
- Export functionality
- Performance optimizations

### Phase 4: AI Features (4-6 weeks)
- Smart planning suggestions
- Automated time optimization
- Natural language processing for goal creation
- Personalized recommendations
- Premium subscription model

---

## 6. Success Metrics

### 6.1 User Engagement
- Daily active users (DAU)
- Session duration and frequency
- Goal completion rates
- Time tracking consistency

### 6.2 Product Metrics
- User retention (1-day, 7-day, 30-day)
- Feature adoption rates
- Time to first goal creation
- Average goals per user

### 6.3 Business Metrics
- User acquisition cost (UAC)
- Lifetime value (LTV)
- Premium conversion rate
- Monthly recurring revenue (MRR)

---

## 7. Risk Assessment

### 7.1 Technical Risks
- Firebase scaling limitations
- Flutter performance on older devices
- Data synchronization issues
- Third-party service dependencies

**Mitigation:** Thorough testing, performance monitoring, fallback mechanisms

### 7.2 User Experience Risks
- Complexity overwhelming users
- Notification fatigue
- Data privacy concerns
- Platform-specific UI inconsistencies

**Mitigation:** User testing, progressive disclosure, clear privacy policy, platform-specific optimizations

### 7.3 Business Risks
- Market competition
- User acquisition challenges
- Monetization difficulties
- Regulatory compliance

**Mitigation:** Competitive analysis, marketing strategy, multiple revenue streams, legal consultation

---

## 8. Future Roadmap

### 8.1 Short-term (3-6 months)
- Team collaboration features
- Advanced reporting and analytics
- Integration with calendar apps
- Wearable device support

### 8.2 Medium-term (6-12 months)
- Web application version
- API for third-party integrations
- Advanced AI coaching features
- Enterprise/team plans

### 8.3 Long-term (12+ months)
- Desktop applications
- Marketplace for productivity templates
- Community features and challenges
- International expansion

---

## 9. Conclusion

LifeManager represents a comprehensive solution for personal productivity and accountability, combining the power of Flutter's cross-platform capabilities with Firebase's serverless architecture. The focus on beautiful, minimal UX paired with data-driven insights positions it as a premium productivity tool for serious users who want to optimize their time and achieve their goals.

The phased development approach ensures rapid iteration and user feedback incorporation, while the technical architecture provides scalability and maintainability for long-term success.