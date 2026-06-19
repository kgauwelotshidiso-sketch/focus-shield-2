class BlockedAttempt {
  const BlockedAttempt({
    required this.id,
    required this.website,
    required this.category,
    required this.timestamp,
    this.recovered = false,
  });

  final int id;
  final String website;
  final String category;
  final DateTime timestamp;
  final bool recovered;
}
