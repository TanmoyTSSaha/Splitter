import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Services/supabase_service.dart';
import 'package:splitr/Utils/app_error_reporter.dart';

/// A device contact matched to a registered Splitr user.
class ContactMatch {
  final String contactName;
  final String email;
  final String userId;
  final String? userName;
  final String? userPic;

  ContactMatch({
    required this.contactName,
    required this.email,
    required this.userId,
    this.userName,
    this.userPic,
  });
}

/// Reads the device contact book and matches emails to Splitr accounts.
class ContactInviteService {
  final SupabaseDatabase _db = SupabaseDatabase();

  Future<bool> requestPermission() async {
    final status =
        await FlutterContacts.permissions.request(PermissionType.read);
    return status == PermissionStatus.granted ||
        status == PermissionStatus.limited;
  }

  Future<List<ContactMatch>> findRegisteredContacts() async {
    try {
      final granted = await requestPermission();
      if (!granted) return [];

      final contacts = await FlutterContacts.getAll(
        properties: {ContactProperty.email, ContactProperty.name},
      );

      final emailToContactName = <String, String>{};
      for (final contact in contacts) {
        final name = contact.displayName ?? '';
        for (final email in contact.emails) {
          final normalized = email.address.trim().toLowerCase();
          if (normalized.isNotEmpty) {
            emailToContactName.putIfAbsent(normalized, () => name);
          }
        }
      }

      if (emailToContactName.isEmpty) return [];

      final users = await _db.searchUsersByEmails(
        emails: emailToContactName.keys.toList(),
      );

      return users.map((u) {
        final email = (u['user_email'] as String).toLowerCase();
        return ContactMatch(
          contactName: emailToContactName[email] ??
              u[SupabaseColumns.userName] ??
              DisplayFallbacks.contact,
          email: email,
          userId: u[SupabaseColumns.userId] as String,
          userName: u[SupabaseColumns.userName] as String?,
          userPic: u[SupabaseColumns.profilePictureUrl] as String?,
        );
      }).toList();
    } catch (e, stack) {
      AppErrorReporter.report(
        'ContactInviteService.findRegisteredContacts failed',
        error: e,
        stack: stack,
        context: {'feature': 'invites', 'operation': 'findRegisteredContacts'},
      );
      return [];
    }
  }
}
