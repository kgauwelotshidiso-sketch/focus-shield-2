class BlockedDomain {
  final int? id;
  final String domain;
  final String category;
  final DateTime updatedAt;

  const BlockedDomain({
    this.id,
    required this.domain,
    required this.category,
    required this.updatedAt,
  });
}
