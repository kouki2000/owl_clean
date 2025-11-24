/// ゴミ出しスケジュールモデル
class GarbageSchedule {
  final String id;
  final String garbageType;
  final int dayOfWeek; // 0: 日曜, 1: 月曜, ..., 6: 土曜
  final DateTime? notificationTime;
  final DateTime createdAt;

  GarbageSchedule({
    required this.id,
    required this.garbageType,
    required this.dayOfWeek,
    this.notificationTime,
    required this.createdAt,
  });

  /// データベースのMapから生成
  factory GarbageSchedule.fromMap(Map<String, dynamic> map) {
    return GarbageSchedule(
      id: map['id'] as String,
      garbageType: map['garbage_type'] as String,
      dayOfWeek: map['day_of_week'] as int,
      notificationTime: map['notification_time'] != null
          ? DateTime.parse(map['notification_time'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// データベースのMapに変換
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'garbage_type': garbageType,
      'day_of_week': dayOfWeek,
      'notification_time': notificationTime?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'GarbageSchedule(id: $id, type: $garbageType, dayOfWeek: $dayOfWeek)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GarbageSchedule && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// ゴミの種類（定数）
class GarbageTypes {
  static const String burnable = '燃えるゴミ';
  static const String nonBurnable = '燃えないゴミ';
  static const String recyclable = '資源ゴミ';
  static const String plastic = 'プラスチック';
  static const String paper = '紙類';
  static const String bottle = 'ビン・カン';
  static const String petBottle = 'ペットボトル';
  static const String bulky = '粗大ゴミ';

  static List<String> get all => [
        burnable,
        nonBurnable,
        recyclable,
        plastic,
        paper,
        bottle,
        petBottle,
        bulky,
      ];
}
