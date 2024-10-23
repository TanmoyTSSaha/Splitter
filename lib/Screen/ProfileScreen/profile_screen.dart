import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Constants/shared.dart';
import 'package:splitter/Screen/FeatureComingUp/feature_coming_up_next.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: neopopBackground,
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(height_16),
            width: devSysWidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: height_16 * 10,
                  width: height_16 * 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(devSysWidth),
                    border: Border.all(
                      color: neopopAccent,
                      width: height_16,
                      strokeAlign: BorderSide.strokeAlignOutside,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(devSysWidth),
                    child: Image.network(
                      "https://jessejimz.b-cdn.net/wp-content/uploads/2021/06/gentleman.jpg",
                      height: height_16 * 10,
                      width: height_16 * 10,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                ),
                SizedBox(height: height_16 * 2),
                Text(
                  "Klaudia June",
                  style: headline2_text.copyWith(
                    color: neopopOnPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: height_10 / 2),
                Text(
                  "Agartala, Tripura, IN",
                  style: body1_text.copyWith(
                    color: neopopOnPrimary,
                  ),
                ),
                SizedBox(height: height_16 * 2),
                Container(
                  height: height_16 * 8,
                  width: devSysWidth,
                  padding: EdgeInsets.all(height_10),
                  decoration: const BoxDecoration(
                    color: neopopAccent,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: devSysWidth * 0.29,
                        padding: EdgeInsets.all(height_10 / 2),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                "Total spent",
                                style: caption_text.copyWith(
                                  color: neopopBackground,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: height_10),
                            Flexible(
                              child: Text(
                                "₹134021",
                                style: sub_headline5_text.copyWith(
                                  color: neopopBackground,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      RotatedBox(
                        quarterTurns: 1,
                        child: SizedBox(
                          width: height_16 * 8,
                          child: const Divider(
                            height: 1,
                            thickness: 1,
                            color: neopopBackground,
                          ),
                        ),
                      ),
                      Container(
                        width: devSysWidth * 0.29,
                        padding: EdgeInsets.all(height_10 / 2),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                "Total received",
                                style: caption_text.copyWith(
                                  color: neopopBackground,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: height_10),
                            Flexible(
                              child: Text(
                                "₹134021",
                                style: sub_headline5_text.copyWith(
                                  color: neopopBackground,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      RotatedBox(
                        quarterTurns: 1,
                        child: SizedBox(
                          width: height_16 * 8,
                          child: const Divider(
                            height: 1,
                            thickness: 1,
                            color: neopopBackground,
                          ),
                        ),
                      ),
                      Container(
                        width: devSysWidth * 0.29,
                        padding: EdgeInsets.all(height_10 / 2),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                "Overall Transaction",
                                style: caption_text.copyWith(
                                  color: neopopBackground,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: height_10),
                            Flexible(
                              child: Text(
                                "₹268042",
                                style: sub_headline5_text.copyWith(
                                  color: neopopBackground,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: height_16 * 1.5),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Account Settings",
                    style: sub_headline5_text,
                  ),
                ),
                SizedBox(height: height_16),
                ElevatedCustomTextAndIconButton(
                  buttonName: "Premium Plan",
                  iconPath: "assets/icons/svg/fluent--premium-32-regular.svg",
                  onPressed: () {
                    Get.to(
                      () => const FeatureComingUpNext(),
                    );
                  },
                ),
                ElevatedCustomTextAndIconButton(
                  buttonName: "Edit Profile",
                  iconPath: "assets/icons/svg/ic--baseline-edit.svg",
                  onPressed: () {
                    Get.to(
                      () => const FeatureComingUpNext(),
                    );
                  },
                ),
                ElevatedCustomTextAndIconButton(
                  buttonName: "Bills & Reminder",
                  iconPath: "assets/icons/svg/solar--bill-check-outline.svg",
                  onPressed: () {
                    Get.to(
                      () => const FeatureComingUpNext(),
                    );
                  },
                ),
                ElevatedCustomTextAndIconButton(
                  buttonName: "Budgeting & Tracking Expense",
                  iconPath: "assets/icons/svg/clarity--piggy-bank-line.svg",
                  onPressed: () {
                    Get.to(
                      () => const FeatureComingUpNext(),
                    );
                  },
                ),
                ElevatedCustomTextAndIconButton(
                  buttonName: "Enable Features",
                  iconPath: "assets/icons/svg/pajamas--issue-type-feature.svg",
                  onPressed: () {
                    Get.to(
                      () => const FeatureComingUpNext(),
                    );
                  },
                ),
                ElevatedCustomTextAndIconButton(
                  buttonName: "Notifications",
                  iconPath: "assets/icons/svg/solar--bell-off-broken.svg",
                  onPressed: () {
                    Get.to(
                      () => const FeatureComingUpNext(),
                    );
                  },
                ),
                ElevatedCustomTextAndIconButton(
                  buttonName: "Edit Currencies",
                  iconPath:
                      "assets/icons/svg/material-symbols--currency-rupee-circle-rounded.svg",
                  onPressed: () {
                    Get.to(
                      () => const FeatureComingUpNext(),
                    );
                  },
                ),
                ElevatedCustomTextAndIconButton(
                  buttonName: "Request a Feature",
                  iconPath: "assets/icons/svg/solar--document-add-broken.svg",
                  onPressed: () {
                    Get.to(
                      () => const FeatureComingUpNext(),
                    );
                  },
                ),
                ElevatedCustomTextAndIconButton(
                  buttonName: "Donate",
                  iconPath: "assets/icons/svg/iconoir--donate.svg",
                  onPressed: () {
                    Get.to(
                      () => const FeatureComingUpNext(),
                    );
                  },
                ),
                ElevatedCustomTextAndIconButton(
                  buttonName: "Logout",
                  iconPath: "assets/icons/svg/material-symbols--logout.svg",
                  onPressed: () {
                    Get.to(
                      () => const FeatureComingUpNext(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
