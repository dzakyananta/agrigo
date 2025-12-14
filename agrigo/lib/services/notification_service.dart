import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/notification_item.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add this
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this
import 'schedule_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background notification: ${message.notification?.title}');
}

class NotificationItem {
  final String id;
  final String title;
  final String description;
  final String time;
  final String iconType;
  final String colorType;
  final bool isUnread;
  final DateTime createdAt;
  final String? scheduleId;

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

  static Future<List<NotificationItem>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = prefs.getStringList(_notificationKey) ?? [];

    return notificationsJson
        .map((json) => NotificationItem.fromMap(jsonDecode(json)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static Future<void> saveNotification(NotificationItem notification) async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = await getNotifications();
    notifications.removeWhere((n) => n.id == notification.id);
    notifications.add(notification);

    if (notifications.length > 50) {
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifications.removeRange(50, notifications.length);
    }

    final notificationsJson = notifications.map((n) => jsonEncode(n.toMap())).toList();
    await prefs.setStringList(_notificationKey, notificationsJson);
  }

  static Future<void> markAsRead(String id) async {
    final notifications = await getNotifications();
    final index = notifications.indexWhere((n) => n.id == id);

    if (index != -1) {
      final updatedNotification = notifications[index].copyWith(isUnread: false);
      await saveNotification(updatedNotification);
    }
  }

  static Future<void> markAllAsRead() async {
    final notifications = await getNotifications();
    for (var notification in notifications) {
      if (notification.isUnread) {
        await saveNotification(notification.copyWith(isUnread: false));
      }
    }
  }

  static Future<void> deleteNotification(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = await getNotifications();
    notifications.removeWhere((n) => n.id == id);

    final notificationsJson = notifications.map((n) => jsonEncode(n.toMap())).toList();
    await prefs.setStringList(_notificationKey, notificationsJson);
  }

  static Future<int> getUnreadCount() async {
    final notifications = await getNotifications();
    return notifications.where((n) => n.isUnread).length;
  }

  static Future<void> generateSmartNotifications({bool force = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheck = prefs.getInt(_lastCheckKey) ?? 0;
    final lastCheckDate = DateTime.fromMillisecondsSinceEpoch(lastCheck);
    final now = DateTime.now();

    if (!force &&
        lastCheckDate.day == now.day &&
        lastCheckDate.month == now.month &&
        lastCheckDate.year == now.year) {
      return;
    }

    final schedules = await ScheduleService.getSchedules();
    final activeSchedules = schedules.where((s) => s.status == 'Sedang Berlangsung').toList();

    for (var schedule in activeSchedules) {
      await _generateScheduleNotifications(schedule);
    }

    await prefs.setInt(_lastCheckKey, now.millisecondsSinceEpoch);
  }

  static Future<void> _generateScheduleNotifications(Schedule schedule) async {
    final now = DateTime.now();
    final daysSinceStart = now.difference(schedule.startDate).inDays;
    final daysUntilEnd = schedule.endDate.difference(now).inDays;

    if (daysSinceStart == 0) {
      await _createNotification(
        title: 'Penanaman ${schedule.komoditas}',
        description: 'Hari ini adalah hari penanaman ${schedule.komoditas}. Pastikan tanah sudah siap!',
        time: 'Hari ini',
        iconType: 'plant',
        colorType: 'green',
        scheduleId: schedule.id,
      );
    }

    if (daysUntilEnd == 0) {
      await _createNotification(
        title: 'Panen ${schedule.komoditas}',
        description: 'Hari ini adalah hari panen ${schedule.komoditas}. Selamat panen!',
        time: 'Hari ini',
        iconType: 'harvest',
        colorType: 'green',
        scheduleId: schedule.id,
      );
    }
  }

  static Future<void> _createNotification({
    required String title,
    required String description,
    required String time,
    required String iconType,
    required String colorType,
    String? scheduleId,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final notifications = await getNotifications();
    final today = DateTime.now();
    
    final existingToday = notifications.where((n) {
      final nDate = n.createdAt;
      return n.title == title &&
          nDate.day == today.day &&
          nDate.month == today.month &&
          nDate.year == today.year;
    }).isNotEmpty;

    if (existingToday) return;

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
}
