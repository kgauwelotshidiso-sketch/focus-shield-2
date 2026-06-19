class AttemptRecord {
  const AttemptRecord({
    required this.id,
    required this.domain,
    required this.category,
    required this.confidence,
    required this.recovered,
    required this.createdAt,
  });

  final int id;
  final String domain;
  final String category;
  final double confidence;
  final bool recovered;
  final DateTime createdAt;

  AttemptRecord copyWith({
    int? id,
    String? domain,
    String? category,
    double? confidence,
    bool? recovered,
    DateTime? createdAt,
  }) {
    return AttemptRecord(
      id: id ?? this.id,
      domain: domain ?? this.domain,
      category: category ?? this.category,
      confidence: confidence ?? this.confidence,
      recovered: recovered ?? this.recovered,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
