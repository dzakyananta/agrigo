import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'firebase_service.dart';
import 'user_data_store.dart';

class Schedule {
  final String id;
  final String komoditas;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;

  Schedule({
    required this.id,
    required this.komoditas,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'komoditas': komoditas,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Schedule.fromMap(Map<String, dynamic> map) {
    return Schedule(
      id: map['id'],
      komoditas: map['komoditas'],
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate']),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['endDate']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  String get status {
    final now = DateTime.now();
    if (now.isBefore(startDate)) {
      return 'Akan Datang';
    } else if (now.isAfter(endDate)) {
      return 'Selesai';
    } else {
      return 'Sedang Berlangsung';
    }
  }
}

class ScheduleService {
  static const String _scheduleKey = 'schedules';

  static Future<List<Schedule>> getSchedules() async {
    final uid = FirebaseService.userId;
    List<dynamic> stored = [];
    if (uid != null) {
      stored = await UserDataStore.instance.loadList(uid, 'schedules');
    } else {
      final prefs = await SharedPreferences.getInstance();
      stored = prefs
              .getStringList(_scheduleKey)
              ?.map((s) => jsonDecode(s))
              .toList() ??
          [];
    }

    final list = stored
        .map((e) => Schedule.fromMap(
            e is String ? jsonDecode(e) : e as Map<String, dynamic>))
        .toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  static Future<void> saveSchedule(Schedule schedule) async {
    final uid = FirebaseService.userId;
    final schedules = await getSchedules();

    // Remove if exists (for updates)
    schedules.removeWhere((s) => s.id == schedule.id);

    // Add new schedule
    schedules.add(schedule);

    // Save to preferences
    final schedulesJson = schedules.map((s) => s.toMap()).toList();
    if (uid != null) {
      await UserDataStore.instance.saveList(uid, 'schedules', schedulesJson);
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
          _scheduleKey, schedules.map((s) => jsonEncode(s.toMap())).toList());
    }
  }

  static Future<void> deleteSchedule(String id) async {
    final uid = FirebaseService.userId;
    final schedules = await getSchedules();

    schedules.removeWhere((s) => s.id == id);

    final schedulesJson = schedules.map((s) => s.toMap()).toList();
    if (uid != null) {
      await UserDataStore.instance.saveList(uid, 'schedules', schedulesJson);
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
          _scheduleKey, schedules.map((s) => jsonEncode(s.toMap())).toList());
    }
  }
}
