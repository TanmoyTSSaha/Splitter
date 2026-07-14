import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Model/group_model.dart';
import 'package:splitr/Repository/transaction_repository.dart';
import 'package:splitr/Services/realtime_service.dart';
import 'package:splitr/Services/supabase_service.dart';
import 'package:splitr/Services/sync_service.dart';
import 'package:splitr/Utils/app_error_reporter.dart';

/// Drives the group transactions tab from local Drift cache + remote refresh.
class TransactionTabController extends GetxController {
  final String groupId;
  final String userId;

  TransactionTabController({required this.groupId, required this.userId});

  final TransactionRepository _repository = Get.find();
  final SyncService _syncService = Get.find();
  final RealtimeService _realtimeService = Get.find();

  final consolidatedTransactions = <ConsolidatedGroupTransactionModel>[].obs;
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
    } catch (e, stack) {
      AppErrorReporter.report(
        'TransactionTabController.refresh failed',
        error: e,
        stack: stack,
        context: {'feature': 'transactions', 'operation': 'refresh'},
        showToastOnUserFacing: false,
      );
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
    } catch (e, stack) {
      AppErrorReporter.report(
        'TransactionTabController._loadConsolidatedFromLocal failed',
        error: e,
        stack: stack,
        context: {'feature': 'transactions', 'operation': 'loadConsolidatedFromLocal'},
        showToastOnUserFacing: false,
      );
      errorMessage.value = AppStrings.errors.loadTransactions;
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
