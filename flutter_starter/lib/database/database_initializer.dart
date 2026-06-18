import 'database_provider.dart';

class DatabaseInitializer {
  final DatabaseProvider provider;

  const DatabaseInitializer(this.provider);

  Future<void> initialize() async {
    await provider.open();

    if (!provider.isInitialized) {
      throw StateError('Focus Shield database failed to initialize.');
    }
  }
}
