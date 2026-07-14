import 'package:splitr/Constants/app_keys.dart';

/// Pure split math for group expenses (even, uneven, %, shares, by-item).
class ExpenseSplitCalculator {
  ExpenseSplitCalculator._();

  static Map<String, double> evenSplit({
    required double totalAmount,
    required List<String> involvedUserIds,
  }) {
    if (involvedUserIds.isEmpty) return {};
    final splitAmount = totalAmount / involvedUserIds.length;
    return {for (final id in involvedUserIds) id: splitAmount};
  }

  static Map<String, double> unevenSplit(
    List<Map<String, dynamic>> userAndSplitDetails,
  ) {
    final splits = <String, double>{};
    for (final item in userAndSplitDetails) {
      final userId = item[SplitDetailKeys.userId]?.toString();
      if (userId == null || userId.isEmpty) continue;
      splits[userId] =
          double.tryParse(item[SplitDetailKeys.amount].toString()) ?? 0.0;
    }
    return splits;
  }

  static Map<String, double> percentageSplit({
    required double totalAmount,
    required List<Map<String, dynamic>> percentageSplitDetails,
  }) {
    final splits = <String, double>{};
    for (final item in percentageSplitDetails) {
      final userId = item[SplitDetailKeys.userId]?.toString();
      if (userId == null || userId.isEmpty) continue;
      final percent =
          double.tryParse(item[SplitDetailKeys.percentage].toString()) ?? 0.0;
      splits[userId] = (totalAmount * percent) / 100;
    }
    return splits;
  }

  static Map<String, double> sharesSplit({
    required double totalAmount,
    required int totalShares,
    required List<Map<String, dynamic>> sharesSplitDetails,
  }) {
    if (totalShares <= 0) return {};
    final splits = <String, double>{};
    for (final item in sharesSplitDetails) {
      final userId = item[SplitDetailKeys.userId]?.toString();
      if (userId == null || userId.isEmpty) continue;
      final userShares =
          int.tryParse(item[SplitDetailKeys.shares].toString()) ?? 0;
      splits[userId] = (totalAmount * userShares) / totalShares;
    }
    return splits;
  }

  static Map<String, double> byItemSplit(
    List<Map<String, dynamic>> itemSplitDetails,
  ) {
    final splits = <String, double>{};
    for (final item in itemSplitDetails) {
      final price =
          double.tryParse(item[SplitDetailKeys.price].toString()) ?? 0.0;
      final assignees =
          List<String>.from(item[SplitDetailKeys.assignees] ?? []);
      if (assignees.isEmpty) continue;
      final perPerson = price / assignees.length;
      for (final uid in assignees) {
        splits[uid] = (splits[uid] ?? 0.0) + perPerson;
      }
    }
    return splits;
  }

  static Map<String, double> forTab({
    required int tabIndex,
    required double totalAmount,
    List<String> involvedUserIds = const [],
    List<Map<String, dynamic>> userAndSplitDetails = const [],
    List<Map<String, dynamic>> percentageSplitDetails = const [],
    int totalShares = 0,
    List<Map<String, dynamic>> sharesSplitDetails = const [],
    List<Map<String, dynamic>> itemSplitDetails = const [],
  }) {
    switch (tabIndex) {
      case 0:
        return evenSplit(
          totalAmount: totalAmount,
          involvedUserIds: involvedUserIds,
        );
      case 1:
        return unevenSplit(userAndSplitDetails);
      case 2:
        return percentageSplit(
          totalAmount: totalAmount,
          percentageSplitDetails: percentageSplitDetails,
        );
      case 3:
        return sharesSplit(
          totalAmount: totalAmount,
          totalShares: totalShares,
          sharesSplitDetails: sharesSplitDetails,
        );
      case 4:
        return byItemSplit(itemSplitDetails);
      default:
        return {};
    }
  }
}
