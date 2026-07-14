/// Data models for Shared Wishlists / Planned Expenses.
library;

import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/domain_values.dart';

class WishlistItem {
  final String id;
  final String groupId;
  final String title;
  final double? estimatedAmount;
  final String addedByUserId;
  final String addedByName;
  final DateTime createdAt;
  final int upvoteCount;
  final bool isAddedToExpenses;
  final bool currentUserUpvoted;

  WishlistItem({
    required this.id,
    required this.groupId,
    required this.title,
    this.estimatedAmount,
    required this.addedByUserId,
    required this.addedByName,
    required this.createdAt,
    this.upvoteCount = 0,
    this.isAddedToExpenses = false,
    this.currentUserUpvoted = false,
  });

  factory WishlistItem.fromJSON(
    Map<String, dynamic> json, {
    int upvotes = 0,
    bool currentUserUpvoted = false,
    String? addedByName,
  }) {
    return WishlistItem(
      id: json[SupabaseColumns.id] as String,
      groupId: json[SupabaseColumns.groupId] as String,
      title: json[SupabaseColumns.title] as String,
      estimatedAmount: json[SupabaseColumns.estimatedAmount] != null
          ? (json[SupabaseColumns.estimatedAmount] as num).toDouble()
          : null,
      addedByUserId: json[SupabaseColumns.addedBy] as String,
      addedByName: addedByName ?? DisplayFallbacks.unknown,
      createdAt: DateTime.parse(json[SupabaseColumns.createdAt] as String),
      upvoteCount: upvotes,
      isAddedToExpenses:
          json[SupabaseColumns.isAddedToExpenses] as bool? ?? false,
      currentUserUpvoted: currentUserUpvoted,
    );
  }

  Map<String, dynamic> toJSON() => {
        SupabaseColumns.groupId: groupId,
        SupabaseColumns.title: title,
        SupabaseColumns.estimatedAmount: estimatedAmount,
        SupabaseColumns.addedBy: addedByUserId,
        SupabaseColumns.isAddedToExpenses: isAddedToExpenses,
      };

  /// Returns a copy with updated fields.
  WishlistItem copyWith({
    int? upvoteCount,
    bool? isAddedToExpenses,
    bool? currentUserUpvoted,
  }) {
    return WishlistItem(
      id: id,
      groupId: groupId,
      title: title,
      estimatedAmount: estimatedAmount,
      addedByUserId: addedByUserId,
      addedByName: addedByName,
      createdAt: createdAt,
      upvoteCount: upvoteCount ?? this.upvoteCount,
      isAddedToExpenses: isAddedToExpenses ?? this.isAddedToExpenses,
      currentUserUpvoted: currentUserUpvoted ?? this.currentUserUpvoted,
    );
  }
}
