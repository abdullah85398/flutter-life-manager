import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/fixed_commitments.dart';
import '../models/user_model.dart';
import '../models/daily_plan.dart';
import '../models/fixed_commitment.dart';
import '../models/goal_model.dart';
import '../models/project_model.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection paths
  static const String _usersCollection = 'users';
  static const String _profileSettingsCollection = 'profileSettings';
  static const String _dailyPlansCollection = 'dailyPlans';
  static const String _fixedCommitmentsCollection = 'fixedCommitments';
  static const String _goalsCollection = 'goals';
  static const String _projectsCollection = 'projects';

  /// Gets the current user's ID, throws if not authenticated
  static String get _currentUserId {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user.uid;
  }

  // MARK: - User Profile Operations

  /// Stream user profile data
  static Stream<UserModel?> streamUserProfile({String? userId}) {
    final uid = userId ?? _currentUserId;
    return _firestore
        .collection(_usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    });
  }

  /// Get user profile data
  static Future<UserModel?> getUserProfile({String? userId}) async {
    try {
      final uid = userId ?? _currentUserId;
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .get();

      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      rethrow;
    }
  }

  /// Update user profile
  static Future<void> updateUserProfile(UserModel user) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(user.id)
          .update(user.updated().toJson());
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      rethrow;
    }
  }

  // MARK: - Fixed Commitments Operations

  /// Gets the fixed commitments for the current user
  static Future<FixedCommitments> getFixedCommitments({String? userId}) async {
    try {
      final uid = userId ?? _currentUserId;
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .collection(_profileSettingsCollection)
          .doc('fixedCommitments')
          .get();

      if (doc.exists && doc.data() != null) {
        return FixedCommitments.fromJson(doc.data()!);
      } else {
        // Return default values if no data exists
        return FixedCommitments.defaultValues();
      }
    } catch (e) {
      debugPrint('Error getting fixed commitments: $e');
      rethrow;
    }
  }

  /// Updates the fixed commitments for the current user
  static Future<void> updateFixedCommitments(FixedCommitments commitments, {String? userId}) async {
    try {
      final uid = userId ?? _currentUserId;
      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .collection(_profileSettingsCollection)
          .doc('fixedCommitments')
          .set(commitments.toJson(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error updating fixed commitments: $e');
      rethrow;
    }
  }

  /// Stream fixed commitments for real-time updates
  static Stream<FixedCommitments> streamFixedCommitments({String? userId}) {
    final uid = userId ?? _currentUserId;
    return _firestore
        .collection(_usersCollection)
        .doc(uid)
        .collection(_profileSettingsCollection)
        .doc('fixedCommitments')
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        return FixedCommitments.fromJson(doc.data()!);
      } else {
        return FixedCommitments.defaultValues();
      }
    });
  }

  // MARK: - Goals Operations

  /// Stream all goals for the current user
  static Stream<List<GoalModel>> streamGoals({String? userId}) {
    final uid = userId ?? _currentUserId;
    return _firestore
        .collection(_usersCollection)
        .doc(uid)
        .collection(_goalsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => GoalModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  /// Get all goals for the current user
  static Future<List<GoalModel>> getGoals({String? userId}) async {
    try {
      final uid = userId ?? _currentUserId;
      final snapshot = await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .collection(_goalsCollection)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => GoalModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      debugPrint('Error getting goals: $e');
      rethrow;
    }
  }

  /// Add a new goal
  static Future<String> addGoal(GoalModel goal, {String? userId}) async {
    try {
      final uid = userId ?? _currentUserId;
      final docRef = await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .collection(_goalsCollection)
          .add(goal.toJson());
      
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding goal: $e');
      rethrow;
    }
  }

  /// Update an existing goal
  static Future<void> updateGoal(GoalModel goal, {String? userId}) async {
    try {
      final uid = userId ?? _currentUserId;
      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .collection(_goalsCollection)
          .doc(goal.id)
          .update(goal.toJson());
    } catch (e) {
      debugPrint('Error updating goal: $e');
      rethrow;
    }
  }

  /// Delete a goal
  static Future<void> deleteGoal(String goalId, {String? userId}) async {
    try {
      final uid = userId ?? _currentUserId;
      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .collection(_goalsCollection)
          .doc(goalId)
          .delete();
    } catch (e) {
      debugPrint('Error deleting goal: $e');
      rethrow;
    }
  }

  // MARK: - Projects Operations

  /// Stream all projects for the current user
  static Stream<List<ProjectModel>> streamProjects({String? userId}) {
    final uid = userId ?? _currentUserId;
    return _firestore
        .collection(_usersCollection)
        .doc(uid)
        .collection(_projectsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ProjectModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  /// Get all projects for the current user
  static Future<List<ProjectModel>> getProjects({String? userId}) async {
    try {
      final uid = userId ?? _currentUserId;
      final snapshot = await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .collection(_projectsCollection)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ProjectModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      debugPrint('Error getting projects: $e');
      rethrow;
    }
  }

  /// Add a new project
  static Future<String> addProject(ProjectModel project, {String? userId}) async {
    try {
      final uid = userId ?? _currentUserId;
      final docRef = await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .collection(_projectsCollection)
          .add(project.toJson());
      
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding project: $e');
      rethrow;
    }
  }

  /// Update an existing project
  static Future<void> updateProject(ProjectModel project, {String? userId}) async {
    try {
      final uid = userId ?? _currentUserId;
      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .collection(_projectsCollection)
          .doc(project.id)
          .update(project.toJson());
    } catch (e) {
      debugPrint('Error updating project: $e');
      rethrow;
    }
  }

  /// Delete a project
  static Future<void> deleteProject(String projectId, {String? userId}) async {
    try {
      final uid = userId ?? _currentUserId;
      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .collection(_projectsCollection)
          .doc(projectId)
          .delete();
    } catch (e) {
      debugPrint('Error deleting project: $e');
      rethrow;
    }
  }

  // MARK: - Daily Plans Operations

  /// Get daily plan for a specific date
  static Future<DailyPlan?> getDailyPlan(DateTime date, {String? userId}) async {
    try {
      final uid = userId ?? _currentUserId;
      final dateKey = _formatDateKey(date);
      
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .collection(_dailyPlansCollection)
          .doc(dateKey)
          .get();

      if (doc.exists && doc.data() != null) {
        return DailyPlan.fromJson({...doc.data()!, 'id': doc.id});
      }
      return null;
    } catch (e) {
      debugPrint('Error getting daily plan: $e');
      rethrow;
    }
  }

  /// Save daily plan
  static Future<void> saveDailyPlan(DailyPlan plan, {String? userId}) async {
    try {
      final uid = userId ?? _currentUserId;
      final dateKey = _formatDateKey(plan.date);
      
      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .collection(_dailyPlansCollection)
          .doc(dateKey)
          .set(plan.toJson(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving daily plan: $e');
      rethrow;
    }
  }

  /// Stream daily plan for a specific date
  static Stream<DailyPlan?> streamDailyPlan(DateTime date, {String? userId}) {
    final uid = userId ?? _currentUserId;
    final dateKey = _formatDateKey(date);
    
    return _firestore
        .collection(_usersCollection)
        .doc(uid)
        .collection(_dailyPlansCollection)
        .doc(dateKey)
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        return DailyPlan.fromJson({...doc.data()!, 'id': doc.id});
      }
      return null;
    });
  }

  /// Get daily plans for a date range
  static Future<List<DailyPlan>> getDailyPlansInRange(
    DateTime startDate,
    DateTime endDate, {
    String? userId,
  }) async {
    try {
      final uid = userId ?? _currentUserId;
      final startKey = _formatDateKey(startDate);
      final endKey = _formatDateKey(endDate);
      
      final snapshot = await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .collection(_dailyPlansCollection)
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: startKey)
          .where(FieldPath.documentId, isLessThanOrEqualTo: endKey)
          .get();

      return snapshot.docs
          .map((doc) => DailyPlan.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      debugPrint('Error getting daily plans in range: $e');
      rethrow;
    }
  }

  // MARK: - Helper Methods

  /// Format date as document key (YYYY-MM-DD)
  static String _formatDateKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
           '${date.month.toString().padLeft(2, '0')}-'
           '${date.day.toString().padLeft(2, '0')}';
  }

  /// Batch operations for better performance
  static WriteBatch batch() => _firestore.batch();

  /// Commit batch operations
  static Future<void> commitBatch(WriteBatch batch) => batch.commit();
}