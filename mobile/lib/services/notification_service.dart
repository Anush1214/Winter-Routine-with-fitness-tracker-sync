import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (kIsWeb) return;
    if (_isInitialized) return;

    // Initialize Timezones
    tz.initializeTimeZones();

    // Android Setup
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS Setup
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint("Notification tapped with payload: ${response.payload}");
      },
    );

    _isInitialized = true;
    await requestPermissions();
    await scheduleDefaultProtocols();
  }

  Future<void> requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.requestNotificationsPermission();
      await androidImplementation?.requestExactAlarmsPermission();
    }
  }

  NotificationDetails _systemNotificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'winter_arc_system_channel',
        'Solo Leveling System Protocol',
        channelDescription:
            'System Notifications, Daily Quests, and Penalty Warnings',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  /// Trigger an instant system alert on the phone
  Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    try {
      await _notificationsPlugin.show(
        DateTime.now().millisecond,
        title,
        body,
        _systemNotificationDetails(),
      );
    } catch (e) {
      debugPrint("Error showing instant notification: $e");
    }
  }

  /// Schedule the 3 core daily Solo Leveling system protocols
  Future<void> scheduleDefaultProtocols() async {
    try {
      // 1. Morning Awakening Protocol at 07:00 AM
      await _scheduleDailyAtTime(
        id: 101,
        hour: 7,
        minute: 0,
        title: "⚡ [ SYSTEM NOTIFICATION : DAILY QUEST ISSUED ]",
        body: "Wake Up & Morning Protocol. Hydrate with 500ml water and initiate the day's expedition.",
      );

      // 2. Evening Placement & DSA Shift at 06:30 PM (18:30)
      await _scheduleDailyAtTime(
        id: 102,
        hour: 18,
        minute: 30,
        title: "⚔️ [ SYSTEM QUEST : PLACEMENT & DSA SHIFT ]",
        body: "Evening Dungeon Active. Fresh up and prepare for Placement, DSA, and Japanese practice.",
      );

      // 3. Night Penalty Warning at 10:30 PM (22:30)
      await _scheduleDailyAtTime(
        id: 103,
        hour: 22,
        minute: 30,
        title: "⚠️ [ CAUTION : PENALTY QUEST WARNING ]",
        body: "30 minutes remaining in daily protocol! Complete all active objectives before 11:00 PM.",
      );
    } catch (e) {
      debugPrint("Error scheduling default protocols: $e");
    }
  }

  /// Schedule a daily repeating alarm at a specific hour and minute
  Future<void> _scheduleDailyAtTime({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      _systemNotificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Cancel all scheduled alarms
  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}
