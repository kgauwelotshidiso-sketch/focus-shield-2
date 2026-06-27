import 'package:flutter/material.dart';

import 'app.dart';
import 'presentation/services/commitment_sync_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CommitmentSyncService.load(forceDefaultIfMissing: true);
  await CommitmentSyncService.ensureDailyUseDefaults();
  runApp(const FocusShieldApp());
}
