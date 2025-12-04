/// タスクモデル
///
/// 掃除タスクのデータ構造を定義
class Task {
  final String id;
  final String title;
  final String? categoryId;
  final bool isCompleted;
  final DateTime? completedDate;
  final int progress;
  final RepeatType repeatType;
  final String? repeatValue; // 曜日や日付の情報（JSON形式）
  final DateTime? notificationTime;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? endDate; // 終了日

  Task({
    required this.id,
    required this.title,
    this.categoryId,
    this.isCompleted = false,
    this.completedDate,
    this.progress = 0,
    this.repeatType = RepeatType.none,
    this.repeatValue,
    this.notificationTime,
    required this.createdAt,
    required this.updatedAt,
    this.endDate,
  });

  /// データベースのMapからTaskオブジェクトを生成
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      categoryId: map['category_id'] as String?,
      isCompleted: (map['is_completed'] as int) == 1,
      completedDate: map['completed_date'] != null
          ? DateTime.parse(map['completed_date'] as String)
          : null,
      progress: map['progress'] as int? ?? 0,
      repeatType: RepeatType.values.firstWhere(
        (e) => e.toString() == 'RepeatType.${map['repeat_type']}',
        orElse: () => RepeatType.none,
      ),
      repeatValue: map['repeat_value'] as String?,
      notificationTime: map['notification_time'] != null
          ? DateTime.parse(map['notification_time'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      endDate: map['end_date'] != null
          ? DateTime.parse(map['end_date'] as String)
          : null,
    );
  }

  /// TaskオブジェクトをデータベースのMapに変換
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category_id': categoryId,
      'is_completed': isCompleted ? 1 : 0,
      'completed_date': completedDate?.toIso8601String(),
      'progress': progress,
      'repeat_type': repeatType.name,
      'repeat_value': repeatValue,
      'notification_time': notificationTime?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
    };
  }

  /// タスクをコピーして一部の値を変更
  Task copyWith({
    String? id,
    String? title,
    String? categoryId,
    bool? isCompleted,
    DateTime? completedDate,
    int? progress,
    RepeatType? repeatType,
    String? repeatValue,
    DateTime? notificationTime,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? endDate,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      categoryId: categoryId ?? this.categoryId,
      isCompleted: isCompleted ?? this.isCompleted,
      completedDate: completedDate ?? this.completedDate,
      progress: progress ?? this.progress,
      repeatType: repeatType ?? this.repeatType,
      repeatValue: repeatValue ?? this.repeatValue,
      notificationTime: notificationTime ?? this.notificationTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      endDate: endDate ?? this.endDate,
    );
  }

  /// 今日のタスクかどうかを判定
  bool isToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 繰り返しタスクの場合
    if (repeatType != RepeatType.none) {
      return _shouldShowToday();
    }

    // 単発タスクの場合
    return !isCompleted;
  }

  /// 繰り返しタスクが今日表示されるべきかを判定
  bool _shouldShowToday() {
    final now = DateTime.now();

    switch (repeatType) {
      case RepeatType.daily:
        return true;
      case RepeatType.weekly:
        // repeatValueにJSON形式で曜日情報が入っている想定
        // 例: "[1,3,5]" → 月、水、金
        return true; // 簡易実装、後で詳細化
      case RepeatType.biweekly:
        // 隔週判定
        final taskDateOnly =
            DateTime(createdAt.year, createdAt.month, createdAt.day);
        final today = DateTime(now.year, now.month, now.day);
        final daysDifference = today.difference(taskDateOnly).inDays;
        return daysDifference % 14 == 0;
      case RepeatType.monthly:
        // repeatValueに日付情報が入っている想定
        return true; // 簡易実装、後で詳細化
      case RepeatType.none:
        return false;
    }
  }

  @override
  String toString() {
    return 'Task(id: $id, title: $title, isCompleted: $isCompleted, progress: $progress)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Task && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 繰り返しタイプ
enum RepeatType {
  none, // 繰り返しなし
  daily, // 毎日
  weekly, // 毎週
  biweekly, // 隔週（2週間に1回）
  monthly, // 毎月
}
