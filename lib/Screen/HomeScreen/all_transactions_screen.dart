import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Controllers/currency_controller.dart';
import 'package:splitter/Services/supabase_service.dart';
import 'package:splitter/Widgets/transaction_tile.dart';
import 'package:splitter/Model/group_model.dart';

class AllTransactionsScreen extends StatefulWidget {
  final bool? isGroupFilter;
  final bool? isTripFilter;
  final List<dynamic>? groups;
  final Set<String>? tripGroupIds;

  const AllTransactionsScreen({
    super.key,
    this.isGroupFilter,
    this.isTripFilter,
    this.groups,
    this.tripGroupIds,
  });

  @override
  State<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen> {
  final SupabaseDatabase _supabase = SupabaseDatabase();
  final String _userID = SupabaseAuth().supabaseGetUserID();

  List<Map<String, dynamic>> _allTransactions = [];
  bool _isLoading = true;

  Worker? _currencyWorker;

  @override
  void initState() {
    super.initState();
    _fetchAllTransactions();
    final cc = Get.find<CurrencyController>();
    _currencyWorker = ever(cc.rxCode, (_) => _fetchAllTransactions());
  }

  @override
  void dispose() {
    _currencyWorker?.dispose();
    super.dispose();
  }

  Future<void> _fetchAllTransactions() async {
    setState(() => _isLoading = true);
    try {
      final String selectedCurrency = Get.find<CurrencyController>().code;
      final txns = await _supabase.getUnifiedTransactions(
        userID: _userID,
        limit: null, // Fetch all
        selectedCurrency: selectedCurrency,
      );

      List<Map<String, dynamic>> filteredTxns = txns;

      // Filter Logic
      if (widget.isGroupFilter == true) {
        // Filter for Group Tab (Non-Trip Groups)
        if (widget.groups != null) {
          final nonTripGroupIds = (widget.groups as List)
              .whereType<GroupModel>()
              .map((g) => g.groupID)
              .whereType<String>()
              .toSet();

          filteredTxns = txns.where((t) {
            return t['type'] == 'group' &&
                nonTripGroupIds.contains(t['group_id']);
          }).toList();
        }
      } else if (widget.isTripFilter == true) {
        // Filter for Trip Tab (Trip Groups)
        if (widget.tripGroupIds != null) {
          filteredTxns = txns.where((t) {
            return t['type'] == 'group' &&
                widget.tripGroupIds!.contains(t['group_id']);
          }).toList();
        }
      }

      setState(() {
        _allTransactions = filteredTxns;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("FETCH ALL TRANSACTIONS ERROR: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = "All Transactions";
    if (widget.isGroupFilter == true) title = "Group Transactions";
    if (widget.isTripFilter == true) title = "Trip Transactions";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const BackButton(color: neopopBackground),
        title: Text(
          title,
          style: headline3_text.copyWith(
            fontFamily: 'Albra',
            color: neopopBackground,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: neopopBackground,
                size: 40,
              ),
            )
          : _allTransactions.isEmpty
              ? Center(
                  child: Text(
                    "No transactions found.",
                    style: body1_text.copyWith(color: neopopGrey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _allTransactions.length,
                  itemBuilder: (context, index) {
                    return TransactionTile(txn: _allTransactions[index]);
                  },
                ),
    );
  }
}
