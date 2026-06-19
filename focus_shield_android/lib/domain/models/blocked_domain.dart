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

  BlockedDomain copyWith({
    int? id,
    String? domain,
    String? category,
    DateTime? updatedAt,
  }) {
    return BlockedDomain(
      id: id ?? this.id,
      domain: domain ?? this.domain,
      category: category ?? this.category,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
