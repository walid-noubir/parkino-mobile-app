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
  late Animation<double> _scaleAnimation;
  final ParkingRepository _repository = ParkingRepository();

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
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
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
                  _buildLegend(),
                  const SizedBox(height: 32),
                  _buildParkingGrid(parkingData.slots),
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
      child: Column(
        children: [
          Image.asset(
            'assets/images/parkino_logo.png',
            width: 100,
            height: 100,
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
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
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
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 1,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: slots.length,
        itemBuilder: (context, index) {
          final slot = slots[index];
          return _buildParkingSpot(slot: slot);
        },
      ),
    );
  }

  Widget _buildParkingSpot({required ParkingSlot slot}) {
    final isFree = !slot.occupied;

    return Container(
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
              const SizedBox(height: 2),
              Text(
                '${slot.distanceCm.toStringAsFixed(1)} cm',
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
            ],
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
