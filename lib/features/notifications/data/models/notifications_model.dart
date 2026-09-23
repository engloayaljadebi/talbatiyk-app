import 'dart:convert';

class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.data,
    required this.isRead,
    required this.readAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      data: _readData(json['data']),
      isRead: json['is_read'] as bool? ?? false,
      readAt: _readDateTime(json['read_at']),
      createdAt:
          _readDateTime(json['created_at']) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      updatedAt:
          _readDateTime(json['updated_at']) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'type': type,
      'title': title,
      'body': body,
      'data': data,
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  static Map<String, dynamic> decodeData(String value) {
    try {
      final decoded = jsonDecode(value);

      if (decoded is Map) {
        return Map<String, dynamic>.unmodifiable(
          decoded.map((key, value) => MapEntry(key.toString(), value)),
        );
      }
    } catch (_) {
      // Corrupt cached metadata must not prevent the timeline from loading.
    }

    return const <String, dynamic>{};
  }

  static Map<String, dynamic> _readData(Object? value) {
    if (value is Map) {
      return Map<String, dynamic>.unmodifiable(
        value.map((key, item) => MapEntry(key.toString(), item)),
      );
    }

    return const <String, dynamic>{};
  }

  static DateTime? _readDateTime(Object? value) {
    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }
}

// Temporary compatibility alias for the pre-existing scaffold.
// It can be removed once the Notifications feature is fully migrated.
typedef NotificationsModel = NotificationModel;
