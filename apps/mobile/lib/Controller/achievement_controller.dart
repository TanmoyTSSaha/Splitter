import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Constants/app_motion.dart';
import 'package:splitr/Model/achievement_model.dart';
import 'package:splitr/Services/achievement_service.dart';
import 'package:splitr/Services/sync_service.dart';
import 'package:splitr/Utils/app_error_reporter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AchievementController extends GetxController with WidgetsBindingObserver {
  AchievementController({AchievementService? service, SyncService? syncService})
      : _service = service ?? AchievementService(),
        _syncService = syncService;

  final AchievementService _service;
  final SyncService? _syncService;

  final achievements = <AchievementModel>[].obs;
  final isLoading = false.obs;
  final activeCelebration = Rxn<AchievementModel>();

  RealtimeChannel? _channel;
  StreamSubscription<SyncStatus>? _syncSub;
  final _queue = <AchievementModel>[];
  bool _showingCelebration = false;
  String? _userId;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _bindSyncListener();
    _initForSession();
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn) {
        _initForSession();
      } else if (data.event == AuthChangeEvent.signedOut) {
        _teardown();
      }
    });
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _syncSub?.cancel();
    _teardown();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      pollPendingCelebrations();
    }
  }

  void _bindSyncListener() {
    if (_syncService != null) {
      _syncSub = _syncService.syncStatus.listen((status) {
        if (status == SyncStatus.synced) {
          pollPendingCelebrations();
        }
      });
      return;
    }
    if (Get.isRegistered<SyncService>()) {
      _syncSub = Get.find<SyncService>().syncStatus.listen((status) {
        if (status == SyncStatus.synced) {
          pollPendingCelebrations();
        }
      });
    }
  }

  Future<void> _initForSession() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    _userId = userId;
    await refreshAchievements();
    await pollPendingCelebrations();
    _subscribeRealtime(userId);
  }

  void _teardown() {
    _userId = null;
    _queue.clear();
    activeCelebration.value = null;
    _showingCelebration = false;
    achievements.clear();
    if (_channel != null) {
      Supabase.instance.client.removeChannel(_channel!);
      _channel = null;
    }
  }

  Future<void> refreshAchievements() async {
    final userId = _userId;
    if (userId == null) return;
    isLoading.value = true;
    try {
      achievements.value = await _service.fetchCatalogWithUnlocks(userId);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pollPendingCelebrations() async {
    final userId = _userId;
    if (userId == null) return;
    try {
      final pending = await _service.fetchPendingCelebrations(userId);
      for (final item in pending) {
        _enqueueCelebration(item);
      }
      await refreshAchievements();
    } catch (e, stack) {
      AppErrorReporter.unexpected(
        'AchievementController.pollPendingCelebrations failed',
        error: e,
        stack: stack,
        context: {'feature': 'achievements'},
      );
    }
  }

  void _subscribeRealtime(String userId) {
    if (_channel != null) {
      Supabase.instance.client.removeChannel(_channel!);
    }

    _channel = Supabase.instance.client
        .channel('${RealtimeChannelPrefixes.achievements}$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: RealtimeSchemas.public,
          table: SupabaseTables.userAchievements,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: SupabaseColumns.userId,
            value: userId,
          ),
          callback: (payload) async {
            final row = payload.newRecord;
            if (row[SupabaseColumns.unlockSource] !=
                AchievementUnlockSources.live) {
              return;
            }
            if (row[SupabaseColumns.celebrationShown] == true) {
              return;
            }
            await _handleRealtimeUnlock(
              row[SupabaseColumns.achievementId]?.toString(),
            );
          },
        )
        .subscribe();
  }

  Future<void> _handleRealtimeUnlock(String? achievementId) async {
    if (achievementId == null) return;
    await pollPendingCelebrations();
  }

  void _enqueueCelebration(AchievementModel item) {
    if (_queue.any((q) => q.id == item.id)) return;
    if (activeCelebration.value?.id == item.id) return;
    _queue.add(item);
    _pumpCelebrationQueue();
  }

  void _pumpCelebrationQueue() {
    if (_showingCelebration || _queue.isEmpty) return;
    _showingCelebration = true;
    activeCelebration.value = _queue.removeAt(0);
  }

  Future<void> onCelebrationComplete() async {
    final current = activeCelebration.value;
    if (current != null) {
      try {
        await _service.markCelebrated(current.id);
      } catch (e, stack) {
        AppErrorReporter.unexpected(
          'AchievementController.markCelebrated failed',
          error: e,
          stack: stack,
          context: {'feature': 'achievements', 'achievementId': current.id},
        );
      }
    }
    activeCelebration.value = null;
    _showingCelebration = false;
    await refreshAchievements();
    if (_queue.isNotEmpty) {
      Future.delayed(AppMotion.micro, _pumpCelebrationQueue);
    }
  }
}
