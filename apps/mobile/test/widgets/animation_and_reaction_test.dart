import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/Constants/swipe_to_settle_widget.dart';
import 'package:splitr/Constants/gradient_mesh_background.dart';
import 'package:splitr/Constants/staggered_list_animation.dart';

import '../helpers/component_test_harness.dart';

void main() {
  group('GradientMeshBackground', () {
    testWidgets('paints animated mesh behind child', (tester) async {
      await ComponentTestHarness.pump(
        tester,
        const GradientMeshBackground(child: Text('Mesh child')),
      );

      expect(find.text('Mesh child'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });

  group('StaggeredListItem', () {
    testWidgets('eventually shows child after animation', (tester) async {
      await ComponentTestHarness.pump(
        tester,
        const StaggeredListItem(
          index: 0,
          delay: Duration(milliseconds: 1),
          duration: Duration(milliseconds: 50),
          child: Text('Staggered'),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Staggered'), findsOneWidget);
    });
  });

  group('SwipeToSettleWidget', () {
    testWidgets('shows settle details and swipe prompt', (tester) async {
      var cancelled = false;

      await ComponentTestHarness.pump(
        tester,
        SwipeToSettleWidget(
          amount: 250,
          fromName: 'Alex',
          toName: 'Sam',
          onSettled: () {},
          onCancel: () => cancelled = true,
        ),
      );

      expect(find.text('Settle Up'), findsOneWidget);
      expect(find.text('₹250.00'), findsOneWidget);
      expect(find.text('Swipe to settle →'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();

      expect(cancelled, isTrue);
    });
  });
}
