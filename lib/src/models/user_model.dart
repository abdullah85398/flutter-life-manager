// import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Temporarily commented out for build issues
// part 'user_model.freezed.dart';
// part 'user_model.g.dart';

/// Manager persona types for follow-up tone
enum ManagerTone {
  gentle,
  neutral,
  strict,
}

/// User preferences for behavior and interaction
class UserPreferences {
  final ManagerTone tone;
  final int strictnessLevel; // 1-10 scale
  final bool dailyReminders;
  final bool weeklyInsights;
  final String followUpCadence; // 'once_a_day', 'multiple_checks', 'end_of_day'

  const UserPreferences({
    this.tone = ManagerTone.neutral,
    this.strictnessLevel = 5,
    this.dailyReminders = true,
    this.weeklyInsights = true,
    this.followUpCadence = 'end_of_day',
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      tone: ManagerTone.values.firstWhere(
        (e) => e.toString().split('.').last == json['tone'],
        orElse: () => ManagerTone.neutral,
      ),
      strictnessLevel: json['strictnessLevel'] ?? 5,
      dailyReminders: json['dailyReminders'] ?? true,
      weeklyInsights: json['weeklyInsights'] ?? true,
      followUpCadence: json['followUpCadence'] ?? 'end_of_day',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tone': tone.toString().split('.').last,
      'strictnessLevel': strictnessLevel,
      'dailyReminders': dailyReminders,
      'weeklyInsights': weeklyInsights,
      'followUpCadence': followUpCadence,
    };
  }

  UserPreferences copyWith({
    ManagerTone? tone,
    int? strictnessLevel,
    bool? dailyReminders,
    bool? weeklyInsights,
    String? followUpCadence,
  }) {
    return UserPreferences(
      tone: tone ?? this.tone,
      strictnessLevel: strictnessLevel ?? this.strictnessLevel,
      dailyReminders: dailyReminders ?? this.dailyReminders,
      weeklyInsights: weeklyInsights ?? this.weeklyInsights,
      followUpCadence: followUpCadence ?? this.followUpCadence,
    );
  }
}

/// User model for the LifeManager app
class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String? photoURL;
  final UserPreferences preferences;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isOnboardingComplete;
  final String? timezone;
  final Map<String, dynamic>? metadata;

  const UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoURL,
    this.preferences = const UserPreferences(),
    required this.createdAt,
    required this.updatedAt,
    this.isOnboardingComplete = false,
    this.timezone,
    this.metadata,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      photoURL: json['photoURL'],
      preferences: json['preferences'] != null
          ? UserPreferences.fromJson(json['preferences'])
          : const UserPreferences(),
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isOnboardingComplete: json['isOnboardingComplete'] ?? false,
      timezone: json['timezone'],
      metadata: json['metadata']?.cast<String, dynamic>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'preferences': preferences.toJson(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isOnboardingComplete': isOnboardingComplete,
      'timezone': timezone,
      'metadata': metadata,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoURL,
    UserPreferences? preferences,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isOnboardingComplete,
    String? timezone,
    Map<String, dynamic>? metadata,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isOnboardingComplete: isOnboardingComplete ?? this.isOnboardingComplete,
      timezone: timezone ?? this.timezone,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.id == id &&
        other.email == email &&
        other.displayName == displayName &&
        other.photoURL == photoURL &&
        other.preferences == preferences &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.isOnboardingComplete == isOnboardingComplete &&
        other.timezone == timezone;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      email,
      displayName,
      photoURL,
      preferences,
      createdAt,
      updatedAt,
      isOnboardingComplete,
      timezone,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, displayName: $displayName, isOnboardingComplete: $isOnboardingComplete)';
  }

  /// Create a new user model with current timestamp
  factory UserModel.create({
    required String id,
    required String email,
    required String displayName,
    String? photoURL,
    UserPreferences? preferences,
    String? timezone,
  }) {
    final now = DateTime.now();
    return UserModel(
      id: id,
      email: email,
      displayName: displayName,
      photoURL: photoURL,
      preferences: preferences ?? const UserPreferences(),
      createdAt: now,
      updatedAt: now,
      timezone: timezone,
    );
  }

  /// Update the model with new timestamp
  UserModel updated() {
    return copyWith(updatedAt: DateTime.now());
  }

  /// Mark onboarding as complete
  UserModel completeOnboarding() {
    return copyWith(
      isOnboardingComplete: true,
      updatedAt: DateTime.now(),
    );
  }
}