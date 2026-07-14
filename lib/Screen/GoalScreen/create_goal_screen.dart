import 'package:flutter/material.dart';
import 'package:splitr/Utils/currency_utils.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:splitr/Constants/app_dimensions.dart';
import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/app_motion.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Controller/create_goal_controller.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Widgets/bordered_input_field.dart';
import 'package:splitr/Widgets/splitr_detail_app_bar.dart';

class CreateGoalScreen extends StatelessWidget {
  const CreateGoalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreateGoalController());
    final surface = Theme.of(context).colorScheme.surface;

    return Scaffold(
      backgroundColor: surface,
      appBar: SplitrDetailAppBar(
        title: AppStrings.goals.newGoal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(groupGutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.goals.savingForLabel,
              style: caption_text.copyWith(color: groupOnSurfaceMuted),
            ),
            const SizedBox(height: groupGapSm),
            BorderedInputField(
              controller: controller.titleController,
              hintText: AppStrings.goals.titleHint,
              style: headline1_text.copyWith(color: groupOnSurface),
            ),
            const SizedBox(height: groupGapMd),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: groupCarouselGap, vertical: groupGapXxs),
              decoration: BoxDecoration(
                color: neopopAccentFillSoft,
                borderRadius: BorderRadius.circular(groupControlRadius),
                border: Border.all(
                  color: groupMutedBorder,
                ),
              ),
              child: Obx(
                () => DropdownButton<String>(
                  value: controller.selectedGoalType.value,
                  dropdownColor: groupOnSurface,
                  icon: const Icon(Icons.arrow_drop_down, color: neopopAccent),
                  elevation: AppDimensions.elevationDropdown,
                  style: body1_text.copyWith(color: neopopOnPrimary),
                  underline: const SizedBox.shrink(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      controller.selectedGoalType.value = newValue;
                    }
                  },
                  selectedItemBuilder: (BuildContext context) {
                    return controller.goalTypes.map<Widget>((String value) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          value,
                          style: body1_text.copyWith(color: groupOnSurface),
                        ),
                      );
                    }).toList();
                  },
                  items: controller.goalTypes
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: groupGapMd),
            Obx(() {
              if (controller.selectedGoalType.value == GoalTypeValues.other) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.goals.specifyGoalTypeLabel,
                      style: caption_text.copyWith(color: groupOnSurfaceMuted),
                    ),
                    const SizedBox(height: groupGapSm),
                    BorderedInputField(
                      controller: controller.otherGoalTypeController,
                      hintText: AppStrings.goals.otherGoalTypeHint,
                    ),
                    const SizedBox(height: groupGapMd),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),
            Text(
              AppStrings.goals.describeForAi,
              style: caption_text.copyWith(color: groupOnSurfaceMuted),
            ),
            const SizedBox(height: groupGapSm),
            BorderedInputField(
              controller: controller.descriptionController,
              hintText: AppStrings.goals.describeHint,
              maxLines: 3,
            ),
            const SizedBox(height: groupGapMd),
            Text(
              AppStrings.goals.goalThemeIcon,
              style: caption_text.copyWith(color: groupOnSurfaceMuted),
            ),
            const SizedBox(height: groupGapSm),
            Row(
              children: [
                Obx(() => Container(
                      padding: const EdgeInsets.all(groupCarouselGap),
                      decoration: BoxDecoration(
                        color: neopopAccentFillSoft,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        controller.selectedIcon.value,
                        style: const TextStyle(fontSize: splitrFontHeadline1),
                      ),
                    )),
                const SizedBox(width: groupGapMd),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: GoalThemeColors.palette
                          .map((colorHex) =>
                              _buildColorOption(controller, colorHex))
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: groupGapLg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      AppStrings.goals.targetAmountLabel,
                      style: caption_text.copyWith(color: groupOnSurfaceMuted),
                    ),
                    Obx(() {
                      if (controller.aiReasoning.value.isNotEmpty) {
                        return Tooltip(
                          message: controller.aiReasoning.value,
                          triggerMode: TooltipTriggerMode.tap,
                          padding: const EdgeInsets.all(groupCarouselGap),
                          margin: const EdgeInsets.symmetric(
                              horizontal: groupGap20),
                          showDuration: AppMotion.aiTooltip,
                          decoration: BoxDecoration(
                            color: neopopSurface,
                            borderRadius:
                                BorderRadius.circular(groupControlRadiusSm),
                          ),
                          textStyle:
                              body1_text.copyWith(color: neopopOnPrimary),
                          child: const Padding(
                            padding: EdgeInsets.only(left: groupGapSm),
                            child: Icon(
                              Icons.info_outline,
                              size: groupCarouselIconSm,
                              color: groupOnSurfaceMuted,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ],
                ),
                Obx(() => controller.isEstimating.value
                    ? Row(
                        children: [
                          const SizedBox(
                            width: 12,
                            height: groupCarouselGap,
                            child: CircularProgressIndicator(
                              strokeWidth: groupProgressStrokeWidth,
                              color: neopopAccent,
                            ),
                          ),
                          const SizedBox(width: groupGapSm),
                          Text(
                            AppStrings.goals.aiEstimating,
                            style: caption_text.copyWith(color: neopopAccent),
                          ),
                        ],
                      )
                    : const SizedBox.shrink()),
              ],
            ),
            const SizedBox(height: groupGapSm),
            BorderedInputField(
              controller: controller.amountController,
              hintText: AppAmountHints.zero,
              prefixText: currencyPrefixText(),
              keyboardType: TextInputType.number,
              style: headline1_text.copyWith(
                color: neopopAccent,
                fontFamily: kFontAlbra,
              ),
            ),
            const SizedBox(height: groupGapLg),
            Text(
              AppStrings.goals.targetDateLabel,
              style: caption_text.copyWith(color: groupOnSurfaceMuted),
            ),
            const SizedBox(height: groupGapSm),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(AppMotion.goalDefaultTarget),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(GoalDefaults.maxTargetYear),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: groupOnSurface,
                          onPrimary: neopopOnPrimary,
                          surface: neopopOnPrimary,
                          onSurface: groupOnSurface,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  controller.selectedDate.value = picked;
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: groupGapMd,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: groupMutedBorderHairline,
                  ),
                  borderRadius: BorderRadius.circular(groupControlRadius),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() => Text(
                          controller.selectedDate.value == null
                              ? AppStrings.goals.selectTargetDate
                              : DateFormat(AppDateFormats.longDayYear)
                                  .format(controller.selectedDate.value!),
                          style: body1_text.copyWith(color: groupOnSurface),
                        )),
                    const Icon(Icons.calendar_today, color: neopopAccent),
                  ],
                ),
              ),
            ),
            Obx(() {
              if (controller.aiFeasibilityMessage.value.isEmpty) {
                return const SizedBox.shrink();
              }
              return Container(
                margin: const EdgeInsets.only(top: groupGapLg),
                padding: const EdgeInsets.all(groupGutter),
                decoration: BoxDecoration(
                  color: neopopAccentFillSoft,
                  borderRadius: BorderRadius.circular(groupCardRadius),
                  border: Border.all(
                    color: neopopAccentBorderSoft,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome,
                        color: neopopAccent, size: AppDimensions.groupIconMd),
                    const SizedBox(width: groupCarouselGap),
                    Expanded(
                      child: Text(
                        controller.aiFeasibilityMessage.value,
                        style: caption_text.copyWith(color: groupOnSurface),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: groupGapXl * 2),
            SizedBox(
              width: double.infinity,
              height: groupCtaHeight,
              child: Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.saveGoal(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: neopopAccent,
                      disabledBackgroundColor: groupMutedBorder,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(groupControlRadius),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: AppDimensions.loadingIndicatorMd,
                            height: AppDimensions.loadingIndicatorMd,
                            child: CircularProgressIndicator(
                              strokeWidth: groupProgressStrokeWidth,
                              color: groupOnSurface,
                            ),
                          )
                        : Text(
                            AppStrings.goals.createSubmit,
                            style: button_text.copyWith(color: groupOnSurface),
                          ),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorOption(CreateGoalController controller, String colorHex) {
    return GestureDetector(
      onTap: () => controller.selectedColor.value = colorHex,
      child: Obx(() => Container(
            margin: const EdgeInsets.only(right: groupCarouselGap),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(int.parse(colorHex)),
              shape: BoxShape.circle,
              border: controller.selectedColor.value == colorHex
                  ? Border.all(color: groupOnSurface, width: 3)
                  : null,
            ),
          )),
    );
  }
}
