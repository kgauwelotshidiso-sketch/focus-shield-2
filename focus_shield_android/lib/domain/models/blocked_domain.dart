class BlockedDomain {
  const BlockedDomain({
    required this.id,
    required this.domain,
    required this.category,
    required this.updatedAt,
  });

  final int id;
  final String domain;
  final String category;
  final DateTime updatedAt;
}
