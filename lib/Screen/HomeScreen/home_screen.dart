import 'package:avatar_stack/avatar_stack.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Model/user_details_model.dart';
import 'package:splitter/Services/supabase_service.dart';

import '../../Constants/shared.dart';
import '../../Model/personal_transaction_model.dart';

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
      child: FutureBuilder<UserDetails>(
          future: SupabaseDatabase().getCurrentUserProfile(
              userID: SupabaseAuth().supabaseGetUserID()),
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
                  child: Container(
                    width: Get.width,
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 16,
                    ),
                    child: FutureBuilder<
                        List<PersonalTransactionWithProductCategoryModel>>(
                      future: SupabaseDatabase().getHomePhaseExpenseHistory(
                          userID: SupabaseAuth().supabaseGetUserID()),
                      builder: (context, trnsDataSnapshot) {
                        if (trnsDataSnapshot.hasData) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // CARD UI CODE
                              Container(
                                width: Get.width,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                                    style:
                                                        headline2_text.copyWith(
                                                      color: neopopBackground,
                                                      fontWeight:
                                                          FontWeight.w600,
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
                                                    style:
                                                        headline2_text.copyWith(
                                                      color: neopopBackground,
                                                      fontWeight:
                                                          FontWeight.w600,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Split To",
                                            style: caption_text.copyWith(
                                              color: neopopBackground,
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
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
                                              CustomSecondaryButton(
                                                buttonText: "View split",
                                                onPressed: () {
                                                  SupabaseDatabase()
                                                      .getHomePhaseExpenseHistory(
                                                    userID: SupabaseAuth()
                                                        .supabaseGetUserID(),
                                                  );
                                                },
                                                buttonHeight: height_16 * 3,
                                                buttonWidth: height_16 * 8,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // EXPENSE HISTORY UI
                              SizedBox(height: height_16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                padding:
                                    EdgeInsets.symmetric(horizontal: height_16),
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
                                  itemCount: trnsDataSnapshot.data!.length,
                                  padding: EdgeInsets.zero,
                                  itemBuilder: (context, index) {
                                    return TransactionCard(
                                      index: index,
                                      cardTitle: trnsDataSnapshot
                                          .data![index].transactionDescription!,
                                      cardSubTitle: trnsDataSnapshot
                                          .data![index].category!,
                                      cardDateTime: trnsDataSnapshot
                                          .data![index].transactionDate!,
                                      cardPrice:
                                          trnsDataSnapshot.data![index].amount!,
                                      categoryLogoURL: trnsDataSnapshot
                                              .data![index]
                                              .masterCategoryModel!
                                              .categoryLogo ??
                                          "",
                                    );
                                  },
                                  separatorBuilder: (context, index) => Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: height_10,
                                      vertical: 0,
                                    ),
                                    child: const Divider(
                                      height: 1,
                                      thickness: 2,
                                      color: neopopSecondaryGrey,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else if (trnsDataSnapshot.hasError) {
                          return Container(
                            height: devSysHeight,
                            width: devSysWidth,
                            decoration: const BoxDecoration(
                              color: neopopBackground,
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
          }),
    );
  }
}
