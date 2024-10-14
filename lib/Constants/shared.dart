import 'dart:math';
import 'package:flutter/material.dart';
import 'package:splitter/Constants/constants.dart';

Color getRandomBrightColor() {
  Random random = Random();

  // Generate high RGB values to create a bright color
  int red = random.nextInt(156) + 100; // Values between 100-255
  int green = random.nextInt(156) + 100;
  int blue = random.nextInt(156) + 100;

  return Color.fromARGB(255, red, green, blue);
}

class PrimaryTextFormField extends StatefulWidget {
  final TextEditingController textEditingController;
  final String fieldName;
  final bool isObscure;
  final String? Function(String?)? validator;
  final Color labelColor;
  final TextStyle errorTextStyle;
  const PrimaryTextFormField({
    super.key,
    required this.textEditingController,
    required this.fieldName,
    required this.isObscure,
    required this.validator,
    this.labelColor = const Color(0xFF91919F),
    this.errorTextStyle = const TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 12,
    ),
  });

  @override
  State<PrimaryTextFormField> createState() => _PrimaryTextFormFieldState();
}

class _PrimaryTextFormFieldState extends State<PrimaryTextFormField> {
  bool isObscure = false;

  @override
  void initState() {
    super.initState();
    isObscure = widget.isObscure;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.textEditingController,
      obscureText: isObscure,
      validator: widget.validator,
      decoration: InputDecoration(
        filled: true,
        fillColor: neopopSecondaryGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(0),
          borderSide: const BorderSide(
            width: 1,
            color: neopopSecondaryGrey,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(0),
          borderSide: const BorderSide(
            width: 1,
            color: neopopSecondaryGrey,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(0),
          borderSide: const BorderSide(
            width: 1,
            color: neopopSecondaryGrey,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(0),
          borderSide: const BorderSide(
            width: 1,
            color: neopopSecondaryGrey,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(0),
          borderSide: const BorderSide(
            width: 1,
            color: neopopError,
          ),
        ),
        labelText: widget.fieldName,
        labelStyle: body2_text.copyWith(
          color: widget.labelColor,
        ),
        errorStyle: widget.errorTextStyle,
        suffixIcon: widget.isObscure
            ? IconButton(
                onPressed: () {
                  setState(() {
                    isObscure = !isObscure;
                  });
                },
                icon: const Icon(
                  Icons.visibility_outlined,
                  color: neopopOnBackground,
                  size: 24,
                ),
              )
            : const SizedBox(
                height: 0,
                width: 0,
              ),
      ),
    );
  }
}

class NeoPopCustomTextButton extends StatelessWidget {
  final String buttonName;
  final Color buttonTextColor;
  final Color buttonForegroundColor;
  final Function()? onPressed;
  const NeoPopCustomTextButton({
    required this.buttonName,
    required this.buttonTextColor,
    required this.buttonForegroundColor,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
        foregroundColor: buttonForegroundColor,
      ),
      child: Text(
        buttonName,
        style: body2_text.copyWith(
          color: buttonTextColor,
        ),
      ),
    );
  }
}

class GroupCard extends StatelessWidget {
  final String groupName;
  void Function()? onTap;
  GroupCard({
    required this.groupName,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: devSysWidth,
        padding: EdgeInsets.all(height_16),
        decoration: BoxDecoration(
          border: Border.all(color: neopopGrey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: height_10 * 8,
                  height: height_10 * 8,
                  decoration: BoxDecoration(
                    color: getRandomBrightColor(),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(width_16 / 2),
                  child: Text(
                    getInitials(groupName),
                    style: headline2_text.copyWith(
                      color: neopopBackground,
                    ),
                  ),
                ),
                SizedBox(
                  width: width_16,
                ),
                SizedBox(
                  width: width_10 * 20,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        groupName,
                        style: sub_headline5_text,
                      ),
                      SizedBox(
                        height: height_10 / 2,
                      ),
                      Text(
                        "You owe Ramesh ₹300",
                        style: caption_text.copyWith(
                          color: neopopPrimary,
                        ),
                      ),
                      Text(
                        "Shudhanshu owe's you ₹500",
                        style: caption_text.copyWith(
                          color: neopopAccent,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: width_10 * 7.5,
                  child: RichText(
                    textAlign: TextAlign.right,
                    text: TextSpan(
                      text: "You'll get\n",
                      style: body2_text.copyWith(
                        color: neopopAccent,
                      ),
                      children: [
                        TextSpan(
                          text: "₹200\n",
                          style: headline3_text.copyWith(
                            color: neopopAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

String getInitials(String name) {
  List<String> names = name.split(" ");
  String initials = "";

  for (var element in names) {
    initials = initials + element.substring(0, 1);
  }

  return initials.toUpperCase();
}

class SettleUpBalanceWidget extends StatelessWidget {
  final int slNo;
  final String balanceHolderName;
  final double totalShare;
  final double sharePercentage;
  final String balanceHolderImage;
  const SettleUpBalanceWidget({
    required this.slNo,
    required this.balanceHolderName,
    required this.totalShare,
    required this.sharePercentage,
    required this.balanceHolderImage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: devSysWidth,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            slNo.toString(),
            style: headline1_text,
          ),
          SizedBox(width: width_10),
          Container(
            height: height_16 * 4,
            width: height_16 * 4,
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
                balanceHolderImage,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: width_10),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: devSysWidth * 0.4,
                child: Text(
                  balanceHolderName,
                  style: body1_text,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: height_10),
              SizedBox(
                width: devSysWidth * 0.4,
                child: LinearProgressIndicator(
                  value: sharePercentage,
                  color: neopopAccent,
                  backgroundColor: neopopAccent.withOpacity(0.25),
                  minHeight: 5,
                  borderRadius: BorderRadius.circular(height_10),
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "₹$totalShare",
                style: sub_headline4_text,
              )
            ],
          ),
        ],
      ),
    );
  }
}

Color getColorOpacity(Color color, int currentIndex, int totalIndex) {
  double opacity = 1.0 - (currentIndex / (totalIndex - 1));

  return color.withOpacity(opacity);
}
