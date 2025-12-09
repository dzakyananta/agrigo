import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'schedule_service.dart';

class NotificationItem {
  final String id;
  final String title;
  final String description;
  final String time;
  final String iconType; // 'water', 'fertilizer', 'pest', 'harvest', 'plant'
  final String colorType; // 'red', 'green', 'orange', 'blue'
  final bool isUnread;
  final DateTime createdAt;
  final String? scheduleId; // Link to schedule if related

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.iconType,
    required this.colorType,
    required this.isUnread,
    required this.createdAt,
    this.scheduleId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'time': time,
      'iconType': iconType,
      'colorType': colorType,
      'isUnread': isUnread,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'scheduleId': scheduleId,
    };
  }

  factory NotificationItem.fromMap(Map<String, dynamic> map) {
    return NotificationItem(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      time: map['time'] ?? '',
      iconType: map['iconType'] ?? 'info',
      colorType: map['colorType'] ?? 'green',
      isUnread: map['isUnread'] ?? true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      scheduleId: map['scheduleId'],
    );
  }

  NotificationItem copyWith({bool? isUnread}) {
    return NotificationItem(
      id: id,
      title: title,
      description: description,
      time: time,
      iconType: iconType,
      colorType: colorType,
      isUnread: isUnread ?? this.isUnread,
      createdAt: createdAt,
      scheduleId: scheduleId,
    );
  }
}

class NotificationService {
  static const String _notificationKey = 'notifications';
  static const String _lastCheckKey = 'last_notification_check';

  // Get all notifications
  static Future<List<NotificationItem>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = prefs.getStringList(_notificationKey) ?? [];

    return notificationsJson
        .map((json) => NotificationItem.fromMap(jsonDecode(json)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Save notification
  static Future<void> saveNotification(NotificationItem notification) async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = await getNotifications();

    // Remove if exists (for updates)
    notifications.removeWhere((n) => n.id == notification.id);

    // Add new notification
    notifications.add(notification);

    // Keep only last 50 notifications
    if (notifications.length > 50) {
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifications.removeRange(50, notifications.length);
    }

    // Save to preferences
    final notificationsJson = notifications
        .map((n) => jsonEncode(n.toMap()))
        .toList();

    await prefs.setStringList(_notificationKey, notificationsJson);
  }

  // Mark as read
  static Future<void> markAsRead(String id) async {
    final notifications = await getNotifications();
    final index = notifications.indexWhere((n) => n.id == id);

    if (index != -1) {
      final updatedNotification = notifications[index].copyWith(
        isUnread: false,
      );
      await saveNotification(updatedNotification);
    }
  }

  // Mark all as read
  static Future<void> markAllAsRead() async {
    final notifications = await getNotifications();
    for (var notification in notifications) {
      if (notification.isUnread) {
        await saveNotification(notification.copyWith(isUnread: false));
      }
    }
  }

  // Delete notification
  static Future<void> deleteNotification(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = await getNotifications();

    notifications.removeWhere((n) => n.id == id);

    final notificationsJson = notifications
        .map((n) => jsonEncode(n.toMap()))
        .toList();

    await prefs.setStringList(_notificationKey, notificationsJson);
  }

  // Get unread count
  static Future<int> getUnreadCount() async {
    final notifications = await getNotifications();
    return notifications.where((n) => n.isUnread).length;
  }

  // Generate smart notifications based on schedules
  static Future<void> generateSmartNotifications({bool force = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheck = prefs.getInt(_lastCheckKey) ?? 0;
    final lastCheckDate = DateTime.fromMillisecondsSinceEpoch(lastCheck);
    final now = DateTime.now();

    // Check only once per day unless forced
    if (!force &&
        lastCheckDate.day == now.day &&
        lastCheckDate.month == now.month &&
        lastCheckDate.year == now.year) {
      return;
    }

    final schedules = await ScheduleService.getSchedules();
    final activeSchedules = schedules
        .where((s) => s.status == 'Sedang Berlangsung')
        .toList();

    for (var schedule in activeSchedules) {
      await _generateScheduleNotifications(schedule);
    }

    // Update last check time
    await prefs.setInt(_lastCheckKey, now.millisecondsSinceEpoch);
  }

  // Generate notifications for a specific schedule
  static Future<void> _generateScheduleNotifications(Schedule schedule) async {
    final now = DateTime.now();
    final daysSinceStart = now.difference(schedule.startDate).inDays;
    final daysUntilEnd = schedule.endDate.difference(now).inDays;

    // For ongoing schedules, create a general reminder if no specific notification applies
    bool hasSpecificNotification = false;

    // Notification for day 1 - Planting reminder
    if (daysSinceStart == 0) {
      hasSpecificNotification = true;
      await _createNotification(
        title: 'Penanaman ${schedule.komoditas}',
        description:
            'Hari ini adalah hari penanaman ${schedule.komoditas}. Pastikan tanah sudah siap!',
        time: 'Hari ini',
        iconType: 'plant',
        colorType: 'green',
        scheduleId: schedule.id,
      );
    }

    // Notification for week 1 - First watering/fertilizing
    if (daysSinceStart == 7) {
      hasSpecificNotification = true;
      await _createNotification(
        title: 'Pemupukan Awal ${schedule.komoditas}',
        description:
            'Saatnya melakukan pemupukan pertama untuk ${schedule.komoditas} Anda.',
        time: 'Hari ini',
        iconType: 'fertilizer',
        colorType: 'green',
        scheduleId: schedule.id,
      );
    }

    // Notification for week 2 - Pest check
    if (daysSinceStart == 14) {
      hasSpecificNotification = true;
      await _createNotification(
        title: 'Pemeriksaan Hama ${schedule.komoditas}',
        description:
            'Periksa tanaman ${schedule.komoditas} untuk tanda-tanda hama atau penyakit.',
        time: 'Hari ini',
        iconType: 'pest',
        colorType: 'orange',
        scheduleId: schedule.id,
      );
    }

    // Regular watering reminder (every 3 days during growth)
    if (daysSinceStart > 0 && daysSinceStart % 3 == 0 && daysUntilEnd > 7) {
      hasSpecificNotification = true;
      await _createNotification(
        title: 'Penyiraman ${schedule.komoditas}',
        description:
            'Jangan lupa lakukan penyiraman untuk ${schedule.komoditas} hari ini.',
        time: 'Hari ini',
        iconType: 'water',
        colorType: 'blue',
        scheduleId: schedule.id,
      );
    }

    // Fertilizing reminder (every 2 weeks)
    if (daysSinceStart > 7 && daysSinceStart % 14 == 0 && daysUntilEnd > 7) {
      hasSpecificNotification = true;
      await _createNotification(
        title: 'Pemupukan ${schedule.komoditas}',
        description:
            'Saatnya melakukan pemupukan untuk ${schedule.komoditas} Anda.',
        time: 'Hari ini',
        iconType: 'fertilizer',
        colorType: 'green',
        scheduleId: schedule.id,
      );
    }

    // Pre-harvest notification (7 days before end)
    if (daysUntilEnd == 7) {
      hasSpecificNotification = true;
      await _createNotification(
        title: 'Persiapan Panen ${schedule.komoditas}',
        description:
            'Panen ${schedule.komoditas} akan dilakukan dalam 7 hari. Mulai persiapkan alat panen.',
        time: '7 hari lagi',
        iconType: 'harvest',
        colorType: 'orange',
        scheduleId: schedule.id,
      );
    }

    // Harvest day notification
    if (daysUntilEnd == 0) {
      hasSpecificNotification = true;
      await _createNotification(
        title: 'Panen ${schedule.komoditas}',
        description:
            'Hari ini adalah hari panen ${schedule.komoditas}. Selamat panen!',
        time: 'Hari ini',
        iconType: 'harvest',
        colorType: 'green',
        scheduleId: schedule.id,
      );
    }

    // If no specific notification, create a general schedule reminder
    if (!hasSpecificNotification && daysSinceStart >= 0 && daysUntilEnd > 0) {
      String timeDisplay;
      if (daysUntilEnd <= 14) {
        timeDisplay = '$daysUntilEnd hari lagi';
      } else {
        final weeks = (daysUntilEnd / 7).floor();
        timeDisplay = '$weeks minggu lagi';
      }

      await _createNotification(
        title: 'Jadwal ${schedule.komoditas} Sedang Berlangsung',
        description:
            'Pantau pertumbuhan ${schedule.komoditas} Anda. Hari ke-${daysSinceStart + 1} dari masa tanam. Panen diperkirakan $timeDisplay.',
        time: _getRelativeTime(DateTime.now()),
        iconType: 'plant',
        colorType: 'green',
        scheduleId: schedule.id,
      );
    }
  }

  // Generate notifications for a new schedule immediately
  static Future<void> generateNotificationsForSchedule(
    Schedule schedule,
  ) async {
    await _generateScheduleNotifications(schedule);
  }

  // Create a notification
  static Future<void> _createNotification({
    required String title,
    required String description,
    required String time,
    required String iconType,
    required String colorType,
    String? scheduleId,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    // Check if similar notification already exists today
    final notifications = await getNotifications();
    final today = DateTime.now();
    final existingToday = notifications.where((n) {
      final nDate = n.createdAt;
      return n.title == title &&
          nDate.day == today.day &&
          nDate.month == today.month &&
          nDate.year == today.year;
    }).isNotEmpty;

    if (existingToday) {
      return; // Don't create duplicate notification
    }

    final notification = NotificationItem(
      id: id,
      title: title,
      description: description,
      time: time,
      iconType: iconType,
      colorType: colorType,
      isUnread: true,
      createdAt: DateTime.now(),
      scheduleId: scheduleId,
    );

    await saveNotification(notification);
  }

  // Manual notification creation
  static Future<void> createManualNotification({
    required String title,
    required String description,
    String? time,
    String iconType = 'info',
    String colorType = 'blue',
  }) async {
    await _createNotification(
      title: title,
      description: description,
      time: time ?? _getRelativeTime(DateTime.now()),
      iconType: iconType,
      colorType: colorType,
    );
  }

  // Get relative time string
  static String _getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  // Get time display for upcoming events
  static String getUpcomingTimeDisplay(int daysUntil) {
    if (daysUntil == 0) {
      return 'Hari ini';
    } else if (daysUntil == 1) {
      return 'Besok';
    } else if (daysUntil <= 7) {
      return '$daysUntil hari lagi';
    } else {
      final weeks = (daysUntil / 7).floor();
      return '$weeks minggu lagi';
    }
  }
}
