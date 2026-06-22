import 'package:flutter/foundation.dart';

/// Modèle pour une notification
class AppNotification {
  final String id;
  final String title;
  final String message;
  final String type; // 'reservation', 'warning', 'success', 'info'
  final int spotNumber;
  final String code; // Code de réservation si applicable
  final DateTime timestamp;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.spotNumber,
    this.code = '',
    required this.timestamp,
    this.isRead = false,
  });

  /// Format the timestamp for display
  String get formattedTime {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) {
      return 'À l\'instant';
    } else if (diff.inMinutes < 60) {
      return 'Il y a ${diff.inMinutes} min';
    } else if (diff.inHours < 24) {
      return 'Il y a ${diff.inHours}h';
    } else if (diff.inDays < 7) {
      return 'Il y a ${diff.inDays}j';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  /// Format the full date-time
  String get formattedDateTime {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} à ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

/// Provider pour gérer les notifications
class NotificationProvider extends ChangeNotifier {
  List<AppNotification> _notifications = [];
  bool _unreadExists = false;

  // Getters
  List<AppNotification> get notifications => _notifications;
  bool get unreadExists => _unreadExists;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Ajoute une nouvelle notification
  void addNotification({
    required String title,
    required String message,
    required String type,
    required int spotNumber,
    String code = '',
  }) {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: type,
      spotNumber: spotNumber,
      code: code,
      timestamp: DateTime.now(),
      isRead: false,
    );

    _notifications.insert(0, notification); // Ajouter au début de la liste
    _unreadExists = true;
    notifyListeners();

    print('🔔 Notification added: $type - $message');
  }

  /// Marque une notification comme lue
  void markAsRead(String notificationId) {
    try {
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index].isRead = true;
        _updateUnreadStatus();
        notifyListeners();
      }
    } catch (e) {
      print(' Error marking notification as read: $e');
    }
  }

  /// Marque toutes les notifications comme lues
  void markAllAsRead() {
    for (var notification in _notifications) {
      notification.isRead = true;
    }
    _updateUnreadStatus();
    notifyListeners();
  }

  /// Supprime une notification
  void deleteNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    _updateUnreadStatus();
    notifyListeners();
  }

  /// Supprime toutes les notifications
  void clearAllNotifications() {
    _notifications.clear();
    _updateUnreadStatus();
    notifyListeners();
  }

  /// Met à jour le statut des notifications non lues
  void _updateUnreadStatus() {
    _unreadExists = _notifications.any((n) => !n.isRead);
  }

  /// Récupère les notifications par type
  List<AppNotification> getNotificationsByType(String type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  /// Récupère les notifications de réservation
  List<AppNotification> getReservationNotifications() {
    return _notifications.where((n) => n.type == 'reservation').toList();
  }
}
