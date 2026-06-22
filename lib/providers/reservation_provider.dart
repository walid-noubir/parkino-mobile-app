import 'package:flutter/foundation.dart';
import 'package:parkino/models/index.dart';
import 'package:parkino/services/index.dart';

/// Provider pour le service de réservation avec support Firestore
class ReservationProvider extends ChangeNotifier {
  final ReservationService _service = ReservationService();

  List<ParkingSlot> get availableSlots => _service.getAvailableSlots();
  List<ParkingSlot> get allSlots => _service.getSecondFloorSlots();

  ReservationProvider() {
    // Floor 2 remains empty - no initialization needed
    print(' ReservationProvider initialized - Floor 2 is empty');
  }

  /// Réinitialise tous les slots dans Firestore (ADMIN FUNCTION)
  Future<void> resetAllParkingSlots() async {
    print('🔄 Resetting all parking slots...');
    try {
      await _service.resetAllParkingSlots();
      print(' All parking slots reset successfully');
    } catch (e) {
      print(' Error resetting parking slots: $e');
    }
    notifyListeners();
  }

  /// Supprime COMPLÈTEMENT toutes les données du floor 2 (DESTRUCTIVE)
  Future<void> deleteAllFloor2Data() async {
    print('🗑️  DELETING ALL FLOOR 2 DATA...');
    try {
      await _service.deleteAllFloor2Data();
      print(' All floor 2 data deleted successfully');
      notifyListeners();
    } catch (e) {
      print(' Error deleting floor 2 data: $e');
    }
  }

  /// Recharge la disponibilité des places depuis Firestore
  Future<void> _refreshAvailableSlots() async {
    print('🔄 Refreshing slots availability...');
    try {
      await _service.refreshSlotsAvailability();
      print(' Slots refreshed');
    } catch (e) {
      print(' Error refreshing slots: $e');
    }
    notifyListeners();
  }

  // ============================================================
  // ASYNC METHODS FOR FIRESTORE OPERATIONS
  // ============================================================

  /// Crée une réservation (sauvegarde dans Firestore)
  Future<Reservation> createReservation({
    required String slotId,
    required int durationHours,
    required double price,
    required String userId,
  }) async {
    final reservation = await _service.createReservation(
      slotId: slotId,
      durationHours: durationHours,
      price: price,
      userId: userId,
    );
    notifyListeners();
    return reservation;
  }

  /// Confirme une réservation après paiement
  Future<Reservation> confirmReservation({
    required String reservationId,
    required String paymentId,
    required String qrCodeData,
  }) async {
    final reservation = await _service.confirmReservation(
      reservationId: reservationId,
      paymentId: paymentId,
      qrCodeData: qrCodeData,
    );
    notifyListeners();
    return reservation;
  }

  /// Annule une réservation
  Future<void> cancelReservation(String reservationId) async {
    await _service.cancelReservation(reservationId);
    notifyListeners();
  }

  /// Récupère une réservation par ID
  Future<Reservation?> getReservation(String reservationId) {
    return _service.getReservation(reservationId);
  }

  /// Récupère toutes les réservations d'un utilisateur
  Future<List<Reservation>> getUserReservations(String userId) async {
    // Handle expired reservations first
    await _service.handleExpiredReservations();
    return await _service.getUserReservations(userId);
  }

  /// Stream of user reservations (real-time updates from Firestore)
  Stream<List<Reservation>> getUserReservationsStream(String userId) {
    return _service.getUserReservationsStream(userId);
  }

  /// Marque une réservation comme utilisée
  Future<Reservation> markAsUsed(String reservationId) async {
    final reservation = await _service.markAsUsed(reservationId);
    notifyListeners();
    return reservation;
  }

  /// Vérifie la disponibilité d'une place
  bool isSlotAvailable(String slotId) {
    return _service.isSlotAvailable(slotId);
  }

  /// Recharge les places disponibles depuis Firestore (appeler avant d'afficher l'écran de réservation)
  Future<void> refreshAvailableSlots() async {
    await _refreshAvailableSlots();
  }

  /// Accès direct au service (pour uses avancés)
  ReservationService getService() => _service;
}
