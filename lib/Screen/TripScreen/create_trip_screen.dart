import 'package:flutter/material.dart';
import 'package:splitr/Widgets/splitr_toast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Controllers/currency_controller.dart';
import 'package:splitr/Services/currency_service.dart';
import 'package:splitr/Services/supabase_service.dart';
import 'package:splitr/Services/trip_service.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Widgets/bordered_input_field.dart';
import 'package:splitr/Widgets/premium_gate.dart';
import 'package:splitr/Widgets/splitr_detail_app_bar.dart';
import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Constants/business_rules.dart';
import 'package:splitr/Utils/app_error_reporter.dart';

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
  late String _tripCurrency;

  @override
  void initState() {
    super.initState();
    _tripCurrency = Get.isRegistered<CurrencyController>()
        ? Get.find<CurrencyController>().code
        : CurrencyDefaults.code;
  }

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
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: neopopAccent,
              onPrimary: Colors.white,
              surface: Theme.of(context).colorScheme.surface,
              onSurface: groupOnSurface,
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
      SplitrToast.show(SplitrToast.join(AppStrings.trips.missingDatesTitle, AppStrings.trips.selectTripDates));
      return;
    }

    final profileCurrency = Get.isRegistered<CurrencyController>()
        ? Get.find<CurrencyController>().code
        : CurrencyDefaults.code;
    if (_tripCurrency != profileCurrency) {
      final ok = await requirePremium(
        featureLabel: AppStrings.trips.multiCurrencyLedger,
      );
      if (!ok) return;
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
        memberIds: [userId],
        tripCurrency: _tripCurrency,
      );

      Get.back(result: true);
      SplitrToast.show(SplitrToast.join(AppStrings.trips.tripCreatedTitle, AppStrings.trips.tripCreatedMessage));
    } catch (e, stack) {
      AppErrorReporter.reportActionFailure(
        AppStrings.trips.createFailedPrefix,
        error: e,
        stack: stack,
      );
    } finally {
      setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat(AppDateFormats.shortDayYear);
    final surface = Theme.of(context).colorScheme.surface;

    return Scaffold(
        backgroundColor: surface,
        appBar: SplitrDetailAppBar(
          title: AppStrings.groups.newTrip,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            groupGutter,
            groupGutter,
            groupGutter,
            groupGutter + MediaQuery.paddingOf(context).bottom,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.trips.tripName,
                  style: caption_text.copyWith(color: groupOnSurfaceMuted),
                ),
                const SizedBox(height: groupGapSm),
                BorderedInputField(
                  controller: _nameController,
                  hintText: AppStrings.trips.tripNameHint,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? AppStrings.validation.required
                      : null,
                ),
                const SizedBox(height: groupGapLg),
                Text(
                  AppStrings.trips.destination,
                  style: caption_text.copyWith(color: groupOnSurfaceMuted),
                ),
                const SizedBox(height: groupGapSm),
                BorderedInputField(
                  controller: _destinationController,
                  hintText: AppStrings.trips.destinationHint,
                ),
                const SizedBox(height: groupGapLg),
                Text(
                  AppStrings.trips.tripDates,
                  style: caption_text.copyWith(color: groupOnSurfaceMuted),
                ),
                const SizedBox(height: groupGapSm),
                GestureDetector(
                  onTap: _pickDateRange,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: groupGutter,
                      vertical: groupGapMd,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: groupMutedBorderHairline,
                      ),
                      borderRadius: BorderRadius.circular(groupControlRadius),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            color: neopopAccent, size: 20),
                        const SizedBox(width: groupGapSm),
                        Text(
                          _dateRange != null
                              ? AppStringFormat.tripDateRange(
                                  dateFormat.format(_dateRange!.start),
                                  dateFormat.format(_dateRange!.end),
                                )
                              : AppStrings.trips.selectDateRange,
                          style: body1_text.copyWith(
                            color: _dateRange != null
                                ? groupOnSurface
                                : groupOnSurfaceMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Duration preview
                if (_dateRange != null) ...[
                  const SizedBox(height: groupGapSm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: groupGapSm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: neopopAccentFillSoft,
                      borderRadius: BorderRadius.circular(groupCardRadiusLg),
                    ),
                    child: Text(
                      AppStringFormat.tripDurationDays(
                        _dateRange!.end.difference(_dateRange!.start).inDays +
                            1,
                      ),
                      style: caption_text.copyWith(color: neopopAccent),
                    ),
                  ),
                ],

                const SizedBox(height: groupGapLg),
                Text(
                  AppStrings.trips.tripCurrency,
                  style: caption_text.copyWith(color: groupOnSurfaceMuted),
                ),
                const SizedBox(height: groupGapSm),
                InkWell(
                  onTap: _pickTripCurrency,
                  borderRadius: BorderRadius.circular(groupControlRadius),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: groupGutter,
                      vertical: groupGapMd,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: groupMutedBorderHairline,
                      ),
                      borderRadius: BorderRadius.circular(groupControlRadius),
                      color: neopopAccentFillFaint,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.currency_exchange_rounded,
                            color: neopopAccent, size: 20),
                        const SizedBox(width: groupGapSm),
                        Expanded(
                          child: Text(
                            '${CurrencyService.symbolFor(_tripCurrency)} $_tripCurrency',
                            style: body1_text.copyWith(color: groupOnSurface),
                          ),
                        ),
                        if (_tripCurrency !=
                            (Get.isRegistered<CurrencyController>()
                                ? Get.find<CurrencyController>().code
                                : CurrencyDefaults.code))
                          const PremiumLockBadge(),
                        const Icon(Icons.chevron_right_rounded,
                            color: neopopGrey),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: groupGapXl * 2),
                SizedBox(
                  width: double.infinity,
                  height: groupCtaHeight,
                  child: ElevatedButton(
                    onPressed: _isCreating ? null : _createTrip,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: neopopAccent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(groupControlRadius),
                      ),
                      elevation: 0,
                    ),
                    child: _isCreating
                        ? const SizedBox(
                            width: groupProgressIndicatorSize,
                            height: groupProgressIndicatorSize,
                            child: CircularProgressIndicator(
                                strokeWidth: groupProgressStrokeWidth,
                                color: Colors.black))
                        : Text(AppStrings.trips.createTrip,
                            style: body1_text.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }

  Future<void> _pickTripCurrency() async {
    final popular = PopularCurrencyCodes.popular;
    final profileCode = Get.isRegistered<CurrencyController>()
        ? Get.find<CurrencyController>().code
        : CurrencyDefaults.code;

    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: groupSheetTopBorderRadius,
      ),
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.all(groupGutter),
              child: Text(
                AppStrings.trips.tripLedgerCurrency,
                style: sub_headline5_text.copyWith(color: groupOnSurface),
              ),
            ),
            ...popular.map((code) {
              final foreign = code != profileCode;
              return ListTile(
                leading: Text(
                  CurrencyService.symbolFor(code),
                  style: body1_text.copyWith(color: neopopAccent),
                ),
                title: Text(
                  '$code — ${CurrencyService.supportedCurrencies[code] ?? code}',
                  style: body2_text.copyWith(color: groupOnSurface),
                ),
                trailing: foreign ? const PremiumLockBadge() : null,
                selected: _tripCurrency == code,
                onTap: () => Navigator.pop(ctx, code),
              );
            }),
          ],
        ),
      ),
    );

    if (picked != null) {
      setState(() => _tripCurrency = picked);
    }
  }
}
