import '../models/blocked_domain.dart';

class BlocklistService {
  Future<BlockedDomain?> findDomain(String domain) async {
    return null;
  }

  Future<void> addDomain(BlockedDomain domain) async {}

  Future<void> removeDomain(String domain) async {}
}
