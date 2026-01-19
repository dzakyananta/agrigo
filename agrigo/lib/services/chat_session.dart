import 'dart:io';

import 'package:flutter/foundation.dart';

/// Simple in-memory chat session to persist messages during app runtime.
/// The data is kept in-memory (process memory) so it will be cleared
/// automatically when the app is terminated.
class ChatMessageLite {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final File? imageFile;

  ChatMessageLite({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.imageFile,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ChatSession {
  ChatSession._private();
  static final ChatSession instance = ChatSession._private();

  /// The in-memory list of messages for the current app session.
  final List<ChatMessageLite> messages = [];

  void clear() => messages.clear();
}
