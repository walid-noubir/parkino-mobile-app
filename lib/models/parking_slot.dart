/// Représente une place de parking
class ParkingSlot {
  final String id; // B1, B2, B3
  final int floor; // Étage (2 pour le 2e étage)
  final bool isAvailable;

  const ParkingSlot({
    required this.id,
    required this.floor,
    this.isAvailable = true,
  });

  factory ParkingSlot.fromJson(Map<String, dynamic> json) {
    return ParkingSlot(
      id: json['id'] as String,
      floor: json['floor'] as int,
      isAvailable: json['isAvailable'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'floor': floor,
    'isAvailable': isAvailable,
  };

  ParkingSlot copyWith({
    String? id,
    int? floor,
    bool? isAvailable,
  }) {
    return ParkingSlot(
      id: id ?? this.id,
      floor: floor ?? this.floor,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  @override
  String toString() => 'ParkingSlot(id: $id, floor: $floor, available: $isAvailable)';
}
