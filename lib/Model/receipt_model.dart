/// Models for the AI Receipt Scanner feature.

class ReceiptData {
  String? merchantName;
  DateTime? date;
  List<ReceiptLineItem> lineItems;
  double? subtotal;
  double? tax;
  double? tip;
  double? total;

  ReceiptData({
    this.merchantName,
    this.date,
    this.lineItems = const [],
    this.subtotal,
    this.tax,
    this.tip,
    this.total,
  });
}

class ReceiptLineItem {
  String name;
  double price;
  int quantity;

  ReceiptLineItem({
    required this.name,
    required this.price,
    this.quantity = 1,
  });

  double get totalPrice => price * quantity;
}

/// Tracks which members are assigned to each line item.
class ReceiptAssignment {
  final ReceiptLineItem item;
  final List<String> assignedMemberIDs;
  final List<String> assignedMemberNames;

  ReceiptAssignment({
    required this.item,
    this.assignedMemberIDs = const [],
    this.assignedMemberNames = const [],
  });

  /// Per-person cost for this item (split evenly among assigned members).
  double get perPersonCost => assignedMemberIDs.isEmpty
      ? 0
      : item.totalPrice / assignedMemberIDs.length;
}
