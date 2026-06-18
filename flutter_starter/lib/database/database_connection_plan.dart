class DatabaseConnectionPlan {
  static const initializationOrder = [
    'Open DatabaseProvider',
    'Run schema creation if database is new',
    'Run migrations if database version changed',
    'Create repository instances',
    'Inject repositories into services',
    'Inject services into screens',
  ];

  static const repositoryFlow = [
    'Screen',
    'Service',
    'Repository',
    'DatabaseProvider',
    'SQLite',
  ];

  static const safetyRules = [
    'Initialize database before protection engine starts',
    'Do not let screens access SQLite directly',
    'Do not start VPN filtering before blocklist repository is ready',
    'Run migrations before reading user data',
    'Never delete user data during migration without user confirmation',
  ];
}
