import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gap/gap.dart';
import '../../localization/app_localizations.dart';
import '../../widgets/language_button.dart';
import '../../widgets/modern_widgets.dart';
import '../../widgets/reservation_countdown_widget.dart';
import '../../providers/language_provider.dart';
import '../../providers/firebase_auth_provider.dart';
import '../../providers/reservation_notification_provider.dart';
import '../../providers/parking_provider.dart';
import '../../theme/parkino_theme.dart';


class HomeScreen extends StatefulWidget {
  final Function(int)? onTabChanged;

  const HomeScreen({super.key, this.onTabChanged});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // Définir l'utilisateur actuel pour les notifications
    final userId = context.read<FirebaseAuthProvider>().user?.uid;
    if (userId != null) {
      context.read<NotificationProvider>().setCurrentUser(userId);
      print('👤 Set current user for notifications: $userId');
    }
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    _pulseAnimation = Tween<double>(begin: 0.98, end: 1.0).animate(
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
    // Watch language provider - this triggers rebuild when language changes
    final currentLocale = context.watch<LanguageProvider>().locale;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ParkinoTheme.primaryDarkBlue.withOpacity(0.03),
              ParkinoTheme.veryLightGray,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Compteur de réservation en haut
              const ReservationCountdownTimer(),
              // Contenu principal
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildModernHeader(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Gap(32),
                            Consumer<ParkingProvider>(
                              builder: (context, parkingProvider, child) {
                                return _buildMainParkingCard(parkingProvider);
                              },
                            ),
                            const Gap(28),
                              _buildQuickActionsSection(),
                            const Gap(32),
                            _buildViewMapButton(),
                            const Gap(32),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ParkinoTheme.primaryDarkBlue.withOpacity(0.95),
            ParkinoTheme.primaryDarkBlue.withOpacity(0.88),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: ParkinoTheme.primaryDarkBlue.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo + Text
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ParkinoTheme.goldenYellow.withOpacity(0.2),
                          ParkinoTheme.goldenYellow.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ParkinoTheme.goldenYellow.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Image.asset(
                      'assets/images/parkino_logo.png',
                      width: 40,
                      height: 40,
                      color: ParkinoTheme.goldenYellow,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const Gap(12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.t('app_name'),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: ParkinoTheme.goldenYellow,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        AppLocalizations.t('smart_parking'),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: ParkinoTheme.white.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Language button
              const LanguageButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainParkingCard(ParkingProvider parkingProvider) {
    // Get slots for floor 2 (étage 2)
    final floor2Slots = parkingProvider.getSlotsForFloor(2);
    
    // Count slots by status
    int availableCount = 0;  // Green - libre (not occupied and not reserved)
    int occupiedCount = 0;   // Red - occupée (occupied)
    int reservedCount = 0;   // Blue - réservée (reserved)
    
    for (var slot in floor2Slots) {
      if (slot.occupied) {
        occupiedCount++;
      } else if (slot.isReserved) {
        reservedCount++;
      } else {
        availableCount++;
      }
    }
    
    final totalSlots = floor2Slots.length > 0 ? floor2Slots.length : 6;
    final occupancyPercent = ((occupiedCount + reservedCount) / totalSlots) * 100;
    final availabilityPercent = (availableCount / totalSlots) * 100;
    
    return ModernCard(
      backgroundColor: ParkinoTheme.white,
      padding: const EdgeInsets.all(32),
      borderRadius: const BorderRadius.all(Radius.circular(32)),
      shadows: ParkinoTheme.modernShadow(elevation: 16),
      child: Column(
        children: [
          // Title
          Text(
            AppLocalizations.t('parking_occupancy'),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: ParkinoTheme.primaryDarkBlue,
            ),
          ),
          const Gap(8),
          Text(
            AppLocalizations.t('floor_2_realtime'),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: ParkinoTheme.darkGray,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Gap(36),
          
          // Main circular indicator
          SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background shadow circle
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: ParkinoTheme.primaryDarkBlue.withOpacity(0.12),
                        blurRadius: 24,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                ),
                // Removed: CircularProgressIndicator (green circle)
                // Center content
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.t('available'),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: ParkinoTheme.successGreen,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const Gap(10),
                    Text(
                      '$availableCount',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: ParkinoTheme.successGreen,
                        fontWeight: FontWeight.w900,
                        fontSize: 60,
                      ),
                    ),
                    const Gap(6),
                    // Removed: Text showing "of 6 spots"
                  ],
                ),
              ],
            ),
          ),
          const Gap(40),
          
          // Enhanced stats row with three columns
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ParkinoTheme.primaryDarkBlue.withOpacity(0.04),
                  ParkinoTheme.successGreen.withOpacity(0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: ParkinoTheme.primaryDarkBlue.withOpacity(0.1),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDetailedStatColumn(
                  label: AppLocalizations.t('available'),
                  value: '$availableCount',
                  percent: '${availabilityPercent.toStringAsFixed(0)}%',
                  color: ParkinoTheme.successGreen,
                ),
                Container(
                  width: 1.5,
                  height: 60,
                  color: ParkinoTheme.mediumGray.withOpacity(0.2),
                ),
                _buildDetailedStatColumn(
                  label: AppLocalizations.t('occupied'),
                  value: '$occupiedCount',
                  percent: '${((occupiedCount / totalSlots) * 100).toStringAsFixed(0)}%',
                  color: ParkinoTheme.errorRed,
                ),
                Container(
                  width: 1.5,
                  height: 60,
                  color: ParkinoTheme.mediumGray.withOpacity(0.2),
                ),
                _buildDetailedStatColumn(
                  label: AppLocalizations.t('reserved'),
                  value: '$reservedCount',
                  percent: '${((reservedCount / totalSlots) * 100).toStringAsFixed(0)}%',
                  color: ParkinoTheme.infoBlue,
                ),
              ],
            ),
          ),
          const Gap(20),
          
          // Live update indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ParkinoTheme.successGreen,
                  boxShadow: [
                    BoxShadow(
                      color: ParkinoTheme.successGreen.withOpacity(0.6),
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const Gap(8),
              Text(
                AppLocalizations.t('live_update'),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: ParkinoTheme.darkGray,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedStatColumn({
    required String label,
    required String value,
    required String percent,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: ParkinoTheme.darkGray,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const Gap(6),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Gap(4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 0.5,
            ),
          ),
          child: Text(
            percent,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.t('parking_info'),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        const Gap(16),
        _buildEnhancedInfoCard(
          icon: Icons.schedule_rounded,
          iconColor: ParkinoTheme.warningOrange,
          title: AppLocalizations.t('peak_hours_today'),
          mainValue: AppLocalizations.t('peak_hours_value'),
          subtitle: AppLocalizations.t('high_activity'),
        ),
        const Gap(12),
        _buildEnhancedInfoCard(
          icon: Icons.trending_up_rounded,
          iconColor: ParkinoTheme.infoBlue,
          title: AppLocalizations.t('current_status'),
          mainValue: AppLocalizations.t('parking_available'),
          subtitle: AppLocalizations.t('parking_open'),
        ),
      ],
    );
  }

  Widget _buildEnhancedInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String mainValue,
    required String subtitle,
  }) {
    return ModernCard(
      backgroundColor: ParkinoTheme.white,
      padding: const EdgeInsets.all(18),
      borderRadius: const BorderRadius.all(Radius.circular(18)),
      shadows: ParkinoTheme.modernShadow(elevation: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      iconColor.withOpacity(0.2),
                      iconColor.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: iconColor.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: ParkinoTheme.darkGray,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      mainValue,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: iconColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: iconColor.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Text(
              subtitle,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: ParkinoTheme.darkGray,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewMapButton() {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ParkinoTheme.goldenYellow,
              ParkinoTheme.moderateGolden,
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: ParkinoTheme.goldenYellow.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => widget.onTabChanged?.call(1),
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.map_rounded,
                    color: ParkinoTheme.primaryDarkBlue,
                    size: 24,
                  ),
                  const Gap(12),
                  Text(
                    AppLocalizations.t('view_parking_map'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: ParkinoTheme.primaryDarkBlue,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const Gap(8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: ParkinoTheme.primaryDarkBlue,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


