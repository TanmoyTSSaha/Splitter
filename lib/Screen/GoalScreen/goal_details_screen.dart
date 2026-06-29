import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Controller/goal_details_controller.dart';
import 'package:splitter/Model/financial_goal_model.dart';
import 'package:splitter/Widgets/dark_surface_theme.dart';

class GoalDetailsScreen extends StatelessWidget {
  const GoalDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (Get.isRegistered<GoalDetailsController>()) {
      Get.delete<GoalDetailsController>(force: true);
    }
    final controller = Get.put(GoalDetailsController());
    // ignore: unused_local_variable
    final FinancialGoalModel goalArgument = Get.arguments;

    return DarkSurfaceTheme(
      child: PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Get.back(result: controller.dataChanged);
        }
      },
      child: Scaffold(
      backgroundColor: neopopBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(result: controller.dataChanged),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showDeleteConfirmation(controller),
            icon: const Icon(Icons.delete_outline, color: neopopError),
          )
        ],
      ),
      body: GetBuilder<GoalDetailsController>(builder: (ctrl) {
        double progress =
            (ctrl.goal.currentAmount ?? 0) / (ctrl.goal.targetAmount ?? 1);
        Color goalColor = ctrl.goal.colorHex != null
            ? Color(int.parse(ctrl.goal.colorHex!))
            : neopopAccent;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: width_16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Hero Progress Circle
              SizedBox(height: height_16),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 200,
                    width: 200,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 12,
                      backgroundColor: Colors.white10,
                      valueColor: AlwaysStoppedAnimation<Color>(goalColor),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        ctrl.goal.icon ?? "🎯",
                        style: const TextStyle(fontSize: 48),
                      ),
                      SizedBox(height: 8),
                      Text("${(progress * 100).toInt()}%",
                          style: headline2_text.copyWith(
                              color: Colors.white, fontWeight: FontWeight.bold))
                    ],
                  )
                ],
              ),
              SizedBox(height: height_16 * 2),

              Text(ctrl.goal.title ?? "Goal",
                  style: headline2_text.copyWith(color: Colors.white)),
              SizedBox(height: 8),
              Text(
                "₹${ctrl.goal.currentAmount?.toStringAsFixed(0)} / ₹${ctrl.goal.targetAmount?.toStringAsFixed(0)}",
                style: body1_text.copyWith(color: Colors.white54),
              ),

              if (ctrl.goal.description != null &&
                  ctrl.goal.description!.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(bottom: height_16),
                  child: Text(
                    ctrl.goal.description!,
                    textAlign: TextAlign.center,
                    style: body1_text.copyWith(
                        color: Colors.white70, fontStyle: FontStyle.italic),
                  ),
                ),

              if (ctrl.goal.goalType != null && ctrl.goal.goalType!.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24)),
                  child: Text(
                    ctrl.goal.goalType!,
                    style: caption_text.copyWith(color: neopopAccent),
                  ),
                ),

              SizedBox(height: height_16 * 2),

              // 2. Actions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showTransactionDialog(
                          context, controller, "deposit"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: neopopAccent,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text("ADD FUNDS",
                          style: button_text.copyWith(color: Colors.black)),
                    ),
                  ),
                  SizedBox(width: width_16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showTransactionDialog(
                          context, controller, "withdraw"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white10,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text("WITHDRAW",
                          style: button_text.copyWith(color: Colors.white)),
                    ),
                  ),
                ],
              ),

              SizedBox(height: height_16 * 3),

              // 3. History
              Align(
                alignment: Alignment.centerLeft,
                child: Text("History",
                    style: headline3_text.copyWith(color: Colors.white)),
              ),
              SizedBox(height: height_16),

              Obx(() {
                if (controller.transactions.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text("No transactions yet.",
                          style: caption_text.copyWith(color: neopopGrey)),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: controller.transactions.length,
                  itemBuilder: (context, index) {
                    final t = controller.transactions[index];
                    bool isDeposit = t.type == 'deposit';
                    return Container(
                      margin: EdgeInsets.only(bottom: 12),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isDeposit
                                      ? Colors.green.withOpacity(0.2)
                                      : Colors.red.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isDeposit
                                      ? Icons.arrow_downward
                                      : Icons.arrow_upward,
                                  color: isDeposit ? Colors.green : Colors.red,
                                  size: 16,
                                ),
                              ),
                              SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isDeposit ? "Deposit" : "Withdrawal",
                                    style: body2_text.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    DateFormat('MMM d').format(
                                        t.transactionDate ?? DateTime.now()),
                                    style: caption_text.copyWith(
                                        color: Colors.white54),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Text(
                            "${isDeposit ? '+' : '-'} ₹${t.amount?.toStringAsFixed(0)}",
                            style: body1_text.copyWith(
                              color: isDeposit ? Colors.green : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    );
                  },
                );
              })
            ],
          ),
        );
      }),
    ),
    ),
    );
  }

  void _showTransactionDialog(
      BuildContext context, GoalDetailsController controller, String type) {
    TextEditingController amountCtrl = TextEditingController();
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: neopopBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: neopopAccent),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              type == "deposit" ? "Add to Goal" : "Withdraw from Goal",
              style: headline3_text.copyWith(color: Colors.white),
            ),
            SizedBox(height: 16),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: headline1_text.copyWith(color: Colors.white),
              decoration: InputDecoration(
                prefixText: "₹ ",
                prefixStyle: headline1_text.copyWith(color: Colors.white),
                hintText: "0",
                hintStyle: headline1_text.copyWith(color: Colors.white24),
                border: InputBorder.none,
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  double? val = double.tryParse(amountCtrl.text);
                  if (val != null && val > 0) {
                    controller.addTransaction(val, type, "Manual Entry");
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: neopopAccent),
                child: Text("CONFIRM",
                    style: button_text.copyWith(color: Colors.black)),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(GoalDetailsController controller) {
    Get.defaultDialog(
      title: "Delete Goal?",
      titleStyle: headline3_text.copyWith(color: neopopError),
      middleText: "This action cannot be undone.",
      middleTextStyle: body2_text.copyWith(color: Colors.white),
      backgroundColor: neopopBackground,
      confirm: TextButton(
        onPressed: () => controller.deleteGoal(),
        child: Text("DELETE", style: TextStyle(color: neopopError)),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: Text("Cancel", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
