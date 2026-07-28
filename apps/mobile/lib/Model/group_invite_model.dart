import 'package:splitr/Constants/app_keys.dart';

class GroupInviteModel {
  final String id;
  final String groupId;
  final String invitedBy;
  final String invitedUserId;
  final String status;
  final DateTime createdAt;

  // Optional: details about the group and inviter for UI display
  final String? groupName;
  final String? inviterName;

  GroupInviteModel({
    required this.id,
    required this.groupId,
    required this.invitedBy,
    required this.invitedUserId,
    required this.status,
    required this.createdAt,
    this.groupName,
    this.inviterName,
  });

  factory GroupInviteModel.fromJSON(Map<String, dynamic> json) {
    return GroupInviteModel(
      id: json[SupabaseColumns.id] as String,
      groupId: json[SupabaseColumns.groupId] as String,
      invitedBy: json[SupabaseColumns.invitedBy] as String,
      invitedUserId: json[SupabaseColumns.invitedUserId] as String,
      status: json[SupabaseColumns.status] as String,
      createdAt: DateTime.parse(json[SupabaseColumns.createdAt] as String),
      groupName: json[SupabaseTables.groups] != null
          ? json[SupabaseTables.groups][SupabaseColumns.groupName]
          : null,
      inviterName: json[SupabaseTables.users] != null
          ? json[SupabaseTables.users][SupabaseColumns.userName]
          : null,
    );
  }
}
