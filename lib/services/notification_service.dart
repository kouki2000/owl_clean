import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/task.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// 初期化
  Future<void> initialize() async {
    if (_initialized) return;

    // タイムゾーンの初期化
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Tokyo'));

    // iOS設定
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // 初期化設定
    const initSettings = InitializationSettings(
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // 権限を自動リクエスト
    await requestPermission();

    _initialized = true;
  }

  /// 通知タップ時の処理
  void _onNotificationTap(NotificationResponse response) {
    // 通知タップ時の処理（必要に応じて実装）
    print('Notification tapped: ${response.payload}');
  }

  /// 通知権限をリクエスト
  Future<bool> requestPermission() async {
    try {
      // iOSの場合、初期化時に自動的に権限がリクエストされる
      return true;
    } catch (e) {
      print('Permission request error: $e');
      return false;
    }
  }

  /// 次の通知時刻を計算
  tz.TZDateTime _getNextScheduledDate({
    required DateTime notificationTime,
    required RepeatType repeatType,
  }) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime.from(notificationTime, tz.local);

    // 過去の時刻でない場合はそのまま返す
    if (!scheduledDate.isBefore(now)) {
      return scheduledDate;
    }

    // 過去の時刻の場合、繰り返しタイプに応じて次の時刻を計算
    switch (repeatType) {
      case RepeatType.none:
        // 1回のみの場合は過去ならそのまま（後でスキップ）
        return scheduledDate;

      case RepeatType.daily:
        // 毎日：次の該当時刻（明日以降）
        while (scheduledDate.isBefore(now)) {
          scheduledDate = scheduledDate.add(const Duration(days: 1));
        }
        return scheduledDate;

      case RepeatType.weekly:
        // 毎週：次の該当曜日
        while (scheduledDate.isBefore(now)) {
          scheduledDate = scheduledDate.add(const Duration(days: 7));
        }
        return scheduledDate;

      case RepeatType.biweekly:
        // 隔週：次の該当日（2週間ごと）
        while (scheduledDate.isBefore(now)) {
          scheduledDate = scheduledDate.add(const Duration(days: 14));
        }
        return scheduledDate;

      case RepeatType.monthly:
        // 毎月：次の該当日
        while (scheduledDate.isBefore(now)) {
          // 次の月の同じ日
          final nextMonth =
              scheduledDate.month == 12 ? 1 : scheduledDate.month + 1;
          final nextYear = scheduledDate.month == 12
              ? scheduledDate.year + 1
              : scheduledDate.year;

          scheduledDate = tz.TZDateTime(
            tz.local,
            nextYear,
            nextMonth,
            scheduledDate.day,
            scheduledDate.hour,
            scheduledDate.minute,
          );
        }
        return scheduledDate;
    }
  }

  /// タスクの通知をスケジュール
  Future<void> scheduleTaskNotification({
    required String taskId,
    required String taskTitle,
    required DateTime notificationTime,
    required RepeatType repeatType,
    DateTime? endDate,
  }) async {
    try {
      await initialize();

      final notificationId = taskId.hashCode;

      const notificationDetails = NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      // 次の通知時刻を計算
      final scheduledDate = _getNextScheduledDate(
        notificationTime: notificationTime,
        repeatType: repeatType,
      );

      // 1回のみのタスクで過去の時刻の場合はスキップ（警告のみ）
      if (repeatType == RepeatType.none &&
          scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
        print('⚠️ 通知時刻が過去のためスキップ: $scheduledDate');
        print('   タスクは正常に登録されました。');
        return;
      }

      switch (repeatType) {
        case RepeatType.none:
          // 1回のみの通知
          await _notifications.zonedSchedule(
            notificationId,
            'タスクのお知らせ',
            taskTitle,
            scheduledDate,
            notificationDetails,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
          break;

        case RepeatType.daily:
          // 毎日の通知
          await _notifications.zonedSchedule(
            notificationId,
            'タスクのお知らせ',
            taskTitle,
            scheduledDate,
            notificationDetails,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.time,
          );
          break;

        case RepeatType.weekly:
          // 毎週の通知
          await _notifications.zonedSchedule(
            notificationId,
            'タスクのお知らせ',
            taskTitle,
            scheduledDate,
            notificationDetails,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          );
          break;

        case RepeatType.biweekly:
          // 隔週の通知（終了日までの回数を計算）
          final end =
              endDate ?? notificationTime.add(const Duration(days: 365));
          final endTz = tz.TZDateTime.from(end, tz.local);
          final totalDays = endTz.difference(scheduledDate).inDays;
          final numberOfNotifications = (totalDays / 14).ceil().clamp(1, 26);

          for (int i = 0; i < numberOfNotifications; i++) {
            final biweeklyDate = scheduledDate.add(Duration(days: 14 * i));

            // 終了日を超えたらスキップ
            if (endDate != null && biweeklyDate.isAfter(endTz)) break;

            await _notifications.zonedSchedule(
              notificationId + i,
              'タスクのお知らせ',
              taskTitle,
              biweeklyDate,
              notificationDetails,
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.absoluteTime,
            );
          }
          break;

        case RepeatType.monthly:
          // 毎月の通知
          await _notifications.zonedSchedule(
            notificationId,
            'タスクのお知らせ',
            taskTitle,
            scheduledDate,
            notificationDetails,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
          );
          break;
      }

      print('✅ 通知をスケジュール: $taskTitle at $scheduledDate');
      if (scheduledDate
          .isAfter(tz.TZDateTime.from(notificationTime, tz.local))) {
        print('   (過去の時刻のため次の該当日時に設定)');
      }
      if (endDate != null) {
        print('   終了日: ${endDate.year}年${endDate.month}月${endDate.day}日');
      }
    } catch (e) {
      print('❌ 通知スケジュールエラー: $e');
      print('   タスクは登録されましたが、通知は設定されませんでした。');
    }
  }

  /// タスクの通知をキャンセル
  Future<void> cancelTaskNotification(String taskId) async {
    try {
      final notificationId = taskId.hashCode;

      // 通常の通知をキャンセル
      await _notifications.cancel(notificationId);

      // 隔週の場合は複数の通知をキャンセル
      for (int i = 0; i < 26; i++) {
        await _notifications.cancel(notificationId + i);
      }

      print('通知をキャンセル: $taskId');
    } catch (e) {
      print('通知キャンセルエラー: $e');
    }
  }

  /// すべての通知をキャンセル
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// スケジュール済み通知の一覧を取得
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
