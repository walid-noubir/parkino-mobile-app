import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/map/parking_map_screen.dart';
import '../screens/stats/stats_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/profile/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  static const Color _primaryDarkBlue = Color(0xFF0B2A4A);
  static const Color _goldenYellow = Color(0xFFFFC107);

  void _onChangeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  late final List<Widget> _screens = [
    HomeScreen(onTabChanged: _onChangeTab),
    const ParkingMapScreen(),
    const StatsScreen(),
    const NotificationsScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: _primaryDarkBlue,
        selectedItemColor: _goldenYellow,
        unselectedItemColor: Colors.grey[400],
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
