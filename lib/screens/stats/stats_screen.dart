import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/parking_provider.dart';
import '../../localization/app_localizations.dart';
import '../../theme/parkino_theme.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with TickerProviderStateMixin {
  static const Color _primaryDarkBlue = Color(0xFF0B2A4A);
  static const Color _goldenYellow = Color(0xFFFFC107);
  late AnimationController _percentageController;
  late Animation<double> _percentageAnimation;
  double _occupancyPercentage = 0;

  @override
  void initState() {
    super.initState();
    _percentageController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    // Will be updated with real value from provider
    _percentageAnimation = Tween<double>(begin: 0, end: _occupancyPercentage).animate(
      CurvedAnimation(parent: _percentageController, curve: Curves.easeInOut),
    );
    _percentageController.forward();
  }

  @override
  void dispose() {
    _percentageController.dispose();
    super.dispose();
  }

  void _updateOccupancyAnimation(double newPercentage) {
    if (_occupancyPercentage != newPercentage) {
      _occupancyPercentage = newPercentage;
      _percentageAnimation = Tween<double>(begin: _percentageAnimation.value, end: newPercentage).animate(
        CurvedAnimation(parent: _percentageController, curve: Curves.easeInOut),
      );
      _percentageController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch language provider - this triggers rebuild when language changes
    final currentLocale = context.watch<LanguageProvider>().locale;
    
    return Scaffold(
      backgroundColor: ParkinoTheme.white,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                _buildHeader(),
                const SizedBox(height: 32),
                _buildOccupancyCard(),
                const SizedBox(height: 32),
                _buildStatsGrid(),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          Image.asset(
            'assets/images/parkino_logo.png',
            width: 130,
            height: 130,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.t('statistics'),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: _primaryDarkBlue,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.t('parking_trends'),
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF999999),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOccupancyCard() {
    return Consumer<ParkingProvider>(
      builder: (context, parkingProvider, child) {
        // Get slots for floor 2 (étage 2)
        final floor2Slots = parkingProvider.getSlotsForFloor(2);
        
        // Count occupied and reserved slots
        int occupiedCount = 0;
        int reservedCount = 0;
        
        for (var slot in floor2Slots) {
          if (slot.occupied) {
            occupiedCount++;
          } else if (slot.isReserved) {
            reservedCount++;
          }
        }
        
        // Calculate occupancy percentage (occupied + reserved)
        final totalOccupiedAndReserved = occupiedCount + reservedCount;
        final totalSlots = floor2Slots.length > 0 ? floor2Slots.length : 6;
        final occupancyPercent = (totalOccupiedAndReserved / totalSlots) * 100;
        
        // Update animation with real value
        _updateOccupancyAnimation(occupancyPercent);
        
        return Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ParkinoTheme.white.withValues(alpha: 0.95),
                ParkinoTheme.white.withValues(alpha: 0.88),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                AppLocalizations.t('occupancy_floor_2'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _primaryDarkBlue,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 200,
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 180,
                      height: 180,
                      child: AnimatedBuilder(
                        animation: _percentageAnimation,
                        builder: (context, child) {
                          return CircularProgressIndicator(
                            value: _percentageAnimation.value / 100,
                            strokeWidth: 16,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              _goldenYellow,
                            ),
                          );
                        },
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _percentageAnimation,
                      builder: (context, child) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${_percentageAnimation.value.toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                color: _primaryDarkBlue,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppLocalizations.t('occupied'),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF999999),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _primaryDarkBlue.withValues(alpha: 0.08),
                      _goldenYellow.withValues(alpha: 0.06),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _goldenYellow.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  '$totalOccupiedAndReserved ${AppLocalizations.t('of')} $totalSlots ${totalOccupiedAndReserved == 1 ? AppLocalizations.t('place') : AppLocalizations.t('places')} ${AppLocalizations.t('occupied_or_reserved')}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: _primaryDarkBlue,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsGrid() {
    return Consumer<ParkingProvider>(
      builder: (context, parkingProvider, child) {
        // Get slots for floor 2 (étage 2)
        final floor2Slots = parkingProvider.getSlotsForFloor(2);
        
        // Count slots by status
        int availableCount = 0;  // Green - libre (not occupied and not reserved)
        int occupiedCount = 0;   // Blue - occupée (occupied)
        int reservedCount = 0;   // Red - réservée (reserved)
        
        for (var slot in floor2Slots) {
          if (slot.occupied) {
            occupiedCount++;
          } else if (slot.isReserved) {
            reservedCount++;
          } else {
            availableCount++;
          }
        }
        
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
          children: [
            _buildStatCard(
              icon: Icons.local_parking_rounded,
              title: AppLocalizations.t('available'),
              value: availableCount.toString(),
              color: Colors.green,
              subtitle: AppLocalizations.t('etage_2'),
            ),
            _buildStatCard(
              icon: Icons.block_rounded,
              title: AppLocalizations.t('occupied'),
              value: occupiedCount.toString(),
              color: Colors.red,
              subtitle: AppLocalizations.t('etage_2'),
            ),
            _buildStatCard(
              icon: Icons.event_busy_rounded,
              title: AppLocalizations.t('reserved_short'),
              value: reservedCount.toString(),
              color: Colors.blue,
              subtitle: AppLocalizations.t('etage_2'),
            ),
            _buildStatCard(
              icon: Icons.info_rounded,
              title: AppLocalizations.t('total_spots'),
              value: '${floor2Slots.length}/6',
              color: _goldenYellow,
              subtitle: AppLocalizations.t('all_spots'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ParkinoTheme.white.withValues(alpha: 0.95),
            ParkinoTheme.white.withValues(alpha: 0.88),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border(
          top: BorderSide(color: color, width: 5),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
