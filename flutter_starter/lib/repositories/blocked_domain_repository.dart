import '../models/blocked_domain.dart';

class BlockedDomainRepository {
  Future<List<BlockedDomain>> getAllActiveDomains() async {
    // TODO: Query blocked_domains where is_active = 1.
    return [];
  }

  Future<BlockedDomain?> findByDomain(String domain) async {
    // TODO: Query blocked_domains by normalized domain.
    return null;
  }

  Future<void> insertDomain(BlockedDomain domain) async {
    // TODO: Insert or replace blocked domain.
  }

  Future<void> deactivateDomain(String domain) async {
    // TODO: Soft-delete by setting is_active = 0.
  }
}
