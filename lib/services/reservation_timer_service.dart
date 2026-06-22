import 'dart:async';

/// Modèle pour gérer le statut d'une réservation avec timer
class ReservationTimer {
  final String reservationId;
  final int spotNumber;
  final Duration totalDuration;
  final DateTime reservedAt;
  
  late Timer _timer;
  Duration _remainingTime;
  Function(Duration)? onTick;
  Function()? onExpired;

  ReservationTimer({
    required this.reservationId,
    required this.spotNumber,
    required this.totalDuration,
    required this.reservedAt,
  }) : _remainingTime = totalDuration {
    _start();
  }

  /// Démarre le timer
  void _start() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _remainingTime = _remainingTime - const Duration(seconds: 1);
      
      if (_remainingTime.isNegative || _remainingTime.inSeconds == 0) {
        _timer.cancel();
        onExpired?.call();
      } else {
        onTick?.call(_remainingTime);
      }
    });
  }

  /// Obtient le temps restant formaté (MM:SS)
  String get formattedTime {
    final minutes = _remainingTime.inMinutes;
    final seconds = _remainingTime.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Obtient la durée restante
  Duration get remainingTime => _remainingTime;

  /// Annule le timer
  void cancel() {
    _timer.cancel();
  }

  /// Vérifie si le timer est expiré
  bool get isExpired => _remainingTime.inSeconds <= 0;
}

/// Service pour gérer les timers de réservation
class ReservationTimerService {
  static final ReservationTimerService _instance = ReservationTimerService._internal();
  
  ReservationTimerService._internal();
  
  factory ReservationTimerService() {
    return _instance;
  }

  final Map<String, ReservationTimer> _timers = {};

  /// Crée un nouveau timer de réservation
  ReservationTimer createTimer({
    required String reservationId,
    required int spotNumber,
    required Duration duration,
  }) {
    // Annule le timer précédent s'il existe
    _timers[reservationId]?.cancel();

    final timer = ReservationTimer(
      reservationId: reservationId,
      spotNumber: spotNumber,
      totalDuration: duration,
      reservedAt: DateTime.now(),
    );

    _timers[reservationId] = timer;
    print('⏱️ Timer created for reservation: $reservationId (${timer.formattedTime})');
    
    return timer;
  }

  /// Obtient un timer existant
  ReservationTimer? getTimer(String reservationId) {
    return _timers[reservationId];
  }

  /// Annule un timer
  void cancelTimer(String reservationId) {
    _timers[reservationId]?.cancel();
    _timers.remove(reservationId);
    print(' Timer cancelled for reservation: $reservationId');
  }

  /// Annule tous les timers
  void cancelAllTimers() {
    for (var timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    print(' All timers cancelled');
  }

  /// Obtient le timer actif (le plus récent)
  ReservationTimer? getActiveTimer() {
    if (_timers.isEmpty) return null;
    return _timers.values.last;
  }

  /// Obtient tous les timers actifs
  List<ReservationTimer> getAllTimers() {
    return _timers.values.where((t) => !t.isExpired).toList();
  }

  /// Obtient le nombre de timers actifs
  int get activeTimerCount => _timers.length;
}
