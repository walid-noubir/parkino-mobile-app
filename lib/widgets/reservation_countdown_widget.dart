import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gap/gap.dart';
import '/theme/parkino_theme.dart';
import '/providers/reservation_notification_provider.dart';
import '/localization/app_localizations.dart';

/// Widget pour afficher le compteur décroissant de réservation
class ReservationCountdownTimer extends StatefulWidget {
  const ReservationCountdownTimer({super.key});

  @override
  State<ReservationCountdownTimer> createState() => _ReservationCountdownTimerState();
}

class _ReservationCountdownTimerState extends State<ReservationCountdownTimer>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, _) {
        final activeTimer = notificationProvider.activeTimer;

        // N'afficher le compteur que s'il y a une réservation active
        if (activeTimer == null || activeTimer.isExpired) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ParkinoTheme.primaryDarkBlue.withOpacity(0.95),
                ParkinoTheme.primaryMediumBlue.withOpacity(0.95),
              ],
            ),
            border: Border(
              bottom: BorderSide(
                color: ParkinoTheme.goldenYellow.withOpacity(0.5),
                width: 2,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: ParkinoTheme.primaryDarkBlue.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Texte de réservation
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.t('active_reservation'),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: ParkinoTheme.goldenYellow,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      '${AppLocalizations.t('spot_number')}${activeTimer.spotNumber}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: ParkinoTheme.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const Gap(12),

              // Compteur avec animation de pulsation
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: ParkinoTheme.goldenYellow.withOpacity(0.15),
                    border: Border.all(
                      color: ParkinoTheme.goldenYellow,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    activeTimer.formattedTime,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: ParkinoTheme.goldenYellow,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      letterSpacing: 1,
                      fontFamily: 'Courier',
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Widget pour afficher le compteur en notification mini
class ReservationCountdownMini extends StatefulWidget {
  final bool showOnlyIfActive;

  const ReservationCountdownMini({
    super.key,
    this.showOnlyIfActive = true,
  });

  @override
  State<ReservationCountdownMini> createState() =>
      _ReservationCountdownMiniState();
}

class _ReservationCountdownMiniState extends State<ReservationCountdownMini>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, _) {
        final activeTimer = notificationProvider.activeTimer;

        if (activeTimer == null || activeTimer.isExpired) {
          return const SizedBox.shrink();
        }

        return ScaleTransition(
          scale: Tween<double>(begin: 1.0, end: 1.05).animate(_scaleController),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: ParkinoTheme.goldenYellow,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              activeTimer.formattedTime,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: ParkinoTheme.primaryDarkBlue,
                fontWeight: FontWeight.w800,
                fontSize: 12,
                fontFamily: 'Courier',
              ),
            ),
          ),
        );
      },
    );
  }
}
