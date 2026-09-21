import 'package:talbatiyk_api/talbatiyk_api.dart';

import '../../domain/entities/notifications_entity.dart';
import '../models/notifications_model.dart';

class NotificationsMapper {
  static NotificationModel fromResource(NotificationResource resource) {
    final createdAt = resource.createdAt;

    if (createdAt == null) {
      throw const FormatException(
        'Notification response does not contain created_at.',
      );
    }

    final updatedAt = resource.updatedAt;

    if (updatedAt == null) {
      throw const FormatException(
        'Notification response does not contain updated_at.',
      );
    }

    final metadata = <String, dynamic>{};

    for (final entry in resource.data.entries) {
      metadata[entry.key] = _normalizeJsonValue(entry.value?.value);
    }

    return NotificationModel(
      id: resource.id,
      type: resource.type,
      title: resource.title,
      body: resource.body,
      data: Map<String, dynamic>.unmodifiable(metadata),
      isRead: resource.isRead,
      readAt: resource.readAt?.toUtc(),
      createdAt: createdAt.toUtc(),
      updatedAt: updatedAt.toUtc(),
    );
  }

  static dynamic _normalizeJsonValue(Object? value) {
    if (value == null || value is bool || value is num || value is String) {
      return value;
    }

    if (value is List) {
      return List<dynamic>.unmodifiable(
        value.map<dynamic>(_normalizeJsonValue),
      );
    }

    if (value is Map) {
      final normalized = <String, dynamic>{};

      for (final entry in value.entries) {
        normalized[entry.key.toString()] = _normalizeJsonValue(entry.value);
      }

      return Map<String, dynamic>.unmodifiable(normalized);
    }

    throw FormatException(
      'Unsupported notification metadata value: '
      '${value.runtimeType}.',
    );
  }

  static NotificationsEntity toEntity(NotificationsModel model) {
    return NotificationsEntity(
      id: model.id,
      type: model.type,
      title: model.title,
      body: model.body,
      data: Map<String, dynamic>.unmodifiable(model.data),
      isRead: model.isRead,
      readAt: model.readAt,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }
}
