import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:splitter/Model/group_model.dart';
import 'package:splitter/Repository/transaction_repository.dart';
import 'package:splitter/Services/realtime_service.dart';
import 'package:splitter/Services/supabase_service.dart';
import 'package:splitter/Services/sync_service.dart';

/// Drives the group transactions tab from local Drift cache + remote refresh.
class TransactionTabController extends GetxController {
  final String groupId;
  final String userId;

  TransactionTabController({required this.groupId, required this.userId});

  final TransactionRepository _repository = Get.find();
  final SyncService _syncService = Get.find();
  final RealtimeService _realtimeService = Get.find();

  final consolidatedTransactions =
      <ConsolidatedGroupTransactionModel>[].obs;
  final isLoading = true.obs;
  final errorMessage = RxnString();
  final syncStatus = SyncStatus.synced.obs;

  StreamSubscription? _transactionSub;
  StreamSubscription? _realtimeSub;
  StreamSubscription? _syncSub;

  @override
  void onInit() {
    super.onInit();
    _transactionSub =
        _repository.watchTransactions(groupId).listen(_onLocalTransactions);
    _realtimeSub = _realtimeService.onTransactionChange.listen((event) {
      if (event.groupId == groupId) {
        refresh();
      }
    });
    _syncSub = _syncService.syncStatus.listen((status) {
      syncStatus.value = status;
    });
    refresh();
  }

  @override
  Future<void> refresh() async {
    try {
      await _repository.refreshFromServer(groupId);
    } catch (e) {
      debugPrint('Transaction refresh error: $e');
      // Keep showing cached Drift data when offline.
    }
    await _loadConsolidatedFromLocal();
  }

  void _onLocalTransactions(_) {
    _loadConsolidatedFromLocal();
  }

  Future<void> _loadConsolidatedFromLocal() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      final local = await _repository.getTransactions(groupId);
      if (local.isEmpty) {
        consolidatedTransactions.clear();
        isLoading.value = false;
        return;
      }
      final models = await _repository.toGroupTransactionModels(local);
      final consolidated = SupabaseDatabase()
          .getConsolidatedGroupTransactionData(groupTransactionList: models);
      consolidatedTransactions.assignAll(consolidated);
    } catch (e) {
      debugPrint('TransactionTabController load error: $e');
      errorMessage.value = 'Failed to load transactions.';
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _transactionSub?.cancel();
    _realtimeSub?.cancel();
    _syncSub?.cancel();
    super.onClose();
  }
}
