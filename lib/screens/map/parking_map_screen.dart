import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../localization/app_localizations.dart';
import '../../services/parking_repository.dart';
import '../../services/parking_models.dart';
import '../../models/slot_reservation.dart';
import '../../providers/language_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/slot_reservation_provider.dart';
import '../../providers/firebase_auth_provider.dart';
import '../../theme/parkino_theme.dart';

class ParkingMapScreen extends StatefulWidget {
  const ParkingMapScreen({super.key});

  @override
  State<ParkingMapScreen> createState() => _ParkingMapScreenState();
}

class _ParkingMapScreenState extends State<ParkingMapScreen>
    with TickerProviderStateMixin {
  static const Color _primaryDarkBlue = Color(0xFF0B2A4A);
  static const Color _goldenYellow = Color(0xFFFFC107);

  late AnimationController _animController;
  late AnimationController _floorChangeController;
  late AnimationController _refreshRotationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _refreshRotation;
  final ParkingRepository _repository = ParkingRepository();
  int _selectedFloor = 1;
  DateTime? _lastUpdateTime;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    // Cleanup expired reservations on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SlotReservationProvider>().cleanupExpiredReservations();
    });
  }

  void _setupAnimation() {
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    
    _floorChangeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _floorChangeController, curve: Curves.easeInOut),
    );

    // Animation for refresh button rotation
    _refreshRotationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _refreshRotation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _refreshRotationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _floorChangeController.dispose();
    _refreshRotationController.dispose();
    super.dispose();
  }

  /// Manually refresh parking data (triggers animation and refreshes UI)
  void _refreshParkingData() async {
    if (_isRefreshing) return;
    
    setState(() {
      _isRefreshing = true;
    });

    _refreshRotationController.forward(from: 0);

    // Trigger a UI rebuild after a short delay
    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      setState(() {
        _lastUpdateTime = DateTime.now();
        _isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch language provider - this triggers rebuild when language changes
    final currentLocale = context.watch<LanguageProvider>().locale;
    
    /// Use combined stream to display both summary and slots
    return Scaffold(
      key: ValueKey(currentLocale),
      backgroundColor: ParkinoTheme.white,
      body: SafeArea(
        child: StreamBuilder<ParkingData>(
          stream: _repository.getCombinedStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: _primaryDarkBlue),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: ${snapshot.error}'),
                  ],
                ),
              );
            }

            final parkingData = snapshot.data;
            if (parkingData == null) {
              return const Center(
                child: Text('No parking data available'),
              );
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  _buildHeader(parkingData.summary),
                  const SizedBox(height: 32),
                  _buildFloorSelector(),
                  const SizedBox(height: 32),
                  _buildLegend(),
                  const SizedBox(height: 32),
                  _buildParkingGrid(
                    parkingData.slots
                        .where((slot) => slot.floor == _selectedFloor)
                        .toList(),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(ParkingSummary summary) {
    return Center(
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Column(
            children: [
              Image.asset(
                'assets/images/parkino_logo.png',
                width: 130,
                height: 130,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.t('parking_map'),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _primaryDarkBlue,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${summary.availableSpots} / ${summary.totalSpots} ${AppLocalizations.t('places_available')}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF999999),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${AppLocalizations.t('updated')}: ${_formatTime(summary.updatedAt)}',
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFFAAAAAA),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          // Refresh button with rotation animation
          Positioned(
            top: 0,
            right: 0,
            child: RotationTransition(
              turns: _refreshRotation,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isRefreshing ? null : _refreshParkingData,
                  borderRadius: BorderRadius.circular(50),
                  splashColor: _goldenYellow.withValues(alpha: 0.2),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _primaryDarkBlue.withValues(alpha: 0.1),
                      border: Border.all(
                        color: _goldenYellow.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.refresh_rounded,
                      color: _isRefreshing ? _goldenYellow : _primaryDarkBlue,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  Widget _buildFloorSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _primaryDarkBlue.withValues(alpha: 0.05),
            _goldenYellow.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _goldenYellow.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _primaryDarkBlue.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            AppLocalizations.t('select_floor'),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _primaryDarkBlue,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 48,
                child: _buildFloorButton(AppLocalizations.t('floor_1'), 1),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 120,
                height: 48,
                child: _buildFloorButton(AppLocalizations.t('floor_2'), 2),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFloorButton(String label, int floor) {
    final isSelected = _selectedFloor == floor;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedFloor = floor;
          });
        },
        borderRadius: BorderRadius.circular(14),
        splashColor: _goldenYellow.withValues(alpha: 0.2),
        child: Container(
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _primaryDarkBlue,
                      _primaryDarkBlue.withValues(alpha: 0.7),
                    ],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      ParkinoTheme.white.withValues(alpha: 0.08),
                      ParkinoTheme.white.withValues(alpha: 0.04),
                    ],
                  ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? _goldenYellow : ParkinoTheme.white.withValues(alpha: 0.2),
              width: isSelected ? 2.5 : 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: _goldenYellow.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  floor == 1 ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                  color: isSelected ? _goldenYellow : Colors.white54,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? _goldenYellow : Colors.white70,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ParkinoTheme.white.withValues(alpha: 0.12),
            ParkinoTheme.white.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ParkinoTheme.white.withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Text(
            AppLocalizations.t('legend'),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: ParkinoTheme.white,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem(
                color: Colors.green,
                label: AppLocalizations.t('free'),
              ),
              Container(
                width: 1,
                height: 30,
                color: ParkinoTheme.white.withValues(alpha: 0.2),
              ),
              _buildLegendItem(
                color: Colors.blue,
                label: 'Réservée',
              ),
              Container(
                width: 1,
                height: 30,
                color: ParkinoTheme.white.withValues(alpha: 0.2),
              ),
              _buildLegendItem(
                color: Colors.red,
                label: AppLocalizations.t('occupied'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    // Déterminer le texte inférieur selon la couleur
    String statusText;
    if (color == Colors.green) {
      statusText = AppLocalizations.t('free').toUpperCase();
    } else if (color == Colors.blue) {
      statusText = AppLocalizations.t('reserved_status');
    } else {
      statusText = AppLocalizations.t('busy').toUpperCase();
    }

    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.7)],
            ),
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 8,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: ParkinoTheme.white,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              statusText,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildParkingGrid(List<ParkingSlot> slots) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: animation,
            child: child,
          ),
        );
      },
      child: ScaleTransition(
        key: ValueKey<int>(_selectedFloor),
        scale: _scaleAnimation,
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 0.85,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: slots.length,
          itemBuilder: (context, index) {
            final slot = slots[index];
            return _buildParkingSpot(slot: slot, index: index);
          },
        ),
      ),
    );
  }

  Widget _buildParkingSpot({required ParkingSlot slot, int index = 0}) {
    // Déterminer la couleur selon l'état:
    // 🔴 ROUGE   = occupied (quelqu'un l'utilise)
    // 🔵 BLEU    = réservé mais pas occupé (quelqu'un l'a réservé)
    // 🟢 VERT    = libre et non réservé
    final isOccupied = slot.occupied;  // status='occupied'
    final isReserved = slot.isReserved; // status='free' mais réservé
    final isFree = !isOccupied && !isReserved;

    late List<Color> gradientColors;
    late Color shadowColor;
    
    if (isOccupied) {
      gradientColors = [Colors.red.shade400, Colors.red.shade600];
      shadowColor = Colors.red;        // 🔴 ROUGE pour occupé
    } else if (isReserved) {
      gradientColors = [Colors.blue.shade400, Colors.blue.shade600];
      shadowColor = Colors.blue;       // 🔵 BLEU pour réservé
    } else {
      gradientColors = [Colors.green.shade400, Colors.green.shade600];
      shadowColor = Colors.green;      // 🟢 VERT pour libre
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + (index * 50)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * 20),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (isFree) {
                _handleSlotTap(slot: slot);
              } else if (isReserved) {
                _handleSlotTap(slot: slot);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.t('spot_occupied')),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${slot.slotNumber}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: ParkinoTheme.white,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.t(slot.statusLocalizationKey),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isFree ? Colors.green : (isReserved ? Colors.blue : Colors.red),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Handle slot tap - check if already reserved or show confirmation dialog
  Future<void> _handleSlotTap({required ParkingSlot slot}) async {
    // Empêcher les réservations au floor 1
    if (slot.floor == 1) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.t('floor_1_not_available')),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    final reservationProvider = context.read<SlotReservationProvider>();
    final currentUserId = context.read<FirebaseAuthProvider>().user?.uid;
    final slotId = 'slot_${slot.slotNumber}';

    try {
      // Check if this slot already has an active reservation
      final hasReservation = await reservationProvider.hasActiveReservationForSlot(slotId);

      if (!mounted) return;

      if (hasReservation) {
        // Get the reservation details to show the code
        final existingReservation =
            await reservationProvider.getReservationForSlot(slotId);

        if (!mounted) return;

        // Show "Already Reserved" dialog
        _showAlreadyReservedDialog(
          slot: slot,
          reservation: existingReservation,
          currentUserId: currentUserId,
        );
      } else {
        // Show confirmation dialog for new reservation
        _showReservationConfirmationDialog(slot: slot);
      }
    } catch (e) {
      print(' Error handling slot tap: $e');
    }
  }

  /// Show dialog for already reserved spot
  void _showAlreadyReservedDialog({
    required ParkingSlot slot,
    required SlotReservation? reservation,
    required String? currentUserId,
  }) {
    // Vérifier si cette réservation appartient à l'utilisateur actuel
    final isMyReservation = reservation?.userId == currentUserId;
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFAFAFA),
        titlePadding: const EdgeInsets.fromLTRB(24, 16, 8, 0),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isMyReservation
                  ? AppLocalizations.t('your_reservation')
                  : AppLocalizations.t('reserved_spot'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0B2A4A),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: const Icon(
                    Icons.close,
                    size: 24,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isMyReservation ? Icons.check_circle_outline : Icons.info_outline,
              size: 64,
              color: isMyReservation ? Colors.blue : Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              isMyReservation
                  ? AppLocalizations.t('already_reserved')
                  : AppLocalizations.t('reserved_by_other'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0B2A4A),
              ),
            ),
            const SizedBox(height: 16),
            if (reservation != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (isMyReservation ? Colors.blue : Colors.orange).shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (isMyReservation ? Colors.blue : Colors.orange).shade300,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '${AppLocalizations.t('spot')} #${slot.slotNumber}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0B2A4A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (isMyReservation) ...[
                      Text(
                        AppLocalizations.t('your_code'),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        reservation.code,
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFFFC107),
                          letterSpacing: 6,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Valide pour: ${reservation.timeRemaining}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ] else ...[
                      Text(
                        'Veuillez choisir une autre place.',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ] else
              const Text(
                'Les détails de la réservation n\'ont pu être chargés.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
        actions: [],
      ),
    );
  }

  /// Show confirmation dialog BEFORE reservation
  Future<void> _showReservationConfirmationDialog({required ParkingSlot slot}) async {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: Text(
          'Confirmer la réservation',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0B2A4A),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.help_outline,
              size: 64,
              color: Color(0xFFFFC107),
            ),
            const SizedBox(height: 16),
            Text(
              'Voulez-vous réserver cette place ?',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.green.shade300,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '${AppLocalizations.t('spot')} #${slot.slotNumber}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0B2A4A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Durée: 5 minutes',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Annuler',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performReservation(slot: slot);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            ),
            child: const Text(
              'Réserver',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Perform the actual reservation after user confirmation
  Future<void> _performReservation({required ParkingSlot slot}) async {
    final reservationProvider = context.read<SlotReservationProvider>();
    
    // Check if user already has an active reservation
    if (reservationProvider.currentReservation != null && 
        !reservationProvider.currentReservation!.isExpired) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.t('active_reservation_exists')
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }
    
    // Show loading indicator
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Get the authenticated user's ID
      final userId = context.read<FirebaseAuthProvider>().user?.uid;
      if (userId == null) {
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.t('error_not_authenticated')),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await reservationProvider.reserveSlot(
        slotId: 'slot_${slot.slotNumber}',
        slotNumber: slot.slotNumber,
        userId: userId,
      );

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      final reservation = reservationProvider.currentReservation;
      if (reservation != null) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFFFAFAFA),
            titlePadding: const EdgeInsets.fromLTRB(24, 16, 8, 0),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.t('reservation_confirmed'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0B2A4A),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.close,
                        size: 24,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 64,
                  color: Colors.green,
                ),
                const SizedBox(height: 24),
                Text(
                  '${AppLocalizations.t('spot')} #${reservation.slotNumber}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B2A4A).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFFC107),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        AppLocalizations.t('your_code'),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        reservation.code,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFFFC107),
                          letterSpacing: 8,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '⏱️ ${AppLocalizations.t('valid_5_minutes')}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  reservation.timeRemaining,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            actions: [],
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      // Show error message
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(
            AppLocalizations.t('reservation_error_title'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.t('reservation_error_message'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.red.shade300,
                  ),
                ),
                child: Text(
                  _formatErrorMessage(e.toString()),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B2A4A),
              ),
              child: const Text('Fermer'),
            ),
          ],
        ),
      );
    }
  }

  /// Format error message for display
  String _formatErrorMessage(String errorText) {
    if (errorText.contains('already reserved')) {
      return 'Cette place a déjà été réservée.\nRafraîchissez la page.';
    } else if (errorText.contains('already occupied')) {
      return 'Cette place est occupée.';
    } else if (errorText.contains('does not exist')) {
      return 'Cette place n\'existe pas.';
    } else if (errorText.contains('PERMISSION_DENIED')) {
      return 'Permissions Firestore insuffisantes.\nVérifiez les règles de sécurité.';
    }
    return errorText;
  }


}
