import 'package:flutter/material.dart';
import '../../services/parking_repository.dart';
import '../../services/parking_models.dart';

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
    /// Use combined stream to display both summary and slots
    return Scaffold(
      backgroundColor: Colors.white,
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
              const Text(
                'Parking Map',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _primaryDarkBlue,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${summary.availableSpots} / ${summary.totalSpots} places disponibles',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF999999),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Mis à jour: ${_formatTime(summary.updatedAt)}',
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
          const Text(
            'Select Floor',
            style: TextStyle(
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
                child: _buildFloorButton('Floor 1', 1),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 120,
                height: 48,
                child: _buildFloorButton('Floor 2', 2),
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
                      Colors.white.withValues(alpha: 0.08),
                      Colors.white.withValues(alpha: 0.04),
                    ],
                  ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? _goldenYellow : Colors.white.withValues(alpha: 0.2),
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
            Colors.white.withValues(alpha: 0.12),
            Colors.white.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLegendItem(
            color: Colors.green,
            label: 'Free / Libre',
          ),
          Container(
            width: 1,
            height: 30,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          _buildLegendItem(
            color: Colors.red,
            label: 'Occupied / Occupé',
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    final isGreen = color == Colors.green;
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
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              isGreen ? 'FREE' : 'BUSY',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white70,
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
    final isFree = !slot.occupied;

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
            colors: isFree
                ? [Colors.green.shade400, Colors.green.shade600]
                : [Colors.red.shade400, Colors.red.shade600],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (isFree ? Colors.green : Colors.red)
                  .withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              _showSpotDetails(slot: slot);
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
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  slot.availabilityDisplay,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
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

  void _showSpotDetails({required ParkingSlot slot}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Spot #${slot.slotNumber} Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(
              'Status:',
              slot.occupied ? '🔴 OCCUPIED' : '🟢 FREE',
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              'Availability:',
              '${slot.availabilityDisplay} - ${slot.occupied ? 'Not Available' : 'Available'}',
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              'Distance:',
              '${slot.distanceCm.toStringAsFixed(1)} cm',
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              'Updated:',
              _formatTime(slot.updatedAt),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0B2A4A),
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF0B2A4A),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.black87),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
