import 'package:flutter/material.dart';
import 'package:splitr/Widgets/splitr_toast.dart';
import 'package:get/get.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Model/group_model.dart';
import 'package:splitr/Repository/group_repository.dart';

import 'package:splitr/Widgets/user_avatar.dart';

import '../../Constants/shared.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Constants/app_dimensions.dart';
import 'package:splitr/Utils/app_error_reporter.dart';

class MembersTab extends StatelessWidget {
  final String userID;
  final String groupID;
  final String? createdBy;
  const MembersTab({
    required this.userID,
    required this.groupID,
    this.createdBy,
    super.key,
  });

  bool get _isCreator =>
      createdBy != null && createdBy!.isNotEmpty && createdBy == userID;

  @override
  Widget build(BuildContext context) {
    // List<Map<String, dynamic>> membersDetails = [
    //   {
    //     "name": "Tanmoy Saha (You)",
    //     "imageURL":
    //         "https://fiverr-res.cloudinary.com/images/t_main1,q_auto,f_auto,q_auto,f_auto/gigs/152776829/original/a563057b8f0884f5325a5ffa3c180a5f2eb72b7b/design-an-anime-style-avatar.png",
    //   },
    //   {
    //     "name": "Deepesh Tyagi",
    //     "imageURL":
    //         "https://fiverr-res.cloudinary.com/images/t_main1,q_auto,f_auto,q_auto,f_auto/gigs/152776829/original/a563057b8f0884f5325a5ffa3c180a5f2eb72b7b/design-an-anime-style-avatar.png",
    //   },
    //   {
    //     "name": "Durgesh Kumar Singh",
    //     "imageURL":
    //         "https://fiverr-res.cloudinary.com/images/t_main1,q_auto,f_auto,q_auto,f_auto/gigs/152776829/original/a563057b8f0884f5325a5ffa3c180a5f2eb72b7b/design-an-anime-style-avatar.png",
    //   },
    //   {
    //     "name": "Hardik Pal",
    //     "imageURL":
    //         "https://fiverr-res.cloudinary.com/images/t_main1,q_auto,f_auto,q_auto,f_auto/gigs/152776829/original/a563057b8f0884f5325a5ffa3c180a5f2eb72b7b/design-an-anime-style-avatar.png",
    //   },
    // ];

    return Column(
        children: [
          if (userID.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: groupGutter),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _leaveGroup(context),
                  icon: const Icon(Icons.exit_to_app_rounded,
                      size: groupCarouselIconSm),
                  label: Text(AppStrings.groups.leaveGroup),
                ),
              ),
            ),
          Expanded(
            child: FutureBuilder<List<GroupMembersWithNameModel>>(
              future: Get.find<GroupRepository>().getGroupMembers(
                groupId: groupID,
                currentUserId: userID,
              ),
              builder: (context, groupMemberSnapshot) {
                if (groupMemberSnapshot.hasData) {
                  return SizedBox(
                    width: devSysWidth,
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1,
                        crossAxisSpacing: groupGutter,
                        mainAxisSpacing: groupGutter,
                      ),
                      itemCount: groupMemberSnapshot.data!.length,
                      itemBuilder: (context, index) {
                        final member = groupMemberSnapshot.data![index];
                        final canRemove = _isCreator &&
                            member.userID != null &&
                            member.userID != userID;
                        return GestureDetector(
                          onLongPress: canRemove
                              ? () => _removeMember(context, member)
                              : null,
                          child: Stack(
                            alignment: index % 4 == 1
                                ? Alignment.bottomLeft
                                : index % 4 == 2
                                    ? Alignment.topRight
                                    : index % 4 == 3
                                        ? Alignment.topLeft
                                        : Alignment.bottomRight,
                            children: [
                              SizedBox(
                                height: devSysWidth * 0.5,
                                width: devSysWidth * 0.5,
                                child: UserAvatar(
                                  userID:
                                      groupMemberSnapshot.data![index].userID!,
                                  userName: groupMemberSnapshot
                                      .data![index].userName!,
                                  imageUrl:
                                      groupMemberSnapshot.data![index].userPic,
                                  radius: devSysWidth * 0.25,
                                  shape: BoxShape.rectangle,
                                  customBorderRadius: BorderRadius.only(
                                    topLeft: index % 4 == 3
                                        ? const Radius.circular(0)
                                        : Radius.circular(devSysHeight * 0.4),
                                    topRight: index % 4 == 2
                                        ? const Radius.circular(0)
                                        : Radius.circular(devSysHeight * 0.4),
                                    bottomRight: index % 4 == 0
                                        ? const Radius.circular(0)
                                        : Radius.circular(devSysHeight * 0.4),
                                    bottomLeft: index % 4 == 1
                                        ? const Radius.circular(0)
                                        : Radius.circular(devSysHeight * 0.4),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(groupGapSm),
                                alignment: index % 4 == 0
                                    ? Alignment.centerRight
                                    : index % 4 == 1
                                        ? Alignment.centerLeft
                                        : index % 4 == 2
                                            ? Alignment.centerRight
                                            : Alignment.centerLeft,
                                width: devSysWidth * 0.35,
                                height: groupGapXl,
                                margin: const EdgeInsets.all(groupGap2),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      neopopBackground.withValues(
                                          alpha: AppDimensions
                                              .glassCardOpacityNav),
                                      groupSurfaceFillSoft
                                    ],
                                    begin: index % 4 == 0
                                        ? Alignment.centerRight
                                        : index % 4 == 1
                                            ? Alignment.centerLeft
                                            : index % 4 == 2
                                                ? Alignment.centerRight
                                                : Alignment.centerLeft,
                                    end: index % 4 == 0
                                        ? Alignment.centerLeft
                                        : index % 4 == 1
                                            ? Alignment.centerRight
                                            : index % 4 == 2
                                                ? Alignment.centerLeft
                                                : Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.only(
                                    topRight: index % 4 == 0
                                        ? Radius.circular(groupPillRadius)
                                        : index % 4 == 1
                                            ? const Radius.circular(0)
                                            : index % 4 == 2
                                                ? Radius.circular(
                                                    groupPillRadius)
                                                : const Radius.circular(0),
                                    bottomRight: index % 4 == 0
                                        ? Radius.circular(groupPillRadius)
                                        : index % 4 == 1
                                            ? const Radius.circular(0)
                                            : index % 4 == 2
                                                ? Radius.circular(
                                                    groupPillRadius)
                                                : const Radius.circular(0),
                                    topLeft: index % 4 == 0
                                        ? const Radius.circular(0)
                                        : index % 4 == 1
                                            ? Radius.circular(groupPillRadius)
                                            : index % 4 == 2
                                                ? const Radius.circular(0)
                                                : Radius.circular(
                                                    groupGutter * 2),
                                    bottomLeft: index % 4 == 0
                                        ? const Radius.circular(0)
                                        : index % 4 == 1
                                            ? Radius.circular(groupPillRadius)
                                            : index % 4 == 2
                                                ? const Radius.circular(0)
                                                : Radius.circular(
                                                    groupGutter * 2),
                                  ),
                                ),
                                child: Text(
                                  member.userName!,
                                  style: caption_text.copyWith(
                                      color: groupChipSelectedFg),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                } else if (groupMemberSnapshot.hasError) {
                  debugPrint("SNAPSHOT ERROR: ${groupMemberSnapshot.error}");
                  return SizedBox(
                    height: devSysHeight * 0.6,
                    width: devSysWidth,
                    child: Center(
                      child: Text(
                        AppStrings.errors.generic,
                        style: sub_headline5_text.copyWith(
                          color: neopopAccent,
                        ),
                      ),
                    ),
                  );
                }

                return SizedBox(
                  height: devSysHeight * 0.6,
                  width: devSysWidth,
                  child: const Center(child: LoadingWidget()),
                );
              },
            ),
          ),
        ],
    );
  }

  Future<void> _removeMember(
    BuildContext context,
    GroupMembersWithNameModel member,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.groups.removeMemberTitle),
        content: Text(
          AppStringFormat.removeMemberFromGroup(
              member.userName ?? DisplayFallbacks.member),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(AppStrings.actions.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(AppStrings.groups.removeMemberAction)),
        ],
      ),
    );
    if (confirm != true || member.userID == null) return;
    try {
      await Get.find<GroupRepository>().removeMember(
        groupId: groupID,
        memberId: member.userID!,
      );
      if (context.mounted) {
        SplitrToast.show(SplitrToast.join(AppStrings.groups.memberRemovedTitle, AppStringFormat.memberWasRemoved(
                member.userName ?? DisplayFallbacks.member)));
      }
    } catch (e, stack) {
      AppErrorReporter.reportActionFailure(
        AppStrings.errors.couldNotRemoveMemberPrefix,
        error: e,
        stack: stack,
      );
    }
  }

  Future<void> _leaveGroup(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.groups.leaveGroupTitle),
        content: Text(AppStrings.groups.leaveGroupConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(AppStrings.actions.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(AppStrings.groups.leaveGroupAction)),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await Get.find<GroupRepository>().leaveGroup(groupID);
      if (context.mounted) {
        Get.back();
        SplitrToast.show(SplitrToast.join(AppStrings.groups.leftGroupTitle, AppStrings.groups.leftGroupMessage));
      }
    } catch (e, stack) {
      AppErrorReporter.reportActionFailure(
        AppStrings.errors.couldNotLeaveGroupPrefix,
        error: e,
        stack: stack,
      );
    }
  }
}
