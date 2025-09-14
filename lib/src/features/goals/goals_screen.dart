import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/goal_model.dart';
import '../../providers/goal_provider.dart';
import '../../providers/auth_provider.dart';

/// Screen for managing user goals
class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  GoalStatus? _selectedStatus;
  GoalPriority? _selectedPriority;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final goalsAsync = ref.watch(goalsStreamProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Goals'),
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
            Tab(text: 'All'),
          ],
        ),
      ),
      body: goalsAsync.when(
        data: (goals) {
          if (goals.isEmpty) {
            return _buildEmptyState(context);
          }
          
          return TabBarView(
            controller: _tabController,
            children: [
              _buildGoalsList(goals.where((g) => g.status != GoalStatus.completed).toList()),
              _buildGoalsList(goals.where((g) => g.status == GoalStatus.completed).toList()),
              _buildGoalsList(goals),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading goals',
                style: TextStyle(color: colorScheme.error),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: TextStyle(color: colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGoalDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flag_outlined,
            size: 64,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No goals yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first goal to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddGoalDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Goal'),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsList(List<GoalModel> goals) {
    if (goals.isEmpty) {
      return const Center(
        child: Text('No goals in this category'),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: goals.length,
      itemBuilder: (context, index) {
        final goal = goals[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getPriorityColor(goal.priority),
              child: Icon(
                _getPriorityIcon(goal.priority),
                color: Colors.white,
              ),
            ),
            title: Text(goal.title),
            subtitle: goal.description != null
                ? Text(
                    goal.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )
                : null,
            trailing: _buildStatusChip(goal.status),
            onTap: () => _showGoalDetails(context, goal),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(GoalStatus status) {
    Color color;
    String label;
    
    switch (status) {
      case GoalStatus.notStarted:
        color = Colors.grey;
        label = 'Not Started';
        break;
      case GoalStatus.inProgress:
        color = Colors.blue;
        label = 'In Progress';
        break;
      case GoalStatus.completed:
        color = Colors.green;
        label = 'Completed';
        break;
      case GoalStatus.paused:
        color = Colors.orange;
        label = 'Paused';
        break;
      case GoalStatus.cancelled:
        color = Colors.red;
        label = 'Cancelled';
        break;
    }
    
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
        ),
      ),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
    );
  }

  Color _getPriorityColor(GoalPriority priority) {
    switch (priority) {
      case GoalPriority.low:
        return Colors.green;
      case GoalPriority.medium:
        return Colors.orange;
      case GoalPriority.high:
        return Colors.red;
      case GoalPriority.critical:
        return Colors.purple;
    }
  }

  IconData _getPriorityIcon(GoalPriority priority) {
    switch (priority) {
      case GoalPriority.low:
        return Icons.low_priority;
      case GoalPriority.medium:
        return Icons.remove;
      case GoalPriority.high:
        return Icons.priority_high;
      case GoalPriority.critical:
        return Icons.warning;
    }
  }

  void _showAddGoalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Goal'),
        content: const Text('Goal creation dialog will be implemented here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement goal creation
              Navigator.of(context).pop();
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showGoalDetails(BuildContext context, GoalModel goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(goal.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (goal.description != null) ..[
              Text(goal.description!),
              const SizedBox(height: 16),
            ],
            Text('Priority: ${goal.priority.name}'),
            Text('Status: ${goal.status.name}'),
            Text('Hours per day: ${goal.plannedHoursPerDay}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}