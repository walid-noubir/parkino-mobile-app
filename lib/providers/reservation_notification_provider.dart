import 'package:flutter/foundation.dart';
import 'package:parkino/services/reservation_timer_service.dart';
import 'package:parkino/services/slot_reservation_service.dart';
import 'package:parkino/localization/app_localizations.dart';

/// Modèle pour une notification avec support des réservations
class AppNotification {
  final String id;
  final String title;
  final String message;
  final String type; // 'reservation', 'warning', 'success', 'info', 'expiration'
  final int spotNumber;
  final String code; // Code de réservation si applicable
  final String userId; //  ID de l'utilisateur qui a créé la notification
  final DateTime timestamp;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.spotNumber,
    required this.userId,
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

/// Provider pour gérer les notifications avec support des réservations
class NotificationProvider extends ChangeNotifier {
  List<AppNotification> _notifications = [];
  bool _unreadExists = false;
  
  // Timer et reservation actifs
  ReservationTimer? _activeTimer;
  String? _currentUserId; //  Tracker l'utilisateur connecté
  final ReservationTimerService _timerService = ReservationTimerService();

  // Getters
  List<AppNotification> get notifications => _notifications;
  bool get unreadExists => _unreadExists;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  ReservationTimer? get activeTimer => _activeTimer;

  ///  Définir l'utilisateur actuel et nettoyer les anciennes données
  void setCurrentUser(String userId) {
    if (_currentUserId != userId) {
      print('🔄 Changement d\'utilisateur: $_currentUserId → $userId');
      _currentUserId = userId;
      // Nettoyer les timers/notifications de l'ancien utilisateur
      _activeTimer = null;
      notifyListeners();
    }
  }

  ///  Obtenir les notifications filtrées pour l'utilisateur actuel
  List<AppNotification> getNotificationsForCurrentUser() {
    if (_currentUserId == null) return [];
    return _notifications.where((n) => n.userId == _currentUserId).toList();
  }

  ///  Ajoute une nouvelle notification pour une réservation
  void addReservationNotification({
    required String title,
    required int spotNumber,
    required String code,
    required Duration reservationDuration,
    required String userId,
  }) {
    // Ajouter la notification
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: '${AppLocalizations.t('you_have_reserved')}$spotNumber. ${AppLocalizations.t('code')}: $code',
      type: 'reservation',
      spotNumber: spotNumber,
      code: code,
      userId: userId, //  Enregistrer le userId
      timestamp: DateTime.now(),
      isRead: false,
    );

    _notifications.insert(0, notification);
    _unreadExists = true;

    // Créer et gérer le timer SEULEMENT si c'est l'utilisateur actuel
    if (userId == _currentUserId) {
      _activeTimer = _timerService.createTimer(
        reservationId: code,
        spotNumber: spotNumber,
        duration: reservationDuration,
      );

      // Callback lors du tick du timer
      _activeTimer!.onTick = (remainingTime) {
        notifyListeners(); // Rafraîchir pour mettre à jour l'affichage du timer
      };

      // Callback quand le timer expire
      _activeTimer!.onExpired = () {
        _handleTimerExpired(spotNumber, code, userId);
      };
    }

    notifyListeners();
    print('🔔 Reservation notification added: Place #$spotNumber, Code: $code, User: $userId');
  }

  /// Gère l'expiration du timer
  void _handleTimerExpired(int spotNumber, String code, String userId) {
    // Créer une notification d'expiration SEULEMENT si c'est l'utilisateur actuel
    if (userId == _currentUserId) {
      final expiredNotif = AppNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Réservation expirée',
        message: 'Votre réservation de la place n°$spotNumber a expiré.',
        type: 'expiration',
        spotNumber: spotNumber,
        code: code,
        userId: userId,
        timestamp: DateTime.now(),
        isRead: false,
      );

      _notifications.insert(0, expiredNotif);
      _activeTimer = null;
      notifyListeners();
    }

    print('⏰ Reservation expired for spot #$spotNumber');
  }

  /// Ajoute une notification simple
  void addNotification({
    required String title,
    required String message,
    required String type,
    required int spotNumber,
    required String userId,
    String code = '',
  }) {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: type,
      spotNumber: spotNumber,
      code: code,
      userId: userId, //  Enregistrer le userId
      timestamp: DateTime.now(),
      isRead: false,
    );

    _notifications.insert(0, notification);
    _unreadExists = true;
    notifyListeners();

    print('🔔 Notification added: $type - $message');
  }

  /// Annule la réservation active
  void cancelActiveReservation() {
    if (_activeTimer != null) {
      _timerService.cancelTimer(_activeTimer!.reservationId);
      _activeTimer = null;
      notifyListeners();
    }
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

  /// Efface toutes les notifications
  void clearAllNotifications() {
    _notifications.clear();
    _updateUnreadStatus();
    notifyListeners();
  }

  /// Met à jour le statut des notifications non lues
  void _updateUnreadStatus() {
    _unreadExists = _notifications.any((n) => !n.isRead);
  }

  /// Obtient les notifications par type
  List<AppNotification> getNotificationsByType(String type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  @override
  void dispose() {
    _timerService.cancelAllTimers();
    super.dispose();
  }
}
