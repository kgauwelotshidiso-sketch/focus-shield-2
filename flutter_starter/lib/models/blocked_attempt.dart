class BlockedAttempt {
  final int? id;
  final String website;
  final String category;
  final String reason;
  final double confidence;
  final DateTime timestamp;

  const BlockedAttempt({
    this.id,
    required this.website,
    required this.category,
    required this.reason,
    required this.confidence,
    required this.timestamp,
  });
}
