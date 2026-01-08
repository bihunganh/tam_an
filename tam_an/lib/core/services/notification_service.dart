import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Xử lý khi người dùng nhấn vào thông báo
      },
    );
  }

  // --- 1. NHẮC CHECK-IN LÚC 20:00 HÀNG NGÀY ---
  Future<void> scheduleDailyReminder() async {
    await _notificationsPlugin.zonedSchedule(
      101,
      'Tâm An nhắc bạn',
      'Đã 8h tối rồi, đừng quên dành ít phút ghi lại cảm xúc ngày hôm nay nhé!',
      _nextInstanceOfTime(20, 0),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder', 'Nhắc nhở hàng ngày',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // --- 2. THÔNG BÁO MẤT CHUỖI ---
  Future<void> showStreakLostNotification() async {
    const NotificationDetails details = NotificationDetails(
      android: AndroidNotificationDetails(
        'streak_channel', 'Thông báo chuỗi',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );
    await _notificationsPlugin.show(
      102,
      'Đứt đoạn chuỗi An Tâm',
      'Hôm qua bạn đã quên check-in rồi. Hãy bắt đầu lại hành trình ngay hôm nay nhé!',
      details,
    );
  }

  // --- 3. NHẮC XEM AI INSIGHTS CUỐI TUẦN ---
  Future<void> scheduleWeeklyInsights() async {
    await _scheduleWeekly(103, 9, 0, DateTime.saturday, 'Cuối tuần rồi!', 'Cùng xem lại những biến chuyển cảm xúc của bạn qua AI Insights nhé.');
    await _scheduleWeekly(104, 9, 0, DateTime.sunday, 'Chủ Nhật thảnh thơi', 'Dành ít phút nhìn lại tuần qua cùng Tâm An nhé.');
  }

  Future<void> _scheduleWeekly(int id, int hour, int minute, int day, String title, String body) async {
    await _notificationsPlugin.zonedSchedule(
      id, title, body,
      _nextInstanceOfDay(day, hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails('weekly_channel', 'Nhắc nhở cuối tuần'),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  tz.TZDateTime _nextInstanceOfDay(int day, int hour, int minute) {
    tz.TZDateTime scheduledDate = _nextInstanceOfTime(hour, minute);
    while (scheduledDate.weekday != day) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}