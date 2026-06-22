import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parkino/models/index.dart';
import 'package:uuid/uuid.dart';

/// Service de gestion des réservations avec Firestore
class ReservationService {
  static const int expirationMinutes = 15; // Expiration après 15 minutes
  static const String _reservationsCollection = 'reservations';
  static const String _paymentsCollection = 'payments';

  final FirebaseFirestore _firestore;

  // Cache local pour les places - FLOOR 2 VIDE
  final List<ParkingSlot> _slots = [];

  ReservationService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Initialise les places disponibles (FLOOR 2 VIDE)
  void initializeSlots() {
    _slots.clear();
    // Floor 2 remains empty - no slots available
  }

  /// Retourne la liste des places du 2e étage
  List<ParkingSlot> getSecondFloorSlots() {
    return _slots;
  }

  /// Retourne les places disponibles
  List<ParkingSlot> getAvailableSlots() {
    return _slots.where((slot) => slot.isAvailable).toList();
  }

  /// Vérifie si une place est disponible
  bool isSlotAvailable(String slotId) {
    return _slots.firstWhere(
      (slot) => slot.id == slotId,
      orElse: () => ParkingSlot(id: 'UNKNOWN', floor: 2, isAvailable: false),
    ).isAvailable;
  }

  /// Crée une nouvelle réservation (avant paiement) - Async with Firestore
  Future<Reservation> createReservation({
    required String slotId,
    required int durationHours,
    required double price,
    required String userId,
  }) async {
    if (!isSlotAvailable(slotId)) {
      throw Exception('Place $slotId non disponible');
    }

    const uuid = Uuid();
    final now = DateTime.now();
    final expiresAt = now.add(Duration(minutes: expirationMinutes));
    final reservationStart = now;
    final reservationEnd = now.add(Duration(hours: durationHours));

    final reservation = Reservation(
      id: uuid.v4(),
      slotId: slotId,
      floor: 2,
      userId: userId,
      createdAt: now,
      expiresAt: expiresAt,
      reservationStart: reservationStart,
      reservationEnd: reservationEnd,
      durationHours: durationHours,
      price: price,
      status: ReservationStatus.pendingPayment,
      paymentId: null,
      qrCode: null,
      qrCodeUsed: false,
    );

    try {
      // Save to Firestore
      await _firestore
          .collection(_reservationsCollection)
          .doc(reservation.id)
          .set(reservation.toJson());

      // Update local cache
      _updateSlotAvailability(slotId, false);

      print(' Reservation created: ${reservation.id}');
      return reservation;
    } catch (e) {
      print(' Error creating reservation: $e');
      rethrow;
    }
  }

  /// Confirme une réservation après paiement réussi
  Future<Reservation> confirmReservation({
    required String reservationId,
    required String paymentId,
    required String qrCodeData,
  }) async {
    try {
      final doc = await _firestore
          .collection(_reservationsCollection)
          .doc(reservationId)
          .get();

      if (!doc.exists) {
        throw Exception('Réservation $reservationId non trouvée');
      }

      final reservation = Reservation.fromJson(doc.data() as Map<String, dynamic>);
      final confirmedReservation = reservation.copyWith(
        status: ReservationStatus.confirmed,
        paymentId: paymentId,
        qrCode: qrCodeData,
      );

      // Update in Firestore
      await _firestore
          .collection(_reservationsCollection)
          .doc(reservationId)
          .update(confirmedReservation.toJson());

      print(' Reservation confirmed: $reservationId');
      return confirmedReservation;
    } catch (e) {
      print(' Error confirming reservation: $e');
      rethrow;
    }
  }

  /// Annule une réservation
  Future<void> cancelReservation(String reservationId) async {
    try {
      final doc = await _firestore
          .collection(_reservationsCollection)
          .doc(reservationId)
          .get();

      if (doc.exists) {
        final reservation = Reservation.fromJson(doc.data() as Map<String, dynamic>);
        
        // Delete from Firestore
        await _firestore
            .collection(_reservationsCollection)
            .doc(reservationId)
            .delete();

        // Free the slot
        _updateSlotAvailability(reservation.slotId, true);
        print(' Reservation cancelled: $reservationId');
      }
    } catch (e) {
      print(' Error cancelling reservation: $e');
      rethrow;
    }
  }

  /// Marque une réservation comme utilisée
  Future<Reservation> markAsUsed(String reservationId) async {
    try {
      final doc = await _firestore
          .collection(_reservationsCollection)
          .doc(reservationId)
          .get();

      if (!doc.exists) {
        throw Exception('Réservation $reservationId non trouvée');
      }

      final reservation = Reservation.fromJson(doc.data() as Map<String, dynamic>);
      final usedReservation = reservation.copyWith(
        status: ReservationStatus.used,
        qrCodeUsed: true,
      );

      await _firestore
          .collection(_reservationsCollection)
          .doc(reservationId)
          .update(usedReservation.toJson());

      print(' Reservation marked as used: $reservationId');
      return usedReservation;
    } catch (e) {
      print(' Error marking reservation as used: $e');
      rethrow;
    }
  }

  /// Récupère une réservation par ID
  Future<Reservation?> getReservation(String reservationId) async {
    try {
      final doc = await _firestore
          .collection(_reservationsCollection)
          .doc(reservationId)
          .get();

      if (!doc.exists) return null;
      return Reservation.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      print(' Error getting reservation: $e');
      return null;
    }
  }

  /// Récupère toutes les réservations d'un utilisateur
  Future<List<Reservation>> getUserReservations(String userId) async {
    try {
      await handleExpiredReservations();

      final snapshot = await _firestore
          .collection(_reservationsCollection)
          .where('userId', isEqualTo: userId)
          .get();

      final reservations = snapshot.docs
          .map((doc) => Reservation.fromJson(doc.data()))
          .toList();

      // Sort by creation date (newest first)
      reservations.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return reservations;
    } catch (e) {
      print(' Error getting user reservations: $e');
      return [];
    }
  }

  /// Stream of user reservations (real-time updates)
  Stream<List<Reservation>> getUserReservationsStream(String userId) {
    return _firestore
        .collection(_reservationsCollection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final reservations = snapshot.docs
          .map((doc) => Reservation.fromJson(doc.data()))
          .toList();
      reservations.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return reservations;
    });
  }

  /// Récupère les réservations confirmées pour une place
  Future<List<Reservation>> getSlotReservations(String slotId) async {
    try {
      final snapshot = await _firestore
          .collection(_reservationsCollection)
          .where('slotId', isEqualTo: slotId)
          .where('status', isEqualTo: 'confirmed')
          .get();

      return snapshot.docs
          .map((doc) => Reservation.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print(' Error getting slot reservations: $e');
      return [];
    }
  }

  /// Gère l'expiration des réservations
  Future<void> handleExpiredReservations() async {
    try {
      final snapshot = await _firestore
          .collection(_reservationsCollection)
          .where('status', isEqualTo: 'pending_payment')
          .get();

      final now = DateTime.now();

      for (var doc in snapshot.docs) {
        final reservation = Reservation.fromJson(doc.data());
        
        if (reservation.expiresAt.isBefore(now)) {
          // Mark as expired
          await _firestore
              .collection(_reservationsCollection)
              .doc(doc.id)
              .update({'status': 'expired'});

          // Free the slot
          _updateSlotAvailability(reservation.slotId, true);
          print('   ⏰ Reservation expired: ${doc.id}');
        }
      }
    } catch (e) {
      print(' Error handling expired reservations: $e');
    }
  }

  /// Réinitialise les places dans Firestore (ADMIN FUNCTION)
  Future<void> resetAllParkingSlots() async {
    try {
      print('🔄 Resetting parking slots in Firestore...');
      
      // Effacer toutes les réservations
      final reservationsSnapshot = await _firestore
          .collection(_reservationsCollection)
          .get();
      for (var doc in reservationsSnapshot.docs) {
        await doc.reference.delete();
      }
      print(' All reservations deleted');
      
      // Effacer tous les paiements
      final paymentsSnapshot = await _firestore
          .collection(_paymentsCollection)
          .get();
      for (var doc in paymentsSnapshot.docs) {
        await doc.reference.delete();
      }
      print(' All payments deleted');
      
      // Clear local slots
      _slots.clear();
      print(' Parking slots reset to empty (Floor 2 remains closed)');
    } catch (e) {
      print(' Error resetting parking slots: $e');
      rethrow;
    }
  }

  /// Supprime COMPLÈTEMENT toutes les données du floor 2 (DESTRUCTIVE OPERATION)
  Future<void> deleteAllFloor2Data() async {
    try {
      print('🗑️  DELETING ALL FLOOR 2 DATA...');
      
      // 1. Effacer toutes les réservations du floor 2
      final reservationsSnapshot = await _firestore
          .collection(_reservationsCollection)
          .where('floor', isEqualTo: 2)
          .get();
      int reservationsDeleted = 0;
      for (var doc in reservationsSnapshot.docs) {
        await doc.reference.delete();
        reservationsDeleted++;
      }
      print(' Deleted $reservationsDeleted reservations from floor 2');
      
      // 2. Effacer tous les paiements associés aux réservations supprimées
      final paymentsSnapshot = await _firestore
          .collection(_paymentsCollection)
          .get();
      int paymentsDeleted = 0;
      for (var doc in paymentsSnapshot.docs) {
        final paymentData = doc.data();
        if (paymentData['floor'] == 2 || paymentData['floorNumber'] == 2) {
          await doc.reference.delete();
          paymentsDeleted++;
        }
      }
      print(' Deleted $paymentsDeleted payments from floor 2');
      
      // 3. Clear local slots
      _slots.clear();
      print(' Cleared all local parking slots');
      
      print(' ALL FLOOR 2 DATA COMPLETELY DELETED ');
      print('   - 0 reservations');
      print('   - 0 slots');
      print('   - 0 payments');
    } catch (e) {
      print(' Error deleting floor 2 data: $e');
      rethrow;
    }
  }

  /// Recharge la disponibilité des places depuis les réservations Firestore
  Future<void> refreshSlotsAvailability() async {
    try {
      // Floor 2 remains empty - no slots to refresh
      print('⚠️ Slots refresh skipped - Floor 2 is empty');
    } catch (e) {
      print('⚠️ Error refreshing slots availability: $e');
    }
  }

  /// Met à jour la disponibilité d'une place
  void _updateSlotAvailability(String slotId, bool available) {
    final index = _slots.indexWhere((slot) => slot.id == slotId);
    if (index != -1) {
      _slots[index] = _slots[index].copyWith(isAvailable: available);
    }
  }

  /// Retourne toutes les réservations (pour debug)
  Future<List<Reservation>> getAllReservations() async {
    try {
      await handleExpiredReservations();

      final snapshot = await _firestore
          .collection(_reservationsCollection)
          .get();

      return snapshot.docs
          .map((doc) => Reservation.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print(' Error getting all reservations: $e');
      return [];
    }
  }

  /// Efface toutes les données (pour testing)
  Future<void> clearAll() async {
    try {
      final snapshot = await _firestore.collection(_reservationsCollection).get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
      _slots.clear();
      print(' All data cleared - Floor 2 remains empty');
    } catch (e) {
      print(' Error clearing data: $e');
    }
  }
}
