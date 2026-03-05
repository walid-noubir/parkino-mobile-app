import 'package:flutter/material.dart';
import '../../widgets/language_button.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onTabChanged;

  const HomeScreen({super.key, this.onTabChanged});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  int _freeSpots = 5;
  static const int _totalSpots = 8;
  static const Color _primaryDarkBlue = Color(0xFF0B2A4A);
  static const Color _goldenYellow = Color(0xFFFFC107);
  static const Color _lightGray = Color(0xFFF5F5F5);
  static const Color _accentBlue = Color(0xFF1E88E5);
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    _pulseAnimation =
        Tween<double>(begin: 0.95, end: 1.0).animate(_pulseController);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFull = _freeSpots == 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with logo and greeting
              _buildHeader(),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Main parking status card
                    _buildMainStatusCard(isFull),
                    const SizedBox(height: 28),
                    // Quick stats
                    _buildStatsRow(),
                    const SizedBox(height: 28),
                    // Info cards
                    _buildInfoCards(),
                    const SizedBox(height: 28),
                    // View map button
                    _buildViewMapButton(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, _lightGray],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Spacer(),
              const LanguageButton(),
            ],
          ),
          const SizedBox(height: 12),
          Image.asset(
            'assets/images/parkino_logo.png',
            width: 80,
            height: 80,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 12),
          const Text(
            'Parkino',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: _primaryDarkBlue,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Smart Parking Management',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF666666),
              fontWeight: FontWeight.w400,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildMainStatusCard(bool isFull) {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: _goldenYellow.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: _lightGray,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // Status header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Parking Availability',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF999999),
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Current Status',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _primaryDarkBlue,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isFull
                          ? [Colors.red.shade400, Colors.red.shade600]
                          : [
                              Colors.green.shade400,
                              Colors.green.shade600,
                            ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: (isFull ? Colors.red : Colors.green)
                            .withValues(alpha: 0.3),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Text(
                    isFull ? 'FULL' : 'AVAILABLE',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 36),
            // Circular progress indicator
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _primaryDarkBlue.withValues(alpha: 0.05),
                    _goldenYellow.withValues(alpha: 0.04),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _goldenYellow.withValues(alpha: 0.15),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: CircularProgressIndicator(
                          value: _freeSpots / _totalSpots,
                          strokeWidth: 10,
                          backgroundColor: _primaryDarkBlue.withValues(alpha: 0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isFull ? Colors.red : _accentBlue,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$_freeSpots',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: _goldenYellow,
                              height: 1,
                            ),
                          ),
                          const Text(
                            'AVAILABLE',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _primaryDarkBlue,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '$_freeSpots out of $_totalSpots parking spots',
                    style: const TextStyle(
                      fontSize: 13,
                      color: _primaryDarkBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Occupancy rate: ${(((_totalSpots - _freeSpots) / _totalSpots) * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF999999),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Last updated 2 minutes ago',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFFBBBBBB),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'OCCUPIED',
            '${_totalSpots - _freeSpots}',
            Icons.local_parking_rounded,
            Colors.red.shade400,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'AVAILABLE',
            '$_freeSpots',
            Icons.check_circle_rounded,
            Colors.green.shade400,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _primaryDarkBlue,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCards() {
    return Column(
      children: [
        _buildInfoCardItem(
          icon: Icons.schedule_rounded,
          iconColor: Colors.orange,
          title: 'Peak Hours',
          subtitle: '9 AM - 11 AM & 5 PM - 7 PM',
          description: 'Expect busy parking times',
        ),
        const SizedBox(height: 12),
        _buildInfoCardItem(
          icon: Icons.location_on_rounded,
          iconColor: _accentBlue,
          title: 'Nearest Spot',
          subtitle: 'Zone A - Bay 5',
          description: '45 meters away',
        ),
      ],
    );
  }

  Widget _buildInfoCardItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _lightGray,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _primaryDarkBlue,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _goldenYellow,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF999999),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: Color(0xFFDDDDDD),
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
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_goldenYellow, Color(0xFFFFB800)],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: _goldenYellow.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 12),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              widget.onTabChanged?.call(1);
            },
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.map_rounded,
                    color: _primaryDarkBlue,
                    size: 26,
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'VIEW PARKING MAP',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _primaryDarkBlue,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: _primaryDarkBlue,
                    size: 22,
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
