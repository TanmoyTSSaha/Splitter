/// Prefill data when opening Add Transaction from a wishlist item.
class WishlistPrefill {
  final String wishlistItemId;
  final String description;
  final double? estimatedAmount;

  const WishlistPrefill({
    required this.wishlistItemId,
    required this.description,
    this.estimatedAmount,
  });
}
