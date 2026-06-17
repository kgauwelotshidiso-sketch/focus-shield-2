import 'package:flutter/material.dart';
import 'routes.dart';
import 'theme.dart';

class FocusShieldApp extends StatelessWidget {
  const FocusShieldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Focus Shield',
      debugShowCheckedModeBanner: false,
      theme: FocusShieldTheme.darkTheme,
      initialRoute: AppRoutes.dashboard,
      routes: AppRoutes.routes,
    );
  }
}
