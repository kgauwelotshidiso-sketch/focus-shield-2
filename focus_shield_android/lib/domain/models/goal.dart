class Goal {
  Goal({
    required this.id,
    required this.title,
    this.description = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  final int id;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  Goal copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
