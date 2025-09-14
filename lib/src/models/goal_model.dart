import 'package:cloud_firestore/cloud_firestore.dart';

/// Priority levels for goals
enum GoalPriority {
  low,
  medium,
  high,
  critical,
}

/// Status of goals
enum GoalStatus {
  notStarted,
  inProgress,
  completed,
  paused,
  cancelled,
}

/// Recurrence patterns for goals
enum GoalRecurrence {
  daily,
  weekly,
  monthly,
  quarterly,
  yearly,
  none,
}

/// Goal model for LifeManager
class GoalModel {
  final String id;
  final String title;
  final double plannedHoursPerDay;
  final GoalPriority priority;
  final GoalRecurrence recurrence;
  final String color;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? targetDate;
  final DateTime? completedAt;
  final bool isActive;
  final GoalStatus status;
  final List<String> tags;
  final Map<String, dynamic>? metadata;

  const GoalModel({
    required this.id,
    required this.title,
    required this.plannedHoursPerDay,
    this.priority = GoalPriority.medium,
    this.recurrence = GoalRecurrence.none,
    this.color = '#2196F3',
    this.description,
    this.createdAt,
    this.updatedAt,
    this.targetDate,
    this.completedAt,
    this.isActive = true,
    this.status = GoalStatus.notStarted,
    this.tags = const [],
    this.metadata,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      plannedHoursPerDay: (json['plannedHoursPerDay'] ?? 0.0).toDouble(),
      priority: GoalPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => GoalPriority.medium,
      ),
      recurrence: GoalRecurrence.values.firstWhere(
        (e) => e.name == json['recurrence'],
        orElse: () => GoalRecurrence.none,
      ),
      color: json['color'] ?? '#2196F3',
      description: json['description'],
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
      targetDate: json['targetDate'] != null
          ? (json['targetDate'] as Timestamp).toDate()
          : null,
      completedAt: json['completedAt'] != null
          ? (json['completedAt'] as Timestamp).toDate()
          : null,
      isActive: json['isActive'] ?? true,
      status: GoalStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => GoalStatus.notStarted,
      ),
      tags: List<String>.from(json['tags'] ?? []),
      metadata: json['metadata']?.cast<String, dynamic>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'plannedHoursPerDay': plannedHoursPerDay,
      'priority': priority.name,
      'recurrence': recurrence.name,
      'color': color,
      'description': description,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'targetDate': targetDate != null ? Timestamp.fromDate(targetDate!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'isActive': isActive,
      'status': status.name,
      'tags': tags,
      'metadata': metadata,
    };
  }

  GoalModel copyWith({
    String? id,
    String? title,
    double? plannedHoursPerDay,
    GoalPriority? priority,
    GoalRecurrence? recurrence,
    String? color,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? targetDate,
    DateTime? completedAt,
    bool? isActive,
    GoalStatus? status,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) {
    return GoalModel(
      id: id ?? this.id,
      title: title ?? this.title,
      plannedHoursPerDay: plannedHoursPerDay ?? this.plannedHoursPerDay,
      priority: priority ?? this.priority,
      recurrence: recurrence ?? this.recurrence,
      color: color ?? this.color,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      targetDate: targetDate ?? this.targetDate,
      completedAt: completedAt ?? this.completedAt,
      isActive: isActive ?? this.isActive,
      status: status ?? this.status,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GoalModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'GoalModel(id: $id, title: $title, status: $status)';
  }

  /// Create a new goal with current timestamp
  factory GoalModel.create({
    required String title,
    required double plannedHoursPerDay,
    GoalPriority priority = GoalPriority.medium,
    GoalRecurrence recurrence = GoalRecurrence.none,
    String color = '#2196F3',
    String? description,
    DateTime? targetDate,
    List<String> tags = const [],
  }) {
    final now = DateTime.now();
    return GoalModel(
      id: '', // Will be set by Firestore
      title: title,
      plannedHoursPerDay: plannedHoursPerDay,
      priority: priority,
      recurrence: recurrence,
      color: color,
      description: description,
      createdAt: now,
      updatedAt: now,
      targetDate: targetDate,
      tags: tags,
    );
  }

  /// Mark goal as completed
  GoalModel complete() {
    return copyWith(
      status: GoalStatus.completed,
      completedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Update goal with new timestamp
  GoalModel updated() {
    return copyWith(updatedAt: DateTime.now());
  }
}