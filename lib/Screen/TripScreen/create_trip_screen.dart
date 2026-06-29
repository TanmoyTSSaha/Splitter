import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Controllers/currency_controller.dart';
import 'package:splitter/Services/supabase_service.dart';
import 'package:splitter/Services/trip_service.dart';
import 'package:splitter/Widgets/dark_surface_theme.dart';

/// Screen to create a new trip with name, destination, dates, and member selection.
class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({super.key});

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _destinationController = TextEditingController();
  final _tripService = TripService();

  DateTimeRange? _dateRange;
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _dateRange,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: neopopAccent,
              onPrimary: neopopBackground,
              surface: Color(0xFF1A1A1A),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _dateRange = picked);
    }
  }

  Future<void> _createTrip() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dateRange == null) {
      Get.snackbar('Missing Dates', 'Please select trip dates',
          backgroundColor: Colors.redAccent.withOpacity(0.8),
          colorText: Colors.white);
      return;
    }

    setState(() => _isCreating = true);

    try {
      final userId = SupabaseAuth().supabaseGetUserID();
      await _tripService.createTrip(
        tripName: _nameController.text.trim(),
        destination: _destinationController.text.trim(),
        startDate: _dateRange!.start,
        endDate: _dateRange!.end,
        createdBy: userId,
        memberIds: [userId], // Creator is always a member
      );

      Get.back(result: true);
      Get.snackbar('🎉 Trip Created', 'Have an amazing trip!',
          backgroundColor: neopopAccent.withOpacity(0.8),
          colorText: neopopBackground);
    } catch (e) {
      Get.snackbar('Error', 'Could not create trip: $e',
          backgroundColor: Colors.redAccent.withOpacity(0.8),
          colorText: Colors.white);
    } finally {
      setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');

    return DarkSurfaceTheme(
      child: SafeArea(
      child: Scaffold(
        backgroundColor: neopopBackground,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: neopopBackground,
          elevation: 0,
          title: Text('New Trip', style: sub_headline5_text),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(height_16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Trip name
                Text('Trip Name',
                    style: caption_text.copyWith(
                        color: neopopOnPrimary.withOpacity(0.6))),
                SizedBox(height: height_10 / 2),
                TextFormField(
                  controller: _nameController,
                  style: body1_text.copyWith(color: neopopOnPrimary),
                  decoration: _inputDecoration('e.g. Goa Weekend 2026'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),

                SizedBox(height: height_16 * 1.5),

                // Destination
                Text('Destination',
                    style: caption_text.copyWith(
                        color: neopopOnPrimary.withOpacity(0.6))),
                SizedBox(height: height_10 / 2),
                TextFormField(
                  controller: _destinationController,
                  style: body1_text.copyWith(color: neopopOnPrimary),
                  decoration: _inputDecoration('e.g. Goa, India'),
                ),

                SizedBox(height: height_16 * 1.5),

                // Date range
                Text('Trip Dates',
                    style: caption_text.copyWith(
                        color: neopopOnPrimary.withOpacity(0.6))),
                SizedBox(height: height_10 / 2),
                GestureDetector(
                  onTap: _pickDateRange,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                        horizontal: height_16, vertical: height_16),
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: neopopOnPrimary.withOpacity(0.2)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            color: neopopAccent, size: 20),
                        SizedBox(width: height_10),
                        Text(
                          _dateRange != null
                              ? '${dateFormat.format(_dateRange!.start)} → ${dateFormat.format(_dateRange!.end)}'
                              : 'Select date range',
                          style: body1_text.copyWith(
                            color: _dateRange != null
                                ? neopopOnPrimary
                                : neopopOnPrimary.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Duration preview
                if (_dateRange != null) ...[
                  SizedBox(height: height_10),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: height_10, vertical: height_10 / 2),
                    decoration: BoxDecoration(
                      color: neopopAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_dateRange!.end.difference(_dateRange!.start).inDays + 1} days',
                      style: caption_text.copyWith(color: neopopAccent),
                    ),
                  ),
                ],

                SizedBox(height: height_16 * 1.5),

                // Default currency from profile / locale
                Text('Trip currency',
                    style: caption_text.copyWith(
                        color: neopopOnPrimary.withOpacity(0.6))),
                SizedBox(height: height_10 / 2),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                      horizontal: height_16, vertical: height_16),
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: neopopOnPrimary.withOpacity(0.2)),
                    borderRadius: BorderRadius.circular(8),
                    color: neopopAccent.withOpacity(0.08),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.currency_exchange_rounded,
                          color: neopopAccent, size: 20),
                      SizedBox(width: height_10),
                      Text(
                        Get.isRegistered<CurrencyController>()
                            ? '${Get.find<CurrencyController>().symbol} ${Get.find<CurrencyController>().code} — from your profile'
                            : '₹ INR — default',
                        style: body1_text.copyWith(color: neopopOnPrimary),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: height_16 * 3),

                // Create button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isCreating ? null : _createTrip,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: neopopAccent,
                      foregroundColor: neopopBackground,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: _isCreating
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: neopopBackground))
                        : Text('Create Trip',
                            style: body1_text.copyWith(
                                color: neopopBackground,
                                fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: body1_text.copyWith(color: neopopOnPrimary.withOpacity(0.3)),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: neopopOnPrimary.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: neopopAccent),
        borderRadius: BorderRadius.circular(8),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.redAccent),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.redAccent),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
