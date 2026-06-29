import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Constants/shared.dart';
import 'package:splitter/Controllers/currency_controller.dart';
import 'package:splitter/Model/product_category_model.dart';
import 'package:splitter/Services/supabase_service.dart';
import 'package:splitter/Widgets/custom_big_text_form_field.dart';

class AddPersonalTransactionScreen extends StatefulWidget {
  const AddPersonalTransactionScreen({super.key});

  @override
  State<AddPersonalTransactionScreen> createState() =>
      _AddPersonalTransactionScreenState();
}

class _AddPersonalTransactionScreenState
    extends State<AddPersonalTransactionScreen> {
  final SupabaseDatabase _supabase = SupabaseDatabase();
  final String _userID = SupabaseAuth().supabaseGetUserID();

  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController otherCategoryController = TextEditingController();

  CategoryOnlyModel? selectedCategory;
  List<CategoryOnlyModel> categories = [];
  bool isLoading = true;
  DateTime selectedDate = DateTime.now();
  String selectedPaymentMethod = "Online"; // Default
  bool isOtherCategorySelected = false;

  final List<String> paymentMethods = ["Online", "Cash"];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      // Use TransactionService method but access via SupabaseDatabase (need to expose it or call directly)
      // SupabaseDatabase doesn't expose getPersonalCategories yet.
      // Assuming I'll update SupabaseDatabase too, or use TransactionService via SupabaseDatabase delegate.
      // For now, let's assume SupabaseDatabase has getPersonalCategoriesDelegate
      // Wait, I updated TransactionService but not SupabaseDatabase facade.
      // I should access TransactionService if possible, or update facade.
      // Let's assume I'll update the facade in next step.
      // For compilation safety, I can instantiate TransactionService directly here or update facade.
      // Let's use _supabase.getPersonalCategories if added, else TransactionService.

      // Update: I haven't added it to SupabaseDatabase facade yet.
      // I will do that in next step. For now I write this code assuming it exists.

      final fetched = await _supabase.getPersonalCategories(userID: _userID);
      setState(() {
        categories = fetched;

        // Add "Other" category for custom entry if not present (usually not in DB)
        categories.add(CategoryOnlyModel(
            category: "Other",
            categoryLogo:
                "https://api.dicebear.com/9.x/initials/svg?seed=Other"));

        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching categories: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: neopopBackground,
              onPrimary: Colors.white,
              onSurface: neopopBackground,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      if (DateUtils.isSameDay(picked, DateTime.now())) {
        // If today, keep current time
        setState(() {
          selectedDate = DateTime.now();
        });
      } else {
        // If other date, set to noon to avoid timezone shift issues or just keep midnight
        // Let's keep midnight as returned by picker
        setState(() {
          selectedDate = picked;
        });
      }
    }
  }

  void _saveTransaction() async {
    if (amountController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: "Please enter amount");
      return;
    }
    if (descriptionController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: "Please enter description");
      return;
    }
    if (selectedCategory == null) {
      Fluttertoast.showToast(msg: "Please select a category");
      return;
    }

    String finalCategory = selectedCategory!.category!;

    // Handle Custom Category
    if (isOtherCategorySelected) {
      String customName = otherCategoryController.text.trim();
      if (customName.isEmpty) {
        Fluttertoast.showToast(msg: "Please enter category name");
        return;
      }
      finalCategory = customName;

      // Save Custom Category
      await _supabase.addPersonalCustomCategory(
        categoryName: customName,
        iconSvgContent:
            "https://api.dicebear.com/9.x/initials/svg?seed=$customName",
        userID: _userID,
      );
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await _supabase.addPersonalTransaction(
        userID: _userID,
        amount: double.parse(amountController.text.trim()),
        description: descriptionController.text.trim(),
        category: finalCategory,
        date: selectedDate,
        paymentMethod: selectedPaymentMethod,
        currency: Get.find<CurrencyController>().code,
      );

      Navigator.pop(context); // Close loading
      Get.back(result: true); // Return to Home with success
      Fluttertoast.showToast(msg: "Transaction Added Successfully");
    } catch (e) {
      Navigator.pop(context); // Close loading
      debugPrint("Error adding transaction: $e");
      Fluttertoast.showToast(msg: "Failed to add transaction");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Add Personal Expense",
            style: headline3_text.copyWith(color: neopopBackground)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: neopopBackground),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Amount
            CustomBigTextFormField(
              customBigTextFormFieldTextEditingController: amountController,
              autofocus: true,
              labelText: "Amount",
            ),
            SizedBox(height: height_16),

            // 2. Description
            CustomBigTextFormFieldWithPrefixIcon(
              customBigTextFormFieldTextEditingController:
                  descriptionController,
              hintText: "What is this for?",
              prefixIconString:
                  "assets/icons/svg/hugeicons--note.svg", // Using note icon or similar
              style: body1_text.copyWith(color: neopopBackground),
            ),
            SizedBox(height: height_16),

            // 3. Category
            Text("Category",
                style: body1_text.copyWith(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            isLoading
                ? Center(
                    child: CircularProgressIndicator(color: neopopBackground))
                : Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: categories.map((cat) {
                      bool isSelected = selectedCategory == cat;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCategory = cat;
                            isOtherCategorySelected = cat.category == "Other";
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? neopopBackground
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            cat.category!,
                            style: body2_text.copyWith(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

            // Custom Category Input
            if (isOtherCategorySelected) ...[
              SizedBox(height: height_16),
              CustomBigTextFormFieldWithPrefixIcon(
                customBigTextFormFieldTextEditingController:
                    otherCategoryController,
                hintText: "Category Name",
                prefixIconString: "assets/icons/svg/hugeicons--tag.svg",
                style: body1_text.copyWith(color: neopopBackground),
              ),
            ],

            SizedBox(height: height_16 * 2),

            // 4. Details Row (Date & Payment)
            Row(
              children: [
                // Date
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 20, color: neopopBackground),
                          SizedBox(width: 8),
                          Text(
                            DateFormat('dd MMM yyyy').format(selectedDate),
                            style: body1_text.copyWith(color: neopopBackground),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: width_16),

                // Payment Method
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedPaymentMethod,
                        isExpanded: true,
                        icon: Icon(Icons.payment,
                            size: 20, color: neopopBackground),
                        items: paymentMethods.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value,
                                style: body1_text.copyWith(
                                    color: neopopBackground)),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            selectedPaymentMethod = newValue!;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: height_10 * 6), // Spacer
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveTransaction,
        backgroundColor: neopopBackground,
        icon: Icon(Icons.check, color: Colors.white),
        label: Text("SAVE EXPENSE",
            style: body1_text.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
