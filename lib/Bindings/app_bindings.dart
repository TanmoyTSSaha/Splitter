import 'package:get/get.dart';
import 'package:splitter/Controller/group_screen_controller.dart';
import 'package:splitter/Controller/notification_badge_controller.dart';
import 'package:splitter/Repository/group_repository.dart';
import 'package:splitter/Repository/transaction_repository.dart';
import 'package:splitter/Services/local/database.dart';
import 'package:splitter/Services/sync_service.dart';

/// Registers offline-capable repositories and shared controllers.
class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => GroupRepository(Get.find<AppDatabase>(), Get.find<SyncService>()),
      fenix: true,
    );
    Get.lazyPut(
      () =>
          TransactionRepository(Get.find<AppDatabase>(), Get.find<SyncService>()),
      fenix: true,
    );
    Get.lazyPut(() => GroupScreenController(), fenix: true);
    Get.lazyPut(() => NotificationBadgeController(), fenix: true);
  }
}
