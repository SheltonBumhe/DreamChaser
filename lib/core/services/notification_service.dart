import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions
    await _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    print('Notification tapped: ${response.payload}');
  }

  static Future<void> scheduleAssignmentReminder({
    required String assignmentId,
    required String title,
    required String description,
    required DateTime dueDate,
  }) async {
    final scheduledDate = dueDate.subtract(const Duration(days: 1));
    
    if (scheduledDate.isAfter(DateTime.now())) {
      await _notifications.zonedSchedule(
        assignmentId.hashCode,
        'Assignment Due Tomorrow',
        '$title is due tomorrow!',
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'assignments',
            'Assignment Reminders',
            channelDescription: 'Reminders for upcoming assignments',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: assignmentId,
      );
    }
  }

  static Future<void> scheduleStudyReminder({
    required String courseId,
    required String courseName,
    required DateTime scheduledTime,
  }) async {
    await _notifications.zonedSchedule(
      courseId.hashCode,
      'Study Time',
      'Time to study $courseName!',
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'study',
          'Study Reminders',
          channelDescription: 'Reminders for scheduled study sessions',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: courseId,
    );
  }

  static Future<void> scheduleGradeUpdate({
    required String courseId,
    required String courseName,
    required String grade,
  }) async {
    await _notifications.show(
      courseId.hashCode,
      'Grade Updated',
      'Your grade in $courseName has been updated to $grade',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'grades',
          'Grade Updates',
          channelDescription: 'Notifications for grade updates',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: courseId,
    );
  }

  static Future<void> scheduleAIInsight({
    required String insightId,
    required String title,
    required String description,
  }) async {
    await _notifications.show(
      insightId.hashCode,
      'AI Insight',
      title,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'ai_insights',
          'AI Insights',
          channelDescription: 'AI-generated insights and recommendations',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: insightId,
    );
  }

  static Future<void> scheduleCareerOpportunity({
    required String opportunityId,
    required String title,
    required String company,
    required DateTime deadline,
  }) async {
    final reminderDate = deadline.subtract(const Duration(days: 3));
    
    if (reminderDate.isAfter(DateTime.now())) {
      await _notifications.zonedSchedule(
        opportunityId.hashCode,
        'Career Opportunity',
        'Application for $title at $company closes in 3 days!',
        tz.TZDateTime.from(reminderDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'career',
            'Career Opportunities',
            channelDescription: 'Reminders for job and internship deadlines',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: opportunityId,
      );
    }
  }

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
} 