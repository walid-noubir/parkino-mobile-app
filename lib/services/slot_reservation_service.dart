import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:parkino/models/slot_reservation.dart';

/// Service pour gérer les réservations courtes (5 minutes) des places de parking
class SlotReservationService {
  static const int _reservationDurationMinutes = 5;
  static const String _parkingsCollection = 'parkings';
  static const String _mainParkingDoc = 'main_parking';
  static const String _floorsCollection = 'floors';
  static const String _etage2 = 'etage_2';
  static const String _slotsSubCollection = 'slots';
  static const String _reservationsSubCollection = 'slot_reservations';

  final FirebaseFirestore _firestore;

  SlotReservationService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Génère un code aléatoire de 4 chiffres (1000-9999)
  String _generateReservationCode() {
    final random = Random();
    return (1000 + random.nextInt(9000)).toString();
  }

  /// Réserve une place avec une transaction Firestore sécurisée
  Future<SlotReservation> reserveSlot({
    required String slotId,
    required int slotNumber,
    required String userId,
  }) async {
    try {
      print('🔄 Attempting to reserve slot: $slotId for user: $userId');

      // CRITICAL FIX: Validate userId before checking
      if (userId.isEmpty) {
        print('ERROR: userId is empty or invalid!');
        throw Exception('Erreur d\'authentification: L\'utilisateur n\'est pas connecté correctement.');
      }

      // VÉRIFICATION: L'utilisateur n'a pas déjà une réservation active
      print('🔍 Checking if user $userId already has an active reservation...');
      final hasActive = await hasActiveReservation(userId);
      if (hasActive) {
        final existingReservation = await getUserActiveReservation(userId);
        print('User $userId already has an active reservation');
        print('   Existing reservation: Slot #${existingReservation?.slotNumber}, Code: ${existingReservation?.code}');
        throw Exception('Vous avez déjà une réservation active (Place #${existingReservation?.slotNumber}).\nVous ne pouvez réserver qu\'une seule place à la fois.');
      }
      
      print('User $userId does NOT have an active reservation. Proceeding with reservation...');

      final slotRef = _firestore
          .collection(_parkingsCollection)
          .doc(_mainParkingDoc)
          .collection(_floorsCollection)
          .doc(_etage2)
          .collection(_slotsSubCollection)
          .doc(slotId);

      // IMPORTANT: Reservations are stored as a subcollection OF THIS SLOT
      final reservationsRef = slotRef.collection(_reservationsSubCollection);

      print('📍 Full path: parkings/$_mainParkingDoc/floors/$_etage2/slots/$slotId');

      // VÉRIFICATION PRÉ-TRANSACTION
      print('🔍 Verifying slot exists before transaction...');
      final preCheckSnapshot = await slotRef.get();
      if (!preCheckSnapshot.exists) {
        print('SLOT DOES NOT EXIST at path: $slotRef');
        throw Exception('Slot DOES NOT EXIST: $slotId');
      }
      print('Slot exists!');

      // Utilise une transaction pour sécuriser la réservation
      final reservation = await _firestore.runTransaction<SlotReservation>(
        (transaction) async {
          print('📖 Reading slot data in transaction...');
          final slotSnapshot = await transaction.get(slotRef);

          if (!slotSnapshot.exists) {
            throw Exception('Slot $slotId does not exist in transaction');
          }

          final slotData = slotSnapshot.data() as Map<String, dynamic>?;
          if (slotData == null) {
            throw Exception('Slot data is null for $slotId');
          }
          
          final status = slotData['status'] as String? ?? 'free';
          final isReserved = slotData['isReserved'] as bool? ?? false;

          print('📊 Slot data: status=$status, isReserved=$isReserved');

          if (status == 'occupied') {
            throw Exception('Slot $slotId is already occupied');
          }

          if (isReserved) {
            throw Exception('Slot $slotId is already reserved');
          }

          // Générer le code et les timestamps
          final code = _generateReservationCode();
          final now = DateTime.now();
          final expiresAt = now.add(Duration(minutes: _reservationDurationMinutes));
          const uuid = Uuid();
          final reservationId = uuid.v4();

          print('🎫 Generated code: $code');
          print('⏰ Created: $now, Expires: $expiresAt');

          // Créer la réservation
          final newReservation = SlotReservation(
            id: reservationId,
            slotId: slotId,
            slotNumber: slotNumber,
            floor: 2,
            code: code,
            userId: userId,
            status: SlotReservationStatus.active,
            createdAt: now,
            expiresAt: expiresAt,
            used: false,
          );

          print('📝 Reservation object created: ID=$reservationId');

          // Mettre à jour le slot
          print('🔄 Updating slot document...');
          transaction.update(slotRef, {
            'status': 'free',            // Reste LIBRE (pas occupied)
            'isReserved': true,          // Mais marquée réservée
            'reservationId': reservationId,
            'reservationCode': code,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          print('Slot update queued');

          // Créer la réservation dans la sous-collection
          print('🔄 Creating reservation document in sub-collection...');
          final reservationJson = newReservation.toJson();
          print('   JSON data: $reservationJson');
          
          transaction.set(
            reservationsRef.doc(reservationId),
            reservationJson,
          );
          print('Reservation document set queued');

          print('Slot reserved successfully: $slotId with code: $code');
          return newReservation;
        },
      );

      return reservation;
    } on FirebaseException catch (e) {
      print('Firebase Error reserving slot: ${e.code} - ${e.message}');
      print('   Stack: ${e.stackTrace}');
      rethrow;
    } catch (e) {
      print('Error reserving slot: $e');
      if (e is FormatException) {
        print('   FormatException: $e');
      }
      rethrow;
    }
  }

  /// Annule une réservation avec transaction
  Future<void> cancelReservation({
    required String slotId,
    required String reservationId,
  }) async {
    try {
      print('🔄 Cancelling reservation: $reservationId for slot: $slotId');

      final slotRef = _firestore
          .collection(_parkingsCollection)
          .doc(_mainParkingDoc)
          .collection(_floorsCollection)
          .doc(_etage2)
          .collection(_slotsSubCollection)
          .doc(slotId);

      final reservationRef = slotRef
          .collection(_reservationsSubCollection)
          .doc(reservationId);

      await _firestore.runTransaction<void>((transaction) async {
        transaction.update(slotRef, {
          'status': 'free',                       // Remettre à libre pour TOUS
          'isReserved': false,
          'reservationId': null,
          'reservationCode': null,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        transaction.update(reservationRef, {
          'status': 'expired',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      print('Reservation cancelled: $reservationId');
    } catch (e) {
      print('Error cancelling reservation: $e');
      rethrow;
    }
  }

  /// Marque une réservation comme utilisée
  Future<void> markReservationAsUsed({
    required String slotId,
    required String reservationId,
  }) async {
    try {
      print('🔄 Marking reservation as used: $reservationId');

      final slotRef = _firestore
          .collection(_parkingsCollection)
          .doc(_mainParkingDoc)
          .collection(_floorsCollection)
          .doc(_etage2)
          .collection(_slotsSubCollection)
          .doc(slotId);

      final reservationRef = slotRef
          .collection(_reservationsSubCollection)
          .doc(reservationId);

      await _firestore.runTransaction<void>((transaction) async {
        // Mark slot as free
        transaction.update(slotRef, {
          'status': 'free',                       // Remettre à libre pour TOUS
          'isReserved': false,
          'reservationId': null,
          'reservationCode': null,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Mark reservation as used
        transaction.update(reservationRef, {
          'status': 'used',
          'used': true,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      print('Reservation marked as used: $reservationId');
    } catch (e) {
      print('Error marking reservation as used: $e');
      rethrow;
    }
  }

  /// Obtient une réservation par ID
  Future<SlotReservation?> getReservation({
    required String slotId,
    required String reservationId,
  }) async {
    try {
      final slotRef = _firestore
          .collection(_parkingsCollection)
          .doc(_mainParkingDoc)
          .collection(_floorsCollection)
          .doc(_etage2)
          .collection(_slotsSubCollection)
          .doc(slotId);

      final doc = await slotRef
          .collection(_reservationsSubCollection)
          .doc(reservationId)
          .get();

      if (!doc.exists) return null;
      return SlotReservation.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      print('Error getting reservation: $e');
      rethrow;
    }
  }

  /// Stream des réservations actives
  Stream<List<SlotReservation>> getActiveReservationsStream() {
    return _firestore
        .collection(_parkingsCollection)
        .doc(_mainParkingDoc)
        .collection(_floorsCollection)
        .doc(_etage2)
        .collection(_slotsSubCollection)
        .snapshots()
        .asyncMap((slotsSnapshot) async {
          final allReservations = <SlotReservation>[];

          for (final slotDoc in slotsSnapshot.docs) {
            final resSnapshot = await slotDoc.reference
                .collection(_reservationsSubCollection)
                .where('status', isEqualTo: 'active')
                .get();

            allReservations.addAll(
              resSnapshot.docs
                  .map((doc) => SlotReservation.fromJson(doc.data()))
                  .where((r) => !r.isExpired)
                  .toList(),
            );
          }

          return allReservations;
        });
  }

  /// Récupère une réservation pour une place spécifique
  Future<SlotReservation?> getReservationForSlot(String slotId) async {
    try {
      final slotRef = _firestore
          .collection(_parkingsCollection)
          .doc(_mainParkingDoc)
          .collection(_floorsCollection)
          .doc(_etage2)
          .collection(_slotsSubCollection)
          .doc(slotId);

      final snapshot = await slotRef
          .collection(_reservationsSubCollection)
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      final reservation =
          SlotReservation.fromJson(snapshot.docs.first.data());

      if (reservation.isExpired) return null;

      return reservation;
    } catch (e) {
      print('Error getting slot reservation: $e');
      rethrow;
    }
  }

  /// Nettoie les réservations expirées
  Future<int> cleanupExpiredReservations() async {
    try {
      print('🧹 Cleaning up expired reservations...');

      final now = DateTime.now();
      int cleanedCount = 0;

      // Get all slots for etage_2
      final slotsSnapshot = await _firestore
          .collection(_parkingsCollection)
          .doc(_mainParkingDoc)
          .collection(_floorsCollection)
          .doc(_etage2)
          .collection(_slotsSubCollection)
          .get();

      // For each slot, check its reservations
      for (final slotDoc in slotsSnapshot.docs) {
        final slotId = slotDoc.id;
        final slotRef = slotDoc.reference;

        // Get active reservations for this slot
        final resSnapshot = await slotRef
            .collection(_reservationsSubCollection)
            .where('status', isEqualTo: 'active')
            .get();

        // Check each reservation
        for (final resDoc in resSnapshot.docs) {
          final reservation = SlotReservation.fromJson(resDoc.data());

          // If expired, clean it up
          if (now.isAfter(reservation.expiresAt)) {
            try {
              await _firestore.runTransaction<void>((transaction) async {
                // Verify slot is still reserved by this reservation
                final currentSlot = await transaction.get(slotRef);
                if (currentSlot.exists) {
                  final data = currentSlot.data() as Map<String, dynamic>?;
                  if (data?['reservationId'] == reservation.id) {
                    // Clear the slot
                    transaction.update(slotRef, {
                      'status': 'free',                    // Remettre à libre pour TOUS
                      'isReserved': false,
                      'reservationId': null,
                      'reservationCode': null,
                      'updatedAt': FieldValue.serverTimestamp(),
                    });
                  }
                }

                // Mark reservation as expired
                transaction.update(resDoc.reference, {
                  'status': 'expired',
                  'updatedAt': FieldValue.serverTimestamp(),
                });
              });

              cleanedCount++;
              print('   ✓ Cleaned up reservation ${reservation.id} from slot $slotId');
            } catch (e) {
              print('   Error cleaning up reservation: $e');
            }
          }
        }
      }

      print('Cleanup complete: $cleanedCount expired reservations cleaned');
      return cleanedCount;
    } catch (e) {
      print('Error cleaning up reservations: $e');
      rethrow;
    }
  }

  /// Obtient toutes les réservations expirées
  Future<List<SlotReservation>> getExpiredReservations() async {
    try {
      final now = DateTime.now();
      final result = <SlotReservation>[];

      // Get all slots for etage_2
      final slotsSnapshot = await _firestore
          .collection(_parkingsCollection)
          .doc(_mainParkingDoc)
          .collection(_floorsCollection)
          .doc(_etage2)
          .collection(_slotsSubCollection)
          .get();

      // For each slot, get expired reservations
      for (final slotDoc in slotsSnapshot.docs) {
        final resSnapshot = await slotDoc.reference
            .collection(_reservationsSubCollection)
            .where('status', isEqualTo: 'active')
            .get();

        final expiredReservations = resSnapshot.docs
            .map((doc) => SlotReservation.fromJson(doc.data()))
            .where((r) => now.isAfter(r.expiresAt))
            .toList();

        result.addAll(expiredReservations);
      }

      return result;
    } catch (e) {
      print('Error getting expired reservations: $e');
      rethrow;
    }
  }

  /// Obtient toutes les réservations actives d'un utilisateur
  Future<List<SlotReservation>> getUserActiveReservations(String userId) async {
    try {
      print('🔍 Getting active reservations for user: $userId');
      
      // CRITICAL FIX: Validate userId before checking
      if (userId.isEmpty) {
        print('WARNING: userId is empty. Returning empty list.');
        return [];
      }
      
      final userReservations = <SlotReservation>[];

      // Get all slots for etage_2
      final slotsSnapshot = await _firestore
          .collection(_parkingsCollection)
          .doc(_mainParkingDoc)
          .collection(_floorsCollection)
          .doc(_etage2)
          .collection(_slotsSubCollection)
          .get();

      print('📊 Checking ${slotsSnapshot.docs.length} slots for user $userId');

      // For each slot, check reservations
      for (final slotDoc in slotsSnapshot.docs) {
        try {
          // SIMPLIFIED: Only filter by status in Firestore, filter userId locally
          // This avoids needing a composite index and ensures reliable results
          final resSnapshot = await slotDoc.reference
              .collection(_reservationsSubCollection)
              .where('status', isEqualTo: 'active')
              .get();

          print('   Slot ${slotDoc.id}: Found ${resSnapshot.docs.length} active reservation(s)');

          // Filter for this user's active, non-expired reservations
          final activeReservations = resSnapshot.docs
              .map((doc) => SlotReservation.fromJson(doc.data()))
              .where((r) {
                // CRITICAL: Match userId exactly (case-sensitive as Firebase Auth UIDs are)
                final isUserMatch = r.userId == userId;
                final isActive = r.status == SlotReservationStatus.active;
                final isNotExpired = !r.isExpired;
                
                if (!isUserMatch) {
                  print('   ✓ Reservation belongs to different user: ${r.userId} vs $userId');
                  return false;
                }
                
                if (!isActive) {
                  print('   ⚠️ Reservation not active: ${r.status.value}');
                  return false;
                }
                
                if (isNotExpired) {
                  print('   ✓ Found ACTIVE reservation: Slot #${r.slotNumber}, Code: ${r.code}, Expires in: ${r.timeRemaining}');
                  return true;
                } else {
                  print('   ⚠️ Reservation expired: ${r.timeRemaining}');
                  return false;
                }
              })
              .toList();

          userReservations.addAll(activeReservations);
        } catch (slotError) {
          print('⚠️ Error checking slot ${slotDoc.id}: $slotError');
          // Continue with next slot instead of failing
          continue;
        }
      }

      print('Found ${userReservations.length} active reservation(s) for user $userId');
      return userReservations;
    } catch (e) {
      print('Error getting user active reservations: $e');
      rethrow;
    }
  }

  /// Vérifie si un utilisateur a une réservation active
  Future<bool> hasActiveReservation(String userId) async {
    try {
      final reservations = await getUserActiveReservations(userId);
      return reservations.isNotEmpty;
    } catch (e) {
      print('Error checking active reservation: $e');
      return false;
    }
  }

  /// Obtient la réservation active d'un utilisateur (s'il en a une)
  Future<SlotReservation?> getUserActiveReservation(String userId) async {
    try {
      final reservations = await getUserActiveReservations(userId);
      if (reservations.isEmpty) return null;
      return reservations.first;
    } catch (e) {
      print('Error getting user active reservation: $e');
      return null;
    }
  }
}
