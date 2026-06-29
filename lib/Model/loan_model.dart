import 'dart:math';

class LoanModel {
  final String? id;
  final String lenderID;
  final String borrowerID;
  final String? createdBy;
  final double principalAmount;
  final double interestRate;
  final String interestType; // 'simple', 'compound', 'flat'
  final String interestPeriod; // 'monthly', 'yearly', 'one_time'
  final DateTime startDate;
  final DateTime? dueDate;
  final String
      status; // 'pending', 'active', 'completed', 'defaulted', 'rejected'
  final double repaymentAmount;

  final int? duration;
  final String? durationUnit; // 'months', 'days', 'years'
  final DateTime? repaymentStartDate;
  final DateTime? repaymentEndDate;
  final int? repaymentStartDay; // 1-31
  final int? repaymentEndDay; // 1-31

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
    this.interestType = 'simple',
    this.interestPeriod = 'monthly',
    required this.startDate,
    this.dueDate,
    this.status = 'pending',
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
    this.currency = 'INR',
    this.exchangeRateToInr = 1.0,
    this.createdAt,
  });

  static String? _profileName(Map<String, dynamic>? profile) {
    if (profile == null) return null;
    final first = (profile['firstname'] as String?)?.trim() ?? '';
    final last = (profile['lastname'] as String?)?.trim() ?? '';
    final full = '$first $last'.trim();
    return full.isEmpty ? null : full;
  }

  factory LoanModel.fromJson(Map<String, dynamic> json) {
    return LoanModel(
      id: json['id'],
      lenderID: json['lender_id'],
      borrowerID: json['borrower_id'],
      createdBy: json['created_by'],
      principalAmount: (json['principal_amount'] as num).toDouble(),
      interestRate: (json['interest_rate'] as num).toDouble(),
      interestType: json['interest_type'],
      interestPeriod: json['interest_period'],
      startDate: DateTime.parse(json['start_date']),
      dueDate:
          json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      status: json['status'],
      repaymentAmount: (json['repayment_amount'] as num).toDouble(),
      duration: json['duration'],
      durationUnit: json['duration_unit'],
      repaymentStartDate: json['repayment_start_date'] != null
          ? DateTime.tryParse(json['repayment_start_date'])
          : null,
      repaymentEndDate: json['repayment_end_date'] != null
          ? DateTime.tryParse(json['repayment_end_date'])
          : null,
      repaymentStartDay: json['repayment_start_day'],
      repaymentEndDay: json['repayment_end_day'],
      lenderName: _profileName(json['lender'] as Map<String, dynamic>?),
      borrowerName: _profileName(json['borrower'] as Map<String, dynamic>?),
      lenderAvatar: json['lender'] != null
          ? json['lender']['profile_picture_url']
          : null,
      borrowerAvatar: json['borrower'] != null
          ? json['borrower']['profile_picture_url']
          : null,
      currency: json['currency'] ?? 'INR',
      exchangeRateToInr:
          double.tryParse(json['exchange_rate_to_inr']?.toString() ?? '1.0') ??
              1.0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lender_id': lenderID,
      'borrower_id': borrowerID,
      'created_by': createdBy,
      'principal_amount': principalAmount,
      'interest_rate': interestRate,
      'interest_type': interestType,
      'interest_period': interestPeriod,
      'start_date': startDate.toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
      'status': status,
      'repayment_amount': repaymentAmount,
      'duration': duration,
      'duration_unit': durationUnit,
      'repayment_start_date': repaymentStartDate?.toIso8601String(),
      'repayment_end_date': repaymentEndDate?.toIso8601String(),
      'repayment_start_day': repaymentStartDay,
      'repayment_end_day': repaymentEndDay,
      'currency': currency,
      'exchange_rate_to_inr': exchangeRateToInr,
    };
  }

  bool get isAwaitingAcceptance => status == 'pending';

  bool isBorrowRequest() =>
      createdBy != null && createdBy == borrowerID;

  bool isLendOffer() =>
      createdBy == null || createdBy == lenderID;

  double get totalDue {
    if (status == 'pending' ||
        status == 'rejected' ||
        status == 'completed') {
      return principalAmount;
    }
    return principalAmount + calculateInterest();
  }

  double get currentAmountOwed {
    if (status == 'completed' ||
        status == 'rejected' ||
        status == 'pending') {
      return 0;
    }

    return (totalDue - repaymentAmount).clamp(0, double.infinity);
  }

  double get repaymentProgress {
    final due = totalDue;
    if (due <= 0) return 0;
    return (repaymentAmount / due).clamp(0.0, 1.0);
  }

  double calculateInterest() {
    if (interestRate == 0 || status != 'active') return 0;

    final now = DateTime.now();
    double timeUnits = 0;
    final diff = now.difference(startDate);

    if (interestPeriod == 'monthly') {
      timeUnits = diff.inDays / 30.0;
    } else if (interestPeriod == 'yearly') {
      timeUnits = diff.inDays / 365.0;
    } else {
      timeUnits = 1;
    }

    if (timeUnits < 0) timeUnits = 0;

    if (interestType == 'simple' || interestType == 'flat') {
      return principalAmount * (interestRate / 100) * timeUnits;
    }
    if (interestType == 'compound') {
      return principalAmount * pow((1 + interestRate / 100), timeUnits) -
          principalAmount;
    }
    return 0;
  }
}
