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
  final int floor;

  ParkingSlot({
    required this.slotNumber,
    required this.occupied,
    required this.distanceCm,
    required this.updatedAt,
    required this.floor,
  });

  /// Create from Firestore document
  /// slotNumber is extracted from document ID (slot1 -> 1)
  /// floor must be provided by the caller since structure separates by floor
  /// Supports both formats:
  /// - 'occupied' as boolean
  /// - 'status' as string ('free' or 'occupied')
  factory ParkingSlot.fromFirestore(String docId, Map<String, dynamic> data, {required int floor}) {
    final slotNum = int.tryParse(docId.replaceAll(RegExp(r'[^\d]'), '')) ?? 1;
    
    // Support both 'occupied' (boolean) and 'status' (string) fields from Firebase
    bool isOccupied = false;
    if (data.containsKey('occupied')) {
      // Legacy format: occupied as boolean
      isOccupied = data['occupied'] as bool? ?? false;
    } else if (data.containsKey('status')) {
      // New format: status as string ('free' or 'occupied')
      final status = data['status'] as String? ?? 'free';
      isOccupied = status.toLowerCase() == 'occupied';
    }
    
    return ParkingSlot(
      slotNumber: slotNum,
      occupied: isOccupied,
      distanceCm: (data['distance_cm'] as num?)?.toDouble() ?? 0.0,
      updatedAt: (data['updatedAt'] as dynamic)?.toDate() ?? DateTime.now(),
      floor: floor,
    );
  }

  /// Helper: returns "1/1" if free, "0/1" if occupied
  String get availabilityDisplay => occupied ? '0/1' : '1/1';

  @override
  String toString() =>
      'Slot $slotNumber(occupied: $occupied, distance: ${distanceCm.toStringAsFixed(1)}cm)';
}
