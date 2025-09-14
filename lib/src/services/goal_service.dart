import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/goal_model.dart';
import '../models/user_model.dart';
import 'firebase_service.dart';

/// Service for managing goals in Firestore
class GoalService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Get goals collection reference for a user
  static CollectionReference<Map<String, dynamic>> _getGoalsCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('goals');
  }

  /// Create a new goal
  static Future<String> createGoal({
    required String userId,
    required Goal goal,
  }) async {
    try {
      final goalData = goal.toFirestore();
      goalData['createdAt'] = FieldValue.serverTimestamp();
      goalData['updatedAt'] = FieldValue.serverTimestamp();
      
      final docRef = await _getGoalsCollection(userId).add(goalData);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create goal: $e');
    }
  }

  /// Get all goals for a user
  static Future<List<Goal>> getGoals(String userId) async {
    try {
      final snapshot = await _getGoalsCollection(userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => Goal.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get goals: $e');
    }
  }

  /// Get active goals for a user
  static Future<List<Goal>> getActiveGoals(String userId) async {
    try {
      final snapshot = await _getGoalsCollection(userId)
          .where('isActive', isEqualTo: true)
          .where('status', isNotEqualTo: 'completed')
          .orderBy('priority', descending: true)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => Goal.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get active goals: $e');
    }
  }

  /// Get goals stream for real-time updates
  static Stream<List<GoalModel>> getGoalsStream(String userId) {
    return _getGoalsCollection(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GoalModel.fromJson({
                  'id': doc.id,
                  ...doc.data(),
                }))
            .toList());
  }

  /// Update an existing goal
  static Future<void> updateGoal({
    required String userId,
    required String goalId,
    required Goal goal,
  }) async {
    try {
      final goalData = goal.toFirestore();
      goalData['updatedAt'] = FieldValue.serverTimestamp();
      
      await _getGoalsCollection(userId).doc(goalId).update(goalData);
    } catch (e) {
      throw Exception('Failed to update goal: $e');
    }
  }

  /// Delete a goal
  static Future<void> deleteGoal({
    required String userId,
    required String goalId,
  }) async {
    try {
      await _getGoalsCollection(userId).doc(goalId).delete();
    } catch (e) {
      throw Exception('Failed to delete goal: $e');
    }
  }

  /// Toggle goal completion status
  static Future<void> toggleGoalCompletion({
    required String userId,
    required String goalId,
  }) async {
    try {
      final docRef = _getGoalsCollection(userId).doc(goalId);
      final doc = await docRef.get();
      
      if (!doc.exists) {
        throw Exception('Goal not found');
      }
      
      final currentStatus = doc.data()?['status'] ?? 'notStarted';
      final newStatus = currentStatus == 'completed' ? 'notStarted' : 'completed';
      final completedAt = newStatus == 'completed' ? FieldValue.serverTimestamp() : null;
      
      await docRef.update({
        'status': newStatus,
        'completedAt': completedAt,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to toggle goal completion: $e');
    }
  }

  /// Archive a goal (soft delete)
  static Future<void> archiveGoal({
    required String userId,
    required String goalId,
  }) async {
    try {
      await _getGoalsCollection(userId).doc(goalId).update({
        'isActive': false,
        'archivedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to archive goal: $e');
    }
  }

  /// Get goals by priority
  static Future<List<Goal>> getGoalsByPriority({
    required String userId,
    required String priority,
  }) async {
    try {
      final snapshot = await _getGoalsCollection(userId)
          .where('priority', isEqualTo: priority)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => Goal.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get goals by priority: $e');
    }
  }

  /// Get goals by status
  static Future<List<Goal>> getGoalsByStatus({
    required String userId,
    required String status,
  }) async {
    try {
      final snapshot = await _getGoalsCollection(userId)
          .where('status', isEqualTo: status)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => Goal.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get goals by status: $e');
    }
  }

  /// Search goals by title or description
  static Future<List<Goal>> searchGoals({
    required String userId,
    required String query,
  }) async {
    try {
      // Note: Firestore doesn't support full-text search natively
      // This is a basic implementation that gets all goals and filters client-side
      final snapshot = await _getGoalsCollection(userId)
          .where('isActive', isEqualTo: true)
          .get();
      
      final goals = snapshot.docs
          .map((doc) => Goal.fromFirestore(doc))
          .toList();
      
      final lowercaseQuery = query.toLowerCase();
      return goals.where((goal) {
        final titleMatch = goal.title.toLowerCase().contains(lowercaseQuery);
        final descriptionMatch = goal.description?.toLowerCase().contains(lowercaseQuery) ?? false;
        return titleMatch || descriptionMatch;
      }).toList();
    } catch (e) {
      throw Exception('Failed to search goals: $e');
    }
  }

  /// Get goals due within a specific timeframe
  static Future<List<Goal>> getGoalsDueWithin({
    required String userId,
    required Duration duration,
  }) async {
    try {
      final now = DateTime.now();
      final futureDate = now.add(duration);
      
      final snapshot = await _getGoalsCollection(userId)
          .where('isActive', isEqualTo: true)
          .where('targetDate', isGreaterThan: Timestamp.fromDate(now))
          .where('targetDate', isLessThanOrEqualTo: Timestamp.fromDate(futureDate))
          .orderBy('targetDate')
          .get();
      
      return snapshot.docs
          .map((doc) => Goal.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get goals due within timeframe: $e');
    }
  }

  /// Get overdue goals
  static Future<List<Goal>> getOverdueGoals(String userId) async {
    try {
      final now = DateTime.now();
      
      final snapshot = await _getGoalsCollection(userId)
          .where('isActive', isEqualTo: true)
          .where('status', isNotEqualTo: 'completed')
          .where('targetDate', isLessThan: Timestamp.fromDate(now))
          .orderBy('targetDate')
          .get();
      
      return snapshot.docs
          .map((doc) => Goal.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get overdue goals: $e');
    }
  }

  /// Get goal statistics for a user
  static Future<Map<String, dynamic>> getGoalStatistics(String userId) async {
    try {
      final snapshot = await _getGoalsCollection(userId)
          .where('isActive', isEqualTo: true)
          .get();
      
      final goals = snapshot.docs
          .map((doc) => Goal.fromFirestore(doc))
          .toList();
      
      final total = goals.length;
      final completed = goals.where((g) => g.status == 'completed').length;
      final inProgress = goals.where((g) => g.status == 'inProgress').length;
      final notStarted = goals.where((g) => g.status == 'notStarted').length;
      
      final now = DateTime.now();
      final overdue = goals.where((g) {
        if (g.targetDate == null) return false;
        return g.targetDate!.isBefore(now) && g.status != 'completed';
      }).length;
      
      return {
        'total': total,
        'completed': completed,
        'inProgress': inProgress,
        'notStarted': notStarted,
        'overdue': overdue,
        'completionRate': total > 0 ? (completed / total * 100).round() : 0,
      };
    } catch (e) {
      throw Exception('Failed to get goal statistics: $e');
    }
  }
}