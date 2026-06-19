import '../../domain/models/affirmation.dart';

class AffirmationMapper {
  static Map<String, Object?> toDatabaseMap(Affirmation affirmation) {
    return {
      'id': affirmation.id,
      'text': affirmation.text,
      'favorite': affirmation.favorite ? 1 : 0,
      'created_at': affirmation.createdAt.toIso8601String(),
      'updated_at': affirmation.updatedAt.toIso8601String(),
    };
  }

  static Affirmation fromDatabaseMap(Map<String, Object?> map) {
    return Affirmation(
      id: (map['id'] as int?) ?? 0,
      text: (map['text'] as String?) ?? '',
      favorite: ((map['favorite'] as int?) ?? 0) == 1,
      createdAt: DateTime.tryParse((map['created_at'] as String?) ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.tryParse((map['updated_at'] as String?) ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
