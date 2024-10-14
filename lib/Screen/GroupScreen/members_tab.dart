import 'package:flutter/material.dart';
import 'package:splitter/Constants/constants.dart';

class MembersTab extends StatelessWidget {
  const MembersTab({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> membersDetails = [
      {
        "name": "Tanmoy Saha (You)",
        "imageURL":
            "https://fiverr-res.cloudinary.com/images/t_main1,q_auto,f_auto,q_auto,f_auto/gigs/152776829/original/a563057b8f0884f5325a5ffa3c180a5f2eb72b7b/design-an-anime-style-avatar.png",
      },
      {
        "name": "Deepesh Tyagi",
        "imageURL":
            "https://fiverr-res.cloudinary.com/images/t_main1,q_auto,f_auto,q_auto,f_auto/gigs/152776829/original/a563057b8f0884f5325a5ffa3c180a5f2eb72b7b/design-an-anime-style-avatar.png",
      },
      {
        "name": "Durgesh Kumar Singh",
        "imageURL":
            "https://fiverr-res.cloudinary.com/images/t_main1,q_auto,f_auto,q_auto,f_auto/gigs/152776829/original/a563057b8f0884f5325a5ffa3c180a5f2eb72b7b/design-an-anime-style-avatar.png",
      },
      {
        "name": "Hardik Pal",
        "imageURL":
            "https://fiverr-res.cloudinary.com/images/t_main1,q_auto,f_auto,q_auto,f_auto/gigs/152776829/original/a563057b8f0884f5325a5ffa3c180a5f2eb72b7b/design-an-anime-style-avatar.png",
      },
    ];
    return SafeArea(
      child: Container(
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1,
            crossAxisSpacing: height_16,
            mainAxisSpacing: height_16,
          ),
          itemCount: membersDetails.length,
          itemBuilder: (context, index) => Stack(
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
                    membersDetails[index]["imageURL"],
                    // height: devSysWidth * 0.2,
                    // width: devSysWidth * 0.2,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(height_16 / 2),
                alignment: index % 4 == 1
                    ? Alignment.bottomLeft
                    : index % 4 == 2
                        ? Alignment.topRight
                        : index % 4 == 3
                            ? Alignment.topLeft
                            : Alignment.bottomRight,
                width: devSysWidth * 0.35,
                child: Text(
                  membersDetails[index]["name"],
                  style: caption_text,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
