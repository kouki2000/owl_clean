/// タスクカテゴリモデル
///
/// タスクを分類するためのカテゴリ（リビング、キッチンなど）
class TaskCategory {
  final String id;
  final String name;
  final String? icon;
  final String? color;
  final DateTime createdAt;

  TaskCategory({
    required this.id,
    required this.name,
    this.icon,
    this.color,
    required this.createdAt,
  });

  /// データベースのMapからTaskCategoryオブジェクトを生成
  factory TaskCategory.fromMap(Map<String, dynamic> map) {
    return TaskCategory(
      id: map['id'] as String,
      name: map['name'] as String,
      icon: map['icon'] as String?,
      color: map['color'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// TaskCategoryオブジェクトをデータベースのMapに変換
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// カテゴリをコピーして一部の値を変更
  TaskCategory copyWith({
    String? id,
    String? name,
    String? icon,
    String? color,
    DateTime? createdAt,
  }) {
    return TaskCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'TaskCategory(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TaskCategory && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// デフォルトカテゴリ
class DefaultCategories {
  static final List<TaskCategory> defaults = [
    TaskCategory(
      id: 'living',
      name: 'リビング',
      icon: '🛋️',
      color: '#E3F2FD',
      createdAt: DateTime.now(),
    ),
    TaskCategory(
      id: 'kitchen',
      name: 'キッチン',
      icon: '🍳',
      color: '#FFF3E0',
      createdAt: DateTime.now(),
    ),
    TaskCategory(
      id: 'bathroom',
      name: 'バスルーム',
      icon: '🚿',
      color: '#E1F5FE',
      createdAt: DateTime.now(),
    ),
    TaskCategory(
      id: 'toilet',
      name: 'トイレ',
      icon: '🚽',
      color: '#F3E5F5',
      createdAt: DateTime.now(),
    ),
    TaskCategory(
      id: 'bedroom',
      name: '寝室',
      icon: '🛏️',
      color: '#FCE4EC',
      createdAt: DateTime.now(),
    ),
    TaskCategory(
      id: 'other',
      name: 'その他',
      icon: '✨',
      color: '#F5F5F5',
      createdAt: DateTime.now(),
    ),
  ];
}
