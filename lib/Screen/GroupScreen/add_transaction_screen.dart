import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:splitter/Constants/shared.dart';
import 'package:splitter/Screen/GroupScreen/share_distribution_screen.dart';
import 'package:splitter/Services/supabase_service.dart';

import '../../Constants/constants.dart';
import '../../Model/group_model.dart';

class AddTransactionScreen extends StatefulWidget {
  final String userID;
  final Map<String, dynamic>? groupDetails;
  final List<GroupMembersWithNameModel> groupMembersDetails;
  const AddTransactionScreen({
    required this.userID,
    this.groupDetails,
    required this.groupMembersDetails,
    super.key,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  String? selectedGroupId;
  Map<String, dynamic>? selectedValue;
  final _formKey = GlobalKey<FormState>();
  TextEditingController notesTextEditingController = TextEditingController();
  TextEditingController expenseTextEditingController = TextEditingController();
  TextEditingController descriptionTextEditingController =
      TextEditingController();

  @override
  void initState() {
    selectedGroupId =
        widget.groupDetails != null ? widget.groupDetails!["group_id"] : null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Form(
        key: _formKey,
        child: GestureDetector(
          onTap: () {
            setState(() {
              FocusManager.instance.primaryFocus!.unfocus();
            });
          },
          child: Scaffold(
            backgroundColor: neopopBackground,
            appBar: AppBar(
              primary: true,
              backgroundColor: neopopBackground,
              centerTitle: false,
              title: Text(
                "Add Transaction",
                style: sub_headline4_text,
              ),
              elevation: 0,
              actions: [
                IconButton(
                  onPressed: () {
                    // HERE WRITE THE LOGIC FOR ADD THE EXPENSE INSIDE THE SPECIFIC GROUP. AND ALSO UPDATE THE CHANGE TRACKER TABLE ONCE UPDATED.
                    Fluttertoast.showToast(
                      msg: "This feature is yet to be implemented!",
                      textColor: neopopBackground,
                      backgroundColor: neopopYellow,
                    );
                  },
                  icon: const Icon(
                    Icons.camera_alt_outlined,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // HERE WRITE THE LOGIC FOR ADD THE EXPENSE INSIDE THE SPECIFIC GROUP. AND ALSO UPDATE THE CHANGE TRACKER TABLE ONCE UPDATED.
                      Get.back();
                      Fluttertoast.showToast(
                        msg: "Split added successfully!",
                        textColor: neopopBackground,
                        backgroundColor: neopopYellow,
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.check_rounded,
                  ),
                ),
              ],
            ),
            body: FutureBuilder<List<Map<String, dynamic>>>(
              future:
                  SupabaseDatabase().getDistinctGroups(userID: widget.userID),
              builder: (context, distinctGroupSnapshot) {
                if (distinctGroupSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  // Show a loading indicator while fetching data
                  return const LoadingWidget();
                } else if (distinctGroupSnapshot.hasError) {
                  // Show an error message if the API call fails
                  return Text("Error: ${distinctGroupSnapshot.error}");
                } else if (!distinctGroupSnapshot.hasData ||
                    distinctGroupSnapshot.data!.isEmpty) {
                  // Show a message if no data is returned
                  return const Text("No data available");
                } else {
                  // Build the dropdown menu with the fetched data
                  final dropdownItems = distinctGroupSnapshot.data!;
                  return Container(
                    height: devSysHeight,
                    width: devSysWidth,
                    padding: EdgeInsets.all(height_16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButton<String>(
                          hint: const Text("Select a user"),
                          value: selectedGroupId,
                          items: dropdownItems.map((item) {
                            return DropdownMenuItem<String>(
                              value: item[
                                  'group_id'], // Use `group_id` as the unique value
                              child: Text(item['group_name'] ??
                                  'Unknown'), // Display `group_name`
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            setState(() {
                              selectedGroupId =
                                  value; // Update only the `group_id`
                            });
                          },
                        ),
                        SizedBox(height: height_16),

                        // NEED TO ADD VALIDATOR IN EACH TEXT FORM FIELD
                        CustomTextFormFieldWithPrefixIcon(
                          customTextFormFieldTextEditingController:
                              descriptionTextEditingController,
                          keyboardType: TextInputType.text,
                          hintText: "Write a description",
                          prefixIconString:
                              "assets/icons/svg/mingcute--bill-line.svg",
                          validator: (value) {
                            if (value == null) {
                              Fluttertoast.showToast(
                                msg: "Description is required!",
                                textColor: neopopBackground,
                                backgroundColor: neopopYellow,
                              );
                              return "Description is required!";
                            }

                            return null;
                          },
                        ),
                        SizedBox(height: height_16),
                        CustomTextFormFieldWithPrefixIcon(
                          customTextFormFieldTextEditingController:
                              expenseTextEditingController,
                          keyboardType: TextInputType.number,
                          hintText: "0.0",
                          prefixIconString:
                              "assets/icons/svg/material-symbols--currency-rupee-circle-rounded.svg",
                          validator: (value) {
                            if (value != null && value.isNumericOnly) {
                              return null;
                            } else if (value == null) {
                              Fluttertoast.showToast(
                                msg: "Need amount here!",
                                textColor: neopopBackground,
                                backgroundColor: neopopYellow,
                              );
                              return "Need amount here!";
                            } else if (!value.isNumericOnly) {
                              Fluttertoast.showToast(
                                msg: "Only numbers are allowed here!",
                                textColor: neopopBackground,
                                backgroundColor: neopopYellow,
                              );
                              return "Only numbers are allowed here!";
                            }

                            return null;
                          },
                        ),
                        SizedBox(height: height_16),
                        CustomBigTextFormFieldWithPrefixIcon(
                          customBigTextFormFieldTextEditingController:
                              notesTextEditingController,
                          hintText: "Write some notes...",
                          prefixIconString:
                              "assets/icons/svg/hugeicons--note.svg",
                        ),
                        SizedBox(height: height_16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: height_10 * 5,
                              width: height_10 * 5,
                              padding: EdgeInsets.all(height_10 / 2),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(
                                  color: neopopGrey,
                                  width: 2,
                                ),
                                borderRadius:
                                    BorderRadius.circular(height_16 / 4),
                              ),
                              child: SvgPicture.asset(
                                "assets/icons/svg/material-symbols--equal.svg",
                                height: 20,
                                width: 20,
                                color: neopopGrey,
                              ),
                            ),
                            SizedBox(
                              width: devSysWidth * 0.79,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Sharing mode: ",
                                        style: body2_text.copyWith(
                                          color: neopopOnBackground,
                                        ),
                                      ),
                                      SizedBox(width: width_10),
                                      NeoPopCustomTextButton(
                                        buttonName: "By Evenly",
                                        buttonTextColor: neopopOnBackground,
                                        buttonForegroundColor: neopopAccent,
                                        onPressed: () {
                                          // ignore: prefer_interpolation_to_compose_strings
                                          Get.to(
                                            () => ShareDistributionScreen(
                                              groupMembersWithNameModel:
                                                  widget.groupMembersDetails,
                                              totalAmount: isNumeric(
                                                      expenseTextEditingController
                                                          .text)
                                                  ? double.parse(
                                                      expenseTextEditingController
                                                          .text)
                                                  : 0.0,
                                            ),
                                          );
                                        },
                                        isBorder: true,
                                        borderColor: neopopOnBackground,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: height_10),
                                  Text(
                                    "Sharing among: ",
                                    style: body2_text.copyWith(
                                      color: neopopOnBackground,
                                    ),
                                  ),
                                  SizedBox(height: height_10),
                                  GridView.builder(
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 6,
                                      childAspectRatio: 1,
                                      crossAxisSpacing: height_10,
                                      mainAxisSpacing: height_10,
                                    ),
                                    itemCount:
                                        widget.groupMembersDetails.length <= 12
                                            ? widget.groupMembersDetails.length
                                            : 12,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return widget.groupMembersDetails.length >
                                              11
                                          ? index == 11
                                              ? Container(
                                                  decoration: BoxDecoration(
                                                    color: neopopOnBackground,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            height_16 * 5),
                                                  ),
                                                  child: SvgPicture.asset(
                                                    "assets/icons/svg/bi--three-dots.svg",
                                                    color: neopopBackground,
                                                    height: height_10 * 2.4,
                                                    width: height_10 * 2.4,
                                                  ),
                                                )
                                              : CircleAvatar(
                                                  backgroundColor: neopopAccent,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            height_16 * 5),
                                                    child: Image.network(
                                                      widget
                                                              .groupMembersDetails[
                                                                  index]
                                                              .userPic
                                                              .toString()
                                                              .trim()
                                                              .isNotEmpty
                                                          ? widget
                                                              .groupMembersDetails[
                                                                  index]
                                                              .userPic!
                                                          : "https://odlzzaroffbgbmiwvcqr.supabase.co/storage/v1/object/sign/splitter_bucket/user_profile_pictures/default_profile_picture_avatar.png?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJzcGxpdHRlcl9idWNrZXQvdXNlcl9wcm9maWxlX3BpY3R1cmVzL2RlZmF1bHRfcHJvZmlsZV9waWN0dXJlX2F2YXRhci5wbmciLCJpYXQiOjE3MzI5NTk1NDQsImV4cCI6MTc2NDQ5NTU0NH0.W1G8X4v_3kcqo2IMUCphY3EnOvxD077foLBfoaIOaPc&t=2024-11-30T09%3A39%3A04.548Z",
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                )
                                          : CircleAvatar(
                                              backgroundColor: neopopAccent,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        height_16 * 5),
                                                child: Image.network(
                                                  widget
                                                          .groupMembersDetails[
                                                              index]
                                                          .userPic
                                                          .toString()
                                                          .trim()
                                                          .isNotEmpty
                                                      ? widget
                                                          .groupMembersDetails[
                                                              index]
                                                          .userPic!
                                                      : "https://odlzzaroffbgbmiwvcqr.supabase.co/storage/v1/object/sign/splitter_bucket/user_profile_pictures/default_profile_picture_avatar.png?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJzcGxpdHRlcl9idWNrZXQvdXNlcl9wcm9maWxlX3BpY3R1cmVzL2RlZmF1bHRfcHJvZmlsZV9waWN0dXJlX2F2YXRhci5wbmciLCJpYXQiOjE3MzI5NTk1NDQsImV4cCI6MTc2NDQ5NTU0NH0.W1G8X4v_3kcqo2IMUCphY3EnOvxD077foLBfoaIOaPc&t=2024-11-30T09%3A39%3A04.548Z",
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
