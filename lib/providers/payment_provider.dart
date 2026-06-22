import 'package:flutter/foundation.dart';
import 'package:parkino/models/index.dart';
import 'package:parkino/services/index.dart';

/// Provider pour le service de paiement
class PaymentProvider extends ChangeNotifier {
  final PaymentService _paymentService = PaymentService();
  final PaymentDatabaseService _databaseService = PaymentDatabaseService();

  bool _isProcessing = false;
  String? _errorMessage;
  Payment? _lastPayment;

  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;
  Payment? get lastPayment => _lastPayment;

  Future<Map<String, dynamic>> processPayment({
    required String cardNumber,
    required String expiryDate,
    required String cvv,
    required String holderName,
    required double amount,
    required String reservationId,
    required String userId,
  }) async {
    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Crée un enregistrement de paiement
      final payment = _databaseService.createPayment(
        reservationId: reservationId,
        userId: userId,
        amount: amount,
        cardLastDigits: cardNumber.substring(cardNumber.length - 4),
      );

      // Traite le paiement
      final result = await _paymentService.processPayment(
        cardNumber: cardNumber,
        expiryDate: expiryDate,
        cvv: cvv,
        holderName: holderName,
        amount: amount,
        reservationId: reservationId,
        userId: userId,
      );

      // Met à jour le statut du paiement
      if (result['success'] as bool) {
        _databaseService.updatePaymentStatus(
          paymentId: payment.id,
          status: PaymentStatus.successful,
        );
        _lastPayment = _databaseService.getPayment(payment.id);
      } else {
        _databaseService.updatePaymentStatus(
          paymentId: payment.id,
          status: PaymentStatus.failed,
          errorMessage: result['errorMessage'] as String?,
        );
        _errorMessage = result['errorMessage'] as String?;
        _lastPayment = _databaseService.getPayment(payment.id);
      }

      _isProcessing = false;
      notifyListeners();

      return {
        'success': result['success'] as bool,
        'errorMessage': result['errorMessage'] as String?,
        'paymentId': payment.id,
      };
    } catch (e) {
      _errorMessage = 'Erreur lors du traitement du paiement: $e';
      _isProcessing = false;
      notifyListeners();
      return {
        'success': false,
        'errorMessage': _errorMessage,
        'paymentId': null,
      };
    }
  }

  double calculatePrice(int durationHours) {
    return PaymentService.calculatePrice(durationHours);
  }

  String formatPrice(double price) {
    return PaymentService.formatPrice(price);
  }

  Payment? getPayment(String paymentId) {
    return _databaseService.getPayment(paymentId);
  }

  List<Payment> getUserPayments(String userId) {
    return _databaseService.getUserPayments(userId);
  }

  Payment? getPaymentByReservation(String reservationId) {
    return _databaseService.getPaymentByReservation(reservationId);
  }

  PaymentDatabaseService getDatabaseService() => _databaseService;
}
