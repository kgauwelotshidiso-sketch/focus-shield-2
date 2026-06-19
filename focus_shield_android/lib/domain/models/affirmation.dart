class Affirmation {
  const Affirmation({
    required this.id,
    required this.text,
    this.favorite = false,
  });

  final int id;
  final String text;
  final bool favorite;
}
