import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:splitr/Constants/app_motion.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Controllers/currency_controller.dart';
import 'package:splitr/Model/group_model.dart';
import 'package:splitr/Repository/group_repository.dart';
import 'package:splitr/Services/transaction_list_helper.dart';
import 'package:splitr/Services/supabase_service.dart';
import 'package:splitr/Utils/transaction_date_formatter.dart';
import 'package:splitr/Utils/transaction_section_grouper.dart';
import 'package:splitr/Utils/app_error_reporter.dart';

class AllTransactionsController extends GetxController {
  AllTransactionsController({
    this.isGroupFilter,
    this.isTripFilter,
    this.groups,
    this.tripGroupIds,
    @visibleForTesting bool forTest = false,
  })  : _forTest = forTest,
        userID = forTest ? TestIds.user : SupabaseAuth().supabaseGetUserID();

  final bool _forTest;
  final bool? isGroupFilter;
  final bool? isTripFilter;
  final List<dynamic>? groups;
  final Set<String>? tripGroupIds;

  SupabaseDatabase? _supabase;
  final String userID;

  final rawTransactions = <Map<String, dynamic>>[].obs;
  final sections = <TransactionSection>[].obs;
  final availableCategories = <String>[].obs;
  final availableGroups = <GroupModel>[].obs;

  final isLoading = true.obs;
  final isLoadingOlder = false.obs;
  final fetchError = RxnString();
  final canLoadOlder = true.obs;
  final sortOption = TransactionSortOption.newestFirst.obs;

  final selectedCategories = <String>{}.obs;
  final selectedGroupIds = <String>{}.obs;
  final selectedPaymentMethods = <String>{}.obs;
  final minAmount = RxnDouble();
  final maxAmount = RxnDouble();
  final customSince = Rxn<DateTime>();
  final customUntil = Rxn<DateTime>();

  DateTime _loadedSince =
      DateTime.now().subtract(AppMotion.allTransactionsLoadedSince);

  Worker? _currencyWorker;

  int get activeFilterCount {
    var count = 0;
    if (selectedCategories.isNotEmpty) count++;
    if (selectedGroupIds.isNotEmpty) count++;
    if (selectedPaymentMethods.isNotEmpty) count++;
    if (minAmount.value != null || maxAmount.value != null) count++;
    if (customSince.value != null || customUntil.value != null) count++;
    return count;
  }

  @override
  void onInit() {
    super.onInit();
    if (_forTest) {
      isLoading.value = false;
      return;
    }
    _supabase = SupabaseDatabase();
    _loadGroups();
    fetchTransactions();
    final cc = Get.find<CurrencyController>();
    _currencyWorker = ever(cc.rxCode, (_) => fetchTransactions(reset: true));
  }

  @override
  void onClose() {
    _currencyWorker?.dispose();
    super.onClose();
  }

  Future<void> _loadGroups() async {
    try {
      if (Get.isRegistered<GroupRepository>()) {
        final repo = Get.find<GroupRepository>();
        final locals = await repo.getGroups(userID);
        final tripIds = await repo.fetchTripGroupIds(
          locals.map((g) => g.groupId).toList(),
        );
        availableGroups.assignAll(
          locals
              .map((g) =>
                  repo.toGroupModel(g, isTrip: tripIds.contains(g.groupId)))
              .toList(),
        );
      }
    } catch (e, stack) {
      AppErrorReporter.report(
        'AllTransactionsController._loadGroups failed',
        error: e,
        stack: stack,
        context: {'feature': 'transactions', 'operation': 'loadGroups'},
        showToastOnUserFacing: false,
      );
    }
  }

  Future<void> fetchTransactions(
      {bool reset = true, bool loadOlder = false}) async {
    if (_forTest) {
      isLoading.value = false;
      isLoadingOlder.value = false;
      _rebuildDisplay();
      return;
    }
    if (loadOlder) {
      isLoadingOlder.value = true;
    } else if (reset) {
      isLoading.value = true;
      fetchError.value = null;
      if (!loadOlder) {
        _loadedSince = customSince.value ??
            DateTime.now().subtract(AppMotion.allTransactionsLoadedSince);
        canLoadOlder.value = customSince.value == null;
      }
    }

    try {
      final String selectedCurrency = Get.find<CurrencyController>().code;
      DateTime? since;
      DateTime? until;

      if (loadOlder) {
        final newSince =
            _loadedSince.subtract(AppMotion.allTransactionsLoadedSince);
        since = newSince;
        until = _loadedSince;
      } else {
        since = customSince.value != null
            ? TransactionDateFormatter.startOfDay(customSince.value!)
            : _loadedSince;
        until = customUntil.value != null
            ? TransactionDateFormatter.endOfDay(customUntil.value!)
            : customUntil.value;
      }

      final txns = await _supabase!.getUnifiedTransactions(
        userID: userID,
        limit: null,
        selectedCurrency: selectedCurrency,
        since: since,
        until: until,
      );

      final baseFiltered = _applyBaseFilter(txns);

      if (loadOlder) {
        if (baseFiltered.isEmpty) {
          canLoadOlder.value = false;
        } else {
          rawTransactions.assignAll(
            TransactionListHelper.mergeDeduped(
              rawTransactions.toList(),
              baseFiltered,
            ),
          );
          _loadedSince = since;
        }
      } else {
        rawTransactions.assignAll(baseFiltered);
      }

      _rebuildCategories();
      _rebuildDisplay();
      fetchError.value = null;
    } catch (e, stack) {
      AppErrorReporter.report(
        'AllTransactionsController.fetchTransactions failed',
        error: e,
        stack: stack,
        context: {'feature': 'transactions', 'operation': 'fetchTransactions'},
        showToastOnUserFacing: false,
      );
      fetchError.value = AppStrings.errors.loadTransactionsShort;
    } finally {
      isLoading.value = false;
      isLoadingOlder.value = false;
    }
  }

  List<Map<String, dynamic>> _applyBaseFilter(List<Map<String, dynamic>> txns) {
    if (isGroupFilter == true && groups != null) {
      final nonTripGroupIds = groups!
          .whereType<GroupModel>()
          .map((g) => g.groupID)
          .whereType<String>()
          .toSet();
      return txns
          .where((t) =>
              t[UnifiedTxnKeys.type] == TransactionTypes.group &&
              nonTripGroupIds.contains(t[UnifiedTxnKeys.groupId]))
          .toList();
    }
    if (isTripFilter == true && tripGroupIds != null) {
      return txns
          .where((t) =>
              t[UnifiedTxnKeys.type] == TransactionTypes.group &&
              tripGroupIds!.contains(t[UnifiedTxnKeys.groupId]))
          .toList();
    }
    return txns;
  }

  void _rebuildCategories() {
    final cats = rawTransactions
        .map((t) => t[UnifiedTxnKeys.category] as String?)
        .whereType<String>()
        .toSet()
        .toList()
      ..sort();
    availableCategories.assignAll(cats);
  }

  void _rebuildDisplay() {
    final criteria = TransactionFilterCriteria(
      categories: selectedCategories.toSet(),
      groupIds: selectedGroupIds.toSet(),
      paymentMethods: selectedPaymentMethods.toSet(),
      minAmount: minAmount.value,
      maxAmount: maxAmount.value,
    );

    var display = TransactionListHelper.applyFilters(
      rawTransactions.toList(),
      criteria,
    );
    display = TransactionListHelper.applySort(display, sortOption.value);
    sections.assignAll(
      TransactionListHelper.groupIntoSections(display),
    );
  }

  void setSort(TransactionSortOption option) {
    sortOption.value = option;
    _rebuildDisplay();
  }

  @visibleForTesting
  void seedFilterOptionsForTest({
    List<String> categories = const [],
    List<GroupModel> groups = const [],
  }) {
    availableCategories.assignAll(categories);
    availableGroups.assignAll(groups);
  }

  void applyFilters({
    required Set<String> categories,
    required Set<String> groupIds,
    Set<String> paymentMethods = const {},
    double? min,
    double? max,
    DateTime? since,
    DateTime? until,
    bool clearDateRange = false,
  }) {
    selectedCategories.assignAll(categories);
    selectedGroupIds.assignAll(groupIds);
    selectedPaymentMethods.assignAll(paymentMethods);
    minAmount.value = min;
    maxAmount.value = max;

    if (clearDateRange) {
      customSince.value = null;
      customUntil.value = null;
      canLoadOlder.value = true;
    } else {
      if (since != null) {
        customSince.value = TransactionDateFormatter.startOfDay(since);
      }
      if (until != null) {
        customUntil.value = TransactionDateFormatter.startOfDay(until);
      }
      if (since != null || until != null) {
        canLoadOlder.value = false;
      }
    }

    final dateChanged = since != null || until != null || clearDateRange;
    if (dateChanged) {
      fetchTransactions(reset: true);
    } else {
      _rebuildDisplay();
    }
  }

  void clearAllFilters() {
    selectedCategories.clear();
    selectedGroupIds.clear();
    selectedPaymentMethods.clear();
    minAmount.value = null;
    maxAmount.value = null;
    customSince.value = null;
    customUntil.value = null;
    fetchTransactions(reset: true);
  }

  void applyDatePreset(Duration lookback) {
    final today = TransactionDateFormatter.today;
    customSince.value = today.subtract(lookback);
    customUntil.value = today;
    canLoadOlder.value = false;
    fetchTransactions(reset: true);
  }

  Future<void> loadOlder() => fetchTransactions(reset: false, loadOlder: true);

  /// Flat list index count: one row per section header plus each transaction.
  int get flatItemCount {
    var count = 0;
    for (final section in sections) {
      count += 1 + section.transactions.length;
    }
    return count;
  }

  /// Maps a flat [index] to section header title or transaction map.
  ({bool isHeader, String? header, Map<String, dynamic>? txn}) flatItemAt(
    int index,
  ) {
    if (index < 0 || index >= flatItemCount) {
      throw RangeError.index(index, this, 'index', null, flatItemCount);
    }
    var cursor = 0;
    for (final section in sections) {
      if (cursor == index) {
        return (isHeader: true, header: section.header, txn: null);
      }
      cursor++;
      for (final txn in section.transactions) {
        if (cursor == index) {
          return (isHeader: false, header: null, txn: txn);
        }
        cursor++;
      }
    }
    throw RangeError.index(index, this, 'index', null, flatItemCount);
  }
}
