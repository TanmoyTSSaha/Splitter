class GroupInviteModel {
  final String id;
  final String groupId;
  final String invitedBy;
  final String invitedUserId;
  final String status; // 'pending', 'accepted', 'declined'
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
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      invitedBy: json['invited_by'] as String,
      invitedUserId: json['invited_user_id'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      // Use joining if available, or fetch separately
      groupName: json['groups'] != null ? json['groups']['group_name'] : null,
      inviterName: json['users'] != null ? json['users']['user_name'] : null,
      // Note: Supabase join on 'invited_by' might return users data.
      // Adjust based on actual query structure.
    );
  }
}
