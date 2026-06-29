import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Controller/create_goal_controller.dart';

class CreateGoalScreen extends StatelessWidget {
  const CreateGoalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreateGoalController());

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leading: const BackButton(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "New Goal",
          style: headline3_text.copyWith(color: neopopBackground),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(width_16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Identity Section
            Text(
              "What are you saving for?",
              style: caption_text.copyWith(color: neopopGrey),
            ),
            SizedBox(height: height_10),
            TextField(
              controller: controller.titleController,
              style: headline1_text.copyWith(color: neopopBackground),
              decoration: InputDecoration(
                hintText: "e.g. Bali Trip",
                hintStyle: headline1_text.copyWith(
                    color: neopopBackground.withOpacity(0.3)),
                border: InputBorder.none,
              ),
            ),
            SizedBox(height: height_16),

            // Goal Type Dropdown
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: neopopAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Obx(
                () => DropdownButton<String>(
                  value: controller.selectedGoalType.value,
                  dropdownColor: neopopBackground,
                  icon: Icon(Icons.arrow_drop_down, color: neopopAccent),
                  elevation: 16,
                  style: body1_text.copyWith(color: Colors.white),
                  underline: Container(height: 0),
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
                          style: body1_text.copyWith(color: neopopBackground),
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
            SizedBox(height: height_16),

            // "Other" Goal Type Input
            Obx(() {
              if (controller.selectedGoalType.value == "Other") {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Specify Goal Type",
                      style: caption_text.copyWith(color: neopopGrey),
                    ),
                    SizedBox(height: height_10 / 2),
                    TextField(
                      controller: controller.otherGoalTypeController,
                      style: body1_text.copyWith(color: neopopBackground),
                      decoration: InputDecoration(
                        hintText: "e.g. Wedding",
                        hintStyle: body1_text.copyWith(
                            color: neopopBackground.withOpacity(0.3)),
                        fillColor: neopopSecondaryGrey.withOpacity(0.1),
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: height_16),
                  ],
                );
              }
              return SizedBox.shrink();
            }),

            // Description Field
            Text(
              "Describe it (AI will help estimate costs)",
              style: caption_text.copyWith(color: neopopGrey),
            ),
            SizedBox(height: height_10 / 2),
            TextField(
              controller: controller.descriptionController,
              maxLines: 3,
              style: body1_text.copyWith(color: neopopBackground),
              decoration: InputDecoration(
                hintText:
                    "e.g. 5 days trip to Bali for 2 people with flight and 4-star hotel...",
                hintStyle: body1_text.copyWith(
                    color: neopopBackground.withOpacity(0.3)),
                fillColor: neopopSecondaryGrey.withOpacity(0.1),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: height_16),

            // Icon & Color Row
            Text(
              "Goal Theme & Icon",
              style: caption_text.copyWith(color: neopopGrey),
            ),
            SizedBox(height: height_10),
            Row(
              children: [
                Obx(() => Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: neopopAccent.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        controller.selectedIcon.value,
                        style: TextStyle(fontSize: 32),
                      ),
                    )),
                SizedBox(width: width_16),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildColorOption(controller, "0xFFFE885D"), // Primary
                        _buildColorOption(controller, "0xFF18C595"), // Accent
                        _buildColorOption(controller, "0xFF2196F3"), // Blue
                        _buildColorOption(controller, "0xFF9C27B0"), // Purple
                        _buildColorOption(controller, "0xFFFFC107"), // Amber
                      ],
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: height_16 * 2),

            // 2. Target Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      "How much do you need?",
                      style: caption_text.copyWith(color: neopopGrey),
                    ),
                    Obx(() {
                      if (controller.aiReasoning.value.isNotEmpty) {
                        return Tooltip(
                          message: controller.aiReasoning.value,
                          triggerMode: TooltipTriggerMode.tap,
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          showDuration: const Duration(seconds: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF333333),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: body1_text.copyWith(color: Colors.white),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Icon(Icons.info_outline,
                                size: 18, color: neopopGrey),
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
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: neopopAccent),
                          ),
                          SizedBox(width: 8),
                          Text("AI estimating...",
                              style:
                                  caption_text.copyWith(color: neopopAccent)),
                        ],
                      )
                    : SizedBox.shrink())
              ],
            ),
            SizedBox(height: height_10),
            TextField(
              controller: controller.amountController,
              keyboardType: TextInputType.number,
              style: headline1_text.copyWith(
                  color: neopopAccent, fontFamily: 'Albra'),
              decoration: InputDecoration(
                prefixText: "₹ ",
                prefixStyle: headline1_text.copyWith(color: neopopAccent),
                hintText: "0",
                hintStyle: headline1_text.copyWith(
                    color: neopopBackground.withOpacity(0.2)),
                border: InputBorder.none,
              ),
            ),
            SizedBox(height: height_16 * 2),

            // 3. Deadline Section
            Text(
              "When do you want this?",
              style: caption_text.copyWith(color: neopopGrey),
            ),
            SizedBox(height: height_10),
            InkWell(
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 90)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2035),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: neopopBackground,
                          onPrimary: Colors.white,
                          surface: Colors.white,
                          onSurface: neopopBackground,
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
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: neopopBackground.withOpacity(0.1)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() => Text(
                          controller.selectedDate.value == null
                              ? "Select Target Date"
                              : DateFormat('MMMM d, yyyy')
                                  .format(controller.selectedDate.value!),
                          style: body1_text.copyWith(color: neopopBackground),
                        )),
                    Icon(Icons.calendar_today, color: neopopAccent),
                  ],
                ),
              ),
            ),

            // 4. AI Insight Section
            Obx(() {
              if (controller.aiFeasibilityMessage.value.isEmpty) {
                return SizedBox.shrink();
              }
              return Container(
                margin: EdgeInsets.only(top: height_16 * 2),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: neopopAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: neopopAccent.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome, color: neopopAccent, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        controller.aiFeasibilityMessage.value,
                        style: caption_text.copyWith(color: neopopBackground),
                      ),
                    ),
                  ],
                ),
              );
            }),

            SizedBox(height: height_16 * 4),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.saveGoal(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: neopopBackground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "CREATE GOAL",
                            style: button_text.copyWith(color: Colors.white),
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
            margin: EdgeInsets.only(right: 12),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(int.parse(colorHex)),
              shape: BoxShape.circle,
              border: controller.selectedColor.value == colorHex
                  ? Border.all(color: neopopBackground, width: 3)
                  : null,
            ),
          )),
    );
  }
}
