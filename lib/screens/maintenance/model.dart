class MaintenanceResponse {
  final bool isInMaintenance;
  final String message;
  final bool success;
  final String heading;
  final String description;
  final String estimatedTime;

  MaintenanceResponse({
    required this.isInMaintenance,
    required this.message,
    required this.success,
    this.heading = 'We\'ll be back soon!',
    this.description = 'We\'re currently performing scheduled maintenance. Please check back in a while.',
    this.estimatedTime = 'A few minutes',
  });
}