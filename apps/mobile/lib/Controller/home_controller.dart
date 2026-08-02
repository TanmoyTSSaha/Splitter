import 'package:get/get.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Controllers/currency_controller.dart';
import 'package:splitr/Model/financial_goal_model.dart';
import 'package:splitr/Repository/personal_transaction_repository.dart';
import 'package:splitr/Services/personal_budget_alert_service.dart';
import 'package:splitr/Services/supabase_service.dart';
import 'package:splitr/Utils/app_error_reporter.dart';

/// Home dashboard state — personal + group visibility and analytics.
class HomeController extends GetxController {
  final SupabaseDatabase _supabase = SupabaseDatabase();
  final PersonalTransactionRepository _personalRepo = Get.find();

  final unifiedTransactions = <Map<String, dynamic>>[].obs;
  final monthlyAnalytics = <String, double>{}.obs;
  final goals = <FinancialGoalModel>[].obs;
  final isLoading = true.obs;
  final showTrueSpend = true.obs;
  final monthlyCashFlow = 0.0.obs;
  final dailySpendData = <Map<String, dynamic>>[].obs;
  final fetchError = RxnString();

  String? _userId;
  Worker? _currencyWorker;

  bool get hasHomeData =>
      unifiedTransactions.isNotEmpty ||
      goals.isNotEmpty ||
      monthlyAnalytics.entries
          .any((e) => e.key != UnifiedTxnKeys.total && e.value > 0);

  void initialize(String userId) {
    if (_userId == userId && _currencyWorker != null) return;
    _userId = userId;
    _currencyWorker?.dispose();
    final cc = Get.find<CurrencyController>();
    _currencyWorker = ever(cc.rxCode, (_) => fetchHomeData());
    fetchHomeData();
  }

  void toggleAnalyticsMode() {
    showTrueSpend.value = !showTrueSpend.value;
  }

  Future<void> fetchHomeData() async {
    if (_userId == null) return;
    isLoading.value = unifiedTransactions.isEmpty && goals.isEmpty;
    fetchError.value = null;

    try {
      final selectedCurrency = Get.find<CurrencyController>().code;
      final results = await Future.wait([
        _supabase.getUnifiedTransactions(
          userID: _userId!,
          selectedCurrency: selectedCurrency,
        ),
        _supabase.getMonthlySpendAnalytics(
          userID: _userId!,
          selectedCurrency: selectedCurrency,
        ),
        _supabase.getGoals(userID: _userId!),
        _supabase.getMonthlyCashFlow(
          userID: _userId!,
          selectedCurrency: selectedCurrency,
        ),
        _supabase.getMonthlyPulseData(
          userID: _userId!,
          selectedCurrency: selectedCurrency,
        ),
        _personalRepo.refreshFromServer(_userId!),
      ]);

      unifiedTransactions.assignAll(results[0] as List<Map<String, dynamic>>);
      monthlyAnalytics.assignAll(results[1] as Map<String, double>);
      goals.assignAll(results[2] as List<FinancialGoalModel>);
      monthlyCashFlow.value = results[3] as double;
      dailySpendData.assignAll(results[4] as List<Map<String, dynamic>>);

      if (Get.isRegistered<PersonalBudgetAlertService>()) {
        await Get.find<PersonalBudgetAlertService>()
            .evaluateAndNotify(_userId!);
      }
    } catch (e, stack) {
      AppErrorReporter.report(
        'HomeController.fetchHomeData failed',
        error: e,
        stack: stack,
        context: {'feature': 'home', 'operation': 'fetchHomeData'},
        showToastOnUserFacing: false,
      );
      fetchError.value = AppStrings.errors.refreshHome;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _currencyWorker?.dispose();
    super.onClose();
  }
}
