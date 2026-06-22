import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../providers/language_provider.dart';
import '../../providers/firebase_auth_provider.dart';
import '../../providers/reservation_notification_provider.dart';
import '../../localization/app_localizations.dart';
import '../../theme/parkino_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.watch<LanguageProvider>().locale;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Consumer2<NotificationProvider, FirebaseAuthProvider>(
          builder: (context, notificationProvider, authProvider, _) {
            // Obtenir uniquement les notifications de l'utilisateur connecté
            final notifications = notificationProvider.getNotificationsForCurrentUser();

            return FadeTransition(
              opacity: _fadeController,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Header with Logo
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                      child: Column(
                        children: [
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: Image.asset(
                              'assets/images/parkino_logo.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            AppLocalizations.t('notifications_title'),
                            style: GoogleFonts.poppins(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: ParkinoTheme.primaryDarkBlue,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.t('stay_updated'),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (notifications.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Text(
                                '${notifications.length} notification${notifications.length > 1 ? 's' : ''}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: ParkinoTheme.goldenYellow,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Empty State
                  if (notifications.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: ParkinoTheme.goldenYellow.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.notifications_none,
                                  size: 64,
                                  color: ParkinoTheme.goldenYellow,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                AppLocalizations.t('notification_empty_title'),
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: ParkinoTheme.primaryDarkBlue,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AppLocalizations.t('notification_empty_subtitle'),
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    // Notifications List
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final notification = notifications[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildNotificationCard(notification),
                            );
                          },
                          childCount: notifications.length,
                        ),
                      ),
                    ),

                  // Bottom spacing
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 20),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotificationCard(AppNotification notification) {
    final statusColors = _getStatusColors(notification.type);
    final statusIcon = _getStatusIcon(notification.type);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ParkinoTheme.white,
            ParkinoTheme.white.withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColors['border']!.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColors['shadow']!.withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.read<NotificationProvider>().markAsRead(notification.id);
            _showNotificationDetails(notification);
          },
          borderRadius: BorderRadius.circular(20),
          splashColor: statusColors['border']!.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 56,
                      height: 56,
                      child: Image.asset(
                        'assets/images/parkino_logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                notification.title,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: ParkinoTheme.primaryDarkBlue,
                                ),
                              ),
                              if (!notification.isRead)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: statusColors['highlight'],
                                    shape: BoxShape.circle,
                                  ),
                                )
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notification.formattedTime,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Divider
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.grey[300]!,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Content
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: statusColors['background']!.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: statusColors['border']!.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: statusColors['highlight']!.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          statusIcon,
                          color: statusColors['highlight'],
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getTitleForType(notification.type, notification.spotNumber),
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: ParkinoTheme.primaryDarkBlue,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notification.message,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey[600],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
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

  Map<String, Color> _getStatusColors(String type) {
    switch (type) {
      case 'reservation':
        return {
          'highlight': ParkinoTheme.goldenYellow,
          'background': ParkinoTheme.goldenYellow,
          'border': ParkinoTheme.goldenYellow,
          'shadow': ParkinoTheme.goldenYellow,
        };
      case 'success':
        return {
          'highlight': ParkinoTheme.successGreen,
          'background': ParkinoTheme.successGreen,
          'border': ParkinoTheme.successGreen,
          'shadow': ParkinoTheme.successGreen,
        };
      case 'warning':
        return {
          'highlight': Colors.orange,
          'background': Colors.orange,
          'border': Colors.orange,
          'shadow': Colors.orange,
        };
      case 'expiration':
        return {
          'highlight': ParkinoTheme.errorRed,
          'background': ParkinoTheme.errorRed,
          'border': ParkinoTheme.errorRed,
          'shadow': ParkinoTheme.errorRed,
        };
      default:
        return {
          'highlight': ParkinoTheme.infoBlue,
          'background': ParkinoTheme.infoBlue,
          'border': ParkinoTheme.infoBlue,
          'shadow': ParkinoTheme.infoBlue,
        };
    }
  }

  IconData _getStatusIcon(String type) {
    switch (type) {
      case 'reservation':
        return Icons.event_available;
      case 'success':
        return Icons.check_circle;
      case 'warning':
        return Icons.warning_rounded;
      case 'expiration':
        return Icons.timer_off;
      default:
        return Icons.info;
    }
  }

  String _getTitleForType(String type, int spotNumber) {
    switch (type) {
      case 'reservation':
        return 'Place réservée';
      case 'success':
        return 'Place disponible';
      case 'warning':
        return 'Place occupée';
      case 'expiration':
        return 'Réservation expirée';
      default:
        return 'Notification';
    }
  }

  void _showNotificationDetails(AppNotification notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getStatusIcon(notification.type),
              color: _getStatusColors(notification.type)['highlight'],
            ),
            const SizedBox(width: 8),
            Text(notification.title),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Place n°${notification.spotNumber}'),
            const SizedBox(height: 8),
            Text(notification.message),
            if (notification.code.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ParkinoTheme.goldenYellow.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Code: ${notification.code}'),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Code copié')),
                        );
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              notification.formattedDateTime,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}
