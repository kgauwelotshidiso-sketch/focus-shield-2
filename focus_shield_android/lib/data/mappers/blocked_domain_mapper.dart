import '../../domain/models/blocked_domain.dart';

class BlockedDomainMapper {
  static Map<String, Object?> toDatabaseMap(BlockedDomain blockedDomain) {
    return {
      'id': blockedDomain.id,
      'domain': blockedDomain.domain,
      'category': blockedDomain.category,
      'updated_at': blockedDomain.updatedAt.toIso8601String(),
    };
  }

  static BlockedDomain fromDatabaseMap(Map<String, Object?> map) {
    return BlockedDomain(
      id: (map['id'] as int?) ?? 0,
      domain: (map['domain'] as String?) ?? '',
      category: (map['category'] as String?) ?? 'custom',
      updatedAt:
          DateTime.tryParse((map['updated_at'] as String?) ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
