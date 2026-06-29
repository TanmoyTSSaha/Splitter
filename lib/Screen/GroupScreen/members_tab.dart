import 'package:flutter/material.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Model/group_model.dart';
import 'package:splitter/Services/supabase_service.dart';

import 'package:splitter/Widgets/user_avatar.dart';

import '../../Constants/shared.dart';

class MembersTab extends StatelessWidget {
  final String userID;
  final String groupID;
  const MembersTab({
    required this.userID,
    required this.groupID,
    super.key,
  });

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

    return SafeArea(
      child: FutureBuilder<List<GroupMembersWithNameModel>>(
        future: SupabaseDatabase().getGroupMembers(
          groupID: groupID,
          currentUserID: userID,
        ),
        builder: (context, groupMemberSnapshot) {
          if (groupMemberSnapshot.hasData) {
            return SizedBox(
              width: devSysWidth,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1,
                  crossAxisSpacing: height_16,
                  mainAxisSpacing: height_16,
                ),
                itemCount: groupMemberSnapshot.data!.length,
                itemBuilder: (context, index) {
                  return Stack(
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
                          userID: groupMemberSnapshot.data![index].userID!,
                          userName: groupMemberSnapshot.data![index].userName!,
                          imageUrl: groupMemberSnapshot.data![index].userPic,
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
                        padding: EdgeInsets.all(height_16 / 2),
                        alignment: index % 4 == 0
                            ? Alignment.centerRight
                            : index % 4 == 1
                                ? Alignment.centerLeft
                                : index % 4 == 2
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                        width: devSysWidth * 0.35,
                        height: height_16 * 2,
                        margin: EdgeInsets.all(height_10 / 5),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              neopopBackground.withOpacity(0.75),
                              neopopBackground.withOpacity(0.1)
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
                                ? Radius.circular(height_16 * 2)
                                : index % 4 == 1
                                    ? const Radius.circular(0)
                                    : index % 4 == 2
                                        ? Radius.circular(height_16 * 2)
                                        : const Radius.circular(0),
                            bottomRight: index % 4 == 0
                                ? Radius.circular(height_16 * 2)
                                : index % 4 == 1
                                    ? const Radius.circular(0)
                                    : index % 4 == 2
                                        ? Radius.circular(height_16 * 2)
                                        : const Radius.circular(0),
                            topLeft: index % 4 == 0
                                ? const Radius.circular(0)
                                : index % 4 == 1
                                    ? Radius.circular(height_16 * 2)
                                    : index % 4 == 2
                                        ? const Radius.circular(0)
                                        : Radius.circular(height_16 * 2),
                            bottomLeft: index % 4 == 0
                                ? const Radius.circular(0)
                                : index % 4 == 1
                                    ? Radius.circular(height_16 * 2)
                                    : index % 4 == 2
                                        ? const Radius.circular(0)
                                        : Radius.circular(height_16 * 2),
                          ),
                        ),
                        child: Text(
                          groupMemberSnapshot.data![index].userName!,
                          style: caption_text.copyWith(color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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
                  "Something went wrong!",
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
    );
  }
}
