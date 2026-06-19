class Goal {
  const Goal({
    required this.id,
    required this.title,
    this.description = '',
  });

  final int id;
  final String title;
  final String description;
}
