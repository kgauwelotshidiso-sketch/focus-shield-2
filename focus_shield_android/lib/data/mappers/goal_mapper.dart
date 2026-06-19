import '../../domain/models/goal.dart';

class GoalMapper {
  static Map<String, Object?> toDatabaseMap(Goal goal) {
    return {
      'id': goal.id,
      'title': goal.title,
      'description': goal.description,
      'created_at': goal.createdAt.toIso8601String(),
      'updated_at': goal.updatedAt.toIso8601String(),
    };
  }

  static Goal fromDatabaseMap(Map<String, Object?> map) {
    return Goal(
      id: (map['id'] as int?) ?? 0,
      title: (map['title'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      createdAt:
          DateTime.tryParse((map['created_at'] as String?) ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt:
          DateTime.tryParse((map['updated_at'] as String?) ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
