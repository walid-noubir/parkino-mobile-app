import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'parking_models.dart';

/// Repository for accessing parking data from Firestore
class ParkingRepository {
  static const String _parkingsCollection = 'parkings';
  static const String _mainParkingDoc = 'main_parking';
  static const String _floorsCollection = 'floors';
  static const String _etage1 = 'etage_1';
  static const String _etage2 = 'etage_2';
  static const String _slotsSubCollection = 'slots';

  final FirebaseFirestore _firestore;

  ParkingRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Initialize the main parking structure:
  /// - Creates parkings/main_parking/floors/etage_1 with 8 slots
  /// - Creates parkings/main_parking/floors/etage_2 with 6 slots
  /// - Checks if documents exist before creating to avoid overwriting data
  Future<void> createMainParkingFloors() async {
    try {
      final mainParkingRef = _firestore
          .collection(_parkingsCollection)
          .doc(_mainParkingDoc);

      // Check if floors collection already exists
      final floorsCollection = mainParkingRef.collection(_floorsCollection);

      // Create Etage 1
      await _createFloor(
        floorsCollection,
        _etage1,
        floorNumber: 1,
        totalSpots: 8,
        slots: 8,
      );

      // Create Etage 2
      await _createFloor(
        floorsCollection,
        _etage2,
        floorNumber: 2,
        totalSpots: 6,
        slots: 6,
      );

      print('✅ Main parking structure initialized successfully');
    } catch (e) {
      print('❌ Error initializing main parking structure: $e');
      rethrow;
    }
  }

  /// Helper method to create a floor with its slots
  Future<void> _createFloor(
    CollectionReference floorsCollection,
    String floorId, {
    required int floorNumber,
    required int totalSpots,
    required int slots,
  }) async {
    final floorDocRef = floorsCollection.doc(floorId);

    // Check if floor document already exists
    final floorSnapshot = await floorDocRef.get();

    if (!floorSnapshot.exists) {
      // Create floor document
      await floorDocRef.set({
        'floorNumber': floorNumber,
        'totalSpots': totalSpots,
        'availableSpots': totalSpots,
        'occupiedSpots': 0,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('   ✓ Created floor $floorId with $totalSpots spots');
    } else {
      print('   ℹ Floor $floorId already exists, skipping...');
    }

    // Create slots for this floor
    await _createFloorSlots(floorDocRef, floorNumber, slots);
  }

  /// Helper method to create slots for a floor
  Future<void> _createFloorSlots(
    DocumentReference floorDocRef,
    int floorNumber,
    int slotsCount,
  ) async {
    final slotsCollection = floorDocRef.collection(_slotsSubCollection);

    for (int i = 1; i <= slotsCount; i++) {
      final slotId = 'slot_$i';
      final slotDocRef = slotsCollection.doc(slotId);

      // Check if slot already exists
      final slotSnapshot = await slotDocRef.get();

      if (!slotSnapshot.exists) {
        // Create slot document
        await slotDocRef.set({
          'slotNumber': i,
          'floor': floorNumber,
          'status': 'free',
          'isReserved': false,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        print('      ✓ Created slot_$i in floor $floorNumber');
      } else {
        print('      ℹ Slot_$i already exists, skipping...');
      }
    }
  }

  /// Reset and recreate the entire parking structure
  /// Deletes all existing floors and slots, then creates a fresh structure
  Future<void> resetAndCreateMainParkingFloors() async {
    try {
      final mainParkingRef = _firestore
          .collection(_parkingsCollection)
          .doc(_mainParkingDoc)
          .collection(_floorsCollection);

      print('🗑️ Deleting old structure...');

      // Delete all existing floors
      final floorsSnapshot = await mainParkingRef.get();
      for (var floorDoc in floorsSnapshot.docs) {
        final slotsCollection = floorDoc.reference.collection(_slotsSubCollection);
        final slotsSnapshot = await slotsCollection.get();

        // Delete all slots
        for (var slotDoc in slotsSnapshot.docs) {
          await slotDoc.reference.delete();
          print('      ✓ Deleted slot: ${slotDoc.id}');
        }

        // Delete the floor document
        await floorDoc.reference.delete();
        print('   ✓ Deleted floor: ${floorDoc.id}');
      }

      print('✅ Old structure deleted');

      // Create new structure
      await createMainParkingFloors();

      print('✅ Structure recreated successfully');
    } catch (e) {
      print('❌ Error resetting parking structure: $e');
      rethrow;
    }
  }

  /// Stream of parking summary (availableSpots, occupiedSpots, totalSpots)
  /// Listens to: parkings/main_parking document
  Stream<ParkingSummary> getParkingSummaryStream() {
    return _firestore
        .collection(_parkingsCollection)
        .doc(_mainParkingDoc)
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        // Return default if document doesn't exist yet
        return ParkingSummary(
          availableSpots: 8,
          occupiedSpots: 0,
          totalSpots: 8,
          updatedAt: DateTime.now(),
        );
      }
      return ParkingSummary.fromFirestore(doc.data() ?? {});
    });
  }

  /// Stream of all parking slots from Etage 1 (slot_1..slot_8)
  /// Listens to: parkings/main_parking/floors/etage_1/slots subcollection
  Stream<List<ParkingSlot>> getFloor1SlotsStream() {
    return _firestore
        .collection(_parkingsCollection)
        .doc(_mainParkingDoc)
        .collection(_floorsCollection)
        .doc(_etage1)
        .collection(_slotsSubCollection)
        .snapshots()
        .map((snapshot) {
      final slots = snapshot.docs
          .map((doc) => ParkingSlot.fromFirestore(doc.id, doc.data(), floor: 1))
          .toList();
      slots.sort((a, b) => a.slotNumber.compareTo(b.slotNumber));
      return slots;
    });
  }

  /// Stream of all parking slots from Etage 2 (slot_1..slot_6)
  /// Listens to: parkings/main_parking/floors/etage_2/slots subcollection
  Stream<List<ParkingSlot>> getFloor2SlotsStream() {
    return _firestore
        .collection(_parkingsCollection)
        .doc(_mainParkingDoc)
        .collection(_floorsCollection)
        .doc(_etage2)
        .collection(_slotsSubCollection)
        .snapshots()
        .map((snapshot) {
      final slots = snapshot.docs
          .map((doc) => ParkingSlot.fromFirestore(doc.id, doc.data(), floor: 2))
          .toList();
      slots.sort((a, b) => a.slotNumber.compareTo(b.slotNumber));
      return slots;
    });
  }

  /// Stream combining both summary and slots from both floors into one convenient stream
  /// Listens to: 
  ///   - parkings/main_parking (summary)
  ///   - parkings/main_parking/floor1/slots (floor 1 slots)
  ///   - parkings/main_parking/floor2/slots (floor 2 slots)
  /// Fixes the issue where floor 1 updates weren't emitted if floor 2 hadn't changed
  Stream<ParkingData> getCombinedStream() {
    return _firestore
        .collection(_parkingsCollection)
        .doc(_mainParkingDoc)
        .snapshots()
        .asyncExpand((summaryDoc) {
      if (!summaryDoc.exists) {
        return Stream.value(
          ParkingData(
            summary: ParkingSummary(
              availableSpots: 14,
              occupiedSpots: 0,
              totalSpots: 14,
              updatedAt: DateTime.now(),
            ),
            slots: [],
          ),
        );
      }

      final summary = ParkingSummary.fromFirestore(summaryDoc.data() ?? {});

      // Get Etage 1 slots stream
      final floor1Stream = summaryDoc.reference
          .collection(_floorsCollection)
          .doc(_etage1)
          .collection(_slotsSubCollection)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => ParkingSlot.fromFirestore(doc.id, doc.data(), floor: 1))
            .toList()
          ..sort((a, b) => a.slotNumber.compareTo(b.slotNumber));
      });

      // Get Etage 2 slots stream
      final floor2Stream = summaryDoc.reference
          .collection(_floorsCollection)
          .doc(_etage2)
          .collection(_slotsSubCollection)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => ParkingSlot.fromFirestore(doc.id, doc.data(), floor: 2))
            .toList()
          ..sort((a, b) => a.slotNumber.compareTo(b.slotNumber));
      });

      // Store latest slots from each floor in a StreamController
      final floorStatesController = StreamController<ParkingData>();
      late StreamSubscription<List<ParkingSlot>> floor1Sub;
      late StreamSubscription<List<ParkingSlot>> floor2Sub;
      
      var floor1Slots = <ParkingSlot>[];
      var floor2Slots = <ParkingSlot>[];

      void emitCombined() {
        final allSlots = [...floor1Slots, ...floor2Slots];
        floorStatesController.add(ParkingData(summary: summary, slots: allSlots));
      }

      floor1Sub = floor1Stream.listen(
        (slots) {
          floor1Slots = slots;
          emitCombined();
        },
        onError: (error) => floorStatesController.addError(error),
      );

      floor2Sub = floor2Stream.listen(
        (slots) {
          floor2Slots = slots;
          emitCombined();
        },
        onError: (error) => floorStatesController.addError(error),
      );

      floorStatesController.onCancel = () {
        floor1Sub.cancel();
        floor2Sub.cancel();
      };

      return floorStatesController.stream;
    });
  }
}

/// Combined parking data (summary + slots)
class ParkingData {
  final ParkingSummary summary;
  final List<ParkingSlot> slots;

  ParkingData({required this.summary, required this.slots});

  ParkingSlot? getSlot(int slotNumber) {
    try {
      return slots.firstWhere((s) => s.slotNumber == slotNumber);
    } catch (e) {
      return null;
    }
  }
}
