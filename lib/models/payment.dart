import 'package:cloud_firestore/cloud_firestore.dart';

enum PaymentStatus {
  pending('pending'),
  successful('successful'),
  failed('failed'),
  cancelled('cancelled');

  final String value;
  const PaymentStatus(this.value);

  static PaymentStatus fromString(String value) {
    return PaymentStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PaymentStatus.pending,
    );
  }
}

enum PaymentMethod {
  creditCard('credit_card'),
  debitCard('debit_card'),
  wallet('wallet');

  final String value;
  const PaymentMethod(this.value);

  static PaymentMethod fromString(String value) {
    return PaymentMethod.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PaymentMethod.creditCard,
    );
  }
}

/// Représente un paiement
class Payment {
  final String id; // uuid
  final String reservationId;
  final String userId;
  final double amount;
  final DateTime createdAt;
  final DateTime? processedAt;
  final PaymentStatus status;
  final PaymentMethod method;
  final String? cardLastDigits; // Derniers chiffres de la carte
  final String? errorMessage; // Message d'erreur si le paiement échoue

  const Payment({
    required this.id,
    required this.reservationId,
    required this.userId,
    required this.amount,
    required this.createdAt,
    this.processedAt,
    required this.status,
    required this.method,
    this.cardLastDigits,
    this.errorMessage,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    DateTime _parseDateTime(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is String) {
        return DateTime.parse(value);
      }
      return DateTime.now();
    }

    return Payment(
      id: json['id'] as String,
      reservationId: json['reservationId'] as String,
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toDouble(),
      createdAt: _parseDateTime(json['createdAt']),
      processedAt: json['processedAt'] != null ? _parseDateTime(json['processedAt']) : null,
      status: PaymentStatus.fromString(json['status'] as String),
      method: PaymentMethod.fromString(json['method'] as String),
      cardLastDigits: json['cardLastDigits'] as String?,
      errorMessage: json['errorMessage'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'reservationId': reservationId,
    'userId': userId,
    'amount': amount,
    'createdAt': Timestamp.fromDate(createdAt),
    'processedAt': processedAt != null ? Timestamp.fromDate(processedAt!) : null,
    'status': status.value,
    'method': method.value,
    'cardLastDigits': cardLastDigits,
    'errorMessage': errorMessage,
  };

  Payment copyWith({
    String? id,
    String? reservationId,
    String? userId,
    double? amount,
    DateTime? createdAt,
    DateTime? processedAt,
    PaymentStatus? status,
    PaymentMethod? method,
    String? cardLastDigits,
    String? errorMessage,
  }) {
    return Payment(
      id: id ?? this.id,
      reservationId: reservationId ?? this.reservationId,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      processedAt: processedAt ?? this.processedAt,
      status: status ?? this.status,
      method: method ?? this.method,
      cardLastDigits: cardLastDigits ?? this.cardLastDigits,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  String get formattedAmount => '${amount.toStringAsFixed(2)} MAD';

  bool get isSuccessful => status == PaymentStatus.successful;
  bool get isFailed => status == PaymentStatus.failed;

  @override
  String toString() => 'Payment(id: $id, status: ${status.value}, amount: $formattedAmount)';
}
