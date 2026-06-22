import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parkino/models/index.dart';
import 'package:parkino/providers/index.dart';
import 'confirmation_screen.dart';

class PaymentScreen extends StatefulWidget {
  final Reservation reservation;

  const PaymentScreen({
    Key? key,
    required this.reservation,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _cardNumberController;
  late TextEditingController _expiryDateController;
  late TextEditingController _cvvController;
  late TextEditingController _holderNameController;
  bool _isProcessing = false;
  bool _showCardDetails = false;

  @override
  void initState() {
    super.initState();
    _cardNumberController = TextEditingController();
    _expiryDateController = TextEditingController();
    _cvvController = TextEditingController();
    _holderNameController = TextEditingController();
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _holderNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiement'),
        elevation: 0,
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Résumé de la réservation
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Résumé de la réservation',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildSummaryRow('Place:', widget.reservation.slotId),
                      _buildSummaryRow('Durée:', '${widget.reservation.durationHours} heure(s)'),
                      _buildSummaryRow(
                        'Date/Heure:',
                        widget.reservation.formattedDate,
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.reservation.formattedPrice,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Formulaire de paiement
              const Text(
                'Informations de paiement',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Numéro de carte
                    TextFormField(
                      controller: _cardNumberController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Numéro de carte',
                        hintText: '0000 0000 0000 0000',
                        prefixIcon: const Icon(Icons.credit_card),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Veuillez entrer le numéro de carte';
                        }
                        if (value!.replaceAll(' ', '').length != 16) {
                          return 'Le numéro doit contenir 16 chiffres';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        // Formate le numéro avec des espaces
                        final cleanValue = value.replaceAll(' ', '');
                        if (cleanValue.length <= 16) {
                          final formatted = cleanValue
                              .replaceAllMapped(RegExp(r'.{1,4}'), (match) => '${match.group(0)} ')
                              .trim();
                          _cardNumberController.value = _cardNumberController.value.copyWith(
                            text: formatted,
                            selection: TextSelection.fromPosition(
                              TextPosition(offset: formatted.length),
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Nom du titulaire
                    TextFormField(
                      controller: _holderNameController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: 'Nom du titulaire',
                        hintText: 'Jean Dupont',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Veuillez entrer le nom du titulaire';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Date d'expiration et CVV
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _expiryDateController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Date d\'expiration',
                              hintText: 'MM/YY',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Requis';
                              }
                              if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value!)) {
                                return 'Format MM/YY';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _cvvController,
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'CVV',
                              hintText: '000',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Requis';
                              }
                              if (!RegExp(r'^\d{3,4}$').hasMatch(value!)) {
                                return '3-4 chiffres';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Info pour tester
              ExpansionTile(
                title: const Text(
                  'Cartes de test',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '✓ Paiement accepté: 4242424242424242',
                          style: TextStyle(color: Colors.green),
                        ),
                        const Text(
                          '✗ Paiement rejeté: 4000000000000000',
                          style: TextStyle(color: Colors.red),
                        ),
                        const Text(
                          'Autres: Acceptées si valides',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Consumer pour afficher les erreurs de paiement
              Consumer<PaymentProvider>(
                builder: (context, paymentProvider, _) {
                  if (paymentProvider.errorMessage != null && _isProcessing == false) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        border: Border.all(color: Colors.red),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.red),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              paymentProvider.errorMessage ?? '',
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 24),

              // Bouton de paiement
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : () => _processPayment(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    disabledBackgroundColor: Colors.grey[300],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Payer maintenant',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Bouton retour
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isProcessing ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Annuler',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _processPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    final paymentProvider = context.read<PaymentProvider>();
    final reservationProvider = context.read<ReservationProvider>();

    final cardNumber = _cardNumberController.text.replaceAll(' ', '');
    final expiryDate = _expiryDateController.text;
    final cvv = _cvvController.text;
    final holderName = _holderNameController.text;

    try {
      final result = await paymentProvider.processPayment(
        cardNumber: cardNumber,
        expiryDate: expiryDate,
        cvv: cvv,
        holderName: holderName,
        amount: widget.reservation.price,
        reservationId: widget.reservation.id,
        userId: widget.reservation.userId,
      );

      if (result['success'] as bool) {
        // Utilise l'ID de réservation comme QR code
        final qrCodeData = widget.reservation.id;

        // Confirme la réservation (sauvegarde dans Firestore)
        await reservationProvider.confirmReservation(
          reservationId: widget.reservation.id,
          paymentId: result['paymentId'] as String,
          qrCodeData: qrCodeData,
        );

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => ConfirmationScreen(
                reservation: widget.reservation,
                qrCodeData: qrCodeData,
              ),
            ),
          );
        }
      } else {
        setState(() {
          _isProcessing = false;
        });
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la confirmation: $e')),
        );
      }
    }
  }
}
