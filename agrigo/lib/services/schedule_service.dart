import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
    final prefs = await SharedPreferences.getInstance();
    final schedulesJson = prefs.getStringList(_scheduleKey) ?? [];

    return schedulesJson
        .map((json) => Schedule.fromMap(jsonDecode(json)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static Future<void> saveSchedule(Schedule schedule) async {
    final prefs = await SharedPreferences.getInstance();
    final schedules = await getSchedules();

    // Remove if exists (for updates)
    schedules.removeWhere((s) => s.id == schedule.id);

    // Add new schedule
    schedules.add(schedule);

    // Save to preferences
    final schedulesJson = schedules.map((s) => jsonEncode(s.toMap())).toList();

    await prefs.setStringList(_scheduleKey, schedulesJson);
  }

  static Future<void> deleteSchedule(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final schedules = await getSchedules();

    schedules.removeWhere((s) => s.id == id);

    final schedulesJson = schedules.map((s) => jsonEncode(s.toMap())).toList();

    await prefs.setStringList(_scheduleKey, schedulesJson);
  }
}
