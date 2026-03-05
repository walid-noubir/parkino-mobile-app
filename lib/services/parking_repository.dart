import 'package:cloud_firestore/cloud_firestore.dart';
import 'parking_models.dart';

/// Repository for accessing parking data from Firestore
class ParkingRepository {
  static const String _parkingsCollection = 'parkings';
  static const String _mainParkingDoc = 'main_parking';
  static const String _slotsSubCollection = 'slots';

  final FirebaseFirestore _firestore;

  ParkingRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

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

  /// Stream of all parking slots (slot1..slot8)
  /// Listens to: parkings/main_parking/slots subcollection
  /// Ordered by slot number
  Stream<List<ParkingSlot>> getSlotStatusesStream() {
    return _firestore
        .collection(_parkingsCollection)
        .doc(_mainParkingDoc)
        .collection(_slotsSubCollection)
        .snapshots()
        .map((snapshot) {
      final slots = snapshot.docs
          .map((doc) => ParkingSlot.fromFirestore(doc.id, doc.data()))
          .toList();
      
      // Sort by slot number
      slots.sort((a, b) => a.slotNumber.compareTo(b.slotNumber));
      
      return slots;
    });
  }

  /// Stream combining both summary and slots into one convenient stream
  /// Useful if you need all data at once
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
              availableSpots: 8,
              occupiedSpots: 0,
              totalSpots: 8,
              updatedAt: DateTime.now(),
            ),
            slots: List.generate(
              8,
              (i) => ParkingSlot(
                slotNumber: i + 1,
                occupied: false,
                distanceCm: 0,
                updatedAt: DateTime.now(),
              ),
            ),
          ),
        );
      }

      final summary = ParkingSummary.fromFirestore(summaryDoc.data() ?? {});

      return summaryDoc.reference
          .collection(_slotsSubCollection)
          .snapshots()
          .map((slotsSnapshot) {
        final slots = slotsSnapshot.docs
            .map((doc) => ParkingSlot.fromFirestore(doc.id, doc.data()))
            .toList();
        slots.sort((a, b) => a.slotNumber.compareTo(b.slotNumber));

        return ParkingData(summary: summary, slots: slots);
      });
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
