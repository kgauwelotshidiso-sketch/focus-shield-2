import '../../domain/models/attempt_record.dart';

class AttemptRecordMapper {
  static Map<String, Object?> toDatabaseMap(AttemptRecord attempt) {
    return {
      'id': attempt.id,
      'domain': attempt.domain,
      'category': attempt.category,
      'confidence': attempt.confidence,
      'recovered': attempt.recovered ? 1 : 0,
      'created_at': attempt.createdAt.toIso8601String(),
    };
  }

  static AttemptRecord fromDatabaseMap(Map<String, Object?> map) {
    final confidenceValue = map['confidence'];

    return AttemptRecord(
      id: (map['id'] as int?) ?? 0,
      domain: (map['domain'] as String?) ?? '',
      category: (map['category'] as String?) ?? 'unknown',
      confidence: confidenceValue is num ? confidenceValue.toDouble() : 0,
      recovered: ((map['recovered'] as int?) ?? 0) == 1,
      createdAt: DateTime.tryParse((map['created_at'] as String?) ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
