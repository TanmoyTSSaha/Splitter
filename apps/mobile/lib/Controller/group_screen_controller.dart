import 'dart:async';

import 'package:get/get.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Model/group_model.dart';
import 'package:splitr/Repository/group_repository.dart';
import 'package:splitr/Services/realtime_service.dart';
import 'package:splitr/Services/sync_service.dart';
import 'package:splitr/Utils/app_error_reporter.dart';

class GroupScreenController extends GetxController {
  late final GroupRepository _repository;
  late final SyncService _syncService;
  late final RealtimeService _realtimeService;

  final groups = <GroupModel>[].obs;
  final isLoadingGroups = true.obs;
  final groupsError = RxnString();
  final syncStatus = SyncStatus.synced.obs;

  var tabIndex = 0.obs;
  var refreshTrigger = 0.obs;
  var wishlistHasItems = false.obs;

  var showArchived = false.obs;

  String? _userId;
  Set<String> _tripGroupIds = {};
  Set<String> _archivedGroupIds = {};
  StreamSubscription? _groupsSub;
  StreamSubscription? _syncSub;
  StreamSubscription? _realtimeSub;
  String? _subscribedGroupId;

  void initialize(String userId) {
    if (_userId == userId) return;
    _userId = userId;
    groups.clear();
    _tripGroupIds = {};
    _groupsSub?.cancel();
    _groupsSub = _repository.watchGroups().listen((_) => _rebuildGroups());
    refreshGroups();
  }

  void updateTabIndex(int index) {
    tabIndex.value = index;
  }

  void triggerRefresh() {
    refreshTrigger.value++;
    refreshGroups();
  }

  /// Pull latest memberships from Supabase into the local cache.
  static void refreshFromAnywhere() {
    if (Get.isRegistered<GroupScreenController>()) {
      Get.find<GroupScreenController>().triggerRefresh();
    }
  }

  Future<void> refreshGroups() async {
    if (_userId == null) return;
    try {
      isLoadingGroups.value = groups.isEmpty;
      groupsError.value = null;
      await _repository.refreshFromServer(_userId!);
      final tripIds =
          await _repository.fetchTripGroupIds(await _localGroupIds());
      _tripGroupIds = tripIds;
      _archivedGroupIds =
          await _repository.fetchArchivedGroupIds(await _localGroupIds());
      await _rebuildGroups();
    } catch (e, stack) {
      AppErrorReporter.report(
        'GroupScreenController.refreshGroups failed',
        error: e,
        stack: stack,
        context: {'feature': 'groups', 'operation': 'refreshGroups'},
        showToastOnUserFacing: false,
      );
      groupsError.value = AppStrings.errors.refreshGroupsCached;
      await _rebuildGroups();
    } finally {
      isLoadingGroups.value = false;
    }
  }

  Future<List<String>> _localGroupIds() async {
    if (_userId == null) return [];
    final local = await _repository.getGroups(_userId!);
    return local.map((g) => g.groupId).toList();
  }

  Future<void> _rebuildGroups() async {
    if (_userId == null) {
      groups.clear();
      return;
    }
    final local = await _repository.getGroups(_userId!);
    local.sort((a, b) {
      final aTime = a.updatedOn ?? a.createdAt;
      final bTime = b.updatedOn ?? b.createdAt;
      if (aTime == null && bTime == null) {
        return a.groupName.compareTo(b.groupName);
      }
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      final cmp = bTime.compareTo(aTime);
      return cmp != 0 ? cmp : a.groupName.compareTo(b.groupName);
    });

    groups.assignAll(local
        .map((g) => _repository.toGroupModel(
              g,
              isTrip: _tripGroupIds.contains(g.groupId),
              isArchived: _archivedGroupIds.contains(g.groupId),
            ))
        .toList());
  }

  /// Subscribe to live transaction updates for a group detail screen.
  void subscribeToGroupRealtime(String groupId) {
    if (_subscribedGroupId == groupId) return;
    if (_subscribedGroupId != null) {
      _realtimeService.unsubscribeFromGroup(_subscribedGroupId!);
    }
    _subscribedGroupId = groupId;
    _realtimeService.subscribeToGroup(groupId);
  }

  void unsubscribeFromGroupRealtime() {
    if (_subscribedGroupId != null) {
      _realtimeService.unsubscribeFromGroup(_subscribedGroupId!);
      _subscribedGroupId = null;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _repository = Get.find<GroupRepository>();
    _syncService = Get.find<SyncService>();
    _realtimeService = Get.find<RealtimeService>();
    _syncSub = _syncService.syncStatus.listen((status) {
      syncStatus.value = status;
    });
    _realtimeSub = _realtimeService.onTransactionChange.listen((event) {
      refreshGroups();
      triggerRefresh();
    });
  }

  @override
  void onClose() {
    unsubscribeFromGroupRealtime();
    _groupsSub?.cancel();
    _syncSub?.cancel();
    _realtimeSub?.cancel();
    super.onClose();
  }
}
