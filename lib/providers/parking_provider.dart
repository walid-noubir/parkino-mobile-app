import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/parking_models.dart';
import '../services/parking_repository.dart';

/// Provider pour gérer l'état du parking en temps réel
class ParkingProvider extends ChangeNotifier {
  final ParkingRepository _repository = ParkingRepository();
  
  ParkingData _parkingData = ParkingData(summary: ParkingSummary(
    availableSpots: 0,
    occupiedSpots: 0,
    totalSpots: 11,
    updatedAt: DateTime.now(),
  ), slots: []);
  
  bool _isLoading = true;
  String? _error;

  ParkingData get parkingData => _parkingData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Obtenez les places d'un étage spécifique
  List<ParkingSlot> getSlotsForFloor(int floor) {
    return _parkingData.slots.where((slot) => slot.floor == floor).toList()
      ..sort((a, b) => a.slotNumber.compareTo(b.slotNumber));
  }

  /// Écoutez les mises à jour en temps réel du parking
  void startListening() {
    _repository.getCombinedStream().listen(
      (data) {
        _parkingData = data;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }
}
