import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Model/loan_interest.dart';
import 'package:splitr/Model/repayment_schedule.dart';

class LoanModel {
  final String? id;
  final String lenderID;
  final String borrowerID;
  final String? createdBy;
  final double principalAmount;
  final double interestRate;
  final String interestType;
  final String interestPeriod;
  final DateTime startDate;
  final DateTime? dueDate;
  final String status;
  final double repaymentAmount;

  final int? duration;
  final String? durationUnit;
  final DateTime? repaymentStartDate;
  final DateTime? repaymentEndDate;
  final int? repaymentStartDay;
  final int? repaymentEndDay;

  final String? lenderName;
  final String? borrowerName;
  final String? lenderAvatar;
  final String? borrowerAvatar;
  final String currency;
  final double exchangeRateToInr;
  final DateTime? createdAt;

  LoanModel({
    this.id,
    required this.lenderID,
    required this.borrowerID,
    this.createdBy,
    required this.principalAmount,
    this.interestRate = 0.0,
    this.interestType = LoanInterestTypes.simple,
    this.interestPeriod = LoanFrequencyValues.monthly,
    required this.startDate,
    this.dueDate,
    this.status = LoanStatusValues.pending,
    this.repaymentAmount = 0.0,
    this.duration,
    this.durationUnit,
    this.repaymentStartDate,
    this.repaymentEndDate,
    this.repaymentStartDay,
    this.repaymentEndDay,
    this.lenderName,
    this.borrowerName,
    this.lenderAvatar,
    this.borrowerAvatar,
    this.currency = CurrencyDefaults.code,
    this.exchangeRateToInr = CurrencyDefaults.exchangeRateToInr,
    this.createdAt,
  });

  static String? _profileName(Map<String, dynamic>? profile) {
    if (profile == null) return null;
    final first = (profile[SupabaseColumns.firstname] as String?)?.trim() ??
        StringDefaults.empty;
    final last = (profile[SupabaseColumns.lastname] as String?)?.trim() ??
        StringDefaults.empty;
    return DisplayFormatters.joinFirstLastOrNull(first, last);
  }

  factory LoanModel.fromJson(Map<String, dynamic> json) {
    return LoanModel(
      id: json[SupabaseColumns.id],
      lenderID: json[SupabaseColumns.lenderId],
      borrowerID: json[SupabaseColumns.borrowerId],
      createdBy: json[SupabaseColumns.createdBy],
      principalAmount:
          (json[SupabaseColumns.principalAmount] as num).toDouble(),
      interestRate: (json[SupabaseColumns.interestRate] as num).toDouble(),
      interestType: json[SupabaseColumns.interestType],
      interestPeriod: json[SupabaseColumns.interestPeriod],
      startDate: DateTime.parse(json[SupabaseColumns.startDate]),
      dueDate: json[SupabaseColumns.dueDate] != null
          ? DateTime.parse(json[SupabaseColumns.dueDate])
          : null,
      status: json[SupabaseColumns.status],
      repaymentAmount:
          (json[SupabaseColumns.repaymentAmount] as num).toDouble(),
      duration: json[SupabaseColumns.duration],
      durationUnit: json[SupabaseColumns.durationUnit],
      repaymentStartDate: json[SupabaseColumns.repaymentStartDate] != null
          ? DateTime.tryParse(json[SupabaseColumns.repaymentStartDate])
          : null,
      repaymentEndDate: json[SupabaseColumns.repaymentEndDate] != null
          ? DateTime.tryParse(json[SupabaseColumns.repaymentEndDate])
          : null,
      repaymentStartDay: json[SupabaseColumns.repaymentStartDay],
      repaymentEndDay: json[SupabaseColumns.repaymentEndDay],
      lenderName: _profileName(
          json[SupabaseRelationKeys.lender] as Map<String, dynamic>?),
      borrowerName: _profileName(
          json[SupabaseRelationKeys.borrower] as Map<String, dynamic>?),
      lenderAvatar: json[SupabaseRelationKeys.lender] != null
          ? json[SupabaseRelationKeys.lender][SupabaseColumns.profilePictureUrl]
          : null,
      borrowerAvatar: json[SupabaseRelationKeys.borrower] != null
          ? json[SupabaseRelationKeys.borrower]
              [SupabaseColumns.profilePictureUrl]
          : null,
      currency: json[SupabaseColumns.currency] ?? CurrencyDefaults.code,
      exchangeRateToInr: double.tryParse(
              json[SupabaseColumns.exchangeRateToInr]?.toString() ??
                  CurrencyDefaults.exchangeRateToInrString) ??
          CurrencyDefaults.exchangeRateToInr,
      createdAt: json[SupabaseColumns.createdAt] != null
          ? DateTime.tryParse(json[SupabaseColumns.createdAt].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      SupabaseColumns.lenderId: lenderID,
      SupabaseColumns.borrowerId: borrowerID,
      SupabaseColumns.createdBy: createdBy,
      SupabaseColumns.principalAmount: principalAmount,
      SupabaseColumns.interestRate: interestRate,
      SupabaseColumns.interestType: interestType,
      SupabaseColumns.interestPeriod: interestPeriod,
      SupabaseColumns.startDate: startDate.toIso8601String(),
      SupabaseColumns.dueDate: dueDate?.toIso8601String(),
      SupabaseColumns.status: status,
      SupabaseColumns.repaymentAmount: repaymentAmount,
      SupabaseColumns.duration: duration,
      SupabaseColumns.durationUnit: durationUnit,
      SupabaseColumns.repaymentStartDate: repaymentStartDate?.toIso8601String(),
      SupabaseColumns.repaymentEndDate: repaymentEndDate?.toIso8601String(),
      SupabaseColumns.repaymentStartDay: repaymentStartDay,
      SupabaseColumns.repaymentEndDay: repaymentEndDay,
      SupabaseColumns.currency: currency,
      SupabaseColumns.exchangeRateToInr: exchangeRateToInr,
    };
  }

  bool get isAwaitingAcceptance => status == LoanStatusValues.pending;

  bool isBorrowRequest() => createdBy != null && createdBy == borrowerID;

  bool isLendOffer() => createdBy == null || createdBy == lenderID;

  double get totalDue {
    if (status == LoanStatusValues.pending ||
        status == LoanStatusValues.rejected ||
        status == LoanStatusValues.completed) {
      return principalAmount;
    }
    return repaymentAllocation.totalPayable;
  }

  LoanRepaymentAllocation get repaymentAllocation =>
      LoanScheduleCalculator.allocation(this);

  /// Principal + full-term interest for the contract.
  double get totalContractPayable => repaymentAllocation.totalPayable;

  double get currentAmountOwed {
    if (status == LoanStatusValues.completed ||
        status == LoanStatusValues.rejected ||
        status == LoanStatusValues.pending) {
      return 0;
    }

    return repaymentAllocation.totalRemaining;
  }

  double get repaymentProgress => repaymentAllocation.repaymentProgress;

  double calculateInterest() => LoanInterest.accruedInterest(this);
}
