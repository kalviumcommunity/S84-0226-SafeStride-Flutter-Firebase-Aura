import '../models/route_model.dart';

/// A service that analyzes and categorizes [AlertModel] data to help users
/// understand risks and route conditions.
class AlertAnalysisService {
  /// Returns a list of alerts that are considered high severity.
  /// Severity is determined based on the alert type and color.
  static List<AlertModel> getHighSeverityAlerts(List<AlertModel> alerts) {
    return alerts.where((alert) {
      final type = alert.type.toLowerCase();
      final color = alert.color.toLowerCase();
      
      return color.contains('red') || 
             type.contains('danger') || 
             type.contains('critical') ||
             type.contains('emergency');
    }).toList();
  }

  /// Groups alerts by their type (e.g., 'Safety', 'Weather', 'Traffic').
  static Map<String, List<AlertModel>> groupAlertsByType(List<AlertModel> alerts) {
    final grouped = <String, List<AlertModel>>{};
    for (final alert in alerts) {
      final type = alert.type;
      if (!grouped.containsKey(type)) {
        grouped[type] = [];
      }
      grouped[type]!.add(alert);
    }
    return grouped;
  }

  /// Returns alerts that occurred in a specific location (case-insensitive).
  static List<AlertModel> getAlertsByLocation(List<AlertModel> alerts, String location) {
    final query = location.toLowerCase().trim();
    if (query.isEmpty) return alerts;
    
    return alerts.where((alert) => alert.location.toLowerCase().contains(query)).toList();
  }

  /// Categorizes an alert into a human-readable severity level.
  static String getSeverityLevel(AlertModel alert) {
    final color = alert.color.toLowerCase();
    if (color.contains('red')) return 'Critical';
    if (color.contains('orange') || color.contains('yellow')) return 'Warning';
    if (color.contains('blue') || color.contains('green')) return 'Information';
    return 'Normal';
  }

  /// Provides a count of alerts per category.
  static Map<String, int> getAlertStatistics(List<AlertModel> alerts) {
    final stats = <String, int>{};
    for (final alert in alerts) {
      stats[alert.type] = (stats[alert.type] ?? 0) + 1;
    }
    return stats;
  }

  /// Returns a list of unique locations that have active alerts.
  static List<String> getAffectedLocations(List<AlertModel> alerts) {
    return alerts.map((a) => a.location).toSet().toList();
  }
}
