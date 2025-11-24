/// タスクの日次完了履歴
class TaskCompletion {
  final String id;
  final String taskId;
  final DateTime completedDate;
  final DateTime createdAt;

  TaskCompletion({
    required this.id,
    required this.taskId,
    required this.completedDate,
    required this.createdAt,
  });

  factory TaskCompletion.fromMap(Map<String, dynamic> map) {
    return TaskCompletion(
      id: map['id'] as String,
      taskId: map['task_id'] as String,
      completedDate: DateTime.parse(map['completed_date'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_id': taskId,
      'completed_date': completedDate.toIso8601String().split('T')[0],
      'created_at': createdAt.toIso8601String(),
    };
  }
}
