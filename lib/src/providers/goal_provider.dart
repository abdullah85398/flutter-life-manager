import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/goal_model.dart';
import '../services/goal_service.dart';
import 'auth_provider.dart';

/// Provider for managing goals state
class GoalNotifier extends StateNotifier<AsyncValue<List<Goal>>> {
  GoalNotifier(this._userId) : super(const AsyncValue.loading()) {
    loadGoals();
  }

  final String _userId;

  /// Load all goals for the user
  Future<void> loadGoals() async {
    try {
      state = const AsyncValue.loading();
      final goals = await GoalService.getGoals(_userId);
      state = AsyncValue.data(goals);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Load only active goals
  Future<void> loadActiveGoals() async {
    try {
      state = const AsyncValue.loading();
      final goals = await GoalService.getActiveGoals(_userId);
      state = AsyncValue.data(goals);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Create a new goal
  Future<String?> createGoal(Goal goal) async {
    try {
      final goalId = await GoalService.createGoal(
        userId: _userId,
        goal: goal,
      );
      
      // Reload goals to reflect the new addition
      await loadGoals();
      return goalId;
    } catch (error) {
      // Handle error appropriately
      rethrow;
    }
  }

  /// Update an existing goal
  Future<void> updateGoal(String goalId, Goal updatedGoal) async {
    try {
      await GoalService.updateGoal(
        userId: _userId,
        goalId: goalId,
        goal: updatedGoal,
      );
      
      // Reload goals to reflect the update
      await loadGoals();
    } catch (error) {
      rethrow;
    }
  }

  /// Delete a goal
  Future<void> deleteGoal(String goalId) async {
    try {
      await GoalService.deleteGoal(
        userId: _userId,
        goalId: goalId,
      );
      
      // Reload goals to reflect the deletion
      await loadGoals();
    } catch (error) {
      rethrow;
    }
  }

  /// Toggle goal completion status
  Future<void> toggleGoalCompletion(String goalId) async {
    try {
      await GoalService.toggleGoalCompletion(
        userId: _userId,
        goalId: goalId,
      );
      
      // Reload goals to reflect the status change
      await loadGoals();
    } catch (error) {
      rethrow;
    }
  }

  /// Archive a goal
  Future<void> archiveGoal(String goalId) async {
    try {
      await GoalService.archiveGoal(
        userId: _userId,
        goalId: goalId,
      );
      
      // Reload goals to reflect the archive
      await loadGoals();
    } catch (error) {
      rethrow;
    }
  }

  /// Get goals by priority
  List<Goal> getGoalsByPriority(GoalPriority priority) {
    return state.maybeWhen(
      data: (goals) => goals.where((goal) => goal.priority == priority).toList(),
      orElse: () => [],
    );
  }

  /// Get goals by status
  List<Goal> getGoalsByStatus(GoalStatus status) {
    return state.maybeWhen(
      data: (goals) => goals.where((goal) => goal.status == status).toList(),
      orElse: () => [],
    );
  }

  /// Search goals by title or description
  List<Goal> searchGoals(String query) {
    if (query.isEmpty) {
      return state.maybeWhen(
        data: (goals) => goals,
        orElse: () => [],
      );
    }
    
    return state.maybeWhen(
      data: (goals) => goals.where((goal) {
        final titleMatch = goal.title.toLowerCase().contains(query.toLowerCase());
        final descriptionMatch = goal.description?.toLowerCase().contains(query.toLowerCase()) ?? false;
        return titleMatch || descriptionMatch;
      }).toList(),
      orElse: () => [],
    );
  }

  /// Get total planned hours per day
  double getTotalPlannedHours() {
    return state.maybeWhen(
      data: (goals) => goals
          .where((goal) => goal.isActive && goal.status != GoalStatus.completed)
          .fold(0.0, (sum, goal) => sum + goal.plannedHoursPerDay),
      orElse: () => 0.0,
    );
  }

  /// Get completion percentage
  double getCompletionPercentage() {
    return state.maybeWhen(
      data: (goals) {
        if (goals.isEmpty) return 0.0;
        final completedCount = goals.where((goal) => goal.status == GoalStatus.completed).length;
        return (completedCount / goals.length) * 100;
      },
      orElse: () => 0.0,
    );
  }

  /// Get goals due soon (within next 7 days)
  List<Goal> getGoalsDueSoon() {
    final now = DateTime.now();
    final weekFromNow = now.add(const Duration(days: 7));
    
    return state.maybeWhen(
      data: (goals) => goals.where((goal) {
        if (goal.targetDate == null) return false;
        return goal.targetDate!.isAfter(now) && goal.targetDate!.isBefore(weekFromNow);
      }).toList(),
      orElse: () => [],
    );
  }

  /// Get overdue goals
  List<Goal> getOverdueGoals() {
    final now = DateTime.now();
    
    return state.maybeWhen(
      data: (goals) => goals.where((goal) {
        if (goal.targetDate == null) return false;
        return goal.targetDate!.isBefore(now) && goal.status != GoalStatus.completed;
      }).toList(),
      orElse: () => [],
    );
  }

  /// Refresh goals data
  Future<void> refresh() async {
    await loadGoals();
  }
}

/// Provider for goals notifier
final goalNotifierProvider = StateNotifierProvider.family<GoalNotifier, AsyncValue<List<Goal>>, String>(
  (ref, userId) => GoalNotifier(userId),
);

/// Provider for goals stream
final goalsStreamProvider = StreamProvider<List<GoalModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Stream.value([]);
  }
  return GoalService.getGoalsStream(user.uid);
});

/// Provider for active goals only
final activeGoalsProvider = Provider<List<Goal>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  
  final goalsAsync = ref.watch(goalNotifierProvider(user.uid));
  return goalsAsync.maybeWhen(
    data: (goals) => goals.where((goal) => goal.isActive && goal.status != GoalStatus.completed).toList(),
    orElse: () => [],
  );
});

/// Provider for completed goals
final completedGoalsProvider = Provider<List<Goal>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  
  final goalsAsync = ref.watch(goalNotifierProvider(user.uid));
  return goalsAsync.maybeWhen(
    data: (goals) => goals.where((goal) => goal.status == GoalStatus.completed).toList(),
    orElse: () => [],
  );
});

/// Provider for goals statistics
final goalStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return {};
  
  final goalsAsync = ref.watch(goalNotifierProvider(user.uid));
  return goalsAsync.maybeWhen(
    data: (goals) {
      final total = goals.length;
      final completed = goals.where((g) => g.status == GoalStatus.completed).length;
      final inProgress = goals.where((g) => g.status == GoalStatus.inProgress).length;
      final overdue = goals.where((g) {
        if (g.targetDate == null) return false;
        return g.targetDate!.isBefore(DateTime.now()) && g.status != GoalStatus.completed;
      }).length;
      
      return {
        'total': total,
        'completed': completed,
        'inProgress': inProgress,
        'overdue': overdue,
        'completionRate': total > 0 ? (completed / total * 100).round() : 0,
      };
    },
    orElse: () => {
      'total': 0,
      'completed': 0,
      'inProgress': 0,
      'overdue': 0,
      'completionRate': 0,
    },
  );
});

/// Provider for total planned hours
final totalPlannedHoursProvider = Provider<double>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return 0.0;
  
  final goalsAsync = ref.watch(goalNotifierProvider(user.uid));
  return goalsAsync.maybeWhen(
    data: (goals) => goals
        .where((goal) => goal.isActive && goal.status != GoalStatus.completed)
        .fold(0.0, (sum, goal) => sum + goal.plannedHoursPerDay),
    orElse: () => 0.0,
  );
});