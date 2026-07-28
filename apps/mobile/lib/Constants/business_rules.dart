/// Thresholds, limits, TTLs, and business defaults.
abstract final class MoneyEpsilon {
  static const balanceSettled = 0.01;
  static const itemSplitRemaining = 0.01;
}

abstract final class MoneyScale {
  static const cents = 100;
}

abstract final class LoanInterestDays {
  static const daysPerMonth = 30.0;
  static const daysPerYear = 365.0;
}

abstract final class RecurringMerchantRules {
  static const amountTolerance = 0.15;
  static const minLabelLength = 3;
  static const minOccurrences = 3;
  static const minMonthlyGaps = 2;
  static const monthlyGapMinDays = 25;
  static const monthlyGapMaxDays = 40;
  static const similarAmountRatio = 0.7;
}

abstract final class TransactionSectionRules {
  static const dailyMaxDaysAgo = 6;
  static const weeklyMaxDaysAgo = 27;
  static const monthlyMaxDaysAgo = 365;
  static const weekSpanDays = 6;
}

abstract final class UpiSmsRules {
  static const minTextLength = 8;
  static const minMerchantLength = 2;
}

abstract final class UpiAccountRules {
  static const maxPerUser = 5;
  static const minCustomBankAliasLength = 2;
}

abstract final class SplitValidationTolerance {
  static const amount = 0.02;
}

abstract final class GoalInputThresholds {
  static const titleIconMinLength = 3;
  static const descriptionEstimateMinLength = 5;
}

abstract final class BudgetRules {
  static const alertThreshold = 0.9;
  static const progressClampMax = 1.5;
}

abstract final class AiThresholds {
  static const ambitiousMonthlyInr = 50000;
  static const extremeMonthlyInr = 100000;
  static const openExposureSettleUpInr = 500;
}

abstract final class InsightsThresholds {
  static const staleGroupDays = 30;
  static const lookbackDays = 90;
  static const goalDeadlineDays = 60;
  static const settleUpExposureInr = 500;
  static const socialTrustExposureInr = 500;
  static const socialTrustStaleDays = 30;
  static const scoreGood = 40;
  static const scoreWatch = 60;
  static const scoreStrong = 80;
  static const scoreExcellent = 90;
  static const spendChangePercent = 15;
  static const zScoreAnomaly = 2;
  static const topCategoryLimit = 5;
}

abstract final class GamificationThresholds {
  static const bigSpenderInr = 1000;
  static const settlementHeroCount = 5;
  static const earlyBirdHour = 8;
  static const defaultPromptness = 85;
  static const defaultPromptnessHigh = 90;
  static const defaultPromptnessLow = 70;
  static const defaultAmount = 100;
}

abstract final class PromptnessScoreTiers {
  static const good = 50;
  static const excellent = 75;
}

abstract final class FriendScreenLayout {
  static const actionButtonMinWidth = 76.0;
  static const actionButtonMinHeight = 36.0;
  static const tabCount = 3;
}

abstract final class CacheTtls {
  static const fxRatesMs = 86400000;
  static const insightsBriefingDays = 7;
  static const insightsBriefingSpendShift = 0.10;
  static const insightsPromoDismissHours = 24;
}

abstract final class NetworkTimeouts {
  static const fxRequestSeconds = 8;
}

abstract final class PremiumDurations {
  static const monthlyDays = 30;
  static const yearlyDays = 365;
}

abstract final class ReminderDelays {
  static const defaultSettlementHours = 12;
}

abstract final class ReminderCadenceDays {
  static const daily = 1;
  static const weekly = 7;
  static const biweekly = 14;
  static const monthly = 30;
}

abstract final class Debouncers {
  static const goalEstimateSeconds = 4;
}

abstract final class ShareTokenConfig {
  static const length = 24;
  static const ttlDays = 30;
}

abstract final class ShareCardConfig {
  static const pixelRatio = 3.0;
}

abstract final class RecapShareCardConfig {
  static const storyWidth = 360.0;
  static const storyHeight = 640.0;
  static const squareSize = 360.0;
}

abstract final class ReceiptScanConfig {
  static const maxWidth = 1920;
  static const maxHeight = 1920;
  static const imageQuality = 85;
}

abstract final class ImageUploadConfig {
  static const maxWidth = 1024;
  static const quality = 85;
}

abstract final class ProfileValidation {
  static const phoneLength = 10;
}

abstract final class GroupBusinessRules {
  static const activityFeedLimit = 10;
  static const memberGridMax = 12;
  static const memberGridColumns = 6;
  static const percentageTotal = 100.0;
}

abstract final class LoanDefaults {
  static const interestRate = 5.0;
  static const duration = 1;
  static const paymentDayStart = 1;
  static const paymentDayEnd = 5;
}

abstract final class TripDatePickerBounds {
  static const pastDays = 30;
  static const futureDays = 365;
}

abstract final class TransactionDateBounds {
  static const minYear = 2000;
  static const filterMinYear = 2015;
}

abstract final class FilterLookbackDays {
  static const defaultDays = 30;
  static const seven = 7;
  static const thirty = 30;
  static const ninety = 90;
  static const oneEighty = 180;
  static const threeSixtyFive = 365;
}

abstract final class AmountFormatThresholds {
  static const crore = 1e7;
  static const lakh = 1e5;
  static const thousand = 1e3;
}

abstract final class DonationPresets {
  static const amounts = [49, 99, 199, 499];
  static const minAmount = 1;
}

abstract final class PopularCurrencyCodes {
  static const regional = ['INR'];
  static const popular = [
    'INR',
    'USD',
    'EUR',
    'GBP',
    'AED',
    'SGD',
    'AUD',
    'JPY',
  ];
  static const international = [
    'USD',
    'EUR',
    'GBP',
    'AED',
    'SGD',
    'AUD',
    'CAD',
    'JPY',
  ];
}

abstract final class SettleSwipeThresholds {
  static const complete = 0.85;
  static const hapticQuarter = 0.25;
  static const hapticHalf = 0.50;
  static const hapticThreeQuarter = 0.75;
}

abstract final class AuthRules {
  static const minPasswordLength = 6;
}

abstract final class FeatureRequestLimits {
  static const titleMaxLength = 80;
  static const descriptionMaxLength = 300;
}

abstract final class ChartScaleFactors {
  static const maxY115 = 1.15;
  static const maxY120 = 1.2;
  static const axisCompactThousands = 1000;
  static const axisDivisorThirds = 3;
  static const axisDivisorQuarters = 4;
  static const axisIntervalUnit = 1;
  static const curveSmoothness = 0.3;
  static const pieTitleOffset = 0.55;
  static const pieStartDegreeFull = 180.0;
  static const pieStartDegreeTop = -90.0;
}

abstract final class ChartTruncateLengths {
  static const name10 = 10;
  static const name8 = 8;
  static const category8 = 8;
}

abstract final class SettleUpThresholds {
  static const nearSettledInr = 50.0;
}

abstract final class InsightsLimits {
  static const unifiedTxnFetch = 1000;
  static const minTxnsForAnomaly = 3;
  static const minTxnsForHabit = 5;
  static const minCategoryAmounts = 2;
  static const minStdDev = 1.0;
  static const minOpenBalance = 1.0;
  static const settleHealthDefault = 75;
  static const settleHealthMax = 100;
  static const unusualExpenseLimit = 5;
  static const categoryDeltaLimit = 5;
  static const actionQueueLimit = 5;
  static const topLeakPctThreshold = 20;
  static const topLeakAmountThreshold = 100;
  static const actionCategoryPctThreshold = 30;
  static const actionCategoryAmountThreshold = 200;
  static const digestChangeUpPct = 5;
  static const digestChangeDownPct = -5;
  static const spendingHealthMultiplierHigh = 1.5;
  static const spendingHealthMultiplierMed = 1.2;
  static const spendingExplainHigh = 50;
  static const spendingExplainMed = 20;
  static const spendingExplainLow = -10;
  static const settleScoreLow = 50;
  static const goalProgressAttention = 0.5;
  static const staleBalanceDays = 30;
  static const settlementLatencyMaxDays = 365;
  static const trendMonthsDefault = 6;
  static const trendMonthsMini = 3;
  static const percentNewCategory = 100;
  static const zScoreAnomaly = 2;
}

abstract final class RecapThresholds {
  static const settlementTickMinScore = 70;
  static const dropNotificationId = 88001;
}

abstract final class ReminderConfig {
  static const cancelSlotCount = 50;
  static const cancelIdModulo = 10000;
}

abstract final class GamificationLimits {
  static const earlyExpenseScanLimit = 200;
}

abstract final class RecapHabitThresholds {
  static const weekendSplurgeRatio = 1.25;
  static const weekdayGrindRatio = 1.25;
}

abstract final class PulseChartConfig {
  static const days = 7;
  static const lookbackDays = 6;
}

abstract final class ChartOpacityRules {
  static const pieFadeStep = 0.15;
  static const pieFadeMin = 0.3;
  static const categoryFadeRange = 0.7;
  static const categoryFadeMin = 0.2;
}
