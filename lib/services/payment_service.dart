import 'package:parkino/models/index.dart';
import 'package:uuid/uuid.dart';

/// Service de paiement virtuel simulé
class PaymentService {
  static const String approvedCardNumber = '4242424242424242';
  static const String rejectedCardNumber = '4000000000000000';
  static const pricePerHour = 5.0; // 5 MAD par heure

  /// Valide les données de carte de crédit
  bool validateCardData({
    required String cardNumber,
    required String expiryDate,
    required String cvv,
    required String holderName,
  }) {
    // Vérifie que tous les champs sont remplis
    if (cardNumber.isEmpty || expiryDate.isEmpty || cvv.isEmpty || holderName.isEmpty) {
      return false;
    }

    // Vérifie le format du numéro de carte (16 chiffres)
    if (!RegExp(r'^\d{16}$').hasMatch(cardNumber)) {
      return false;
    }

    // Vérifie le format de la date d'expiration (MM/YY)
    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(expiryDate)) {
      return false;
    }

    // Vérifie le format du CVV (3-4 chiffres)
    if (!RegExp(r'^\d{3,4}$').hasMatch(cvv)) {
      return false;
    }

    return true;
  }

  /// Traite le paiement (simulation)
  /// Retourne {success: bool, errorMessage: String?, paymentId: String?}
  Future<Map<String, dynamic>> processPayment({
    required String cardNumber,
    required String expiryDate,
    required String cvv,
    required String holderName,
    required double amount,
    required String reservationId,
    required String userId,
  }) async {
    // Validation des données
    if (!validateCardData(
      cardNumber: cardNumber,
      expiryDate: expiryDate,
      cvv: cvv,
      holderName: holderName,
    )) {
      return {
        'success': false,
        'errorMessage': 'Données de carte invalides',
        'paymentId': null,
      };
    }

    // Simule un délai de traitement
    await Future.delayed(const Duration(milliseconds: 1500));

    // Logique de simulation de paiement
    bool paymentSuccessful = false;
    String? errorMessage;

    if (cardNumber == approvedCardNumber) {
      // Numéro approuvé
      paymentSuccessful = true;
    } else if (cardNumber == rejectedCardNumber) {
      // Numéro rejeté
      paymentSuccessful = false;
      errorMessage = 'Carte déclinée. Veuillez vérifier vos informations.';
    } else {
      // Autres numéros : accepter si tous les champs sont valides (ce qui est déjà vérifié)
      paymentSuccessful = true;
    }

    // Génère un ID de paiement
    const uuid = Uuid();
    final paymentId = uuid.v4();

    return {
      'success': paymentSuccessful,
      'errorMessage': errorMessage,
      'paymentId': paymentId,
    };
  }

  /// Calcule le prix total de la réservation
  static double calculatePrice(int durationHours) {
    return durationHours * pricePerHour;
  }

  /// Formate le prix en MAD
  static String formatPrice(double price) {
    return '${price.toStringAsFixed(2)} MAD';
  }
}
