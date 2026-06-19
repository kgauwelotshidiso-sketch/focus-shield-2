class Affirmation {
  Affirmation({
    required this.id,
    required this.text,
    this.favorite = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  final int id;
  final String text;
  final bool favorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  Affirmation copyWith({
    int? id,
    String? text,
    bool? favorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Affirmation(
      id: id ?? this.id,
      text: text ?? this.text,
      favorite: favorite ?? this.favorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
