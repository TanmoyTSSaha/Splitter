import 'package:get/get.dart';
import 'package:splitr/Controller/achievement_controller.dart';
import 'package:splitr/Controller/group_screen_controller.dart';
import 'package:splitr/Controller/home_controller.dart';
import 'package:splitr/Controller/profile_controller.dart';
import 'package:splitr/Controller/notification_badge_controller.dart';
import 'package:splitr/Repository/friend_repository.dart';
import 'package:splitr/Repository/group_repository.dart';
import 'package:splitr/Repository/loan_repository.dart';
import 'package:splitr/Repository/personal_transaction_repository.dart';
import 'package:splitr/Repository/transaction_repository.dart';
import 'package:splitr/Services/local/database.dart';
import 'package:splitr/Services/personal_budget_alert_service.dart';
import 'package:splitr/Services/sync_service.dart';

/// Registers offline-capable repositories and shared controllers.
class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => GroupRepository(Get.find<AppDatabase>(), Get.find<SyncService>()),
      fenix: true,
    );
    Get.lazyPut(
      () => TransactionRepository(
          Get.find<AppDatabase>(), Get.find<SyncService>()),
      fenix: true,
    );
    Get.lazyPut(
      () => PersonalTransactionRepository(
        Get.find<AppDatabase>(),
        Get.find<SyncService>(),
      ),
      fenix: true,
    );
    Get.lazyPut(
      () => FriendRepository(Get.find<AppDatabase>(), Get.find<SyncService>()),
      fenix: true,
    );
    Get.lazyPut(() => LoanRepository(), fenix: true);
    Get.lazyPut(() => PersonalBudgetAlertService(), fenix: true);
    Get.lazyPut(() => GroupScreenController(), fenix: true);
    Get.lazyPut(() => HomeController(), fenix: true);
    Get.lazyPut(() => ProfileController(), fenix: true);
    Get.lazyPut(() => NotificationBadgeController(), fenix: true);
    Get.lazyPut(
      () => AchievementController(syncService: Get.find<SyncService>()),
      fenix: true,
    );
  }
}
