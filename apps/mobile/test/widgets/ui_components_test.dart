import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/Constants/category_style.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/shared.dart';
import 'package:splitr/Model/group_model.dart';
import 'package:splitr/Model/product_category_model.dart';
import 'package:splitr/Model/trip_model.dart';
import 'package:splitr/Screen/HomeScreen/widgets/personal_transaction_form_fields.dart';
import 'package:splitr/Screen/LendingScreen/widgets/loan_payment_sheet.dart';
import 'package:splitr/Model/loan_model.dart';
import 'package:splitr/Widgets/active_group_card.dart';
import 'package:splitr/Widgets/animated_glass_bottom_nav_bar.dart';
import 'package:splitr/Widgets/pill_tab_bar.dart';
import 'package:splitr/Widgets/summary_stat_card.dart';
import 'package:splitr/Widgets/transaction_tile.dart';
import 'package:splitr/Widgets/trip_gradient_card.dart';

import '../helpers/component_test_harness.dart';

void main() {
  tearDown(ComponentTestHarness.tearDownGetX);

  group('category_style', () {
    test('categoryColor maps known categories', () {
      expect(categoryColor('food'), neopopAccent);
      expect(categoryColor('unknown'), Colors.grey);
    });

    test('categoryIcon maps food to restaurant icon', () {
      expect(categoryIcon('food'), Icons.restaurant);
    });
  });

  group('PrimaryTextFormField', () {
    testWidgets('renders label and toggles obscure text', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await ComponentTestHarness.pump(
        tester,
        PrimaryTextFormField(
          textEditingController: controller,
          fieldName: 'Password',
          isObscure: true,
          validator: null,
        ),
      );

      expect(find.text('Password'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });
  });

  group('PersonalTransactionTypeToggle', () {
    testWidgets('switches between expense and income', (tester) async {
      var income = false;

      await ComponentTestHarness.pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            return PersonalTransactionTypeToggle(
              isIncome: income,
              onChanged: (v) => setState(() => income = v),
            );
          },
        ),
      );

      expect(find.text('Expense'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
      await tester.tap(find.text('Income'));
      await tester.pump();
      expect(income, isTrue);
    });
  });

  group('PersonalCategoryPicker', () {
    testWidgets('shows loading indicator', (tester) async {
      await ComponentTestHarness.pump(
        tester,
        PersonalCategoryPicker(
          categories: const [],
          selected: null,
          isIncome: false,
          loading: true,
          onSelected: (_) {},
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error with retry', (tester) async {
      var retried = false;

      await ComponentTestHarness.pump(
        tester,
        PersonalCategoryPicker(
          categories: const [],
          selected: null,
          isIncome: false,
          loading: false,
          errorMessage: 'Offline',
          onRetry: () => retried = true,
          onSelected: (_) {},
        ),
      );

      expect(find.text('Offline'), findsOneWidget);
      await tester.tap(find.text('Try again'));
      expect(retried, isTrue);
    });

    testWidgets('renders category chips', (tester) async {
      final food = CategoryOnlyModel(category: 'Food', categoryLogo: '');
      CategoryOnlyModel? selected;

      await ComponentTestHarness.pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            return PersonalCategoryPicker(
              categories: [food],
              selected: selected,
              isIncome: false,
              loading: false,
              onSelected: (c) => setState(() => selected = c),
            );
          },
        ),
      );

      expect(find.text('Food'), findsOneWidget);
      await tester.tap(find.text('Food'));
      await tester.pump();
      expect(selected?.category, 'Food');
    });
  });

  group('PersonalTransactionMetaRow', () {
    testWidgets('shows date and payment method', (tester) async {
      await ComponentTestHarness.pump(
        tester,
        SizedBox(
          width: 800,
          child: PersonalTransactionMetaRow(
            date: DateTime(2026, 3, 15),
            paymentMethod: 'UPI',
            paymentMethods: const ['Cash', 'UPI'],
            onPickDate: () {},
            onPaymentChanged: (_) {},
          ),
        ),
        surfaceSize: const Size(800, 800),
      );

      expect(find.textContaining('15 Mar'), findsOneWidget);
      expect(find.text('UPI'), findsWidgets);
    });
  });

  group('PillTabBar', () {
    testWidgets('renders tab labels', (tester) async {
      await ComponentTestHarness.pump(
        tester,
        DefaultTabController(
          length: 2,
          child: Builder(
            builder: (context) {
              return PillTabBar(
                controller: DefaultTabController.of(context),
                tabs: const ['One', 'Two'],
                badgeCounts: const [3, null],
              );
            },
          ),
        ),
      );

      expect(find.text('One'), findsOneWidget);
      expect(find.text('Two'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });
  });

  group('AnimatedGlassBottomNavBar', () {
    testWidgets('renders items and handles tap', (tester) async {
      var index = 0;

      await ComponentTestHarness.pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            return AnimatedGlassBottomNavBar(
              currentIndex: index,
              onTap: (i) => setState(() => index = i),
              items: const [
                BottomNavItemData(
                  outlineIcon: Icons.home_outlined,
                  filledIcon: Icons.home,
                  label: 'Home',
                ),
                BottomNavItemData(
                  outlineIcon: Icons.group_outlined,
                  filledIcon: Icons.group,
                  label: 'Groups',
                ),
              ],
            );
          },
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.group_outlined));
      await tester.pump();
      expect(index, 1);
    });
  });

  group('SummaryStatCard', () {
    testWidgets('shows title and currency amount', (tester) async {
      await ComponentTestHarness.pump(
        tester,
        const SummaryStatCard(
          title: 'SPENT',
          amount: '1200',
          subtitle: 'This month',
        ),
        withGetX: true,
      );

      expect(find.text('SPENT'), findsOneWidget);
      expect(find.textContaining('1200'), findsOneWidget);
    });
  });

  group('TransactionTile', () {
    testWidgets('renders personal expense row', (tester) async {
      await ComponentTestHarness.pump(
        tester,
        TransactionTile(
          currencySymbol: '₹',
          txn: {
            'title': 'Coffee',
            'amount': 120,
            'category': 'food',
            'is_credit': false,
            'type': 'personal',
            'date': DateTime(2026, 1, 15),
            'subtitle': 'Cash',
          },
        ),
        withGetX: true,
      );

      expect(find.text('Coffee'), findsOneWidget);
      expect(find.textContaining('120'), findsOneWidget);
    });
  });

  group('ActiveGroupCard', () {
    testWidgets('shows group name', (tester) async {
      await ComponentTestHarness.pump(
        tester,
        ActiveGroupCard(
          groupModel: GroupModel(groupName: 'Roommates'),
          onTap: () {},
        ),
      );

      expect(find.text('Roommates'), findsOneWidget);
    });
  });

  group('TripGradientCard', () {
    testWidgets('shows trip name and date range', (tester) async {
      await ComponentTestHarness.pump(
        tester,
        TripGradientCard(
          trip: TripModel(
            groupId: 'g1',
            tripName: 'Goa Trip',
            startDate: DateTime(2026, 3, 1),
            endDate: DateTime(2026, 3, 5),
            createdBy: 'u1',
            memberIds: const ['u1', 'u2', 'u3'],
          ),
          onTap: () {},
        ),
      );

      expect(find.text('Goa Trip'), findsOneWidget);
    });
  });

  group('LoanPaymentForm', () {
    testWidgets('shows record payment title and balance', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      final loan = LoanModel(
        id: 'loan-1',
        lenderID: 'l1',
        borrowerID: 'b1',
        principalAmount: 5000,
        repaymentAmount: 1000,
        startDate: DateTime(2026, 1, 1),
        status: 'active',
      );

      await ComponentTestHarness.pump(
        tester,
        LoanPaymentForm(
          loan: loan,
          controller: controller,
          isSubmitting: false,
          onSubmit: () {},
        ),
        withGetX: true,
      );

      expect(find.text('Record Payment'), findsOneWidget);
      expect(find.textContaining('Remaining balance'), findsOneWidget);
      expect(find.text('RECORD PAYMENT'), findsOneWidget);
    });
  });
}
