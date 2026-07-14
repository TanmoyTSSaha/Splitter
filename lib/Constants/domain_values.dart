/// Canonical domain/status/action string values used across persistence and UI.
abstract final class CurrencyDefaults {
  static const code = 'INR';
  static const exchangeRateToInr = 1.0;
  static const exchangeRateToInrString = '1.0';
}

abstract final class PaymentMethodDefaults {
  static const online = 'Online';
}

abstract final class CategoryDefaults {
  static const other = 'Other';
  static const general = 'General';
  static const income = 'Income';
  static const expense = 'Expense';
  static const settlement = 'Settlement';
  static const settlementPayment = 'Settlement payment';
  static const others = 'Others';
  static const miscellaneous = 'miscellaneous';
  static const foodAndDining = 'Food & Dining';
  static const receiptExpense = 'Receipt expense';
  static const importedExpense = 'Imported expense';
  static const importedFromSplitwise = 'Imported from Splitwise';
  static const dash = '-';
}

abstract final class DisplayFallbacks {
  static const unknown = 'Unknown';
  static const unknownUser = 'Unknown';
  static const user = 'User';
  static const member = 'Member';
  static const group = 'Group';
  static const aGroup = 'a group';
  static const friend = 'Friend';
  static const aFriend = 'A friend';
  static const someone = 'Someone';
  static const contact = 'Contact';
  static const goal = 'Goal';
  static const untitled = 'Untitled';
  static const untitledGroup = 'Untitled Group';
  static const unnamedGroup = 'Unnamed';
  static const questionMark = '?';
  static const none = 'None';
  static const nothing = 'Nothing';
  static const notSet = 'Not set';
  static const na = 'N/A';
  static const your = 'YOUR';
}

abstract final class GroupCopy {
  static const self = 'You';
  static const selfLower = 'you';
  static const pays = ' pays ';
  static const paidByYou = 'Paid by You';
}

abstract final class SyncStatusValues {
  static const synced = 'synced';
  static const pending = 'pending';
  static const failed = 'failed';
}

abstract final class FriendStatusValues {
  static const pending = 'pending';
  static const accepted = 'accepted';
  static const rejected = 'rejected';
}

abstract final class InviteStatusValues {
  static const active = 'active';
  static const used = 'used';
}

abstract final class InviteTypes {
  static const group = 'group';
  static const friend = 'friend';
}

abstract final class GoalStatusValues {
  static const active = 'active';
}

abstract final class GoalTransactionTypes {
  static const deposit = 'deposit';
  static const withdraw = 'withdraw';
}

abstract final class LoanStatusValues {
  static const pending = 'pending';
  static const active = 'active';
  static const rejected = 'rejected';
  static const completed = 'completed';
  static const defaulted = 'defaulted';
}

abstract final class LoanInterestTypes {
  static const simple = 'simple';
  static const compound = 'compound';
  static const flat = 'flat';
}

abstract final class LoanFrequencyValues {
  static const monthly = 'monthly';
  static const yearly = 'yearly';
  static const oneTime = 'one_time';
}

abstract final class GroupInviteStatusValues {
  static const pending = 'pending';
  static const accepted = 'accepted';
  static const declined = 'declined';
}

abstract final class LoanDurationUnits {
  static const days = 'days';
  static const months = 'months';
  static const years = 'years';
}

abstract final class LoanRoleFallbacks {
  static const borrower = 'Borrower';
  static const lender = 'Lender';
}

abstract final class SharingTypeValues {
  static const evenly = 'evenly';
  static const unevenly = 'unevenly';
  static const percentage = 'percentage';
  static const shares = 'shares';
  static const byItem = 'by_item';
  static const settlement = 'settlement';
}

abstract final class TransactionTypes {
  static const group = 'group';
  static const personal = 'personal';
}

abstract final class UnifiedTxnKeys {
  static const type = 'type';
  static const groupId = 'group_id';
  static const category = 'category';
  static const isCredit = 'is_credit';
  static const total = 'total';
  static const amount = 'amount';
  static const title = 'title';
  static const date = 'date';
}

abstract final class BalanceDisplayPrefixes {
  static const userId = 'ID:';
}

abstract final class SyncOperations {
  static const insert = 'INSERT';
  static const update = 'UPDATE';
  static const delete = 'DELETE';
}

abstract final class InsightActionTypes {
  static const settleUp = 'settle_up';
  static const reviewCategory = 'review_category';
  static const viewGoal = 'view_goal';
  static const viewExpense = 'view_expense';
}

abstract final class PromoHookTypes {
  static const settleUp = 'settle_up';
  static const spendingUp = 'spending_up';
  static const spendingDown = 'spending_down';
  static const generic = 'generic';
}

abstract final class BudgetAlertTypes {
  static const over = 'over';
  static const near = 'near';
}

abstract final class NotificationTypes {
  static const friendRequest = 'friend_request';
  static const groupInvite = 'group_invite';
  static const expenseAdded = 'expense_added';
  static const settlementRequest = 'settlement_request';
  static const settlement = 'settlement';
  static const general = 'general';
}

abstract final class ThemeModeValues {
  static const dark = 'dark';
  static const light = 'light';
  static const system = 'system';
}

abstract final class ShareTypes {
  static const monthlyRecap = 'monthly_recap';
}

abstract final class TestIds {
  static const user = 'test-user';
}

abstract final class BudgetPeriodValues {
  static const daily = 'daily';
  static const weekly = 'weekly';
  static const monthly = 'monthly';
  static const quarterly = 'quarterly';
  static const halfYearly = 'half_yearly';
  static const yearly = 'yearly';
  static const all = [
    daily,
    weekly,
    monthly,
    quarterly,
    halfYearly,
    yearly,
  ];
}

abstract final class BudgetDefaults {
  static const alertThreshold = 0.9;
  static const overallLabel = 'Overall';
  static const defaultPeriod = BudgetPeriodValues.monthly;
}

abstract final class GoalDefaults {
  static const defaultEmoji = '🎯';
  static const manualEntry = 'Manual Entry';
  static const defaultTargetDays = 90;
  static const maxTargetYear = 2035;
}

abstract final class GoalThemeColors {
  static const primary = '0xFFFE885D';
  static const teal = '0xFF18C595';
  static const blue = '0xFF2196F3';
  static const purple = '0xFF9C27B0';
  static const amber = '0xFFFFC107';
  static const defaultColor = primary;
  static const palette = [primary, teal, blue, purple, amber];
}

abstract final class GoalTypeValues {
  static const travel = 'Travel';
  static const gadget = 'Gadget';
  static const vehicle = 'Vehicle';
  static const home = 'Home';
  static const education = 'Education';
  static const emergency = 'Emergency';
  static const investment = 'Investment';
  static const other = 'Other';
  static const all = [
    travel,
    gadget,
    vehicle,
    home,
    education,
    emergency,
    investment,
    other,
  ];
}

abstract final class UpiDefaults {
  static const scheme = 'upi';
  static const host = 'pay';
}

abstract final class OAuthScopes {
  static const googleEmail = 'email';
  static const googleProfile = 'profile';
}

abstract final class BadgeRequirementTypes {
  static const createTrip = 'create_trip';
  static const totalSpent = 'total_spent';
  static const settlementsCount = 'settlements_count';
  static const earlyExpense = 'early_expense';
}

abstract final class ExpenseTypeLabels {
  static const expense = 'expense';
}

abstract final class AiResponseKeys {
  static const estimatedAmount = 'estimated_amount';
  static const currency = 'currency';
  static const reasoning = 'reasoning';
  static const headline = 'headline';
  static const narrative = 'narrative';
  static const actions = 'actions';
  static const isAi = 'is_ai';
}

abstract final class TransactionCopy {
  static const youPaid = 'You paid';
  static const youOwe = 'You owe';
  static const youPaidForSelf = 'You paid for yourself';
  static const youNotInvolved = 'You are not involved';
  static const groupExpense = 'Group Expense';
  static const expense = 'Expense';
  static const newExpense = 'New expense';
  static const paidYou = ' paid you ';
  static const owesPrefix = ' owes ';
  static const youGetFrom = 'You get ';
  static const fromPeople = ' from ';
  static const people = ' people';
}

abstract final class ActivityCopy {
  static const settledUp = 'settled up';
  static const addedPrefix = "added '";
  static const addedSuffix = "'";
}

abstract final class GroupCopyExtras {
  static const splitWithPrefix = 'Split with ';
  static const memberYouSuffix = '(you)';
  static const directSplitGroupName = 'Split with ';
}

abstract final class InsightScoreLabels {
  static const good = 'Good';
  static const watch = 'Watch';
  static const needsAttention = 'Needs attention';
}

abstract final class InsightActionTitles {
  static const settleStaleBalances = 'Settle stale balances';
  static const clearOpenBalances = 'Clear open balances';
  static const reviewCategoryPrefix = 'Review ';
  static const checkUnusualSpend = 'Check unusual spend';
  static const goalNeedsAttention = 'Goal needs attention';
  static const settleGroupBalances = 'Settle group balances';
}

abstract final class BadgeIds {
  static const firstTrip = 'first_trip';
  static const bigSpender = 'big_spender';
  static const settlementHero = 'settlement_hero';
  static const earlyBird = 'early_bird';
}

abstract final class FeatureRequestCategories {
  static const splitting = 'splitting';
  static const analytics = 'analytics';
  static const payments = 'payments';
  static const design = 'design';
  static const other = 'other';
}

abstract final class FeatureRequestPriorities {
  static const niceToHave = 'nice_to_have';
  static const reallyNeed = 'really_need';
  static const dealBreaker = 'deal_breaker';
}

abstract final class BadgeNames {
  static const explorer = 'Explorer';
  static const bigSpender = 'Big Spender';
  static const settlementHero = 'Settlement Hero';
  static const earlyBird = 'Early Bird';
}

abstract final class BadgeDescriptions {
  static const createFirstTrip = 'Create your first trip.';
  static const spendMoreThan = 'Spend more than ';
  static const inTotal = ' in total.';
  static const settleUpTimes = 'Settle up ';
  static const times = ' times.';
  static const addExpenseBefore = 'Add an expense before ';
  static const am = ' AM.';
}

abstract final class AchievementUnlockSources {
  static const live = 'live';
  static const backfill = 'backfill';
}

abstract final class AchievementRuleTypes {
  static const tripCount = 'trip_count';
  static const settlementCount = 'settlement_count';
  static const lifetimeSpend = 'lifetime_spend';
  static const earlyExpense = 'early_expense';
  static const groupCount = 'group_count';
  static const friendCount = 'friend_count';
  static const groupExpenseCount = 'group_expense_count';
  static const personalExpenseCount = 'personal_expense_count';
  static const goalCount = 'goal_count';
  static const loanCount = 'loan_count';
}

abstract final class ServiceErrors {
  static const notSignedIn = 'Not signed in';
  static const cannotAddYourself = 'Cannot add yourself';
  static const inviteInvalidOrExpired = 'Invite link is invalid or expired';
  static const invalidGroupInvite = 'Invalid group invite';
  static const alreadyGroupMember = 'User is already a member of this group.';
  static const inviteAlreadySent = 'Invite already sent.';
  static const couldNotLoadSplitGroup = 'Could not load new split group';
  static const noTransactionsToExport = 'No transactions to export';
}

abstract final class UpiAccountErrors {
  static const duplicateVpa = 'duplicate_vpa';
}

abstract final class LoanServiceErrors {
  static const failedCreatePrefix = 'Failed to create loan: ';
  static const failedFetchLoansPrefix = 'Failed to fetch loans: ';
  static const failedFetchLoanPrefix = 'Failed to fetch loan: ';
  static const failedUpdateRepaymentPrefix = 'Failed to update repayment: ';
  static const failedUpdateStatusPrefix = 'Failed to update loan status: ';
  static const failedFetchPendingPrefix = 'Failed to fetch pending loans: ';
  static const notFound = 'Loan not found';
  static const paymentsActiveOnly =
      'Payments can only be recorded on active loans';
  static const paymentMustBePositive =
      'Payment amount must be greater than zero';
}

abstract final class GroupInviteCopy {
  static const joinMeOn = 'Join me on ';
  static const joinGroupOn = 'Join "';
  static const onBrandSuffix = '" on ';
  static const groupInviteSubject = 'Group invite — ';
  static const invitedYouTo = ' invited you to ';
  static const addThemAsFriend = '! Add them as a friend: ';
}

abstract final class CurrencyDisplayNames {
  static const inr = 'Indian Rupee';
  static const usd = 'US Dollar';
  static const eur = 'Euro';
  static const gbp = 'British Pound';
  static const jpy = 'Japanese Yen';
  static const aud = 'Australian Dollar';
  static const cad = 'Canadian Dollar';
  static const sgd = 'Singapore Dollar';
  static const aed = 'UAE Dirham';
  static const chf = 'Swiss Franc';
  static const cny = 'Chinese Yuan';
  static const hkd = 'Hong Kong Dollar';
  static const sek = 'Swedish Krona';
  static const nok = 'Norwegian Krone';
  static const nzd = 'New Zealand Dollar';
  static const mxn = 'Mexican Peso';
  static const brl = 'Brazilian Real';
  static const zar = 'South African Rand';
  static const krw = 'South Korean Won';
  static const thb = 'Thai Baht';
  static const myr = 'Malaysian Ringgit';
  static const idr = 'Indonesian Rupiah';
  static const pln = 'Polish Złoty';
  static const try_ = 'Turkish Lira';
  static const sar = 'Saudi Riyal';
}

abstract final class CurrencySymbols {
  static const inr = '₹';
  static const usd = '\$';
  static const eur = '€';
  static const gbp = '£';
  static const jpy = '¥';
  static const aud = 'A\$';
  static const cad = 'C\$';
  static const sgd = 'S\$';
  static const aed = 'د.إ';
  static const chf = 'Fr';
  static const cny = '¥';
  static const hkd = 'HK\$';
  static const sek = 'kr';
  static const nok = 'kr';
  static const nzd = 'NZ\$';
  static const mxn = 'Mex\$';
  static const brl = 'R\$';
  static const zar = 'R';
  static const krw = '₩';
  static const thb = '฿';
  static const myr = 'RM';
  static const idr = 'Rp';
  static const pln = 'zł';
  static const try_ = '₺';
  static const sar = '﷼';
}

/// Lowercase category slug tokens for icon/color heuristics.
abstract final class CategorySlugValues {
  static const shopping = 'shopping';
  static const food = 'food';
  static const transport = 'transport';
  static const travel = 'travel';
  static const entertainment = 'entertainment';
  static const bills = 'bills';
  static const health = 'health';
  static const education = 'education';
  static const groceries = 'groceries';
  static const rent = 'rent';
  static const other = 'other';
  static const dining = 'dining';
  static const restaurant = 'restaurant';
  static const home = 'home';
  static const apartment = 'apartment';
  static const trip = 'trip';
  static const transportation = 'transportation';
  static const stay = 'stay';
  static const accommodation = 'accommodation';
  static const drinks = 'drinks';
  static const settlement = 'settlement';
  static const group = 'group';
  static const income = 'income';
  static const salary = 'salary';
  static const refund = 'refund';
  static const cashback = 'cashback';
  static const reimbursement = 'reimbursement';
  static const receipt = 'receipt';
}

/// Trip-name tokens for gradient/icon heuristics.
abstract final class TripNameKeywords {
  static const goa = 'goa';
  static const bali = 'bali';
  static const flight = 'flight';
  static const beach = 'beach';
}

/// Inline UI separators.
abstract final class DisplaySeparators {
  static const pipe = '|';
  static const nameWordSplit = ' ';
}

/// Category logo source prefixes.
abstract final class LogoUrlPrefixes {
  static const svg = '<svg';
  static const http = 'http';
}
