class Goal {
  final int? id;
  final String title;
  final String description;
  final bool completed;
  final DateTime createdAt;

  const Goal({
    this.id,
    required this.title,
    required this.description,
    required this.completed,
    required this.createdAt,
  });
}
