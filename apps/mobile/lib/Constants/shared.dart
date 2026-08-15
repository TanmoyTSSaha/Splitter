import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:splitr/Utils/currency_utils.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:splitr/Constants/app_dimensions.dart';
import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/app_palette.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/category_style.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Utils/transaction_date_formatter.dart';

import 'package:splitr/Widgets/bordered_input_field.dart';
import 'package:splitr/Widgets/user_avatar.dart';

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
    this.labelColor = AppPalette.labelMuted,
    this.errorTextStyle = const TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: splitrFontCaption,
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
    final borderColor = groupMutedBorderHairline;
    final mutedFill = groupMutedFillFaint;
    final inputStyle = body1_text.copyWith(color: groupOnSurface);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.fieldName.isNotEmpty) ...[
          Text(
            widget.fieldName,
            style: body2_text.copyWith(
              color: widget.labelColor == AppPalette.labelMuted
                  ? groupOnSurfaceMuted
                  : widget.labelColor,
            ),
          ),
          const SizedBox(height: groupGapSm),
        ],
        Container(
          decoration: BoxDecoration(
            color: mutedFill,
            borderRadius: BorderRadius.circular(groupControlRadius),
            border: Border.all(color: borderColor),
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: groupGap14, vertical: groupGapXxs),
          child: TextFormField(
            controller: widget.textEditingController,
            obscureText: isObscure,
            validator: widget.validator,
            style: inputStyle,
            decoration: InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: groupGap10),
              errorStyle: widget.errorTextStyle,
              suffixIcon: widget.isObscure
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          isObscure = !isObscure;
                        });
                      },
                      icon: Icon(
                        isObscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: groupOnSurfaceMuted,
                        size: AppDimensions.loadingIndicatorMd,
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ],
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
            color: borderColor ?? groupTransparent,
            width: isBorder ? AppDimensions.borderWidthHalf : groupGapNone,
          ),
          borderRadius: BorderRadius.zero,
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
        padding: const EdgeInsets.all(groupGutter),
        decoration: BoxDecoration(
          border: Border.all(
            color: neopopGreyIconMuted,
          ),
          borderRadius: BorderRadius.circular(groupControlRadiusSm),
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
                      radius: AppDimensions.loadingIndicatorLg,
                      shape: BoxShape.rectangle,
                      customBorderRadius: BorderRadius.circular(groupRadiusSm),
                      fontSize:
                          splitrFontHeadline3, // Estimate for headline2_text
                    ),
                    const SizedBox(width: groupGutter),
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
                          const SizedBox(
                            height: groupGap5,
                          ),
                          if (maxDonation != null)
                            Text(
                              AppStringFormat.owesYou(
                                maxDonation.receiver!.split(" ")[0],
                                '${userCurrencySymbol()}${maxDonation.amount!.toStringAsFixed(0)}',
                              ),
                              style: caption_text.copyWith(
                                color: neopopPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          if (maxReceived != null)
                            Text(
                              AppStringFormat.youOwe(
                                maxReceived.donor!.split(" ")[0],
                                '${userCurrencySymbol()}${maxReceived.amount!.toStringAsFixed(0)}',
                              ),
                              style: caption_text.copyWith(
                                color: neopopAccent,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          if (maxDonation == null && maxReceived == null)
                            Text(
                              AppStrings.settle.noTransactions,
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
                            ? AppStrings.settle.settledUp
                            : (isPositive
                                ? AppStrings.settle.youllPay
                                : AppStrings.settle.youllGet),
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
                            "${userCurrencySymbol()}${absBalance.toStringAsFixed(0)}",
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
          const SizedBox(width: groupGap10),
          Container(
            height: groupGutter * 4,
            width: groupGutter * 4,
            margin: const EdgeInsets.only(left: groupGutter),
            decoration: BoxDecoration(
              border: Border.all(
                color: groupTransparent,
                width: groupGapXs,
              ),
              borderRadius:
                  BorderRadius.circular(AppDimensions.biometricIconSize),
            ),
            padding: const EdgeInsets.all(groupRadiusHairline),
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(AppDimensions.loadingIndicatorLg),
              child: CachedNetworkImage(
                imageUrl: balanceHolderImage,
                fit: BoxFit.cover,
                memCacheWidth: (groupGutter * 4 *
                        MediaQuery.devicePixelRatioOf(context))
                    .round(),
              ),
            ),
          ),
          const SizedBox(width: groupGap10),
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
              const SizedBox(height: groupGap10),
              SizedBox(
                width: devSysWidth * 0.4,
                child: LinearProgressIndicator(
                  value: sharePercentage,
                  color: neopopAccent,
                  backgroundColor: neopopAccentBorderHairline,
                  minHeight: groupGap5,
                  borderRadius: BorderRadius.circular(groupRadiusMd),
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
                "${userCurrencySymbol()}$totalShare",
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
    final textColor = forLightSurface ? neopopBackground : neopopOnBackground;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: groupGapLg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(groupRadiusFull),
              color: neopopSecondaryGrey,
            ),
            padding: const EdgeInsets.all(groupGap5),
            alignment: Alignment.center,
            height: groupCtaHeightCompact,
            width: groupCtaHeightCompact,
            child: buildCategoryLogo(
              categoryLogo: categoryLogoURL,
              category: category,
              color: neopopAccent,
              size: groupGapXl,
            ),
          ),
          const SizedBox(width: AppDimensions.groupIconMd),
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
                const SizedBox(height: groupGap10),
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
          const SizedBox(width: groupGap10),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                TransactionDateFormatter.formatTime(cardDateTime),
                overflow: TextOverflow.ellipsis,
                style: caption_text.copyWith(
                  color: textColor,
                ),
              ),
              const SizedBox(height: groupGap10),
              cardPrice != 0
                  ? Text(
                      "${userCurrencySymbol()}$cardPrice",
                      overflow: TextOverflow.ellipsis,
                      style: body1_text.copyWith(
                        color: amountColor ?? neopopAccent,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  : Text(
                      AppStrings.settle.notInTransaction,
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
        padding: const EdgeInsets.symmetric(
          vertical: groupGutter,
          horizontal: groupGutter,
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
            height: groupGapLg,
            width: groupGapLg,
            color: neopopBackground,
          ),
          const SizedBox(width: groupGutter),
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
        height: groupGutter * 7,
        width: groupGutter * 7,
        padding: const EdgeInsets.all(groupGapLg),
        decoration: BoxDecoration(
          color: neopopOnPrimary,
          borderRadius: BorderRadius.circular(groupGapSm),
        ),
        alignment: Alignment.center,
        child: LoadingAnimationWidget.staggeredDotsWave(
          color: neopopAccent,
          size: groupCtaHeight,
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
        height: groupGutter * 7,
        width: groupGutter * 7,
        padding: const EdgeInsets.all(groupGapLg),
        decoration: BoxDecoration(
          color: neopopOnPrimary,
          borderRadius: BorderRadius.circular(groupGapSm),
        ),
        alignment: Alignment.center,
        child: LoadingAnimationWidget.inkDrop(
          color: neopopAccent,
          size: groupCtaHeight,
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
    this.buttonHeight = groupCtaHeightCompact,
    this.buttonWidth = groupGutter * 8,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: neopopBackground,
        minimumSize: Size(buttonWidth, buttonHeight),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
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
    this.buttonHeight = groupCtaHeightCompact,
    this.buttonWidth = groupGutter * 8,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: neopopAccent,
        minimumSize: Size(buttonWidth, buttonHeight),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
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
    return BorderedInputField.withSvgIcon(
      controller: customTextFormFieldTextEditingController,
      svgAssetPath: prefixIconString,
      hintText: hintText,
      validator: validator,
      keyboardType: keyboardType,
      style: sub_headline5_text.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
      ),
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
    return BorderedInputField.withSvgIcon(
      controller: customBigTextFormFieldTextEditingController,
      svgAssetPath: prefixIconString,
      hintText: hintText,
      keyboardType: TextInputType.multiline,
      maxLines: 5,
      style: style ??
          sub_headline5_text.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
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
    final inputStyle = sub_headline5_text.copyWith(
        color: Theme.of(context).colorScheme.onSurface);
    return SizedBox(
      height: groupGap10 * 5,
      width: groupGap80,
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
            borderRadius: BorderRadius.circular(groupRadiusSm),
            borderSide: const BorderSide(
              color: neopopGrey,
              width: AppDimensions.borderWidthHairline,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(groupRadiusSm),
            borderSide: const BorderSide(
              color: neopopGrey,
              width: AppDimensions.borderWidthFocus,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(groupRadiusSm),
            borderSide: const BorderSide(
              color: neopopGrey,
              width: AppDimensions.borderWidthHairline,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(groupRadiusSm),
            borderSide: const BorderSide(
              color: neopopError,
              width: AppDimensions.borderWidthFocus,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(groupRadiusSm),
            borderSide: const BorderSide(
              color: neopopError,
              width: AppDimensions.borderWidthFocus,
            ),
          ),
          errorStyle: const TextStyle(
            fontSize: DefaultDecimalPlaces.hiddenErrorFontSize,
          ),
          hintText: '${userCurrencySymbol()}${AppAmountHints.decimal}',
          hintStyle: sub_headline5_text.copyWith(
            color: neopopGrey,
          ),
        ),
      ),
    );
  }
}
