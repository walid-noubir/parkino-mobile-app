import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const Color _primaryDarkBlue = Color(0xFF0B2A4A);
  static const Color _goldenYellow = Color(0xFFFFC107);

  final List<Map<String, String>> notifications = const [
    {
      'title': 'Parking is full',
      'message': 'All 8 parking spots are currently occupied',
      'type': 'warning',
      'time': '2 hours ago',
    },
    {
      'title': 'Spot 3 is now free',
      'message': 'A parking spot has become available',
      'type': 'success',
      'time': '30 minutes ago',
    },
    {
      'title': 'System Maintenance',
      'message': 'Scheduled maintenance will occur tonight',
      'type': 'info',
      'time': '1 day ago',
    },
    {
      'title': 'New Feature Available',
      'message': 'Real-time parking predictions are now available',
      'type': 'success',
      'time': '2 days ago',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 16),
            Center(
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
                    'Notifications',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: _primaryDarkBlue,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return _buildNotificationCard(
                  context: context,
                  notification: notifications[index],
                  index: index,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required BuildContext context,
    required Map<String, String> notification,
    required int index,
  }) {
    Color iconColor;
    IconData iconData;

    switch (notification['type']) {
      case 'warning':
        iconColor = Colors.orange;
        iconData = Icons.warning_rounded;
        break;
      case 'success':
        iconColor = Colors.green;
        iconData = Icons.check_circle_rounded;
        break;
      case 'info':
      default:
        iconColor = _goldenYellow;
        iconData = Icons.info_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  notification['title'] ?? '',
                  style: const TextStyle(
                    color: _primaryDarkBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                backgroundColor: _goldenYellow,
                duration: const Duration(seconds: 3),
                margin: const EdgeInsets.all(16),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    iconData,
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
                        notification['title'] ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _primaryDarkBlue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification['message'] ?? '',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        notification['time'] ?? '',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
