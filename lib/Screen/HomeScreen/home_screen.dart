import 'package:avatar_stack/avatar_stack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:splitter/Constants/constants.dart';

import '../../Constants/shared.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> expenseHistoryStrings = [
    "Flight Confirmation",
    "Hotel Reservation",
    "Activity Planning",
    "Packing List",
    "Travel Insurance",
    "Resort Booking",
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
              child: Image.network(
                "https://fiverr-res.cloudinary.com/images/t_main1,q_auto,f_auto,q_auto,f_auto/gigs/152776829/original/a563057b8f0884f5325a5ffa3c180a5f2eb72b7b/design-an-anime-style-avatar.png",
                fit: BoxFit.cover,
              ),
            ),
          ),
          elevation: 0,
          title: RichText(
            text: TextSpan(
              text: "Hi Klaudia\n",
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
          child: Container(
            width: Get.width,
            padding: const EdgeInsets.symmetric(
              vertical: 24,
              horizontal: 16,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // CARD UI CODE
                Container(
                  width: Get.width,
                  color: neopopAccent,
                  padding: EdgeInsets.symmetric(vertical: height_16),
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
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ClipRRect(
                            //   borderRadius: BorderRadius.circular(56),
                            //   child: Container(
                            //     height: height_10 * 3.6,
                            //     width: height_10 * 3.6,
                            //     color: neopopOnBackground,
                            //     child: SvgPicture.asset(
                            //       "assets/dev_images/undraw_traveling_yhxq.svg",
                            //       height: height_10 * 3.6,
                            //       width: height_10 * 3.6,
                            //       fit: BoxFit.contain,
                            //     ),
                            //   ),
                            // ),
                            // SizedBox(width: height_10 * 1.2),
                            Text(
                              "Trip to Paris",
                              style: headline3_text.copyWith(
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
                          bottom: height_16,
                          right: width_16,
                          left: width_16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: (Get.width - 70) / 2,
                              child: RichText(
                                text: TextSpan(
                                  text: "Total\n",
                                  style: body2_text.copyWith(
                                    color: neopopBackground,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "₹3800",
                                      style: headline2_text.copyWith(
                                        color: neopopBackground,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              width: (Get.width - 70) / 2,
                              child: RichText(
                                textAlign: TextAlign.right,
                                text: TextSpan(
                                  text: "To Collect\n",
                                  style: body2_text.copyWith(
                                    color: neopopBackground,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "₹900",
                                      style: headline2_text.copyWith(
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
                      const Divider(
                        color: neopopBackground,
                        height: 1,
                        thickness: 2,
                      ),
                      Padding(
                        padding: EdgeInsets.all(height_16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Split To",
                              style: caption_text.copyWith(
                                color: neopopBackground,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                AvatarStack(
                                  height: 36,
                                  width: width_10 * 15,
                                  avatars: [
                                    for (int n = 0; n < 5; n++)
                                      NetworkImage(
                                          "https://placedog.net/50$n/50$n")
                                  ],
                                ),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: neopopBackground,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                  ),
                                  child: Text(
                                    "View Split",
                                    style: button_text.copyWith(
                                      color: neopopOnBackground,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // const Divider(
                      //   color: neopopBackground,
                      //   height: 1,
                      //   thickness: 2,
                      // ),
                      // Padding(
                      //   padding: EdgeInsets.only(
                      //     top: height_16,
                      //     right: height_16,
                      //     left: height_16,
                      //   ),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     crossAxisAlignment: CrossAxisAlignment.center,
                      //     children: [
                      //       Container(
                      //         height: height_16 * 6,
                      //         width: devSysWidth * 0.4,
                      //         padding: EdgeInsets.all(width_16),
                      //         decoration: const BoxDecoration(
                      //           color: neopopYellow,
                      //         ),
                      //         child: Row(
                      //           mainAxisAlignment: MainAxisAlignment.start,
                      //           crossAxisAlignment: CrossAxisAlignment.center,
                      //           children: [
                      //             SizedBox(
                      //               height: height_16 * 2.5,
                      //               width: width_16 * 2.5,
                      //               child: CircularProgressIndicator(
                      //                 color: neopopBackground,
                      //                 backgroundColor:
                      //                     neopopBackground.withOpacity(0.3),
                      //                 value: 0.3,
                      //                 strokeWidth: 7,
                      //                 strokeCap: StrokeCap.round,
                      //               ),
                      //             ),
                      //             SizedBox(width: width_10),
                      //             Column(
                      //               mainAxisAlignment: MainAxisAlignment.center,
                      //               crossAxisAlignment:
                      //                   CrossAxisAlignment.start,
                      //               children: [
                      //                 Text(
                      //                   "Today",
                      //                   style: sub_headline5_text.copyWith(
                      //                     color: neopopBackground,
                      //                   ),
                      //                 ),
                      //                 Text(
                      //                   "₹120",
                      //                   style: headline3_text.copyWith(
                      //                     color: neopopBackground,
                      //                   ),
                      //                 ),
                      //               ],
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //       Container(
                      //         height: height_16 * 6,
                      //         width: devSysWidth * 0.4,
                      //         padding: EdgeInsets.all(width_16),
                      //         decoration: const BoxDecoration(
                      //           color: neopopYellow,
                      //         ),
                      //         child: Row(
                      //           mainAxisAlignment: MainAxisAlignment.start,
                      //           crossAxisAlignment: CrossAxisAlignment.center,
                      //           children: [
                      //             SizedBox(
                      //               height: height_16 * 2.5,
                      //               width: width_16 * 2.5,
                      //               child: CircularProgressIndicator(
                      //                 color: neopopBackground,
                      //                 backgroundColor:
                      //                     neopopBackground.withOpacity(0.3),
                      //                 value: 0.3,
                      //                 strokeWidth: 7,
                      //                 strokeCap: StrokeCap.round,
                      //               ),
                      //             ),
                      //             SizedBox(width: width_10),
                      //             Column(
                      //               mainAxisAlignment: MainAxisAlignment.center,
                      //               crossAxisAlignment:
                      //                   CrossAxisAlignment.start,
                      //               children: [
                      //                 Text(
                      //                   DateFormat.MMM()
                      //                       .format(DateTime.now())
                      //                       .toString(),
                      //                   style: sub_headline5_text.copyWith(
                      //                     color: neopopBackground,
                      //                   ),
                      //                 ),
                      //                 Text(
                      //                   "₹1200",
                      //                   style: headline3_text.copyWith(
                      //                     color: neopopBackground,
                      //                   ),
                      //                 ),
                      //               ],
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ),
                // EXPENSE HISTORY UI
                SizedBox(height: height_16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Expense History",
                      style: sub_headline4_text.copyWith(
                        color: neopopOnBackground,
                      ),
                    ),
                    NeoPopCustomTextButton(
                      buttonName: "View all",
                      buttonForegroundColor: neopopAccent,
                      buttonTextColor: neopopOnBackground,
                      onPressed: () {},
                    ),
                  ],
                ),
                SizedBox(height: height_16),
                Container(
                  width: Get.width,
                  padding: EdgeInsets.symmetric(horizontal: height_16),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: neopopGrey.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 6,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      return TransactionCard(
                        index: index,
                        cardTitle: expenseHistoryStrings[index % 6],
                        cardSubTitle: "Trip to Paris - Paid by Rini",
                        cardDateTime: DateTime.now(),
                        cardPrice: 600,
                      );
                    },
                    separatorBuilder: (context, index) => Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: height_10, vertical: 0),
                      child: const Divider(
                        height: 1,
                        thickness: 2,
                        color: neopopSecondaryGrey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
