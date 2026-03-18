import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/mock_data.dart';
import '../models/route_model.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({
    super.key,
  });

  IconData _getAlertIcon(String type) {
    switch (type) {
      case 'warning':
        return Icons.warning;
      case 'success':
        return Icons.check_circle;
      case 'info':
        return Icons.info;
      default:
        return Icons.info;
    }
  }

  Color _getAlertColor(String colorHex) {
    return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: (Theme.of(context).brightness == Brightness.dark) ? AppColors.darkBlue : AppColors.lightBackground,
      body: Column(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: (Theme.of(context).brightness == Brightness.dark)
                    ? [AppColors.lightBlue, Colors.transparent]
                    : [AppColors.lightBackground, Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: const EdgeInsets.only(left: 24, right: 24, top: 64, bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alerts',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white : AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Stay updated on route conditions',
                  style: TextStyle(
                    fontSize: 14,
                    color: (Theme.of(context).brightness == Brightness.dark) ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Stats Summary
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(child: _buildStatCard(context, Icons.check_circle, '3', 'Updates', AppColors.neonGreen)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard(context, Icons.warning, '2', 'Warnings', AppColors.safetyMedium)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard(context, Icons.info, '1', 'Info', AppColors.skyBlue)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Alerts List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: MockData.alerts.length + 2, // +2 for header and bottom spacing
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      'Recent Alerts',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white : AppColors.textDark,
                      ),
                    ),
                  );
                }
                
                if (index == MockData.alerts.length + 1) {
                  return const SizedBox(height: 100);
                }
                
                final alert = MockData.alerts[index - 1];
                return _buildAlertCard(context, alert);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (Theme.of(context).brightness == Brightness.dark) ? AppColors.mediumBlue : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity((Theme.of(context).brightness == Brightness.dark) ? 0.3 : 0.08),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: (Theme.of(context).brightness == Brightness.dark) ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, AlertModel alert) {
    final alertColor = _getAlertColor(alert.color);
    final alertIcon = _getAlertIcon(alert.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: (Theme.of(context).brightness == Brightness.dark) ? AppColors.mediumBlue : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity((Theme.of(context).brightness == Brightness.dark) ? 0.2 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: alertColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(alertIcon, color: alertColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white : AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  alert.message,
                  style: TextStyle(
                    fontSize: 14,
                    color: (Theme.of(context).brightness == Brightness.dark) ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.place,
                      size: 16,
                      color: (Theme.of(context).brightness == Brightness.dark) ? Colors.grey[500] : Colors.grey[400],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      alert.location,
                      style: TextStyle(
                        fontSize: 12,
                        color: (Theme.of(context).brightness == Brightness.dark) ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: (Theme.of(context).brightness == Brightness.dark) ? Colors.grey[500] : Colors.grey[400],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      alert.time,
                      style: TextStyle(
                        fontSize: 12,
                        color: (Theme.of(context).brightness == Brightness.dark) ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: (Theme.of(context).brightness == Brightness.dark) ? Colors.grey[600] : Colors.grey[400],
          ),
        ],
      ),
    );
  }
}
