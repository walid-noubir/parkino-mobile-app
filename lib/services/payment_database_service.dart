import 'package:parkino/models/index.dart';

/// Service de gestion des paiements et base de données
class PaymentDatabaseService {
  // Simuler une base de données en mémoire
  final List<Payment> _payments = [];

  /// Crée un enregistrement de paiement
  Payment createPayment({
    required String reservationId,
    required String userId,
    required double amount,
    required String cardLastDigits,
  }) {
    final payment = Payment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      reservationId: reservationId,
      userId: userId,
      amount: amount,
      createdAt: DateTime.now(),
      status: PaymentStatus.pending,
      method: PaymentMethod.creditCard,
      cardLastDigits: cardLastDigits,
    );

    _payments.add(payment);
    return payment;
  }

  /// Met à jour le statut d'un paiement
  Payment updatePaymentStatus({
    required String paymentId,
    required PaymentStatus status,
    String? errorMessage,
  }) {
    final index = _payments.indexWhere((p) => p.id == paymentId);
    if (index == -1) {
      throw Exception('Paiement $paymentId non trouvé');
    }

    final updatedPayment = _payments[index].copyWith(
      status: status,
      processedAt: DateTime.now(),
      errorMessage: errorMessage,
    );

    _payments[index] = updatedPayment;
    return updatedPayment;
  }

  /// Récupère un paiement par ID
  Payment? getPayment(String paymentId) {
    try {
      return _payments.firstWhere((p) => p.id == paymentId);
    } catch (e) {
      return null;
    }
  }

  /// Récupère tous les paiements d'un utilisateur
  List<Payment> getUserPayments(String userId) {
    return _payments.where((p) => p.userId == userId).toList();
  }

  /// Récupère le paiement associé à une réservation
  Payment? getPaymentByReservation(String reservationId) {
    try {
      return _payments.firstWhere((p) => p.reservationId == reservationId);
    } catch (e) {
      return null;
    }
  }

  /// Récupère tous les paiements
  List<Payment> getAllPayments() {
    return _payments;
  }

  /// Récupère les statistiques de paiement
  Map<String, dynamic> getPaymentStatistics() {
    final successful = _payments.where((p) => p.status == PaymentStatus.successful).length;
    final failed = _payments.where((p) => p.status == PaymentStatus.failed).length;
    final pending = _payments.where((p) => p.status == PaymentStatus.pending).length;
    final totalAmount = _payments
        .where((p) => p.status == PaymentStatus.successful)
        .fold<double>(0, (sum, p) => sum + p.amount);

    return {
      'totalPayments': _payments.length,
      'successful': successful,
      'failed': failed,
      'pending': pending,
      'totalAmount': totalAmount,
    };
  }

  /// Efface toutes les données (pour testing)
  void clearAll() {
    _payments.clear();
  }
}
