import 'package:flutter/material.dart';
import 'package:splitter/Constants/constants.dart';

import '../../Constants/shared.dart';

class SettleUpTab extends StatefulWidget {
  const SettleUpTab({super.key});

  @override
  State<SettleUpTab> createState() => _SettleUpTabState();
}

class _SettleUpTabState extends State<SettleUpTab> {
  List<Map<String, dynamic>> cardDetails = [
    {
      "name": "Deepesh Tyagi",
      "image":
          "https://fiverr-res.cloudinary.com/images/t_main1,q_auto,f_auto,q_auto,f_auto/gigs/152776829/original/a563057b8f0884f5325a5ffa3c180a5f2eb72b7b/design-an-anime-style-avatar.png",
      "share": 1453.00,
      "sharePercentage": 0.6
    },
    {
      "name": "Durgesh Kumar Singh",
      "image":
          "https://fiverr-res.cloudinary.com/images/t_main1,q_auto,f_auto,q_auto,f_auto/gigs/152776829/original/a563057b8f0884f5325a5ffa3c180a5f2eb72b7b/design-an-anime-style-avatar.png",
      "share": 484.00,
      "sharePercentage": 0.2
    },
    {
      "name": "Hardik Pal",
      "image":
          "https://fiverr-res.cloudinary.com/images/t_main1,q_auto,f_auto,q_auto,f_auto/gigs/152776829/original/a563057b8f0884f5325a5ffa3c180a5f2eb72b7b/design-an-anime-style-avatar.png",
      "share": 484.00,
      "sharePercentage": 0.2
    },
  ];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          width: devSysWidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Select a balance to settle!",
                style: sub_headline4_text,
              ),
              SizedBox(height: height_16),
              SizedBox(
                width: devSysWidth,
                child: ListView.separated(
                  itemCount: cardDetails.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) => SettleUpBalanceWidget(
                    slNo: index + 1,
                    balanceHolderName: cardDetails[index]["name"],
                    balanceHolderImage: cardDetails[index]["image"],
                    sharePercentage: cardDetails[index]["sharePercentage"],
                    totalShare: cardDetails[index]["share"],
                  ),
                  separatorBuilder: (context, index) =>
                      SizedBox(height: height_10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
