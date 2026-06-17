import 'package:flutter/material.dart';

import '../screens/dashboard/dashboard_screen.dart';
import '../screens/protection_dashboard/protection_dashboard_screen.dart';
import '../screens/blocklist/blocklist_screen.dart';
import '../screens/url_analysis/url_analysis_screen.dart';
import '../screens/intervention/intervention_screen.dart';
import '../screens/settings/settings_screen.dart';

class AppRoutes {
  static const dashboard = '/';
  static const protectionDashboard = '/protection-dashboard';
  static const blocklist = '/blocklist';
  static const urlAnalysis = '/url-analysis';
  static const intervention = '/intervention';
  static const settings = '/settings';

  static Map<String, WidgetBuilder> get routes {
    return {
      dashboard: (_) => const DashboardScreen(),
      protectionDashboard: (_) => const ProtectionDashboardScreen(),
      blocklist: (_) => const BlocklistScreen(),
      urlAnalysis: (_) => const UrlAnalysisScreen(),
      intervention: (_) => const InterventionScreen(),
      settings: (_) => const SettingsScreen(),
    };
  }
}
