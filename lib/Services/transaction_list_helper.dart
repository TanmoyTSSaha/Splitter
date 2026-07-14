import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Utils/transaction_section_grouper.dart';

enum TransactionSortOption {
  newestFirst,
  oldestFirst,
  largestFirst,
  smallestFirst,
}

class TransactionFilterCriteria {
  final Set<String> categories;
  final Set<String> groupIds;
  final Set<String> paymentMethods;
  final double? minAmount;
  final double? maxAmount;

  const TransactionFilterCriteria({
    this.categories = const {},
    this.groupIds = const {},
    this.paymentMethods = const {},
    this.minAmount,
    this.maxAmount,
  });

  bool get isEmpty =>
      categories.isEmpty &&
      groupIds.isEmpty &&
      paymentMethods.isEmpty &&
      minAmount == null &&
      maxAmount == null;

  TransactionFilterCriteria copyWith({
    Set<String>? categories,
    Set<String>? groupIds,
    Set<String>? paymentMethods,
    double? minAmount,
    double? maxAmount,
    bool clearMinAmount = false,
    bool clearMaxAmount = false,
  }) {
    return TransactionFilterCriteria(
      categories: categories ?? this.categories,
      groupIds: groupIds ?? this.groupIds,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      minAmount: clearMinAmount ? null : (minAmount ?? this.minAmount),
      maxAmount: clearMaxAmount ? null : (maxAmount ?? this.maxAmount),
    );
  }
}

class TransactionListHelper {
  TransactionListHelper._();

  static List<Map<String, dynamic>> applySort(
    List<Map<String, dynamic>> transactions,
    TransactionSortOption sort,
  ) {
    final sorted = List<Map<String, dynamic>>.from(transactions);
    switch (sort) {
      case TransactionSortOption.newestFirst:
        sorted.sort(
          (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime),
        );
      case TransactionSortOption.oldestFirst:
        sorted.sort(
          (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime),
        );
      case TransactionSortOption.largestFirst:
        sorted.sort(
          (a, b) =>
              (b['amount'] as num).abs().compareTo((a['amount'] as num).abs()),
        );
      case TransactionSortOption.smallestFirst:
        sorted.sort(
          (a, b) =>
              (a['amount'] as num).abs().compareTo((b['amount'] as num).abs()),
        );
    }
    return sorted;
  }

  static List<Map<String, dynamic>> applyFilters(
    List<Map<String, dynamic>> transactions,
    TransactionFilterCriteria criteria,
  ) {
    if (criteria.isEmpty) return transactions;

    return transactions.where((txn) {
      if (criteria.categories.isNotEmpty) {
        final cat = (txn['category'] as String?) ?? '';
        if (!criteria.categories.contains(cat)) return false;
      }

      if (criteria.groupIds.isNotEmpty) {
        if (txn['type'] != TransactionTypes.group) return false;
        final gid = txn['group_id'] as String?;
        if (gid == null || !criteria.groupIds.contains(gid)) return false;
      }

      if (criteria.paymentMethods.isNotEmpty) {
        if (txn['type'] != TransactionTypes.personal) return false;
        final method =
            (txn['payment_method'] as String?)?.trim().isNotEmpty == true
                ? (txn['payment_method'] as String).trim()
                : PaymentMethodDefaults.online;
        if (!criteria.paymentMethods.contains(method)) return false;
      }

      final amount = (txn['amount'] as num).toDouble().abs();
      if (criteria.minAmount != null && amount < criteria.minAmount!) {
        return false;
      }
      if (criteria.maxAmount != null && amount > criteria.maxAmount!) {
        return false;
      }

      return true;
    }).toList();
  }

  static List<TransactionSection> groupIntoSections(
    List<Map<String, dynamic>> transactions, {
    DateTime? reference,
  }) {
    return TransactionSectionGrouper.group(transactions, reference: reference);
  }

  /// Merges [incoming] into [existing], deduplicating by [dedupe_key].
  static List<Map<String, dynamic>> mergeDeduped(
    List<Map<String, dynamic>> existing,
    List<Map<String, dynamic>> incoming,
  ) {
    final keys = existing
        .map((t) => t['dedupe_key'] as String?)
        .whereType<String>()
        .toSet();
    final merged = List<Map<String, dynamic>>.from(existing);
    for (final txn in incoming) {
      final key = txn['dedupe_key'] as String?;
      if (key != null && keys.contains(key)) continue;
      if (key != null) keys.add(key);
      merged.add(txn);
    }
    return merged;
  }

  static String sortLabel(TransactionSortOption sort) {
    switch (sort) {
      case TransactionSortOption.newestFirst:
        return AppStrings.home.sortNewestFirst;
      case TransactionSortOption.oldestFirst:
        return AppStrings.home.sortOldestFirst;
      case TransactionSortOption.largestFirst:
        return AppStrings.home.sortLargestFirst;
      case TransactionSortOption.smallestFirst:
        return AppStrings.home.sortSmallestFirst;
    }
  }
}
