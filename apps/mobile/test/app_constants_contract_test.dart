import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/Constants/ai_config.dart';
import 'package:splitr/Constants/app_branding.dart';
import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/auth_validators.dart';
import 'package:splitr/Constants/business_rules.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Utils/sync_table_keys.dart';
import 'package:splitr/Utils/transaction_date_formatter.dart';

void main() {
  group('domain contract values', () {
    test('currency and sync defaults', () {
      expect(CurrencyDefaults.code, 'INR');
      expect(SyncStatusValues.synced, 'synced');
      expect(SyncStatusValues.pending, 'pending');
      expect(SharingTypeValues.evenly, 'evenly');
      expect(SharingTypeValues.byItem, 'by_item');
      expect(FriendStatusValues.accepted, 'accepted');
      expect(LoanStatusValues.pending, 'pending');
      expect(GoalTransactionTypes.deposit, 'deposit');
      expect(InsightActionTypes.settleUp, 'settle_up');
    });

    test('SharingMode maps to db values and labels', () {
      expect(SharingMode.byEvenly.dbValue, SharingTypeValues.evenly);
      expect(SharingMode.byItem.dbValue, SharingTypeValues.byItem);
      expect(SharingMode.byItem.label, 'By Item');
      expect(
        SharingModeValues.fromDbValue(SharingTypeValues.byItem),
        SharingMode.byItem,
      );
    });
  });

  group('schema and persistence keys', () {
    test('supabase tables and pref keys', () {
      expect(SupabaseTables.groups, 'groups');
      expect(SupabaseTables.groupTransaction, 'group_transaction');
      expect(SupabaseTables.personalTransaction, 'personal_transaction');
      expect(SupabaseRpc.createGroupWithMember, 'create_group_with_member');
      expect(PrefKeys.hasSeenOnboarding, 'hasSeenOnboarding');
      expect(PrefKeys.selectedCurrency, 'selected_currency');
    });

    test('sync primary key field unchanged', () {
      expect(
          syncPrimaryKeyField(SupabaseTables.groups), SupabaseColumns.groupId);
      expect(
        syncPrimaryKeyField(SupabaseTables.groupTransaction),
        SupabaseColumns.transactionId,
      );
      expect(syncPrimaryKeyField('unknown_table'), SupabaseColumns.id);
    });
  });

  group('formats and thresholds', () {
    test('date format patterns', () {
      expect(AppDateFormats.exportDate, 'yyyy-MM-dd');
      expect(AppDateFormats.shortDayYear, 'MMM d, yyyy');
      expect(AppDateFormats.transactionPicker, 'dd MMM yyyy');
    });

    test('business thresholds', () {
      expect(MoneyEpsilon.balanceSettled, 0.01);
      expect(BudgetRules.alertThreshold, 0.9);
      expect(AiThresholds.ambitiousMonthlyInr, 50000);
      expect(GroupBusinessRules.percentageTotal, 100.0);
      expect(AuthRules.minPasswordLength, 6);
    });
  });

  group('representative copy', () {
    test('date labels', () {
      final ref = DateTime(2026, 7, 1);
      expect(
        TransactionDateFormatter.formatRelative(
          DateTime(2026, 7, 1),
          reference: ref,
        ),
        AppStrings.dates.today,
      );
      expect(
        TransactionDateFormatter.formatRelative(
          DateTime(2026, 6, 30),
          reference: ref,
        ),
        AppStrings.dates.yesterday,
      );
    });

    test('auth validators', () {
      expect(AuthValidators.email(''), AuthValidators.emailRequired);
      expect(AuthValidators.email('bad'), AuthValidators.emailInvalid);
      expect(
          AuthValidators.password('12345'), AuthValidators.passwordMinLength);
      expect(
        AuthValidators.confirmPassword('x', 'y'),
        AuthValidators.passwordsDoNotMatch,
      );
    });

    test('branding and ai model', () {
      expect(AppBranding.brandName, 'Splitr');
      expect(AppBranding.webBaseUrl, 'https://splitr.money');
      expect(AppBranding.webHost, 'splitr.money');
      expect(AiConfig.model, 'gemini-3-flash-preview');
    });
  });
}
