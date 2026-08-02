import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:splitr/Model/achievement_model.dart';
import 'package:splitr/Widgets/achievement_celebration_overlay.dart';

void main() {
  testWidgets('AchievementCelebrationOverlay shows badge name and completes',
      (tester) async {
    var completed = false;
    const achievement = AchievementModel(
      id: 'a1',
      slug: 'first_trip',
      name: 'Explorer',
      description: 'Create your first trip.',
      iconKey: 'explorer',
      isUnlocked: true,
      celebrationShown: false,
    );

    await tester.pumpWidget(
      GetMaterialApp(
        home: AchievementCelebrationOverlay(
          achievement: achievement,
          onComplete: () async {
            completed = true;
          },
        ),
      ),
    );

    expect(find.text('Explorer'), findsOneWidget);
    expect(find.text('Create your first trip.'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump();

    expect(completed, isTrue);
  });
}
