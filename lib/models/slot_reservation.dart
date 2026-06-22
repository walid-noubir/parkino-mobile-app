import 'package:cloud_firestore/cloud_firestore.dart';

/// Représente une réservation courte (5 minutes) d'une place de parking
class SlotReservation {
  final String id; // UUID
  final String slotId; // slot_1, slot_2, etc.
  final int slotNumber;
  final int floor;
  final String code; // Code de 4 chiffres (ex: "1234")
  final String userId; // ID de l'utilisateur qui a réservé
  final SlotReservationStatus status; // active, expired, used
  final DateTime createdAt;
  final DateTime expiresAt; // createdAt + 5 minutes
  final bool used;

  const SlotReservation({
    required this.id,
    required this.slotId,
    required this.slotNumber,
    required this.floor,
    required this.code,
    required this.userId,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    this.used = false,
  });

  /// Vérifie si la réservation a expiré
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Vérifie si la réservation est active
  bool get isActive => status == SlotReservationStatus.active && !isExpired;

  /// Temps restant en secondes
  int get secondsRemaining {
    final remaining = expiresAt.difference(DateTime.now()).inSeconds;
    return remaining > 0 ? remaining : 0;
  }

  /// Temps restant formaté (ex: "4:32")
  String get timeRemaining {
    final seconds = secondsRemaining;
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  /// Convertit en JSON pour Firestore
  Map<String, dynamic> toJson() => {
    'id': id,
    'slotId': slotId,
    'slotNumber': slotNumber,
    'floor': floor,
    'code': code,
    'userId': userId,
    'status': status.value,
    'createdAt': Timestamp.fromDate(createdAt),
    'expiresAt': Timestamp.fromDate(expiresAt),
    'used': used,
  };

  /// Crée une instance à partir de JSON Firestore
  factory SlotReservation.fromJson(Map<String, dynamic> json) {
    return SlotReservation(
      id: json['id'] as String? ?? '',
      slotId: json['slotId'] as String? ?? '',
      slotNumber: json['slotNumber'] as int? ?? 0,
      floor: json['floor'] as int? ?? 2,
      code: json['code'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      status: SlotReservationStatus.fromString(
        json['status'] as String? ?? 'active',
      ),
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'] as String)
          : (json['createdAt'] as dynamic).toDate(),
      expiresAt: json['expiresAt'] is String
          ? DateTime.parse(json['expiresAt'] as String)
          : (json['expiresAt'] as dynamic).toDate(),
      used: json['used'] as bool? ?? false,
    );
  }

  /// Copie avec des modifications
  SlotReservation copyWith({
    String? id,
    String? slotId,
    int? slotNumber,
    int? floor,
    String? code,
    String? userId,
    SlotReservationStatus? status,
    DateTime? createdAt,
    DateTime? expiresAt,
    bool? used,
  }) {
    return SlotReservation(
      id: id ?? this.id,
      slotId: slotId ?? this.slotId,
      slotNumber: slotNumber ?? this.slotNumber,
      floor: floor ?? this.floor,
      code: code ?? this.code,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      used: used ?? this.used,
    );
  }

  @override
  String toString() =>
      'SlotReservation(slot: $slotId, code: $code, status: ${status.value}, expires: ${timeRemaining})';
}

/// Énumération pour le statut de la réservation
enum SlotReservationStatus {
  active('active'),
  expired('expired'),
  used('used');

  final String value;
  const SlotReservationStatus(this.value);

  static SlotReservationStatus fromString(String value) {
    return SlotReservationStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SlotReservationStatus.active,
    );
  }
}
