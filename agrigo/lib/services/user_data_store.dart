import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'chat_session.dart';

class UserDataStore {
  UserDataStore._private();
  static final UserDataStore instance = UserDataStore._private();

  // Keys: we'll store per-user JSON under 'user:{uid}:{key}'
  String _key(String uid, String name) => 'user:$uid:$name';

  Future<void> saveChatMessages(
      String uid, List<ChatMessageLite> messages) async {
    if (uid.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final list = messages
        .map((m) => {
              'text': m.text,
              'isUser': m.isUser,
              'timestamp': m.timestamp.millisecondsSinceEpoch,
              'imagePath': m.imageFile?.path ?? '',
            })
        .toList();
    await prefs.setString(_key(uid, 'chat_messages'), jsonEncode(list));
  }

  Future<List<ChatMessageLite>> loadChatMessages(String uid) async {
    if (uid.isEmpty) return [];
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(uid, 'chat_messages'));
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) {
        final map = e as Map<String, dynamic>;
        final imagePath = (map['imagePath'] as String?) ?? '';
        return ChatMessageLite(
          text: map['text'] ?? '',
          isUser: map['isUser'] ?? false,
          timestamp: DateTime.fromMillisecondsSinceEpoch(
              map['timestamp'] ?? DateTime.now().millisecondsSinceEpoch),
          imageFile: imagePath.isNotEmpty ? File(imagePath) : null,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Generic helpers for other per-user JSON blobs (schedules, finance, profile)
  Future<void> saveJson(
      String uid, String name, Map<String, dynamic> data) async {
    if (uid.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(uid, name), jsonEncode(data));
  }

  Future<void> saveList(String uid, String name, List<dynamic> data) async {
    if (uid.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(uid, name), jsonEncode(data));
  }

  Future<List<dynamic>> loadList(String uid, String name) async {
    if (uid.isEmpty) return [];
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(uid, name));
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) return decoded;
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> loadJson(String uid, String name) async {
    if (uid.isEmpty) return null;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(uid, name));
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  Future<void> clearUserData(String uid) async {
    if (uid.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    // For now remove known keys
    await prefs.remove(_key(uid, 'chat_messages'));
    await prefs.remove(_key(uid, 'schedules'));
    await prefs.remove(_key(uid, 'finance'));
    await prefs.remove(_key(uid, 'finance_transactions'));
    await prefs.remove(_key(uid, 'notifications'));
    await prefs.remove(_key(uid, 'profile'));
  }
}
