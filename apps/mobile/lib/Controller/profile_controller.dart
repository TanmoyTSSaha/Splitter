import 'package:get/get.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Controller/achievement_controller.dart';
import 'package:splitr/Model/user_details_model.dart';
import 'package:splitr/Services/SupabaseServices/transaction_service.dart';
import 'package:splitr/Services/supabase_service.dart';
import 'package:splitr/Utils/app_error_reporter.dart';

/// Profile tab state — user details and lifetime stats.
class ProfileController extends GetxController {
  final SupabaseDatabase _supabase = SupabaseDatabase();
  final TransactionService _transactionService = TransactionService();

  final isLoading = true.obs;
  final errorMessage = RxnString();
  final user = Rxn<UserDetails>();
  final stats = <String, double>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    isLoading.value = user.value == null;
    errorMessage.value = null;

    try {
      final userId = SupabaseAuth().supabaseGetUserID();
      final results = await Future.wait([
        _supabase.getCurrentUserProfile(userID: userId),
        _transactionService.getLifetimeStats(userID: userId),
      ]);
      user.value = results[0] as UserDetails;
      stats.assignAll(results[1] as Map<String, double>);
      if (Get.isRegistered<AchievementController>()) {
        await Get.find<AchievementController>().refreshAchievements();
      }
    } catch (e, stack) {
      AppErrorReporter.report(
        'ProfileController.fetchProfileData failed',
        error: e,
        stack: stack,
        context: {'feature': 'profile', 'operation': 'fetchProfileData'},
        showToastOnUserFacing: false,
      );
      errorMessage.value = AppStrings.errors.generic;
    } finally {
      isLoading.value = false;
    }
  }
}
