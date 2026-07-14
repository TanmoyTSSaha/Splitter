import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Model/achievement_model.dart';
import 'package:splitr/Utils/app_error_reporter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AchievementService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<AchievementModel>> fetchCatalogWithUnlocks(String userId) async {
    try {
      final catalog = await _supabase
          .from(SupabaseTables.achievements)
          .select(
            '${SupabaseColumns.id}, ${SupabaseColumns.slug}, ${SupabaseColumns.name}, '
            '${SupabaseColumns.description}, ${SupabaseColumns.iconKey}, ${SupabaseColumns.sortOrder}',
          )
          .eq(SupabaseColumns.isActive, true)
          .order(SupabaseColumns.sortOrder);

      final unlocks = await _supabase
          .from(SupabaseTables.userAchievements)
          .select(
            '${SupabaseColumns.achievementId}, ${SupabaseColumns.celebrationShown}',
          )
          .eq(SupabaseColumns.userId, userId);

      final unlockedIds = <String, bool>{};
      for (final row in unlocks) {
        unlockedIds[row[SupabaseColumns.achievementId].toString()] =
            row[SupabaseColumns.celebrationShown] == true;
      }

      return catalog
          .map<AchievementModel>((row) {
            final model = AchievementModel.fromCatalogRow(
              Map<String, dynamic>.from(row),
            );
            final unlocked = unlockedIds.containsKey(model.id);
            return model.copyWith(
              isUnlocked: unlocked,
              celebrationShown: unlocked
                  ? (unlockedIds[model.id] ?? true)
                  : true,
            );
          })
          .toList();
    } catch (e, stack) {
      AppErrorReporter.unexpected(
        'AchievementService.fetchCatalogWithUnlocks failed',
        error: e,
        stack: stack,
        context: {'feature': 'achievements'},
      );
      return [];
    }
  }

  Future<List<AchievementModel>> fetchPendingCelebrations(
      String userId) async {
    try {
      final rows = await _supabase
          .from(SupabaseTables.userAchievements)
          .select(
            '${SupabaseColumns.achievementId}, ${SupabaseColumns.celebrationShown}, '
            'achievements!inner(${SupabaseColumns.id}, ${SupabaseColumns.slug}, '
            '${SupabaseColumns.name}, ${SupabaseColumns.description}, ${SupabaseColumns.iconKey})',
          )
          .eq(SupabaseColumns.userId, userId)
          .eq(SupabaseColumns.unlockSource, AchievementUnlockSources.live)
          .eq(SupabaseColumns.celebrationShown, false);

      return rows.map<AchievementModel>((row) {
        final achievement =
            Map<String, dynamic>.from(row['achievements'] as Map);
        return AchievementModel.fromCatalogRow(achievement).copyWith(
          isUnlocked: true,
          celebrationShown: false,
        );
      }).toList();
    } catch (e, stack) {
      AppErrorReporter.unexpected(
        'AchievementService.fetchPendingCelebrations failed',
        error: e,
        stack: stack,
        context: {'feature': 'achievements'},
      );
      return [];
    }
  }

  Future<void> markCelebrated(String achievementId) async {
    await _supabase.rpc(
      SupabaseRpc.markAchievementCelebrated,
      params: {SupabaseRpc.pAchievementId: achievementId},
    );
  }
}
