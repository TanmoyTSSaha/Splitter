/// Data models for Shared Wishlists / Planned Expenses.

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
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      title: json['title'] as String,
      estimatedAmount: json['estimated_amount'] != null
          ? (json['estimated_amount'] as num).toDouble()
          : null,
      addedByUserId: json['added_by'] as String,
      addedByName: addedByName ?? 'Unknown',
      createdAt: DateTime.parse(json['created_at'] as String),
      upvoteCount: upvotes,
      isAddedToExpenses: json['is_added_to_expenses'] as bool? ?? false,
      currentUserUpvoted: currentUserUpvoted,
    );
  }

  Map<String, dynamic> toJSON() => {
        'group_id': groupId,
        'title': title,
        'estimated_amount': estimatedAmount,
        'added_by': addedByUserId,
        'is_added_to_expenses': isAddedToExpenses,
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
