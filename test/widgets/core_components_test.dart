import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:splitr/Constants/glass_card.dart';
import 'package:splitr/Constants/sync_indicator_widget.dart';
import 'package:splitr/Services/sync_service.dart';
import 'package:splitr/Widgets/hero_amount_field.dart';
import 'package:splitr/Widgets/bordered_input_field.dart';
import 'package:splitr/Widgets/custom_big_text_form_field.dart';
import 'package:splitr/Widgets/dark_surface_theme.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Controller/notification_badge_controller.dart';
import 'package:splitr/Widgets/notification_bell_button.dart';
import 'package:splitr/Widgets/premium_gate.dart';
import 'package:splitr/Widgets/smart_decimal_text_field.dart';
import 'package:splitr/Widgets/tab_empty_state.dart';

import '../helpers/component_test_harness.dart';

void main() {
  group('BorderedInputField', () {
    testWidgets('renders hint and uses borderless inner decoration',
        (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await ComponentTestHarness.pump(
        tester,
        BorderedInputField(
          controller: controller,
          hintText: 'Enter amount',
          labelText: 'Amount',
        ),
      );

      expect(find.text('Amount'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('accepts text input', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await ComponentTestHarness.pump(
        tester,
        BorderedInputField(controller: controller, hintText: 'Type here'),
      );

      await tester.enterText(find.byType(TextFormField), '250');
      expect(controller.text, '250');
    });
  });

  group('CustomBigTextFormField', () {
    testWidgets('shows rupee prefix and amount label', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await ComponentTestHarness.pump(
        tester,
        CustomBigTextFormField(
          customBigTextFormFieldTextEditingController: controller,
          labelText: 'Amount',
        ),
      );

      expect(find.text('₹'), findsOneWidget);
      expect(find.text('Amount'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });
  });

  group('SmartDecimalTextField', () {
    testWidgets('renders and accepts decimal input', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await ComponentTestHarness.pump(
        tester,
        SmartDecimalTextField(controller: controller),
      );

      await tester.enterText(find.byType(TextField), '12.5');
      expect(controller.text, '12.5');
    });
  });

  group('PremiumLockBadge', () {
    testWidgets('shows PRO label', (tester) async {
      await ComponentTestHarness.pump(
        tester,
        const PremiumLockBadge(),
      );
      expect(find.text('PRO'), findsOneWidget);
      expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
    });
  });

  group('DarkSurfaceTheme', () {
    testWidgets('applies dark theme to child', (tester) async {
      await ComponentTestHarness.pump(
        tester,
        const DarkSurfaceTheme(
          child: Text('Dark child', key: Key('child')),
        ),
      );

      final childContext = tester.element(find.byKey(const Key('child')));
      expect(Theme.of(childContext).brightness, Brightness.dark);
    });
  });

  group('GlassCard', () {
    testWidgets('renders child inside frosted container', (tester) async {
      await ComponentTestHarness.pump(
        tester,
        const GlassCard(child: Text('Inside glass')),
      );

      expect(find.text('Inside glass'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsOneWidget);
    });
  });

  group('TabEmptyState', () {
    testWidgets('shows title and optional subtitle', (tester) async {
      await ComponentTestHarness.pump(
        tester,
        const TabEmptyState(
          title: 'Nothing here',
          subtitle: 'Add something',
          compact: true,
        ),
      );

      expect(find.text('Nothing here'), findsOneWidget);
      expect(find.text('Add something'), findsOneWidget);
    });
  });

  group('SyncIndicator', () {
    testWidgets('hides when synced', (tester) async {
      await ComponentTestHarness.pump(
        tester,
        const SyncIndicator(status: SyncStatus.synced),
      );
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('shows error icon on failure', (tester) async {
      await ComponentTestHarness.pump(
        tester,
        const SyncIndicator(status: SyncStatus.error),
      );
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });

    testWidgets('SyncStatusBanner shows syncing message', (tester) async {
      await ComponentTestHarness.pump(
        tester,
        const SyncStatusBanner(status: SyncStatus.syncing),
      );
      expect(find.text('Syncing changes...'), findsOneWidget);
    });
  });

  group('HeroAmountField', () {
    tearDown(ComponentTestHarness.tearDownGetX);

    testWidgets('renders currency symbol and hint', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await ComponentTestHarness.pump(
        tester,
        HeroAmountField(
          controller: controller,
          label: 'Amount',
          hintText: '0.00',
        ),
        withGetX: true,
      );

      expect(find.text('Amount'), findsOneWidget);
      expect(find.text('₹'), findsOneWidget);
      expect(find.text('0.00'), findsOneWidget);
    });
  });

  group('NotificationBellButton', () {
    tearDown(ComponentTestHarness.tearDownGetX);

    testWidgets('renders bell icon', (tester) async {
      Get.put(NotificationBadgeController(forTest: true));

      await ComponentTestHarness.pump(
        tester,
        const NotificationBellButton(),
        withGetX: true,
      );

      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    });

    testWidgets('shows badge dot when unseen', (tester) async {
      final badge = NotificationBadgeController(forTest: true);
      badge.seedUnseenForTest(true);
      Get.put(badge);

      await ComponentTestHarness.pump(
        tester,
        const NotificationBellButton(iconColor: neopopOnPrimary),
        withGetX: true,
      );

      final stacks = tester.widgetList<Stack>(find.byType(Stack));
      expect(stacks.any((stack) => stack.children.length > 1), isTrue);
    });
  });
}
