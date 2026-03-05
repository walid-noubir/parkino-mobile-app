import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _percentageController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _percentageAnimation = Tween<double>(begin: 0, end: 37.5).animate(
      CurvedAnimation(parent: _percentageController, curve: Curves.easeInOut),
    );
    _percentageController.forward();
  }

  @override
  void dispose() {
    _percentageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
            width: 100,
            height: 100,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          const Text(
            'Statistics',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: _primaryDarkBlue,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Parking analytics',
            style: TextStyle(
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
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.95),
            Colors.white.withValues(alpha: 0.88),
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
          const Text(
            'Occupancy Rate',
            style: TextStyle(
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
                        const Text(
                          'Occupied',
                          style: TextStyle(
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
            child: const Text(
              '3 out of 8 spots occupied',
              style: TextStyle(
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
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildStatCard(
          icon: Icons.local_parking_rounded,
          title: 'Available',
          value: '5',
          color: Colors.green,
        ),
        _buildStatCard(
          icon: Icons.block_rounded,
          title: 'Occupied',
          value: '3',
          color: Colors.red,
        ),
        _buildStatCard(
          icon: Icons.access_time_rounded,
          title: 'Peak Hour',
          value: '6 PM',
          color: _goldenYellow,
        ),
        _buildStatCard(
          icon: Icons.timer_rounded,
          title: 'Avg. Stay',
          value: '2h 15m',
          color: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.95),
            Colors.white.withValues(alpha: 0.88),
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
