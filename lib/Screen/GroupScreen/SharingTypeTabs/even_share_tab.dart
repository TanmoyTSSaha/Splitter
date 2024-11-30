import 'package:flutter/material.dart';
import 'package:splitter/Constants/constants.dart';

import '../../../Model/group_model.dart';

class EvenShareTab extends StatefulWidget {
  final List<GroupMembersWithNameModel> groupMembersWithNameModel;
  const EvenShareTab({
    super.key,
    required this.groupMembersWithNameModel,
  });

  @override
  State<EvenShareTab> createState() => _EvenShareTabState();
}

class _EvenShareTabState extends State<EvenShareTab> {
  List<bool> checkBoxBool = [];

  @override
  Widget build(BuildContext context) {
    widget.groupMembersWithNameModel.forEach((x) {
      checkBoxBool.add(true);
    });
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: widget.groupMembersWithNameModel.length,
        itemBuilder: (context, index) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: height_16 * 2.5,
                    width: height_16 * 2.5,
                    decoration: BoxDecoration(
                      color: neopopAccent,
                      borderRadius: BorderRadius.circular(height_16 * 2.5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(height_16 * 2.5),
                      child: Image.network(
                        widget.groupMembersWithNameModel[index].userPic
                                .toString()
                                .trim()
                                .isNotEmpty
                            ? widget.groupMembersWithNameModel[index].userPic!
                            : "https://odlzzaroffbgbmiwvcqr.supabase.co/storage/v1/object/sign/splitter_bucket/user_profile_pictures/default_profile_picture_avatar.png?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJzcGxpdHRlcl9idWNrZXQvdXNlcl9wcm9maWxlX3BpY3R1cmVzL2RlZmF1bHRfcHJvZmlsZV9waWN0dXJlX2F2YXRhci5wbmciLCJpYXQiOjE3MzI5NTk1NDQsImV4cCI6MTc2NDQ5NTU0NH0.W1G8X4v_3kcqo2IMUCphY3EnOvxD077foLBfoaIOaPc&t=2024-11-30T09%3A39%3A04.548Z",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: width_10),
                  Text(
                    widget.groupMembersWithNameModel[index].userName!,
                    style:
                        sub_headline5_text.copyWith(color: neopopOnBackground),
                  ),
                ],
              ),
              Checkbox(
                activeColor: neopopAccent,
                value: checkBoxBool[index],
                onChanged: (value) {
                  setState(() {
                    checkBoxBool[index] = !checkBoxBool[index];
                  });
                },
              ),
            ],
          );
        },
        separatorBuilder: (context, index) {
          return SizedBox(height: height_10);
        },
      ),
    );
  }
}
