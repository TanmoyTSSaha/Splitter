import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Screen/GroupScreen/group_detailed_screen.dart';

import '../../Constants/shared.dart';
import '../../Model/group_model.dart';
import '../../Model/user_details_model.dart';
import '../../Services/supabase_service.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({
    super.key,
  });

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  List<String> groupNames = [
    "Mysuru Trip",
    "Paris Trip",
    "Flat Expenses",
    "Rental Expenses",
    "Office Expenses",
    "Lifestyle Expenses"
  ];

  String userID = SupabaseAuth().supabaseGetUserID();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<UserDetails>(
        future: SupabaseDatabase().getCurrentUserProfile(userID: userID),
        builder: (context, userDetailsSnapshot) {
          if (userDetailsSnapshot.hasData) {
            return Scaffold(
              backgroundColor: neopopBackground,
              appBar: AppBar(
                primary: true,
                backgroundColor: neopopBackground,
                automaticallyImplyLeading: false,
                leadingWidth: height_10 * 7.2,
                // toolbarHeight: 72,
                centerTitle: false,
                leading: Container(
                  height: height_10 * 4,
                  width: height_10 * 4,
                  margin: EdgeInsets.only(left: height_16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.transparent,
                      width: 6,
                    ),
                    borderRadius: BorderRadius.circular(height_10 * 3.6),
                  ),
                  padding: EdgeInsets.all(height_10 * 0.2),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(height_10 * 4),
                    child: CachedNetworkImage(
                      imageUrl: userDetailsSnapshot.data!.profilePictureURL!,
                      fit: BoxFit.cover,
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) {
                        return ImageLoadingWidget(
                          loaderRadius: height_10 * 4,
                        );
                      },
                      errorWidget: (context, url, error) {
                        return SvgPicture.asset(
                          "assets/icons/svg/error_svg.svg",
                          fit: BoxFit.contain,
                          color: neopopPrimary,
                        );
                      },
                    ),
                  ),
                ),
                elevation: 0,
                title: RichText(
                  text: TextSpan(
                    text: "Hi ${userDetailsSnapshot.data!.firstName}\n",
                    style: sub_headline5_text.copyWith(
                      color: neopopOnBackground,
                    ),
                    children: [
                      TextSpan(
                        text: "Make your group and split bills easy",
                        style: caption_text.copyWith(
                          color: neopopGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  Padding(
                    padding: EdgeInsets.only(
                      right: height_16,
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: SvgPicture.asset(
                        "assets/icons/svg/solar--bell-off-broken.svg",
                        height: height_10 * 2.4,
                        width: height_10 * 2.4,
                        color: neopopOnPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              body: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: FutureBuilder<List<GroupModel>>(
                  future: SupabaseDatabase().getGroupData(userID: userID),
                  builder: (context, groupDataSnapshot) {
                    if (groupDataSnapshot.hasData) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          vertical: height_10 * 2.4,
                          horizontal: height_16,
                        ),
                        width: devSysWidth,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: devSysWidth,
                              color: neopopAccent,
                              padding:
                                  EdgeInsets.symmetric(vertical: height_16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                      right: width_16,
                                      left: width_16,
                                      top: 0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Your overall calculations!",
                                          style: sub_headline5_text.copyWith(
                                            fontFamily: "NunitoSans",
                                            color: neopopBackground,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: height_16),
                                  Padding(
                                    padding: EdgeInsets.only(
                                      right: width_16,
                                      left: width_16,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: (devSysWidth - 70) / 2,
                                          child: RichText(
                                            text: TextSpan(
                                              text: "You'll receive\n",
                                              style: body2_text.copyWith(
                                                color: neopopBackground,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: "\$3800",
                                                  style:
                                                      headline2_text.copyWith(
                                                    color: neopopBackground,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: (devSysWidth - 70) / 2,
                                          child: RichText(
                                            textAlign: TextAlign.right,
                                            text: TextSpan(
                                              text: "You'll pay\n",
                                              style: body2_text.copyWith(
                                                color: neopopBackground,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: "\$900",
                                                  style:
                                                      headline2_text.copyWith(
                                                    color: neopopBackground,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: height_16),
                            Text(
                              "Groups",
                              style: sub_headline4_text.copyWith(
                                color: neopopOnBackground,
                              ),
                            ),
                            SizedBox(height: height_16),
                            ListView.separated(
                              shrinkWrap: true,
                              itemCount: groupDataSnapshot.data!.length,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) => GroupCard(
                                groupModel: groupDataSnapshot.data![index],
                                userID: userID,
                                onTap: () => Get.to(
                                  () => GroupDetailedScreen(
                                    groupModel: groupDataSnapshot.data![index],
                                    userID: userID,
                                  ),
                                ),
                              ),
                              separatorBuilder: (context, index) => SizedBox(
                                height: height_16,
                              ),
                            ),
                          ],
                        ),
                      );
                    } else if (userDetailsSnapshot.hasError) {
                      return Container(
                        height: devSysHeight,
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
                      height: devSysHeight * 0.75,
                      width: devSysWidth,
                      decoration: const BoxDecoration(
                        color: neopopBackground,
                      ),
                      alignment: Alignment.center,
                      child: const LoadingWidget(),
                    );
                  },
                ),
              ),
            );
          } else if (userDetailsSnapshot.hasError) {
            return Container(
              height: devSysHeight,
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
            height: devSysHeight,
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
