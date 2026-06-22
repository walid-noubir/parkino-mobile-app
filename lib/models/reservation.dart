import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

enum ReservationStatus {
  pendingPayment('pending_payment'),
  confirmed('confirmed'),
  used('used'),
  expired('expired');

  final String value;
  const ReservationStatus(this.value);

  static ReservationStatus fromString(String value) {
    return ReservationStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ReservationStatus.pendingPayment,
    );
  }
}

/// Représente une réservation de place de parking
class Reservation {
  final String id; // uuid
  final String slotId; // B1, B2, ou B3
  final int floor; // 2 pour le 2e étage
  final String userId;
  final DateTime createdAt;
  final DateTime expiresAt; // Expiration de la réservation
  final DateTime reservationStart; // Début de la réservation
  final DateTime reservationEnd; // Fin de la réservation
  final int durationHours;
  final double price; // Prix total
  final ReservationStatus status;
  final String? paymentId;
  final String? qrCode; // Données du QR code (JSON)
  final bool qrCodeUsed; // Si le QR code a été utilisé

  const Reservation({
    required this.id,
    required this.slotId,
    required this.floor,
    required this.userId,
    required this.createdAt,
    required this.expiresAt,
    required this.reservationStart,
    required this.reservationEnd,
    required this.durationHours,
    required this.price,
    required this.status,
    this.paymentId,
    this.qrCode,
    this.qrCodeUsed = false,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    DateTime _parseDateTime(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is String) {
        return DateTime.parse(value);
      }
      return DateTime.now();
    }

    return Reservation(
      id: json['id'] as String,
      slotId: json['slotId'] as String,
      floor: json['floor'] as int,
      userId: json['userId'] as String,
      createdAt: _parseDateTime(json['createdAt']),
      expiresAt: _parseDateTime(json['expiresAt']),
      reservationStart: _parseDateTime(json['reservationStart']),
      reservationEnd: _parseDateTime(json['reservationEnd']),
      durationHours: json['durationHours'] as int,
      price: (json['price'] as num).toDouble(),
      status: ReservationStatus.fromString(json['status'] as String),
      paymentId: json['paymentId'] as String?,
      qrCode: json['qrCode'] as String?,
      qrCodeUsed: json['qrCodeUsed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'slotId': slotId,
    'floor': floor,
    'userId': userId,
    'createdAt': Timestamp.fromDate(createdAt),
    'expiresAt': Timestamp.fromDate(expiresAt),
    'reservationStart': Timestamp.fromDate(reservationStart),
    'reservationEnd': Timestamp.fromDate(reservationEnd),
    'durationHours': durationHours,
    'price': price,
    'status': status.value,
    'paymentId': paymentId,
    'qrCode': qrCode,
    'qrCodeUsed': qrCodeUsed,
  };

  Reservation copyWith({
    String? id,
    String? slotId,
    int? floor,
    String? userId,
    DateTime? createdAt,
    DateTime? expiresAt,
    DateTime? reservationStart,
    DateTime? reservationEnd,
    int? durationHours,
    double? price,
    ReservationStatus? status,
    String? paymentId,
    String? qrCode,
    bool? qrCodeUsed,
  }) {
    return Reservation(
      id: id ?? this.id,
      slotId: slotId ?? this.slotId,
      floor: floor ?? this.floor,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      reservationStart: reservationStart ?? this.reservationStart,
      reservationEnd: reservationEnd ?? this.reservationEnd,
      durationHours: durationHours ?? this.durationHours,
      price: price ?? this.price,
      status: status ?? this.status,
      paymentId: paymentId ?? this.paymentId,
      qrCode: qrCode ?? this.qrCode,
      qrCodeUsed: qrCodeUsed ?? this.qrCodeUsed,
    );
  }

  // Vérifie si la réservation a expiré
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  // Vérifie si la réservation est active
  bool get isActive => status == ReservationStatus.confirmed && !isExpired;

  // Formate le prix en MAD
  String get formattedPrice => '${price.toStringAsFixed(2)} MAD';

  // Formate les dates
  String get formattedDate {
    final formatter = DateFormat('dd/MM/yyyy HH:mm');
    return '${formatter.format(reservationStart)} - ${formatter.format(reservationEnd)}';
  }

  @override
  String toString() => 'Reservation(id: $id, slot: $slotId, status: ${status.value})';
}
