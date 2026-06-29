import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:splitter/Constants/category_style.dart';
import 'package:splitter/Constants/constants.dart';

import 'package:splitter/Widgets/user_avatar.dart';

import '../Model/group_model.dart';

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
    final inputStyle =
        body1_text.copyWith(color: Theme.of(context).colorScheme.onSurface);
    return TextFormField(
      controller: widget.textEditingController,
      obscureText: isObscure,
      validator: widget.validator,
      style: inputStyle,
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
  final bool isBorder;
  final Color? borderColor;
  const NeoPopCustomTextButton({
    required this.buttonName,
    required this.buttonTextColor,
    required this.buttonForegroundColor,
    required this.onPressed,
    this.isBorder = false,
    this.borderColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: borderColor ?? Colors.transparent,
            width: isBorder ? 0.5 : 0,
          ),
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
  final GroupModel groupModel;
  final String userID;
  void Function()? onTap;
  GroupCard({
    required this.groupModel,
    required this.userID,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    List<GroupBalanceModel> donorList = [];
    List<GroupBalanceModel> receiverList = [];

    double totalReceived = 0;
    double totalPaid = 0;

    for (var element in groupModel.groupBalance!) {
      if (element.donorID == userID) {
        donorList.add(element);
        totalPaid += element.amount ?? 0;
      } else if (element.receiverID == userID) {
        receiverList.add(element);
        totalReceived += element.amount ?? 0;
      }
    }

    double netBalance = totalReceived - totalPaid;
    final bool isPositive = netBalance >= 0;
    final double absBalance = netBalance.abs();

    GroupBalanceModel? maxDonation;
    if (donorList.isNotEmpty) {
      for (int i = 0; i < donorList.length; i++) {
        if (i == 0) {
          maxDonation = donorList[i];
        } else if (donorList[i].amount! > maxDonation!.amount!) {
          maxDonation = donorList[i];
        }
      }
    }

    GroupBalanceModel? maxReceived;

    if (receiverList.isNotEmpty) {
      for (int i = 0; i < receiverList.length; i++) {
        if (i == 0) {
          maxReceived = receiverList[i];
        } else if (receiverList[i].amount! > maxReceived!.amount!) {
          maxReceived = receiverList[i];
        }
      }
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        width: devSysWidth,
        padding: EdgeInsets.all(height_16),
        decoration: BoxDecoration(
          border: Border.all(
            color: neopopGrey.withOpacity(0.5),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    UserAvatar(
                      userID: groupModel.groupID!,
                      userName: groupModel.groupName!,
                      radius: height_10 *
                          4, // width/height was 8 * 10 = 80. Radius = 40.
                      shape: BoxShape.rectangle,
                      customBorderRadius: BorderRadius.circular(4),
                      fontSize: 24, // Estimate for headline2_text
                    ),
                    SizedBox(width: width_16),
                    SizedBox(
                      width: devSysWidth * 0.45, // Constrain middle column
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            groupModel.groupName!,
                            style: sub_headline5_text,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          SizedBox(
                            height: height_10 / 2,
                          ),
                          if (maxDonation != null)
                            Text(
                              "${maxDonation.receiver!.split(" ")[0]} owes You ₹${maxDonation.amount!.toStringAsFixed(0)}",
                              style: caption_text.copyWith(
                                color: neopopPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          if (maxReceived != null)
                            Text(
                              "You owe ${maxReceived.donor!.split(" ")[0]} ₹${maxReceived.amount!.toStringAsFixed(0)}",
                              style: caption_text.copyWith(
                                color: neopopAccent,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          if (maxDonation == null && maxReceived == null)
                            Text(
                              "No transactions.",
                              style: caption_text.copyWith(
                                color: neopopAccent,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        absBalance < 0.01
                            ? "Settled Up"
                            : (isPositive ? "You'll pay" : "You'll get"),
                        textAlign: TextAlign.right,
                        style: body2_text.copyWith(
                          color: absBalance < 0.01
                              ? neopopGrey
                              : (isPositive ? neopopPrimary : neopopAccent),
                        ),
                      ),
                      if (absBalance >= 0.01)
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "₹${absBalance.toStringAsFixed(0)}",
                            textAlign: TextAlign.right,
                            style: headline3_text.copyWith(
                              color: isPositive ? neopopPrimary : neopopAccent,
                            ),
                          ),
                        ),
                    ],
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
  double opacity = 1.0 / currentIndex + 1;

  return color.withOpacity(opacity);
}

class TransactionCard extends StatelessWidget {
  final int index;
  final String cardTitle;
  final String cardSubTitle;
  final DateTime cardDateTime;
  final double cardPrice;
  final String categoryLogoURL;
  final String category;
  const TransactionCard({
    required this.index,
    required this.cardTitle,
    required this.cardSubTitle,
    required this.cardDateTime,
    required this.cardPrice,
    required this.categoryLogoURL,
    this.category = '',
    this.amountColor,
    this.forLightSurface = false,
    super.key,
  });

  final Color? amountColor;
  final bool forLightSurface;

  @override
  Widget build(BuildContext context) {
    final textColor =
        forLightSurface ? neopopBackground : neopopOnBackground;
    return Container(
      padding: EdgeInsets.symmetric(vertical: height_10 * 2.4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(56),
              color: neopopSecondaryGrey,
            ),
            padding: EdgeInsets.all(height_10 / 2),
            alignment: Alignment.center,
            height: height_16 * 3,
            width: width_16 * 3,
            child: buildCategoryLogo(
              categoryLogo: categoryLogoURL,
              category: category,
              color: neopopAccent,
              size: height_16 * 2,
            ),
          ),
          SizedBox(
              width: width_10 *
                  2), // Reduced padding slightly or keep same? Logic used width_10 is fine.

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cardTitle,
                  overflow: TextOverflow.ellipsis,
                  style: body1_text.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: height_10),
                Text(
                  cardSubTitle,
                  overflow: TextOverflow.ellipsis,
                  style: caption_text.copyWith(
                    color: neopopGrey,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: width_10),

          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat('HH:mm \t EEE d MMM').format(cardDateTime),
                overflow: TextOverflow.ellipsis,
                style: caption_text.copyWith(
                  color: textColor,
                ),
              ),
              SizedBox(height: height_10),
              cardPrice != 0
                  ? Text(
                      "₹$cardPrice",
                      overflow: TextOverflow.ellipsis,
                      style: body1_text.copyWith(
                        color: amountColor ?? neopopAccent,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  : Text(
                      "You're not in",
                      overflow: TextOverflow.ellipsis,
                      style: caption_text.copyWith(
                        color: neopopAccent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}

enum DurationLabel {
  daily('Daily', 0),
  weekly('Weekly', 1),
  monthly('Monthly', 2),
  yearly('Yearly', 3);

  const DurationLabel(this.label, this.idx);
  final String label;
  final int idx;
}

class ElevatedCustomTextAndIconButton extends StatelessWidget {
  final String iconPath;
  final String buttonName;
  final Color buttonBackgroundColor;
  final Color buttonForegroundColor;
  void Function()? onPressed;
  ElevatedCustomTextAndIconButton({
    required this.iconPath,
    required this.buttonName,
    this.buttonBackgroundColor = neopopAccent,
    this.buttonForegroundColor = neopopOnPrimary,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        padding: EdgeInsets.symmetric(
          vertical: height_16,
          horizontal: height_16,
        ),
        backgroundColor: buttonBackgroundColor,
        foregroundColor: buttonForegroundColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            iconPath,
            height: height_10 * 2.4,
            width: height_10 * 2.4,
            color: neopopBackground,
          ),
          SizedBox(width: width_16),
          Text(
            buttonName,
            style: button_text.copyWith(
              color: neopopBackground,
            ),
          ),
        ],
      ),
    );
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: height_16 * 7,
        width: height_16 * 7,
        padding: EdgeInsets.all(height_16 * 1.5),
        decoration: BoxDecoration(
          color: neopopOnPrimary,
          borderRadius: BorderRadius.circular(height_16 / 2),
        ),
        alignment: Alignment.center,
        child: LoadingAnimationWidget.staggeredDotsWave(
          color: neopopAccent,
          size: height_16 * 3.5,
        ),
      ),
    );
  }
}

class ImageLoadingWidget extends StatelessWidget {
  final double loaderRadius;
  const ImageLoadingWidget({
    required this.loaderRadius,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: loaderRadius,
        width: loaderRadius,
        padding: EdgeInsets.all(loaderRadius - (loaderRadius * 0.75)),
        decoration: BoxDecoration(
          color: neopopSecondaryGrey,
          borderRadius: BorderRadius.circular(loaderRadius),
        ),
        alignment: Alignment.center,
        child: LoadingAnimationWidget.waveDots(
          color: neopopAccent,
          size: loaderRadius * 0.75,
        ),
      ),
    );
  }
}

class SuccessWidget extends StatelessWidget {
  const SuccessWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: height_16 * 7,
        width: height_16 * 7,
        padding: EdgeInsets.all(height_16 * 1.5),
        decoration: BoxDecoration(
          color: neopopOnPrimary,
          borderRadius: BorderRadius.circular(height_16 / 2),
        ),
        alignment: Alignment.center,
        child: LoadingAnimationWidget.inkDrop(
          color: neopopAccent,
          size: height_16 * 3.5,
        ),
      ),
    );
  }
}

class CustomSecondaryButton extends StatelessWidget {
  final String buttonText;
  void Function()? onPressed;
  double buttonHeight;
  double buttonWidth;
  CustomSecondaryButton({
    required this.buttonText,
    required this.onPressed,
    this.buttonHeight = 16 * 3,
    this.buttonWidth = 16 * 8,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: neopopBackground,
        minimumSize: Size(buttonWidth, buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
      ),
      child: Text(
        buttonText,
        style: button_text.copyWith(
          color: neopopOnBackground,
        ),
      ),
    );
  }
}

class CustomPrimaryButton extends StatelessWidget {
  final String buttonText;
  final void Function()? onPressed;
  final double buttonHeight;
  final double buttonWidth;

  const CustomPrimaryButton({
    required this.buttonText,
    required this.onPressed,
    this.buttonHeight = 16 * 3,
    this.buttonWidth = 16 * 8,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: neopopAccent,
        minimumSize: Size(buttonWidth, buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
      ),
      child: Text(
        buttonText,
        style: button_text.copyWith(
          color: neopopOnPrimary,
        ),
      ),
    );
  }
}

class CustomTextFormFieldWithPrefixIcon extends StatelessWidget {
  final TextEditingController customTextFormFieldTextEditingController;
  final String prefixIconString;
  final String hintText;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  const CustomTextFormFieldWithPrefixIcon({
    super.key,
    required this.customTextFormFieldTextEditingController,
    required this.prefixIconString,
    required this.hintText,
    required this.validator,
    required this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final inputStyle =
        sub_headline5_text.copyWith(color: Theme.of(context).colorScheme.onSurface);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
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
            borderRadius: BorderRadius.circular(height_16 / 4),
          ),
          child: SvgPicture.asset(
            prefixIconString,
            height: 20,
            width: 20,
            color: neopopGrey,
          ),
        ),
        SizedBox(
          width: devSysWidth * 0.79,
          height: height_10 * 5.25,
          child: TextFormField(
            obscureText: false,
            controller: customTextFormFieldTextEditingController,
            validator: validator,
            keyboardType: keyboardType,
            style: inputStyle,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(height_16 / 4),
                borderSide: const BorderSide(
                  color: neopopGrey,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(height_16 / 4),
                borderSide: const BorderSide(
                  color: neopopGrey,
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(height_16 / 4),
                borderSide: const BorderSide(
                  color: neopopGrey,
                  width: 1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(height_16 / 4),
                borderSide: const BorderSide(
                  color: neopopError,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(height_16 / 4),
                borderSide: const BorderSide(
                  color: neopopError,
                  width: 2,
                ),
              ),
              errorStyle: const TextStyle(
                fontSize: 0,
              ),
              hintText: hintText,
              hintStyle: sub_headline5_text.copyWith(
                color: neopopGrey,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CustomBigTextFormFieldWithPrefixIcon extends StatelessWidget {
  final TextEditingController customBigTextFormFieldTextEditingController;
  final String prefixIconString;
  final String hintText;
  final TextStyle? style;

  const CustomBigTextFormFieldWithPrefixIcon({
    super.key,
    required this.customBigTextFormFieldTextEditingController,
    required this.prefixIconString,
    required this.hintText,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final inputStyle = style ??
        sub_headline5_text.copyWith(color: Theme.of(context).colorScheme.onSurface);
    return Row(
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
            borderRadius: BorderRadius.circular(height_16 / 4),
          ),
          child: SvgPicture.asset(
            prefixIconString,
            height: 20,
            width: 20,
            color: neopopGrey,
          ),
        ),
        SizedBox(
          width: devSysWidth * 0.79,
          height: devSysHeight * 0.175,
          child: TextFormField(
            obscureText: false,
            maxLines: 5,
            controller: customBigTextFormFieldTextEditingController,
            style: inputStyle,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(height_16 / 4),
                borderSide: const BorderSide(
                  color: neopopGrey,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(height_16 / 4),
                borderSide: const BorderSide(
                  color: neopopGrey,
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(height_16 / 4),
                borderSide: const BorderSide(
                  color: neopopGrey,
                  width: 1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(height_16 / 4),
                borderSide: const BorderSide(
                  color: neopopError,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(height_16 / 4),
                borderSide: const BorderSide(
                  color: neopopError,
                  width: 2,
                ),
              ),
              hintText: hintText,
              hintStyle: sub_headline5_text.copyWith(
                color: neopopGrey,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

bool isNumeric(String str) {
  return double.tryParse(str) != null;
}

class ExtraSmallTextFormField extends StatelessWidget {
  final TextEditingController extraSmallTextFieldTextEditingController;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final void Function(String)? onChanged;
  const ExtraSmallTextFormField({
    super.key,
    required this.extraSmallTextFieldTextEditingController,
    required this.keyboardType,
    required this.validator,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final inputStyle =
        sub_headline5_text.copyWith(color: Theme.of(context).colorScheme.onSurface);
    return SizedBox(
      height: height_10 * 5,
      width: height_16 * 5,
      child: TextFormField(
        obscureText: false,
        // onEditingComplete: onEditingComplete,
        onChanged: onChanged,
        controller: extraSmallTextFieldTextEditingController,
        validator: validator,
        keyboardType: keyboardType,
        style: inputStyle,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(height_16 / 4),
            borderSide: const BorderSide(
              color: neopopGrey,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(height_16 / 4),
            borderSide: const BorderSide(
              color: neopopGrey,
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(height_16 / 4),
            borderSide: const BorderSide(
              color: neopopGrey,
              width: 1,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(height_16 / 4),
            borderSide: const BorderSide(
              color: neopopError,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(height_16 / 4),
            borderSide: const BorderSide(
              color: neopopError,
              width: 2,
            ),
          ),
          errorStyle: const TextStyle(
            fontSize: 0,
          ),
          hintText: "₹0.00",
          hintStyle: sub_headline5_text.copyWith(
            color: neopopGrey,
          ),
        ),
      ),
    );
  }
}
