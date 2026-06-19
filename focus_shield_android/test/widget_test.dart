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

  testWidgets('Debug center opens from settings', (tester) async {
    await tester.pumpWidget(
      FocusShieldApp(repository: InMemoryAppStateRepository()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Database Debug Center'));
    await tester.pumpAndSettle();

    expect(find.text('Database Debug Center'), findsOneWidget);
    expect(find.text('Attempt History'), findsOneWidget);
  });

  testWidgets('Coach screen reacts to pending attempt history', (tester) async {
    await tester.pumpWidget(
      FocusShieldApp(repository: InMemoryAppStateRepository()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.shield_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Test Blocked Domain'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Back to Scanner'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.psychology_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Recovery Intelligence'), findsOneWidget);
    expect(find.text('Needs Action'), findsOneWidget);
    expect(find.text('Recovery Discipline'), findsOneWidget);
  });

  testWidgets('Debug center can mark attempt recovered', (tester) async {
    await tester.pumpWidget(
      FocusShieldApp(repository: InMemoryAppStateRepository()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.shield_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Test Blocked Domain'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Back to Scanner'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Database Debug Center'));
    await tester.pumpAndSettle();

    expect(find.text('Pending'), findsOneWidget);

    await tester.tap(find.text('Mark Recovered').first);
    await tester.pumpAndSettle();

    expect(find.text('Recovered'), findsWidgets);
  });

  testWidgets('Goals and affirmations manager adds custom items', (tester) async {
    await tester.pumpWidget(
      FocusShieldApp(repository: InMemoryAppStateRepository()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Goals & Affirmations'));
    await tester.pumpAndSettle();

    expect(find.text('Goals & Affirmations'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('goalTitleInput')), 'Custom discipline goal');
    await tester.enterText(find.byKey(const Key('goalDescriptionInput')), 'Stay consistent.');
    await tester.tap(find.text('Add Goal'));
    await tester.pumpAndSettle();

    expect(find.text('Custom discipline goal'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('affirmationInput')), 'I return to my goals immediately.');
    await tester.tap(find.text('Add Affirmation'));
    await tester.pumpAndSettle();

    expect(find.text('I return to my goals immediately.'), findsOneWidget);
  });

  testWidgets('Protection database manager adds custom blocked domain', (tester) async {
    await tester.pumpWidget(
      FocusShieldApp(repository: InMemoryAppStateRepository()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Protection Database'));
    await tester.pumpAndSettle();

    expect(find.text('Protection Database'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('blockedDomainInput')), 'custom-risk.test');
    await tester.enterText(find.byKey(const Key('blockedCategoryInput')), 'custom-blocklist');

    await tester.tap(find.text('Add Domain'));
    await tester.pumpAndSettle();

    expect(find.text('custom-risk.test'), findsOneWidget);
  });

  testWidgets('Scanner blocks custom saved domain', (tester) async {
    await tester.pumpWidget(
      FocusShieldApp(repository: InMemoryAppStateRepository()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Protection Database'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('blockedDomainInput')), 'custom-risk.test');
    await tester.tap(find.text('Add Domain'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.shield_rounded));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('scannerDomainInput')), 'custom-risk.test');
    await tester.tap(find.text('Scan'));
    await tester.pumpAndSettle();

    expect(find.text('Intervention'), findsOneWidget);
    expect(find.text('custom-risk.test'), findsOneWidget);
  });

  testWidgets('Reset app data clears progress', (tester) async {
    await tester.pumpWidget(
      FocusShieldApp(repository: InMemoryAppStateRepository()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Log Listening Win').first);
    await tester.pumpAndSettle();

    expect(find.text('1 / 3'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.settings_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reset App Data').last);
    await tester.pumpAndSettle();

    expect(find.text('0 / 3'), findsOneWidget);
    expect(find.text('45'), findsOneWidget);
  });
}
