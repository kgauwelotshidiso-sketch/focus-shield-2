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
}
