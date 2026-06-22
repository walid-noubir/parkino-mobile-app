import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:parkino/models/slot_reservation.dart';
import 'package:parkino/services/slot_reservation_service.dart';
import 'package:parkino/utils/cleanup_firestore.dart';
import 'package:parkino/providers/reservation_notification_provider.dart';
import 'package:parkino/providers/firebase_auth_provider.dart';

/// Provider pour gérer les réservations de courte durée des places de parking
class SlotReservationProvider extends ChangeNotifier {
  final SlotReservationService _service = SlotReservationService();
  static bool _cleanupDone = false;
  Timer? _cleanupTimer;

  // État
  SlotReservation? _currentReservation;
  List<SlotReservation> _activeReservations = [];
  bool _isLoading = false;
  String? _error;
  int _cleanupCount = 0;
  
  // Référence au provider de notifications et auth
  NotificationProvider? _notificationProvider;
  FirebaseAuthProvider? _authProvider;
  String? _lastAuthUser;

  SlotReservationProvider() {
    // Clean up orphaned collections only once at startup
    if (!_cleanupDone) {
      _cleanupDone = true;
      deleteOrphanedReservationsCollection();
    }
    
    // Start periodic cleanup timer (every 30 seconds to check for expired reservations)
    _startCleanupTimer();
  }
  
  /// Définit la référence au NotificationProvider
  void setNotificationProvider(NotificationProvider notificationProvider) {
    _notificationProvider = notificationProvider;
  }

  ///  NEW: Set up auth listener to auto-reset on auth state changes
  void setupAuthListener(FirebaseAuthProvider authProvider) {
    _authProvider = authProvider;
    _lastAuthUser = authProvider.user?.uid;
    
    // Listen to auth state changes
    authProvider.addListener(_onAuthStateChanged);
    print('🔄 SlotReservationProvider is now listening to auth changes');
  }

  ///  NEW: Auto-reset when user changes
  void _onAuthStateChanged() {
    if (_authProvider == null) return;
    
    final currentUserId = _authProvider!.user?.uid;
    
    // If user was logged in and is now logged out, reset
    if (_lastAuthUser != null && currentUserId == null) {
      print('🔄 Auth state changed: User logged out. Resetting SlotReservationProvider');
      resetOnLogout();
    }
    
    // If user changed (logged out then another user logged in), reset
    if (currentUserId != null && currentUserId != _lastAuthUser) {
      print('🔄 Auth state changed: Different user logged in. Resetting SlotReservationProvider');
      resetOnLogout();
    }
    
    _lastAuthUser = currentUserId;
  }

  // Getters
  SlotReservation? get currentReservation => _currentReservation;
  List<SlotReservation> get activeReservations => _activeReservations;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get cleanupCount => _cleanupCount;

  /// Réserve une place
  Future<SlotReservation> reserveSlot({
    required String slotId,
    required int slotNumber,
    required String userId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      //  CRITICAL FIX: Validate userId at provider level
      if (userId.isEmpty) {
        throw Exception('Erreur d\'authentification: L\'utilisateur n\'est pas connecté correctement.');
      }

      print('📱 [Provider] Attempting to reserve slot $slotNumber for user: $userId');

      final reservation = await _service.reserveSlot(
        slotId: slotId,
        slotNumber: slotNumber,
        userId: userId,
      );
      
      _currentReservation = reservation;
      
      // Ajouter une notification de réservation
      if (_notificationProvider != null) {
        _notificationProvider!.addReservationNotification(
          title: 'Place réservée',
          spotNumber: slotNumber,
          code: reservation.code,
          reservationDuration: const Duration(minutes: 5),
          userId: userId,
        );
      }
      
      print(' Slot reserved in provider: ${reservation.code}');
      
      return reservation;
    } catch (e) {
      _error = e.toString();
      print(' Error reserving slot: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Annule une réservation
  Future<void> cancelReservation({
    required String slotId,
    required String reservationId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.cancelReservation(
        slotId: slotId,
        reservationId: reservationId,
      );

      if (_currentReservation?.id == reservationId) {
        _currentReservation = null;
        // Annuler le timer de notification
        if (_notificationProvider != null) {
          _notificationProvider!.cancelActiveReservation();
        }
      }

      print(' Reservation cancelled in provider: $reservationId');
    } catch (e) {
      _error = e.toString();
      print(' Error cancelling reservation: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Marque une réservation comme utilisée
  Future<void> markAsUsed({
    required String slotId,
    required String reservationId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.markReservationAsUsed(
        slotId: slotId,
        reservationId: reservationId,
      );

      if (_currentReservation?.id == reservationId) {
        _currentReservation = _currentReservation?.copyWith(
          status: SlotReservationStatus.used,
          used: true,
        );
      }

      print(' Reservation marked as used in provider: $reservationId');
    } catch (e) {
      _error = e.toString();
      print(' Error marking as used: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Obtient la réservation pour une place spécifique
  Future<SlotReservation?> getReservationForSlot(String slotId) async {
    try {
      final reservation = await _service.getReservationForSlot(slotId);
      return reservation;
    } catch (e) {
      print(' Error getting slot reservation: $e');
      return null;
    }
  }

  /// Vérifie si une place a une réservation active
  Future<bool> hasActiveReservationForSlot(String slotId) async {
    try {
      final reservation = await _service.getReservationForSlot(slotId);
      if (reservation == null) return false;
      // Vérifier si la réservation n'est pas expirée
      return !reservation.isExpired && reservation.status == SlotReservationStatus.active;
    } catch (e) {
      print('⚠️ Error checking reservation: $e');
      return false;
    }
  }

  /// Vérifie si l'utilisateur a une réservation active
  Future<bool> hasActiveReservation(String userId) async {
    try {
      return await _service.hasActiveReservation(userId);
    } catch (e) {
      print('⚠️ Error checking user active reservation: $e');
      return false;
    }
  }

  /// Obtient la réservation active de l'utilisateur (s'il en a une)
  Future<SlotReservation?> getUserActiveReservation(String userId) async {
    try {
      return await _service.getUserActiveReservation(userId);
    } catch (e) {
      print('⚠️ Error getting user active reservation: $e');
      return null;
    }
  }

  /// Obtient toutes les réservations actives de l'utilisateur
  Future<List<SlotReservation>> getUserActiveReservations(String userId) async {
    try {
      return await _service.getUserActiveReservations(userId);
    } catch (e) {
      print('⚠️ Error getting user active reservations: $e');
      return [];
    }
  }

  /// Charge les réservations actives
  Future<void> loadActiveReservations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _activeReservations = await _service.getExpiredReservations();
      // On récupère les réservations expirées par erreur, on doit les filtrer
      // Mais pour maintenant, on va les charger via le stream
      print(' Loaded active reservations: ${_activeReservations.length}');
    } catch (e) {
      _error = e.toString();
      print(' Error loading active reservations: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Stream des réservations actives
  Stream<List<SlotReservation>> getActiveReservationsStream() {
    return _service.getActiveReservationsStream();
  }

  /// Nettoie les réservations expirées
  Future<void> cleanupExpiredReservations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cleanupCount = await _service.cleanupExpiredReservations();
      print(' Cleaned up $_cleanupCount expired reservations');
    } catch (e) {
      _error = e.toString();
      print(' Error during cleanup: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Efface l'erreur actuelle
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Réinitialise la réservation courante
  void resetCurrentReservation() {
    _currentReservation = null;
    notifyListeners();
  }

  ///  NEW: Complete reset when user logs out
  /// This ensures no data from previous user persists
  void resetOnLogout() {
    print('🔄 Resetting SlotReservationProvider due to logout');
    _currentReservation = null;
    _activeReservations = [];
    _error = null;
    _cleanupCount = 0;
    notifyListeners();
  }

  /// Démarre le timer de nettoyage périodique (toutes les 30 secondes)
  void _startCleanupTimer() {
    // Cancel existing timer if any
    _cleanupTimer?.cancel();
    
    // Start new periodic cleanup timer
    _cleanupTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      cleanupExpiredReservations();
    });
    
    print('🔄 Started periodic cleanup timer (every 30 seconds)');
  }

  /// Arrête le timer de nettoyage périodique
  void _stopCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
    print('⏹️ Stopped periodic cleanup timer');
  }

  @override
  void dispose() {
    _stopCleanupTimer();
    //  NEW: Remove auth listener when provider is disposed
    if (_authProvider != null) {
      _authProvider!.removeListener(_onAuthStateChanged);
      print('🔄 Removed auth listener from SlotReservationProvider');
    }
    super.dispose();
  }
}
