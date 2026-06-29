import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:splitter/Model/personal_transaction_model.dart';
import 'package:splitter/Model/product_category_model.dart';
import 'package:splitter/Model/group_model.dart';
import 'package:splitter/Services/currency_service.dart';

class TransactionService {
  final supabase = Supabase.instance.client;

  Future<List<PersonalTransactionModel>> getPersonalTransaction(
      {required String userID, int? limit}) async {
    final data = limit != null
        ? await supabase
            .from("personal_transaction")
            .select()
            .eq("user_id", userID)
            .order("transaction_date", ascending: false)
            .limit(limit)
        : await supabase
            .from("personal_transaction")
            .select()
            .eq("user_id", userID)
            .order("transaction_date", ascending: false);

    List<PersonalTransactionModel> personalTransactionsModel = [];

    for (final singleData in data) {
      PersonalTransactionModel personalTransaction;

      personalTransaction = PersonalTransactionModel.fromJSON(singleData);

      personalTransactionsModel.add(personalTransaction);
    }

    return personalTransactionsModel;
  }

  Future<List<PersonalTransactionWithProductCategoryModel>>
      getHomePhaseExpenseHistory({required String userID}) async {
    final personalTransactionData = await supabase
        .from("personal_transaction")
        .select()
        .eq("user_id", userID)
        .order("transaction_date", ascending: false)
        .limit(10);

    if (personalTransactionData.isEmpty) return [];

    // Parse transactions and collect unique categories in one pass
    List<PersonalTransactionModel> personalTransactionsModel = [];
    final Set<String> productCategories = {};

    for (final singleData in personalTransactionData) {
      personalTransactionsModel
          .add(PersonalTransactionModel.fromJSON(singleData));
      productCategories.add(singleData["category"] ?? '');
    }

    // Single query for category logos
    final productCategoryData = await supabase
        .from("master_product_category")
        .select("category, category_logo")
        .inFilter("category", productCategories.toList());

    // Build lookup map for O(1) access instead of O(n²) nested loop
    final Map<String, CategoryOnlyModel> categoryMap = {};
    for (var element in productCategoryData) {
      categoryMap.putIfAbsent(element["category"] as String,
          () => CategoryOnlyModel.fromJSON(element));
    }

    // Match transactions to categories via map lookup
    List<PersonalTransactionWithProductCategoryModel>
        personalTransactionWithCategoryList = [];

    for (var txn in personalTransactionsModel) {
      final cat = categoryMap[txn.category];
      if (cat != null) {
        personalTransactionWithCategoryList.add(
            PersonalTransactionWithProductCategoryModel.fromModel(txn, cat));
      }
    }

    return personalTransactionWithCategoryList;
  }

  List<ConsolidatedGroupTransactionModel> getConsolidatedGroupTransactionData(
      {required List<GroupTransactionModel> groupTransactionList}) {
    List<ConsolidatedGroupTransactionModel> cnsGrpTrnsData = [];
    List<String> transactionGroupIDs = [];
    List<String> categories = [];

    for (var element in groupTransactionList) {
      if (!transactionGroupIDs.contains(element.transactionGroupID!)) {
        transactionGroupIDs.add(element.transactionGroupID!);
      }
    }

    for (var element in groupTransactionList) {
      if (!categories.contains(element.category!)) {
        categories.add(element.category!);
      }
    }

    for (var element in transactionGroupIDs) {
      List<GroupTransactionModel> grpTrnsList = [];

      for (var grpTrnselem in groupTransactionList) {
        if (element == grpTrnselem.transactionGroupID) {
          grpTrnsList.add(grpTrnselem);
        }
      }

      cnsGrpTrnsData.add(ConsolidatedGroupTransactionModel.fromTransactionModel(
        grpTrnsList,
      ));
    }

    return cnsGrpTrnsData;
  }

  Future<List<GroupTransactionModel>> getGroupTransactionsData(
      {required String userID, required String groupID}) async {
    final grpTrnsData = await supabase
        .from("group_transaction")
        .select()
        .eq("group_id", groupID)
        .order("transaction_date", ascending: false);

    if (grpTrnsData.isEmpty) return [];

    // Collect unique categories and user IDs in one pass
    final Set<String> categories = {};
    final Set<String> userIDs = {};
    for (var element in grpTrnsData) {
      categories.add(element["category"] ?? '');
      userIDs.add(element["paid_by"]);
      userIDs.add(element["shared_with"]);
    }

    // Run both lookups in parallel instead of sequentially
    final results = await Future.wait([
      supabase
          .from("master_product_category")
          .select("category, category_logo")
          .inFilter('category', categories.toList()),
      supabase
          .from("users")
          .select("user_id, firstname, lastname")
          .inFilter("user_id", userIDs.toList()),
    ]);

    final masterProdCategory = results[0] as List<dynamic>;
    final usersData = results[1] as List<dynamic>;

    // Build lookup maps
    final Map<String, String> categoryLogoMap = {};
    for (var element in masterProdCategory) {
      categoryLogoMap.putIfAbsent(element["category"] as String,
          () => element["category_logo"] as String);
    }

    final Map<String, String> userNameMap = {};
    for (var user in usersData) {
      userNameMap[user["user_id"]] = "${user["firstname"]} ${user["lastname"]}";
    }

    // Build models using lookup maps (no nested loops)
    List<GroupTransactionModel> groupTransactions = [];
    for (var element in grpTrnsData) {
      final String paidByName = userNameMap[element["paid_by"]] ?? "Unknown";
      final String sharedWithName =
          userNameMap[element["shared_with"]] ?? "Unknown";
      final String catLogo = categoryLogoMap[element["category"]] ?? '';

      groupTransactions.add(
        GroupTransactionModel.fromJSON(
          element,
          paidByName,
          sharedWithName,
          catLogo,
        ),
      );
    }

    return groupTransactions;
  }

  Future<List<CategoryOnlyModel>> getProductCategories(
      {String? groupID}) async {
    // 1. Fetch Global Categories
    final globalDataFuture = supabase
        .from("master_product_category")
        .select("category, category_logo");

    // 2. Fetch Group Custom Categories (if groupID is provided)
    Future<List<Map<String, dynamic>>>? customDataFuture;
    if (groupID != null) {
      customDataFuture = supabase
          .from("group_custom_category")
          .select("category, icon_url")
          .eq("group_id", groupID);
    }

    // 3. Wait for both
    final results = await Future.wait([
      globalDataFuture,
      if (customDataFuture != null) customDataFuture else Future.value([]),
    ]);

    final globalData = results[0];
    final customData = results[1];

    List<CategoryOnlyModel> categories = [];

    // Add Global
    for (final element in globalData) {
      categories.add(CategoryOnlyModel.fromJSON(element));
    }

    // Add Custom
    for (final element in customData) {
      categories.add(CategoryOnlyModel(
        category: element["category"],
        categoryLogo: element["icon_url"], // Map icon_url to categoryLogo
      ));
    }

    return categories;
  }

  Future<void> deleteGroupTransaction(
      {required String transactionGroupID}) async {
    try {
      // 1. Fetch the transactions to be deleted
      final transactions = await supabase
          .from("group_transaction")
          .select()
          .eq("transaction_group_id", transactionGroupID);

      if (transactions.isEmpty) return;

      final String groupID = transactions[0]["group_id"];

      // 2. Fetch current group balances
      final groupData = await supabase
          .from("groups")
          .select("group_balance")
          .eq("group_id", groupID)
          .single();

      List<Map<String, dynamic>> currentBalances = [];
      if (groupData["group_balance"] != null) {
        currentBalances =
            List<Map<String, dynamic>>.from(groupData["group_balance"]);
      }

      // Helper to update/add balance (Local copy of logic)
      void updateBalance(
          String donorId, String receiverId, double amountToAdd) {
        // Check for existing (Donor -> Receiver)
        int index = currentBalances.indexWhere((element) =>
            element["donor_id"] == donorId &&
            element["receiver_id"] == receiverId);

        if (index != -1) {
          double newAmount =
              double.parse(currentBalances[index]["amount"].toString()) +
                  amountToAdd;
          currentBalances[index]["amount"] =
              double.parse(newAmount.toStringAsFixed(2));
        } else {
          // Check for reverse (Receiver -> Donor) and net out
          int reverseIndex = currentBalances.indexWhere((element) =>
              element["donor_id"] == receiverId &&
              element["receiver_id"] == donorId);

          if (reverseIndex != -1) {
            double reverseAmount = double.parse(
                currentBalances[reverseIndex]["amount"].toString());

            if (amountToAdd > reverseAmount) {
              // Flip the debt
              double diff = amountToAdd - reverseAmount;
              currentBalances.removeAt(reverseIndex);
              currentBalances.add({
                "donor": "ID:$donorId",
                "donor_id": donorId,
                "receiver": "ID:$receiverId",
                "receiver_id": receiverId,
                "amount": double.parse(diff.toStringAsFixed(2)),
              });
            } else if (amountToAdd < reverseAmount) {
              // Reduce reverse debt
              double remaining = reverseAmount - amountToAdd;
              currentBalances[reverseIndex]["amount"] =
                  double.parse(remaining.toStringAsFixed(2));
            } else {
              // Exact match, remove entry
              currentBalances.removeAt(reverseIndex);
            }
          } else {
            // New Entry
            if (donorId != receiverId) {
              currentBalances.add({
                "donor": "ID:$donorId",
                "donor_id": donorId,
                "receiver": "ID:$receiverId",
                "receiver_id": receiverId,
                "amount": double.parse(amountToAdd.toStringAsFixed(2)),
              });
            }
          }
        }
      }

      // 3. Revert impact of each transaction
      // Logic: If Payer paid for Consumer, debt was Payer->Consumer.
      // To revert, we apply Consumer->Payer (Consumer pays back Payer).
      for (var txn in transactions) {
        String paidBy = txn["paid_by"];
        String sharedWith = txn["shared_with"];
        double amount =
            double.parse(txn["shared_transaction_amount"].toString());

        // Skip self-transactions or zero amounts
        if (paidBy != sharedWith && amount > 0) {
          // Revert: SharedWith "pays back" PaidBy
          updateBalance(sharedWith, paidBy, amount);
        }
      }

      // 4. Update group balance in DB
      await supabase.from("groups").update({
        "group_balance": currentBalances,
        "updated_on": DateTime.now().toIso8601String(),
      }).eq("group_id", groupID);

      // 5. Delete transactions
      await supabase
          .from("group_transaction")
          .delete()
          .eq("transaction_group_id", transactionGroupID);
    } catch (e) {
      debugPrint("DELETE TRANSACTION EXCEPTION: $e");
      rethrow;
    }
  }

  Future<void> addCustomCategory({
    required String groupID,
    required String categoryName,
    required String iconSvgContent,
    required String userID,
  }) async {
    await supabase.from("group_custom_category").insert({
      "group_id": groupID,
      "category": categoryName,
      "icon_url": iconSvgContent,
      "created_by": userID,
    });
  }

  Future<List<Map<String, dynamic>>> getUnifiedTransactions({
    required String userID,
    int? limit = 10,
    String selectedCurrency = 'INR',
  }) async {
    // 1. Fetch Personal Transactions
    var personalQuery = supabase
        .from("personal_transaction")
        .select(
            "amount, currency, exchange_rate_to_inr, category, transaction_description, transaction_date")
        .eq("user_id", userID)
        .order("transaction_date", ascending: false);

    if (limit != null) {
      personalQuery = personalQuery.limit(limit);
    }

    final personalTxns = await personalQuery;

    // 2. Fetch Group Transactions where user is involved
    var groupQuery = supabase
        .from("group_transaction")
        .select(
            "shared_transaction_amount, currency, exchange_rate_to_inr, paid_by, shared_with, transaction_group_id, transaction_date, description, category, group_id, *, groups(group_name)")
        .or("paid_by.eq.$userID,shared_with.eq.$userID")
        .order("transaction_date", ascending: false);

    if (limit != null) {
      groupQuery = groupQuery.limit(limit * 3);
    }

    final groupTxns = await groupQuery;

    // Fetch live rate for INR -> selectedCurrency conversion
    final Map<String, double> liveRates =
        await CurrencyService().getRates(base: 'INR');
    final double inrToSelected =
        selectedCurrency == 'INR' ? 1.0 : (liveRates[selectedCurrency] ?? 1.0);

    List<Map<String, dynamic>> unifiedList = [];

    // Process Personal
    for (var txn in personalTxns) {
      final String category = txn["category"] ?? "General";
      final bool isIncome = _isIncomeCategory(category);
      final double storedRate =
          double.tryParse(txn["exchange_rate_to_inr"]?.toString() ?? "1.0") ??
              1.0;
      final double rawAmount = double.parse(txn["amount"].toString());
      final double amountInInr = rawAmount * storedRate;
      final double displayAmount = amountInInr * inrToSelected;
      unifiedList.add({
        "type": "personal",
        "title": txn["transaction_description"] ?? "Expense",
        "subtitle": category,
        "amount": displayAmount,
        "date": DateTime.parse(txn["transaction_date"]),
        "is_credit": isIncome,
        "category": category,
      });
    }

    // Process Group Transactions - CONSOLIDATE BY transaction_group_id
    Map<String, Map<String, dynamic>> groupedMap = {};

    for (var txn in groupTxns) {
      String groupID = txn["transaction_group_id"] ?? "unknown_${txn['id']}";
      String paidBy = txn["paid_by"];
      final double storedRate =
          double.tryParse(txn["exchange_rate_to_inr"]?.toString() ?? "1.0") ??
              1.0;
      final double rawAmount =
          double.parse(txn["shared_transaction_amount"].toString());
      final double amountInInr = rawAmount * storedRate;
      final double amount = amountInInr * inrToSelected;
      bool isPayer = paidBy == userID;
      String rawTitle = txn["description"] ?? "Group Expense";
      // Start with raw title
      String title = rawTitle;

      title = title
          .replaceAll(RegExp(r'\s*Notes:.*', caseSensitive: false), '')
          .trim();

      if (!groupedMap.containsKey(groupID)) {
        groupedMap[groupID] = {
          "type": "group",
          "title": title,
          "subtitle": isPayer ? "You paid" : "You owe", // Initial guess
          "amount": 0.0,
          "date": DateTime.parse(txn["transaction_date"]),
          "is_credit": isPayer,
          "is_payer": isPayer,
          "is_settlement": (txn['category'] == 'Settlement'),
          "category": txn['category'] ?? 'General',
          "group_id": txn["group_id"],
          "context": txn["groups"] != null ? txn["groups"]["group_name"] : null,
        };
      }

      var entry = groupedMap[groupID]!;
      bool isSettlement = (txn['category'] == 'Settlement');

      if (isPayer) {
        if (entry["is_payer"] == true || entry["amount"] == 0.0) {
          entry["amount"] = (entry["amount"] as double) + amount;
          entry["is_credit"] = false; // Paying is always debit
        }
      } else {
        if (entry["is_payer"] == false || entry["amount"] == 0.0) {
          entry["amount"] = (entry["amount"] as double) + amount;

          if (isSettlement) {
            entry["is_credit"] = true; // Received settlement is credit
          } else {
            entry["is_credit"] = false; // Owing for expense is debit
          }
        }
      }
    }

    unifiedList.addAll(groupedMap.values);
    // Sort by Date Descending
    unifiedList.sort(
        (a, b) => (b["date"] as DateTime).compareTo(a["date"] as DateTime));

    // Limit again after merge
    if (limit != null && unifiedList.length > limit) {
      unifiedList = unifiedList.sublist(0, limit);
    }

    return unifiedList;
  }

  bool _isIncomeCategory(String category) {
    const incomeCategories = [
      'income',
      'salary',
      'refund',
      'cashback',
      'reimbursement',
    ];
    return incomeCategories.contains(category.toLowerCase());
  }

  Future<Map<String, double>> getMonthlySpendAnalytics(
      {required String userID,
      String selectedCurrency = 'INR',
      DateTime? month}) async {
    final targetMonth = month ?? DateTime.now();
    final startOfMonth =
        DateTime(targetMonth.year, targetMonth.month, 1).toIso8601String();
    final endOfMonth = DateTime(targetMonth.year, targetMonth.month + 1, 1)
        .subtract(const Duration(seconds: 1))
        .toIso8601String();

    Map<String, double> categoryTotals = {};
    double totalSpendInr = 0;

    // Fetch live rate for INR -> selectedCurrency
    final Map<String, double> liveRates =
        await CurrencyService().getRates(base: 'INR');
    final double inrToSelected =
        selectedCurrency == 'INR' ? 1.0 : (liveRates[selectedCurrency] ?? 1.0);

    // 1. Fetch personal transactions for this month
    final personalTxns = await supabase
        .from("personal_transaction")
        .select("amount, category, exchange_rate_to_inr")
        .eq("user_id", userID)
        .gte("transaction_date", startOfMonth)
        .lte("transaction_date", endOfMonth);

    for (var txn in personalTxns) {
      final double storedRate =
          double.tryParse(txn["exchange_rate_to_inr"]?.toString() ?? "1.0") ??
              1.0;
      final double rawAmount = double.parse(txn["amount"].toString());
      final double amountInInr = rawAmount * storedRate;
      String category = txn["category"] ?? "Others";

      categoryTotals[category] = (categoryTotals[category] ?? 0) + amountInInr;
      totalSpendInr += amountInInr;
    }

    // 2. Fetch Group Expenses (Where I am SHARED WITH) for this month
    // EXCLUDE SETTLEMENTS (Receiving money isn't a spend)
    final groupTxns = await supabase
        .from("group_transaction")
        .select("shared_transaction_amount, category, exchange_rate_to_inr")
        .eq("shared_with", userID) // Only what I consumed
        .gte("transaction_date", startOfMonth)
        .lte("transaction_date", endOfMonth)
        .neq("category", "Settlement");

    for (var txn in groupTxns) {
      final double storedRate =
          double.tryParse(txn["exchange_rate_to_inr"]?.toString() ?? "1.0") ??
              1.0;
      final double rawAmount =
          double.parse(txn["shared_transaction_amount"].toString());
      final double amountInInr = rawAmount * storedRate;
      String category = txn["category"] ?? "Others";

      categoryTotals[category] = (categoryTotals[category] ?? 0) + amountInInr;
      totalSpendInr += amountInInr;
    }

    // Convert all INR totals to selected currency
    final Map<String, double> result = {};
    result["total"] = totalSpendInr * inrToSelected;
    for (var entry in categoryTotals.entries) {
      result[entry.key] = entry.value * inrToSelected;
    }
    return result;
  }

  Future<double> getMonthlyCashFlow(
      {required String userID,
      String selectedCurrency = 'INR',
      DateTime? month}) async {
    final targetMonth = month ?? DateTime.now();
    final startOfMonth =
        DateTime(targetMonth.year, targetMonth.month, 1).toIso8601String();
    final endOfMonth = DateTime(targetMonth.year, targetMonth.month + 1, 1)
        .subtract(const Duration(seconds: 1))
        .toIso8601String();

    double totalOutflowInr = 0;

    // Fetch live rate for INR -> selectedCurrency
    final Map<String, double> liveRates =
        await CurrencyService().getRates(base: 'INR');
    final double inrToSelected =
        selectedCurrency == 'INR' ? 1.0 : (liveRates[selectedCurrency] ?? 1.0);

    // 1. Personal
    final personalTxns = await supabase
        .from("personal_transaction")
        .select("amount, exchange_rate_to_inr")
        .eq("user_id", userID)
        .gte("transaction_date", startOfMonth)
        .lte("transaction_date", endOfMonth);

    for (var txn in personalTxns) {
      final double storedRate =
          double.tryParse(txn["exchange_rate_to_inr"]?.toString() ?? "1.0") ??
              1.0;
      totalOutflowInr += double.parse(txn["amount"].toString()) * storedRate;
    }

    // 2. Group (Paid By Me)
    final groupTxns = await supabase
        .from("group_transaction")
        .select("shared_transaction_amount, exchange_rate_to_inr")
        .eq("paid_by", userID)
        .gte("transaction_date", startOfMonth)
        .lte("transaction_date", endOfMonth);

    for (var txn in groupTxns) {
      final double storedRate =
          double.tryParse(txn["exchange_rate_to_inr"]?.toString() ?? "1.0") ??
              1.0;
      totalOutflowInr +=
          double.parse(txn["shared_transaction_amount"].toString()) *
              storedRate;
    }

    return totalOutflowInr * inrToSelected;
  }

  Future<List<Map<String, dynamic>>> getMonthlyPulseData(
      {required String userID, String selectedCurrency = 'INR'}) async {
    final now = DateTime.now();
    final DateTime endDate = DateTime(now.year, now.month, now.day);
    final DateTime startDate = endDate.subtract(const Duration(days: 6));

    String dateKey(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    final Map<String, Map<String, double>> dailyCategorySpendInr = {};
    for (int i = 0; i < 7; i++) {
      dailyCategorySpendInr[dateKey(startDate.add(Duration(days: i)))] = {};
    }

    void addCategorySpend(DateTime date, String? category, double amountInInr) {
      final localDate = DateTime(date.year, date.month, date.day);
      if (localDate.isBefore(startDate) || localDate.isAfter(endDate)) return;

      final key = (category == null || category.trim().isEmpty)
          ? 'Others'
          : category.trim();
      final dayMap = dailyCategorySpendInr[dateKey(localDate)]!;
      dayMap[key] = (dayMap[key] ?? 0) + amountInInr;
    }

    // Fetch live rate for INR -> selectedCurrency
    final Map<String, double> liveRates =
        await CurrencyService().getRates(base: 'INR');
    final double inrToSelected =
        selectedCurrency == 'INR' ? 1.0 : (liveRates[selectedCurrency] ?? 1.0);

    final rangeStart = startDate.toIso8601String();

    // 1. Personal
    final personalTxns = await supabase
        .from("personal_transaction")
        .select("amount, transaction_date, exchange_rate_to_inr, category")
        .eq("user_id", userID)
        .gte("transaction_date", rangeStart);

    for (var txn in personalTxns) {
      final date = DateTime.parse(txn["transaction_date"]);
      final double storedRate =
          double.tryParse(txn["exchange_rate_to_inr"]?.toString() ?? "1.0") ??
              1.0;
      final double amountInInr =
          double.parse(txn["amount"].toString()) * storedRate;
      addCategorySpend(date, txn["category"] as String?, amountInInr);
    }

    // 2. Group (My Share)
    final groupTxns = await supabase
        .from("group_transaction")
        .select(
            "shared_transaction_amount, transaction_date, exchange_rate_to_inr, category")
        .eq("shared_with", userID)
        .gte("transaction_date", rangeStart)
        .neq("category", "Settlement");

    for (var txn in groupTxns) {
      final date = DateTime.parse(txn["transaction_date"]);
      final double storedRate =
          double.tryParse(txn["exchange_rate_to_inr"]?.toString() ?? "1.0") ??
              1.0;
      final double amountInInr =
          double.parse(txn["shared_transaction_amount"].toString()) *
              storedRate;
      addCategorySpend(date, txn["category"] as String?, amountInInr);
    }

    // 3. Last 7 days with per-category breakdown (selected currency)
    final List<Map<String, dynamic>> pulseData = [];

    for (int i = 0; i < 7; i++) {
      final date = startDate.add(Duration(days: i));
      final categoriesInr = dailyCategorySpendInr[dateKey(date)] ?? {};
      final Map<String, double> categories = {};
      double total = 0;

      for (final entry in categoriesInr.entries) {
        final amount = entry.value * inrToSelected;
        categories[entry.key] = amount;
        total += amount;
      }

      pulseData.add({
        "date": date.toIso8601String(),
        "day": date.day,
        "month": date.month,
        "year": date.year,
        "total": total,
        "categories": categories,
      });
    }

    return pulseData;
  }

  Future<void> addPersonalTransaction({
    required String userID,
    required double amount,
    required String description,
    required String category,
    required DateTime date,
    required String paymentMethod,
    required String currency,
  }) async {
    final double exchangeRate =
        await CurrencyService().getExchangeRateToInr(currency);
    await supabase.from("personal_transaction").insert({
      "user_id": userID,
      "amount": amount,
      "transaction_description": description,
      "category": category,
      "transaction_date": date.toIso8601String(),
      "payment_method": paymentMethod,
      "currency": currency,
      "exchange_rate_to_inr": exchangeRate,
    });
  }

  Future<List<CategoryOnlyModel>> getPersonalCategories(
      {required String userID}) async {
    // 1. Fetch Global Categories
    final globalDataFuture = supabase
        .from("master_product_category")
        .select("category, category_logo");

    // 2. Fetch Personal Custom Categories
    final customDataFuture = supabase
        .from("personal_custom_category")
        .select("category, icon_url")
        .eq("user_id", userID);

    // 3. Wait for both
    final results = await Future.wait([
      globalDataFuture,
      customDataFuture,
    ]);

    final globalData = results[0];
    final customData = results[1];

    List<CategoryOnlyModel> categories = [];

    // Add Global
    for (final element in globalData) {
      categories.add(CategoryOnlyModel.fromJSON(element));
    }

    // Add Custom
    for (final element in customData) {
      categories.add(CategoryOnlyModel(
        category: element["category"],
        categoryLogo: element["icon_url"],
      ));
    }

    return categories;
  }

  Future<void> addPersonalCustomCategory({
    required String categoryName,
    required String iconSvgContent,
    required String userID,
  }) async {
    await supabase.from("personal_custom_category").insert({
      "user_id": userID,
      "category": categoryName,
      "icon_url": iconSvgContent,
    });
  }

  /// Lifetime stats fetched directly from Supabase.
  /// totalSpent  = personal txns + group txns (my share, excl. settlements)
  /// totalReceived = settlement txns received by me
  Future<Map<String, double>> getLifetimeStats({required String userID}) async {
    // Run all three queries in parallel
    final results = await Future.wait([
      // 1. Personal transactions (all amounts)
      supabase
          .from("personal_transaction")
          .select("amount")
          .eq("user_id", userID),

      // 2. Group txns where I paid — my own selfShareAmount isn't stored
      //    directly, so we treat the paidBy rows differently:
      //    "shared_with == userID" (own row) captures the payer's own share.
      //    We include ALL shared_with rows for the user excluding settlements.
      supabase
          .from("group_transaction")
          .select("shared_transaction_amount")
          .eq("shared_with", userID)
          .neq("category", "Settlement"),

      // 3. Settlements received (money came IN to me)
      supabase
          .from("group_transaction")
          .select("shared_transaction_amount")
          .eq("shared_with", userID)
          .eq("category", "Settlement"),
    ]);

    final personalRows = results[0] as List<dynamic>;
    final spentRows = results[1] as List<dynamic>;
    final receivedRows = results[2] as List<dynamic>;

    double totalSpent = 0;
    for (var r in personalRows) {
      totalSpent += double.parse(r["amount"].toString());
    }
    for (var r in spentRows) {
      totalSpent += double.parse(r["shared_transaction_amount"].toString());
    }

    double totalReceived = 0;
    for (var r in receivedRows) {
      totalReceived += double.parse(r["shared_transaction_amount"].toString());
    }

    return {
      'totalSpent': totalSpent,
      'totalReceived': totalReceived,
    };
  }
}
