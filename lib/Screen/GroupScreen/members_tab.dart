import 'package:flutter/material.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Model/group_model.dart';
import 'package:splitter/Services/supabase_service.dart';

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
                  debugPrint(
                      "USER DP -> $index: ${groupMemberSnapshot.data![index].userPic!}");
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
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
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
                          child: Image.network(
                            groupMemberSnapshot.data![index].userPic != ""
                                ? groupMemberSnapshot.data![index].userPic!
                                : "https://fiverr-res.cloudinary.com/images/t_main1,q_auto,f_auto,q_auto,f_auto/gigs/152776829/original/a563057b8f0884f5325a5ffa3c180a5f2eb72b7b/design-an-anime-style-avatar.png",
                            // height: devSysWidth * 0.2,
                            // width: devSysWidth * 0.2,
                            fit: BoxFit.cover,
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
                          style: caption_text,
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
            return Container(
              height: devSysHeight * 0.6,
              width: devSysWidth,
              decoration: const BoxDecoration(
                color: neopopBackground,
              ),
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

          return Container(
            height: devSysHeight * 0.6,
            width: devSysWidth,
            decoration: const BoxDecoration(
              color: neopopBackground,
            ),
            alignment: Alignment.center,
            child: const LoadingWidget(),
          );
        },
      ),
    );
  }
}
