import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focus_shield_android/app.dart';
import 'package:focus_shield_android/data/repositories/in_memory_app_state_repository.dart';

void main() {
  testWidgets('Focus Shield app loads home screen', (tester) async {
    await tester.pumpWidget(
      FocusShieldApp(repository: InMemoryAppStateRepository()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Focus Shield'), findsOneWidget);
    expect(find.text('Discipline + protection dashboard'), findsOneWidget);
  });

  testWidgets('Listening win updates mission and XP', (tester) async {
    await tester.pumpWidget(
      FocusShieldApp(repository: InMemoryAppStateRepository()),
    );
    await tester.pumpAndSettle();

    expect(find.text('0 / 3'), findsOneWidget);
    expect(find.text('45'), findsOneWidget);

    await tester.tap(find.text('Log Listening Win').first);
    await tester.pumpAndSettle();

    expect(find.text('1 / 3'), findsOneWidget);
    expect(find.text('55'), findsOneWidget);
  });

  testWidgets('Blocked scanner test opens intervention screen', (tester) async {
    await tester.pumpWidget(
      FocusShieldApp(repository: InMemoryAppStateRepository()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.shield_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Test Blocked Domain'));
    await tester.pumpAndSettle();

    expect(find.text('Intervention'), findsOneWidget);
    expect(find.text('⚠ Temptation Detected'), findsOneWidget);
    expect(find.text('blocked-example.com'), findsOneWidget);
  });

  testWidgets('Intervention recovery updates recovery rate', (tester) async {
    await tester.pumpWidget(
      FocusShieldApp(repository: InMemoryAppStateRepository()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.shield_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Test Blocked Domain'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('I am back in control'));
    await tester.pumpAndSettle();

    expect(find.text('Recovery'), findsOneWidget);
    expect(find.text('100%'), findsWidgets);
  });

  testWidgets('Settings toggles protection status', (tester) async {
    await tester.pumpWidget(
      FocusShieldApp(repository: InMemoryAppStateRepository()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings_rounded));
    await tester.pumpAndSettle();

    expect(find.text('ON'), findsOneWidget);

    await tester.tap(find.text('Turn Protection Off'));
    await tester.pumpAndSettle();

    expect(find.text('OFF'), findsOneWidget);
  });
}
