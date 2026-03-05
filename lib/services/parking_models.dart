/// Models for parking data from Firestore

class ParkingSummary {
  final int availableSpots;
  final int occupiedSpots;
  final int totalSpots;
  final DateTime updatedAt;

  ParkingSummary({
    required this.availableSpots,
    required this.occupiedSpots,
    required this.totalSpots,
    required this.updatedAt,
  });

  factory ParkingSummary.fromFirestore(Map<String, dynamic> data) {
    return ParkingSummary(
      availableSpots: data['availableSpots'] as int? ?? 0,
      occupiedSpots: data['occupiedSpots'] as int? ?? 0,
      totalSpots: data['totalSpots'] as int? ?? 8,
      updatedAt: (data['updatedAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  @override
  String toString() =>
      'ParkingSummary(available: $availableSpots, occupied: $occupiedSpots, total: $totalSpots)';
}

class ParkingSlot {
  final int slotNumber;
  final bool occupied;
  final double distanceCm;
  final DateTime updatedAt;

  ParkingSlot({
    required this.slotNumber,
    required this.occupied,
    required this.distanceCm,
    required this.updatedAt,
  });

  /// Create from Firestore document
  /// slotNumber is extracted from document ID (slot1 -> 1)
  factory ParkingSlot.fromFirestore(String docId, Map<String, dynamic> data) {
    final slotNum = int.tryParse(docId.replaceAll(RegExp(r'[^\d]'), '')) ?? 1;
    return ParkingSlot(
      slotNumber: slotNum,
      occupied: data['occupied'] as bool? ?? false,
      distanceCm: (data['distance_cm'] as num?)?.toDouble() ?? 0.0,
      updatedAt: (data['updatedAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  /// Helper: returns "1/1" if free, "0/1" if occupied
  String get availabilityDisplay => occupied ? '0/1' : '1/1';

  @override
  String toString() =>
      'Slot $slotNumber(occupied: $occupied, distance: ${distanceCm.toStringAsFixed(1)}cm)';
}
