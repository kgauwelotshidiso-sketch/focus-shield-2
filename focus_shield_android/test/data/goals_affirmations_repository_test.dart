import 'package:flutter_test/flutter_test.dart';
import 'package:focus_shield_android/data/database/database_provider.dart';
import 'package:focus_shield_android/data/repositories/in_memory_app_state_repository.dart';
import 'package:focus_shield_android/data/repositories/sqlite_app_state_repository.dart';
import 'package:focus_shield_android/domain/models/affirmation.dart';
import 'package:focus_shield_android/domain/models/goal.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  test('in-memory repository saves and deletes goals and affirmations', () async {
    final repository = InMemoryAppStateRepository();

    await repository.saveGoal(
      Goal(
        id: 0,
        title: 'Custom discipline goal',
        description: 'Stay consistent.',
      ),
    );

    await repository.saveAffirmation(
      Affirmation(
        id: 0,
        text: 'I return to my goals immediately.',
        favorite: true,
      ),
    );

    var goals = await repository.loadGoals();
    var affirmations = await repository.loadAffirmations();

    expect(goals.any((goal) => goal.title == 'Custom discipline goal'), true);
    expect(affirmations.any((item) => item.text == 'I return to my goals immediately.'), true);

    final customGoal = goals.firstWhere((goal) => goal.title == 'Custom discipline goal');
    final customAffirmation = affirmations.firstWhere(
      (item) => item.text == 'I return to my goals immediately.',
    );

    await repository.deleteGoal(customGoal.id);
    await repository.deleteAffirmation(customAffirmation.id);

    goals = await repository.loadGoals();
    affirmations = await repository.loadAffirmations();

    expect(goals.any((goal) => goal.title == 'Custom discipline goal'), false);
    expect(affirmations.any((item) => item.text == 'I return to my goals immediately.'), false);
  });

  test('SQLite repository saves and deletes goals and affirmations', () async {
    sqfliteFfiInit();

    final provider = DatabaseProvider(
      overridePath: inMemoryDatabasePath,
      databaseFactory: databaseFactoryFfi,
    );

    final repository = SqliteAppStateRepository(databaseProvider: provider);

    await repository.saveGoal(
      Goal(
        id: 0,
        title: 'Custom discipline goal',
        description: 'Stay consistent.',
      ),
    );

    await repository.saveAffirmation(
      Affirmation(
        id: 0,
        text: 'I return to my goals immediately.',
        favorite: true,
      ),
    );

    var goals = await repository.loadGoals();
    var affirmations = await repository.loadAffirmations();

    expect(goals.any((goal) => goal.title == 'Custom discipline goal'), true);
    expect(affirmations.any((item) => item.text == 'I return to my goals immediately.'), true);

    final customGoal = goals.firstWhere((goal) => goal.title == 'Custom discipline goal');
    final customAffirmation = affirmations.firstWhere(
      (item) => item.text == 'I return to my goals immediately.',
    );

    await repository.deleteGoal(customGoal.id);
    await repository.deleteAffirmation(customAffirmation.id);

    goals = await repository.loadGoals();
    affirmations = await repository.loadAffirmations();

    expect(goals.any((goal) => goal.title == 'Custom discipline goal'), false);
    expect(affirmations.any((item) => item.text == 'I return to my goals immediately.'), false);

    await provider.close();
  });
}
