import 'dart:math';

import 'package:splitr/Constants/app_branding.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/app_motion.dart';
import 'package:splitr/Constants/business_rules.dart';
import 'package:splitr/Services/supabase_service.dart';
import 'package:splitr/Utils/app_error_reporter.dart';

/// Creates tokenized public share links (`public_share_links` table).

class PublicShareLinkService {
  final _db = SupabaseDatabase();

  static String _token() {
    final r = Random.secure();

    return List.generate(
      ShareTokenConfig.length,
      (_) => ShareTokenChars
          .alphanumeric[r.nextInt(ShareTokenChars.alphanumeric.length)],
    ).join();
  }

  Future<String?> createLink({
    required String type,
    required Map<String, dynamic> payload,
    Duration ttl = AppMotion.shareLinkTtl,
  }) async {
    try {
      final uid = SupabaseAuth().supabaseGetUserID();

      if (uid.isEmpty) return null;

      final token = _token();

      await _db.supabase.from(SupabaseTables.publicShareLinks).insert({
        SupabaseColumns.token: token,
        SupabaseColumns.payload: {
          MetadataKeys.type: type,
          ...payload,
        },
        SupabaseColumns.createdBy: uid,
        SupabaseColumns.expiresAt:
            DateTime.now().add(ttl).toUtc().toIso8601String(),
      });

      return '${AppBranding.webBaseUrl}${DeepLinkPaths.publicShare}$token';
    } catch (e, stack) {
      AppErrorReporter.report(
        'PublicShareLinkService.createLink failed',
        error: e,
        stack: stack,
        context: {'feature': 'sharing', 'operation': 'createLink'},
      );

      return null;
    }
  }
}
