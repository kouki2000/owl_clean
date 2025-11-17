/// ゴミ出しスケジュールモデル
class GarbageSchedule {
  final String id;
  final String garbageType; // '燃えるゴミ', '資源ゴミ', 'プラスチック', etc.
  final int dayOfWeek; // 0:日曜日 ~ 6:土曜日
  final DateTime? notificationTime;
  final bool isEnabled;
  final DateTime createdAt;

  GarbageSchedule({
    required this.id,
    required this.garbageType,
    required this.dayOfWeek,
    this.notificationTime,
    this.isEnabled = true,
    required this.createdAt,
  });

  /// データベースのMapからGarbageScheduleオブジェクトを生成
  factory GarbageSchedule.fromMap(Map<String, dynamic> map) {
    return GarbageSchedule(
      id: map['id'] as String,
      garbageType: map['garbage_type'] as String,
      dayOfWeek: map['day_of_week'] as int,
      notificationTime: map['notification_time'] != null
          ? DateTime.parse(map['notification_time'] as String)
          : null,
      isEnabled: (map['is_enabled'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// GarbageScheduleオブジェクトをデータベースのMapに変換
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'garbage_type': garbageType,
      'day_of_week': dayOfWeek,
      'notification_time': notificationTime?.toIso8601String(),
      'is_enabled': isEnabled ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// コピーして一部の値を変更
  GarbageSchedule copyWith({
    String? id,
    String? garbageType,
    int? dayOfWeek,
    DateTime? notificationTime,
    bool? isEnabled,
    DateTime? createdAt,
  }) {
    return GarbageSchedule(
      id: id ?? this.id,
      garbageType: garbageType ?? this.garbageType,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      notificationTime: notificationTime ?? this.notificationTime,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// 曜日名を取得
  String get dayOfWeekName {
    const days = ['日', '月', '火', '水', '木', '金', '土'];
    return days[dayOfWeek];
  }

  /// 指定した日付がこのスケジュールに該当するかチェック
  bool matchesDate(DateTime date) {
    return date.weekday % 7 == dayOfWeek;
  }

  @override
  String toString() {
    return 'GarbageSchedule(type: $garbageType, day: $dayOfWeekName曜日)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GarbageSchedule && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// ゴミの種類
class GarbageTypes {
  static const String burnable = '燃えるゴミ';
  static const String nonBurnable = '燃えないゴミ';
  static const String recyclable = '資源ゴミ';
  static const String plastic = 'プラスチック';
  static const String paper = '古紙';
  static const String bottles = 'ビン・缶';
  static const String bulk = '粗大ゴミ';

  static const List<String> all = [
    burnable,
    nonBurnable,
    recyclable,
    plastic,
    paper,
    bottles,
    bulk,
  ];

  /// ゴミの種類に対応する絵文字を取得
  static String getEmoji(String type) {
    switch (type) {
      case burnable:
        return '🗑️';
      case nonBurnable:
        return '📦';
      case recyclable:
        return '♻️';
      case plastic:
        return '🥤';
      case paper:
        return '📄';
      case bottles:
        return '🍶';
      case bulk:
        return '🪑';
      default:
        return '🗑️';
    }
  }

  /// ゴミの種類に対応する色を取得
  static String getColor(String type) {
    switch (type) {
      case burnable:
        return '#FFF3E0'; // オレンジ系
      case nonBurnable:
        return '#E3F2FD'; // 青系
      case recyclable:
        return '#E8F5E9'; // 緑系
      case plastic:
        return '#F3E5F5'; // 紫系
      case paper:
        return '#FFF9C4'; // 黄色系
      case bottles:
        return '#E0F2F1'; // 青緑系
      case bulk:
        return '#EFEBE9'; // 茶色系
      default:
        return '#F5F5F5'; // グレー系
    }
  }
}
