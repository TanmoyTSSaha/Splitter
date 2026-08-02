/// User-facing copy grouped by feature area.
library;
import 'package:splitr/Constants/app_branding.dart';
import 'package:splitr/Constants/app_formats.dart';

abstract final class AppStrings {
  static const actions = _Actions();
  static const validation = _Validation();
  static const errors = _Errors();
  static const auth = _Auth();
  static const dates = _Dates();
  static const home = _Home();
  static const friends = _Friends();
  static const goals = _Goals();
  static const groups = _Groups();
  static const analytics = _Analytics();
  static const settle = _Settle();
  static const profile = _Profile();
  static const currency = _Currency();
  static const splitwiseImport = _SplitwiseImport();
  static const smsDraft = _SmsDraft();
  static const budget = _Budget();
  static const donate = _Donate();
  static const featureRequest = _FeatureRequest();
  static const notifications = _Notifications();
  static const lending = _Lending();
  static const trips = _Trips();
  static const insights = _Insights();
  static const export_ = _Export();
  static const sync = _Sync();
  static const biometric = _Biometric();
  static const premium = _Premium();
  static const reminders = _Reminders();
  static const comments = _Comments();
  static const onboarding = _Onboarding();
  static const bottomNav = _BottomNav();
  static const a11y = _A11y();
  static const recap = _Recap();
  static const durations = _Durations();
  static const services = _Services();
  static const upi = _Upi();
}

final class _Actions {
  const _Actions();
  final retry = 'Retry';
  final tryAgain = 'Try again';
  final dismiss = 'Dismiss';
  final apply = 'Apply';
  final confirm = 'CONFIRM';
  final cancel = 'Cancel';
  final save = 'Save';
  final saveChanges = 'SAVE CHANGES';
  final delete = 'Delete';
  final deleteTransaction = 'Delete transaction';
  final accept = 'Accept';
  final decline = 'Decline';
  final reject = 'Reject';
  final view = 'View';
  final viewAll = 'VIEW ALL';
  final viewDetails = 'VIEW DETAILS';
  final yes = 'Yes';
  final no = 'No';
  final done = 'Done';
  final share = 'Share';
  final edit = 'Edit';
  final skip = 'Skip';
  final next = 'Next';
  final getStarted = 'Get Started';
}

final class _Validation {
  const _Validation();
  final validAmount = 'Enter a valid amount';
  final required = 'Required';
  final needAmount = 'Need amount here!';
  final numbersOnly = 'Only numbers are allowed here!';
  final needPercentage = 'Need percentage here!';
  final needShares = 'Need shares here!';
  final wholeNumbersOnly = 'Only whole numbers are allowed!';
  final descriptionRequired = 'Description is required!';
  final categoryNameRequired = 'Category name is required';
  final selectGroup = 'Please select a group';
  final selectGroupFirst = 'Please select a group first';
  final selectPersonToSplit = 'Select at least one person to split with';
  final selectRecipient = 'Select Recipient';
  final selectBalance = 'Select a balance to settle!';
  final validPaymentAmount = 'Please enter a valid payment amount';
  final paymentExceedsBalance = 'Payment exceeds remaining balance';
  final phoneLength = 'Phone number must be 10 digits';
  final enterSplitAmounts = 'Enter split amounts for at least one person';
  final totalSharesGreaterThanZero = 'Total shares must be greater than 0';
  final assignEachItem = 'Assign each item to at least one person';
  final enterAmount = 'Please enter an amount';
  final assignItemToMember = 'Assign at least one item to a member';
}

final class _Errors {
  const _Errors();
  final generic = 'Something went wrong!';
  final errorTitle = 'Error';
  final successTitle = 'Success';
  final loadTransactions = 'Failed to load transactions.';
  final loadTransactionsShort = 'Could not load transactions';
  final loadAnalytics = 'Failed to load analytics data.';
  final loadFriends = 'Failed to load friends.';
  final refreshGroups = 'Could not refresh groups. Pull to refresh.';
  final refreshHome = 'Could not refresh home data.';
  final loadBalances = 'Failed to load balances. Please try again.';
  final loadBalancesPullToRetry = 'Failed to load balances. Pull to retry.';
  final refreshGroupsCached = 'Could not refresh groups. Showing cached data.';
  final searchUsersFailed =
      'Could not search. Check your connection and try again.';
  final categoriesLoadFailed = 'Could not load categories';
  final passwordUpdateFailed = 'Could not update password.';
  final biometricFailed = 'Authentication failed. Tap to retry.';
  final exportEmpty = 'No transactions to export';
  final exportFailed = 'Export failed';
  final postCommentFailed = 'Could not post comment: ';
  final loadActivityFeed = 'Could not load activity feed.';
  final loadTripTimeline = 'Could not load trip timeline';
  final loadLending = 'Could not load lending data. Pull to refresh.';
  final loadBudgets = 'Could not load budgets';
  final loadNotifications = 'Error loading notifications';
  final noUpiApp = 'No UPI app found on this device';
  final missingSupabaseConfig =
      'Missing Supabase configuration. Provide SUPABASE_URL and SUPABASE_ANON_KEY via --dart-define or .env';
  final missingSupabaseStartup =
      'Missing Supabase config. Copy .env.example to .env or run with '
      '--dart-define-from-file=env.json';
  final failedToLoadData = 'Failed to load data.';
  final failedToReactPrefix = 'Failed to react: ';
  final loadGroupDetailsPrefix = 'Failed to load group details: ';
  final couldNotOpenReminderPrefix = 'Could not open reminder settings: ';
  final couldNotUpdateGroupPrefix = 'Could not update group: ';
  final couldNotCreateInvitePrefix = 'Could not create invite: ';
  final couldNotRemoveMemberPrefix = 'Could not remove member: ';
  final couldNotLeaveGroupPrefix = 'Could not leave group: ';
  final couldNotLoadTripDetails = 'Could not load trip details.';
  final couldNotOpenAddExpensePrefix = 'Could not open add expense: ';
  final failedProcessReceiptPrefix = 'Failed to process receipt: ';

  /// Light-humor defaults — never show raw backend/DB text to users.
  final genericHumorous =
      'Oops — our expense gremlins tripped. Try again?';
  final accessHumorous =
      "You don't have access to that. If this feels wrong, try again later.";
  final paymentHumorous =
      "Payment didn't go through. No money harmed — try again.";
  final networkHumorous =
      'Connection hiccup. Check signal and retry.';
  final loadHumorous =
      "Couldn't load this right now. Pull to refresh or try again.";
  final exportHumorous =
      "Export hit a snag. Your data is fine — try again.";
  final actionHumorous =
      "That didn't work. Give it another shot?";

  String unknownSyncOperation(String operation) =>
      'Unknown sync operation: $operation';
}

final class _Auth {
  const _Auth();
  final changePasswordTitle = 'Change password';
  final passwordsNoMatch = 'Passwords do not match';
  final savePassword = 'Save password';
  final login = 'Login';
  final register = 'Register';
  final loginSubtitle = 'Hello welcome back!\nYou have been missed.';
  final registerSubtitle = 'Please provide us with the below information';
  final email = 'Email ID';
  final password = 'Password';
  final firstName = 'First Name';
  final lastName = 'Last Name';
  final username = 'Username';
  final confirmPassword = 'Confirm Password';
  final forgotPassword = 'Forgot Password?';
  final sendingResetLink = 'Sending reset link...';
  final orSignInWith = 'or sign in with';
  final orSignUpWith = 'or sign up with';
  final signInGoogle = 'Sign In with Google';
  final signUpGoogle = 'Sign Up with Google';
  final noAccount = "Don't have an account?";
  final registerNow = ' Register now!';
  final hasAccount = 'Already have an account?';
  final loginNow = ' Login now!';
  final setNewPassword = 'Set new password';
  final passwordHint = 'Choose a strong password for your Splitr account.';
  final newPassword = 'New password';
  final confirmPasswordLabel = 'Confirm password';
  final updatePassword = 'Update password';
  final pleaseLogIn = 'Please log in.';
  final loginSuccess = 'Yay! Logged in successfully.';
  final registerSuccess = 'Registration successful! Please login.';
  final lastUsed = 'Last used';
  final passwordUpdated = 'Password updated. Please sign in.';
  final passwordUpdatedShort = 'Password updated';
}

final class _Dates {
  const _Dates();
  final today = 'Today';
  final yesterday = 'Yesterday';
  final justNow = 'Just now';
  final minutesAgoSuffix = 'm ago';
  final hoursAgoSuffix = 'h ago';
  final daysAgoSuffix = 'd ago';
}

final class _Home {
  const _Home();
  final tagline = 'money matters,\nsimplified.';
  final trueSpend = 'True Spend';
  final cashFlow = 'Cash Flow';
  final spend = 'Spend';
  final flow = 'Flow';
  final totalOutflow = 'Total Outflow';
  final monthlySpend = 'Monthly Spend';
  final transactions = 'Transactions';
  final financialGoals = 'Financial Goals';
  final setAGoal = 'SET A GOAL';
  final welcomeNamed = 'Welcome, ';
  final welcomeBrand = 'Welcome to ';
  final emptySubtitle =
      'Create a group to split bills, track personal spending, or set a savings goal.';
  final emptyPickFirstStep =
      'Split bills, track spending, and reach your goals. Pick a first step below.';
  final goalsEmptyQuote = 'Goals are essential,\nto have better lifestyle.';
  final trueSpendSubtitle = 'Actual cost incurred';
  final cashFlowSubtitle = 'Total money out';
  final cashFlowDisclaimer =
      'This assumes full amount paid by you, including what others owe you.';
  final enterAmount = 'Please enter amount';
  final enterDescription = 'Please enter description';
  final selectCategory = 'Please select a category';
  final recapDropTitle = 'Monthly recap';
  final viewRecap = 'View recap';
  final enterCategoryName = 'Please enter category name';
  final transactionAdded = 'Transaction Added Successfully';
  final transactionAddFailed = 'Failed to add transaction';
  final transactionUpdated = 'Transaction updated';
  final transactionUpdateFailed = 'Failed to update transaction';
  final transactionDeleted = 'Transaction deleted';
  final transactionDeleteFailed = 'Failed to delete transaction';
  final cannotEditTransaction = 'Cannot edit this transaction';
  final cannotDeleteTransaction = 'Cannot delete this transaction';
  final deleteTransactionConfirm =
      'This will remove the transaction permanently.';
  final deleteTransactionTitle = 'Delete transaction?';
  final quickRange = 'Quick range';
  final paymentMethod = 'Payment method';
  final noCategoriesLoaded = 'No categories in loaded transactions';
  final noGroupsAvailable = 'No groups available';
  final filterDateBothRequired = 'Both From and To dates are required';
  final filterDateFuture = 'Dates cannot be in the future';
  final filterDateOrder = 'To date cannot be before From date';
  final filterMinInvalid = 'Enter a valid minimum amount';
  final filterMaxInvalid = 'Enter a valid maximum amount';
  final filterMinMaxOrder = 'Min cannot be greater than max';
  final createGroup = 'Create Group';
  final addTransaction = 'Add Transaction';
  final setGoal = 'Set a Goal';
  final noTransactions = 'No transactions found.';
  final loadOlder = 'Load older transactions';
  final groupTransactions = 'Group Transactions';
  final tripTransactions = 'Trip Transactions';
  final allTransactions = 'All Transactions';
  final chartNoData = 'No Data Yet';
  final chartTotalTrueSpend = 'Total true spend';
  final chartSpentSuffix = ' spent';
  final sortBy = 'Sort by';
  final sortNewestFirst = 'Newest first';
  final sortOldestFirst = 'Oldest first';
  final sortLargestFirst = 'Largest first';
  final sortSmallestFirst = 'Smallest first';
  final filters = 'Filters';
  final clearAll = 'Clear all';
  final filterPresets7 = '7 days';
  final filterPresets30 = '30 days';
  final filterPresets3Months = '3 months';
  final filterPresets6Months = '6 months';
  final filterPresets12Months = '12 months';
  final priceRange = 'Price range';
  final min = 'Min';
  final max = 'Max';
  final customDateRange = 'Custom date range';
  final from = 'From';
  final to = 'To';
  final personalExpense = 'Expense';
  final personalIncome = 'Income';
  final addPersonalIncome = 'Add Personal Income';
  final addPersonalExpense = 'Add Personal Expense';
  final editTransaction = 'Edit transaction';
  final category = 'Category';
  final amount = 'Amount';
  final whatFor = 'What is this for?';
  final categoryName = 'Category Name';
  final saveIncome = 'SAVE INCOME';
  final saveExpense = 'SAVE EXPENSE';
}

final class _Friends {
  const _Friends();
  final title = 'Friends';
  final tabFriends = 'Friends';
  final tabPending = 'Pending';
  final tabIncoming = 'Incoming';
  final addFriend = 'Add Friend';
  final tabSearch = 'Search';
  final tabContacts = 'Contacts';
  final searchHint = 'Search by email...';
  final searchResults = 'Search Results';
  final yourFriends = 'Your Friends';
  final inviteMembers = 'Invite Members';
  final quickSplit = 'Quick split';
  final quickSplitDefaultDescription = 'Quick split';
  final quickSplitSubmit = 'Split now';
  final settlementPromptness = 'Settlement promptness';
  final groupBreakdown = 'Group Breakdown';
  final noGroupBalances = 'No shared group balances.';
  final owesYou = 'owes you';
  final youOwe = 'you owe';
  final settledUp = 'settled up';
  final theyOweYou = 'they owe you';
  final youOweThem = 'you owe them';
  final splitRecorded = 'Split recorded!';
  final addFriendsEmpty = 'Add friends to start splitting!';
  final addFriendsEmptySubtitle = 'Tap the + icon to search by email.';
  final noPendingRequests = 'No pending requests';
  final noPendingSubtitle = 'Friend requests you send appear here.';
  final noIncomingRequests = 'No incoming requests';
  final noIncomingSubtitle = "When someone adds you, they'll show up here.";
  final friendRequestAccepted = 'Friend request accepted!';
  final friendRequestFailed = 'Failed to accept.';
  final requestCancelled = 'Request cancelled.';
  final requestCancelFailed = 'Failed to cancel.';
  final reminderSent = 'Reminder sent.';
  final reminderFailed = 'Failed to send reminder.';
  final friendRequestSent = 'Friend request sent!';
  final friendRequestSendFailed = 'Failed to send request.';
  final contactsPrivacyPrefix =
      'We only use contacts on your device to find friends already on ';
  final noUsersFound = 'No users found.';
  final searchFriendsHint = 'Search for friends by their email address';
  final contactsFromBookPrefix = 'Friends from your contact book who use ';
  final noMatchingContacts =
      'No matching contacts found.\nGrant contact access or share your invite link.';
  final promptnessFast = 'Usually settles quickly';
  final promptnessAverage = 'Average settle-up speed';
  final promptnessSlow = 'Balances tend to linger';
  final quickSplitWithPrefix = 'with ';
  final friendPaidSuffix = ' paid';
  final youOweThemShort = 'You owe them';
  final theyOweYouShort = 'They owe you';
  final whatForShort = 'What for?';
  final remind = 'Remind';
  final add = 'Add';
  final failedPrefix = 'Failed: ';
}

final class _Goals {
  const _Goals();
  final newGoal = 'New Goal';
  final createSubmit = 'CREATE GOAL';
  final history = 'History';
  final historyEmpty = 'No transactions yet.';
  final addFunds = 'ADD FUNDS';
  final withdraw = 'WITHDRAW';
  final deposit = 'Deposit';
  final withdrawal = 'Withdrawal';
  final aiEstimating = 'AI estimating...';
  final selectTargetDate = 'Select Target Date';
  final goalDeleted = 'Deleted';
  final goalSuccess = 'Success';
  final fillAllFields = 'Please fill all fields';
  final specifyGoalType = 'Please specify the goal type';
  final goalCreatedSuccess = 'Goal created successfully!';
  final failedCreateGoal = 'Failed to create goal';
  final transactionAdded = 'Transaction added';
  final failedAddTransaction = 'Failed to add transaction';
  final goalDeletedSuccess = 'Goal deleted successfully';
  final failedDeleteGoal = 'Failed to delete goal';
  final estimatedAmountFallback = 'Estimated amount based on description';
  final savingForLabel = 'What are you saving for?';
  final titleHint = 'e.g. Bali Trip';
  final specifyGoalTypeLabel = 'Specify Goal Type';
  final otherGoalTypeHint = 'e.g. Wedding';
  final describeForAi = 'Describe it (AI will help estimate costs)';
  final describeHint =
      'e.g. 5 days trip to Bali for 2 people with flight and 4-star hotel...';
  final goalThemeIcon = 'Goal Theme & Icon';
  final targetAmountLabel = 'How much do you need?';
  final targetDateLabel = 'When do you want this?';
  final addToGoal = 'Add to Goal';
  final withdrawFromGoal = 'Withdraw from Goal';
  final deleteGoalTitle = 'Delete Goal?';
  final deleteGoalBody = 'This action cannot be undone.';
}

final class _Groups {
  const _Groups();
  final newGroup = 'New Group';
  final newTrip = 'New Trip';
  final createGroup = 'Create Group';
  final groupName = 'Group Name';
  final groupNameHint = 'e.g. Weekend Trip Squad';
  final addTransaction = 'Add Transaction';
  final editTransaction = 'Edit Transaction';
  final settleUp = 'Settle Up';
  final addMember = 'Add Member';
  final addWishlist = 'Add Wishlist';
  final noGroupsYet = 'No groups yet';
  final noGroupsSubtitle = 'Create a group to split bills with friends.';
  final noActivityYet = 'No activity yet';
  final noActivitySubtitle = 'Group updates will show up here.';
  final noTransactions = 'No transactions.';
  final retry = 'Retry';
  final shareDistributionToast = 'Split shared preciously!';
  final shareDistributionTitle = 'Adjust share';
  final paidBy = 'Paid By';
  final selectRecipient = 'Select a person to pay';
  final enterAmount = 'Enter Amount';
  final writeDescription = 'Write a description';
  final writeNotes = 'Write some notes...';
  final category = 'Category';
  final sharingMode = 'Sharing mode: ';
  final sharingAmong = 'Sharing among: ';
  final transactionUpdated = 'Transaction updated successfully!';
  final splitAdded = 'Split added successfully!';
  final groupCreatedTitle = '🎉 Group Created';
  final offline = 'Offline';
  final archiveGroup = 'Archive group';
  final unarchiveGroup = 'Unarchive group';
  final exportTransactions = 'Export transactions';
  final exportCsv = 'Export as CSV';
  final exportPdf = 'Export as PDF';
  final shareInviteLink = 'Share group invite link';
  final reminderSettings = 'Reminder settings';
  final comment = 'Comment';
  final scanReceipt = 'Scan Receipt';
  final receiptExpenseCreated = 'Transaction created from receipt! 🧾';
  final planExpense = 'Plan an Expense';
  final addToWishlist = 'Add to Wishlist';
  final itemAdded = 'Item added! 🎯';
  final addAsExpense = 'Add as Expense';
  final addedCheck = 'Added ✓';
  final shareSettlement = 'Share Settlement';
  final settledBadge = 'SETTLED';
  final paid = 'Paid';
  final received = 'Received';
  final itemsTotal = 'Items total';
  final itemNameHint = 'Item name';
  final whoSharesThisItem = 'Who shares this item?';
  final addAnotherItem = 'Add another item';
  final percentSign = '%';
  final perShareSuffix = '/ share';
  final perPersonSuffix = '/ Person';
  final selectAtLeastOneMember = 'Select at least one member.';
  final invitesSent = 'Invites sent successfully!';
  final failedToSendInvitesPrefix = 'Failed to send invites: ';
  final noFriendsAvailableToAdd =
      'No friends available to add.\nTry searching by email.';
  final searchFriendsOrEmail = 'Search friends or by email...';
  final noTransactionsYet = 'No transactions yet';
  final addExpenseToStart = 'Add an expense to start splitting.';
  final deleteTransactionTitle = 'Delete Transaction';
  final deleteTransactionGroupConfirm =
      'Are you sure you want to delete this transaction from the group?';
  final transactionDeletedSuccess = 'Transaction deleted successfully';
  final tabTimeline = 'Timeline';
  final tabActivity = 'Activity';
  final tabAnalytics = 'Analytics';
  final tabSettleUp = 'Settle up';
  final tabMembers = 'Members';
  final tabWishlist = 'Wishlist';
  final createGroupNeedsInternet =
      'Creating a group requires an internet connection.';
  final couldNotCreateGroupPrefix = 'Could not create group: ';
  final csvOrPdfPro = 'CSV or PDF (Pro)';
  final featureCsvPdfExport = 'CSV & PDF Export';
  final featureAdvancedAnalytics = 'Advanced Analytics';
  final featureAiReceiptScanning = 'AI Receipt Scanning';
  final featureUpiQuickSettle = 'UPI Quick Settle';
  final analyticsGroupExpense = 'Group Expense';
  final analyticsSplitBalances = 'Split Balances & Debt';
  final analyticsContribution = 'Contribution Analysis';
  final analyticsSpendingTrends = 'Spending Trends';
  final analyticsExpenseComparison = 'Expense Comparison';
  final analyticsTopCategories = 'Top Categories';
  final noDataAvailable = 'No data available';
  final selectAGroup = 'Select a group';
  final errorLoadingCategories = 'Error loading categories';
  final noCategoriesFound = 'No categories found';
  final customCategoryNameHint = 'Enter custom category name';
  final noPlannedExpensesYet = 'No planned expenses yet';
  final noPlannedExpensesSubtitle =
      'Propose expenses the group should plan for.';
  final addFirstItem = 'Add first item';
  final whatDoYouNeed = 'What do you need?';
  final wishlistTitleHint = 'e.g. Birthday cake for Alex';
  final optional = 'Optional';
  final noSplitsYet = 'No splits yet';
  final noSplitsSubtitle = 'Add a group expense to see who owes what.';
  final allSettledUp = 'All settled up';
  final allSettledUpSubtitle = 'No outstanding balances in this group.';
  final failedRecordSettlement = 'Failed to record settlement.';
  final youAreOwed = 'YOU ARE OWED';
  final youOwe = 'YOU OWE';
  final groupExpenseTab = 'Group Expense';
  final tripExpenseTab = 'Trip Expense';
  final activeGroups = 'Active groups';
  final hideArchived = 'Hide archived';
  final showArchived = 'Show archived';
  final recentActivity = 'Recent Activity';
  final myTrips = 'My Trips';
  final recentTripActivity = 'Recent Trip Activity';
  final noRecentActivity = 'No recent activity';
  final unlockReceiptExports = 'Unlock receipt scanning & exports →';
  final emptyStateExtendedSubtitle =
      'Create a group to split bills with friends, roommates, or coworkers.';
  final leaveGroup = 'Leave group';
  final removeMemberTitle = 'Remove member?';
  final removeMemberAction = 'Remove';
  final memberRemovedTitle = 'Member removed';
  final leaveGroupTitle = 'Leave group?';
  final leaveGroupConfirm =
      'Are you sure you want to leave this group? You will lose access to its transactions.';
  final leaveGroupAction = 'Leave';
  final leftGroupTitle = 'Left group';
  final leftGroupMessage = 'You have left the group.';
  final scanReceiptSubtitle = 'Scan a receipt to auto-fill expense details';
  final camera = 'Camera';
  final gallery = 'Gallery';
  final scanningReceipt = 'Scanning receipt...';
  final onDeviceProcessing = 'Processing on device...';
  final tapMembersToAssign = 'Tap members to assign items';
  final taxGst = 'Tax / GST';
  final tipService = 'Tip / Service';
  final taxTipSplitProportionally = 'Tax & tip split proportionally';
  final perPersonBreakdown = 'Per-person breakdown';
  final upiQuickSettlePro = 'UPI Quick Settle (Pro)';
  final payViaRazorpay = 'Pay via Razorpay';
  final receiverUpiId = 'Receiver UPI ID';
  final nameUpiHint = 'name@upi';
  final payeeVpa = 'Payee VPA';
  final openUpi = 'Open UPI';
  final payeeNoUpiAccounts =
      'has not added a UPI account. Ask them to add one in Profile → Personal details.';
  final upiPaymentConfirmQuestion = 'Did you complete the UPI payment?';
  final selectPayeeBank = 'Select payee bank';
}

final class _Analytics {
  const _Analytics();
  final noTransactionData = 'No transaction data yet';
  final noComparisonData = 'No comparison data yet';
  final noExpenseDataForPeriod = 'No expense data for this period';
  final noBalanceData = 'No balance data yet';
  final noCategoryData = 'No category data yet';
  final notEnoughTrendData = 'Not enough data for trends yet.';
  final yourShare = 'Your share';
  final spendingVsGroupAverage = 'Your Spending vs Group Average';
  final spendingVsGroupAverageSubtitle =
      'Amount paid out-of-pocket vs group average paid per member';
  final youPaid = 'You paid';
  final groupAvgPaid = 'Group avg paid';
  final monthlySpendingOverview = 'Monthly Spending Overview';
  final avgPerMonth = 'Avg/Month';
  final splitBalancesAndDebt = 'Split Balances & Debt';
  final netBalanceSubtitle = 'Net balance per member (same as Settle Up)';
  final isOwed = 'Is owed';
  final owes = 'Owes';
  final topSharedExpenseCategories = 'Top Shared Expense Categories';
  final total = 'Total';
  final duration = 'Duration';
  final share = 'Share';
}

final class _Settle {
  const _Settle();
  final title = 'Settle Up';
  final swipeHint = 'Swipe to settle →';
  final flowArrow = '  →  ';
  final settled = 'Settled! 🎉';
  final recorded = 'Settlement recorded! ✅';
  final paymentReceived = 'Payment received';
  final youllPay = "You'll pay";
  final youllGet = "You'll get";
  final settledUp = 'Settled Up';
  final noTransactions = 'No transactions.';
  final notInTransaction = "You're not in";
  final owesYouTemplate = '{name} owes You {amount}';
  final youOweTemplate = 'You owe {name} {amount}';
}

final class _Profile {
  const _Profile();
  final accountInfo = 'ACCOUNT INFO';
  final appSettings = 'APP SETTINGS';
  final generous = 'GENEROUS';
  final proMember = 'PRO MEMBER';
  final justVibing = 'JUST VIBING';
  final totalSpent = 'TOTAL SPENT';
  final totalReceived = 'TOTAL RECEIVED';
  final personalDetails = 'Personal Details';
  final donate = 'Donate';
  final supportSplitr = 'Support\nSplitr';
  final achievements = 'Achievements';
  final notifications = 'Notifications';
  final today = 'Today';
  final earlier = 'Earlier';
  final noNotifications = 'No notifications yet';
  final noNotificationsSubtitle =
      'Updates about groups, friends, and goals appear here.';
  final changePhoto = 'Change photo';
  final uploading = 'Uploading...';
  final notSet = 'Not set';
  final verifyFingerprint = 'Verify your fingerprint to enable biometric lock';
  final defaultUserName = 'User';
  final personalDetailsSubtitle = 'Name, email, phone number';
  final friendsSubtitle = 'Manage your connections';
  final insightsSubtitle = 'Trends, unusual spends, settle-up health';
  final monthlyRecap = 'Monthly Recap';
  final monthlyRecapSubtitle = 'Your spending wrap-up for this month';
  final premiumPlan = 'Premium Plan';
  final premiumPlanSubtitle = 'Upgrade your experience';
  final importSplitwise = 'Import from Splitwise';
  final importSplitwiseSubtitle = 'Migrate balances via CSV';
  final smsExpenseDraft = 'SMS expense draft';
  final smsExpenseDraftSubtitle = 'Paste UPI SMS → add expense';
  final changePassword = 'Change Password';
  final changePasswordSubtitle = 'Update your account password';
  final appearance = 'Appearance';
  final appearanceSubtitle = 'Light, dark, or system theme';
  final editCurrency = 'Edit Currency';
  final editCurrencySubtitle = 'Change your default currency';
  final budgets = 'Budgets';
  final budgetsSubtitle = 'Spending caps & period alerts';
  final notificationsSubtitle = 'Expense alerts, reminders';
  final donateSubtitle = 'Support the project';
  final requestFeature = 'Request a Feature';
  final requestFeatureSubtitle = 'Tell us what you need';
  final logout = 'Logout';
  final logoutSubtitle = 'Sign out of your account';
  final splashPreview = 'Splash preview';
  final splashPreviewSubtitle = 'Loop startup animation (debug)';
  final logoutConfirmTitle = 'Are you sure?';
  final logoutConfirmBody = 'Do you really wanted to logout?';
  final biometricLock = 'Biometric Lock';
  final biometricEnabledSubtitle = 'Require auth on app open';
  final biometricUnsupportedSubtitle = 'Not supported on this device';
  final identitySection = 'IDENTITY';
  final contactSection = 'CONTACT';
  final paymentSection = 'PAYMENT';
  final upiAccountsSection = 'UPI accounts';
  final addUpiAccount = 'Add UPI account';
  final editUpiAccount = 'Edit UPI account';
  final bankLabel = 'Bank / UPI app';
  final customBankHint = 'Enter bank or app name';
  final vpaLabel = 'UPI ID (VPA)';
  final primaryBadge = 'Default';
  final setAsDefault = 'Set as default';
  final upiAccountAdded = 'UPI account added.';
  final upiAccountUpdated = 'UPI account updated.';
  final upiAccountDeleted = 'UPI account removed.';
  final maxUpiAccountsReached = 'You can add up to 5 UPI accounts.';
  final invalidVpa = 'Enter a valid UPI ID (e.g. name@bank).';
  final duplicateVpa =
      'This UPI ID is already saved on another bank account.';
  final noUpiAccounts = 'No UPI accounts added yet.';
  final deleteUpiAccountTitle = 'Remove UPI account?';
  final deleteUpiAccountBody =
      'This account will no longer appear when friends pay you.';
  final usernameHint = 'Your public username';
  final firstNameHint = 'Enter your first name';
  final lastNameHint = 'Enter your last name';
  final phone = 'Phone';
  final phoneHint = '10-digit phone number';
  final phoneExactDigits = 'Phone number must be exactly 10 digits.';
  final profileUpdated = 'Profile updated successfully.';
  final profileUpdateFailedPrefix = 'Failed to update profile: ';
  final photoUpdated = 'Profile photo updated.';
  final photoUploadFailedPrefix = 'Photo upload failed: ';
  final photoStorageUnavailable =
      'Photo upload is not available right now. Please try again later.';
  final themeLight = 'Light';
  final themeDark = 'Dark';
  final themeSystem = 'System';
}

final class _Currency {
  const _Currency();
  final title = 'Edit Currency';
  final searchHint = 'Search currencies...';
  final yourRegion = 'YOUR REGION';
  final popular = 'POPULAR';
  final allCurrencies = 'ALL CURRENCIES';
  final setPrefix = 'Currency set to ';
}

final class _SplitwiseImport {
  const _SplitwiseImport();
  final title = 'Import from Splitwise';
  final description =
      'Export a CSV from Splitwise and pick it here. We create a group and import line items as personal expenses for you to reconcile.';
  final chooseCsv = 'Choose CSV file';
  final csvNoData = 'CSV has no data rows.';
  final importComplete = 'Import complete';
  final importFailedPrefix = 'Import failed: ';
}

final class _SmsDraft {
  const _SmsDraft();
  final title = 'SMS expense draft';
  final description =
      'Paste a UPI or bank debit SMS. We extract amount and payee — no SMS access needed.';
  final hint = 'Rs 500 spent at…';
  final paste = 'Paste';
  final addExpense = 'Add expense';
  final unknownPayee = 'Unknown payee';
  final defaultMerchant = 'UPI payment';
}

final class _Budget {
  const _Budget();
  final title = 'Budgets';
  final addBudget = 'Add budget';
  final editBudget = 'Edit budget';
  final categoryLabel = 'Category';
  final limitLabel = 'Budget limit';
  final monthlyLimitLabel = 'Monthly limit';
  final emptyState = 'No budgets yet.\nSet a spending cap to track spend.';
  final overBudget = 'Over budget';
  final nearLimit = 'Near limit';
  final overallChip = 'Overall';
  final includeGroupExpenses = 'Include group expenses';
  final personalOnlyHint = 'Personal transactions only';
  final periodDaily = 'Daily';
  final periodWeekly = 'Weekly';
  final periodMonthly = 'Monthly';
  final periodQuarterly = 'Quarterly';
  final periodHalfYearly = 'Half-yearly';
  final periodYearly = 'Yearly';
  final duplicateBudget = 'A budget already exists for this category and period';
  final selectCategory = 'Select a category or Overall';
  final periodLabel = 'Period';
}

final class _Donate {
  const _Donate();
  final headline = 'Support\nSplitr';
  final contributionConfigured =
      'Your contribution helps keep Splitr free and improving for everyone.';
  final paymentsNotConfigured =
      'Payments are not configured on this build. Add RAZORPAY_KEY_ID to enable donations.';
  final chooseAmount = 'CHOOSE AN AMOUNT';
  final customAmount = 'Custom amount';
  final minAmountError = 'Enter a valid amount (min ₹1)';
  final checkoutDescription = 'Support Splitr development';
  final thankYou = 'Thank you for supporting Splitr!';
  final donateAmountPrefix = 'Donate ₹';
  final footerNote =
      '100% of donations go toward server costs, new features, and keeping the app ad-free.';
}

final class _FeatureRequest {
  const _FeatureRequest();
  final title = 'Request a Feature';
  final submitIdea = 'Submit Idea';
  final communityWishlist = 'Community Wishlist';
  final mostVoted = 'Most voted';
  final newest = 'Newest';
  final loadError = 'Could not load feature requests.';
  final emptyTitle = 'No feature requests yet.';
  final emptySubtitle = 'Be the first to submit an idea!';
  final submitNewIdea = 'Submit a new idea';
  final titleLabel = 'TITLE';
  final titleHint = 'e.g. Add UPI QR code to settle';
  final categoryLabel = 'CATEGORY';
  final descriptionLabel = 'DESCRIPTION (OPTIONAL)';
  final descriptionHint = 'Describe the feature in a bit more detail...';
  final priorityLabel = 'HOW IMPORTANT IS THIS?';
  final submitIdeaButton = 'SUBMIT IDEA';
  final ideaSubmitted = 'Idea submitted! Thanks 🙌';
  final categorySplitting = 'Splitting';
  final categoryAnalytics = 'Analytics';
  final categoryPayments = 'Payments';
  final categoryDesign = 'Design';
  final priorityNiceToHave = '🙂 Nice to have';
  final priorityReallyNeed = '😮 I really need this';
  final priorityDealBreaker = '🔥 Deal-breaker';
  final statusImplemented = 'Implemented';
  final statusClosed = 'Closed';
}

final class _Notifications {
  const _Notifications();
  final title = 'Notifications';
  final markAllRead = 'Mark all read';
  final silentRemindersTitle = 'Silent settlement reminders';
  final silentRemindersSubtitle =
      'Pause friendly local nudges about open balances';
  final pushAlertsTitle = 'Push alerts';
  final pushAlertsSubtitle = 'Choose which notifications reach this device';
  final pushFriendRequest = 'Friend requests';
  final pushGroupInvite = 'Group invites';
  final pushExpenseAdded = 'New group expenses';
  final pushSettlement = 'Settlements';
  final pushSettlementReminder = 'Settlement reminders';
  final pushLoanRequest = 'Loan requests';
  final pushBudgetAlert = 'Budget alerts';
  final pushMarketing = 'Product updates';
  final pushMarketingSubtitle = 'Off by default. Opt in for announcements.';
  final pushPrefsSaveError = 'Could not save push settings';
  final caughtUp = "You're all caught up ✓";
  final noNewRightNow = 'No new notifications right now.';
  final inviteSuccess = 'Success';
  final inviteDeclined = 'Declined';
  final inviteAccepted = 'You have joined the group!';
  final inviteRejected = 'Invite declined.';
  final loadError = 'Error loading notifications';
  final noNewNotifications = 'No new notifications';
  final needsYourAction = 'Needs your action';
  final noNewSubtitle =
      'Invites, loan requests, settlements, and other activity will appear here.';
  final processInviteError = 'Could not process invite: ';
  final actionFailed = 'Action failed: ';
  final loanAcceptedTitle = 'Loan Accepted';
  final loanRejectedTitle = 'Loan Rejected';
  final loanNowActive = 'The loan is now active.';
  final loanOfferRejected = 'You have rejected the loan offer.';
  final offeredLoan = ' offered you a loan of ';
  final requestedBorrow = ' requested to borrow ';
  final fromYou = ' from you';
  final aGroup = 'a group';
  final invitePending = 'Pending invite';
  final invitedYouToJoin = ' invited you to join ';
  final loanOffer = 'Loan offer';
  final borrowRequest = 'Borrow request';
  final loanAccepted = 'Loan accepted.';
  final loanRejected = 'Loan declined.';
}

final class _Lending {
  const _Lending();
  final tagline = 'lending,\nsimplified.';
  final active = 'Active';
  final pending = 'Pending';
  final completed = 'Completed';
  final newContract = '+ New Contract';
  final createContract = 'Create Contract';
  final requestLoan = 'Request Loan';
  final lendMoney = 'Lend Money';
  final borrowMoney = 'Borrow Money';
  final recordPayment = 'RECORD PAYMENT';
  final recordPaymentTitle = 'Record Payment';
  final eitherPartyCanLog = 'Either party can log a repayment.';
  final repaymentBreakdown = 'REPAYMENT BREAKDOWN';
  final repaymentSchedule = 'Repayment Schedule';
  final monthlyInstallments = 'Monthly installments';
  final scheduleBuildError =
      'Unable to build a repayment schedule. Check duration and due date.';
  final principal = 'Principal';
  final loanAmount = 'Loan amount';
  final totalInterest = 'Total interest';
  final monthlyEmi = 'Monthly EMI';
  final perInstallment = 'Per installment';
  final totalPayable = 'Total payable';
  final principalPaid = 'Principal paid';
  final interestPaid = 'Interest paid';
  final pay = 'Pay';
  final paid = 'Paid';
  final partial = 'Partial';
  final prepaid = 'Pre-paid';
  final missed = 'Missed';
  final upcoming = 'Upcoming';
  final paymentRecorded = 'Payment recorded';
  final contractDetails = 'Contract Details';
  final terms = 'Terms';
  final contractPdf = 'Contract PDF';
  final promissoryPdf = 'Contract PDF';
  final noActiveContracts = 'No active contracts';
  final activeEmptySubtitle = 'Lend or borrow to start a contract.';
  final noPendingOffers = 'No pending offers';
  final pendingEmptySubtitle = 'Offers awaiting acceptance appear here.';
  final noCompletedContracts = 'No completed contracts';
  final completedEmptySubtitle =
      'Closed, declined, and defaulted loans appear here.';
  final totalNetPosition = 'Total Net Position';
  final activeContractsOnly = 'Active contracts only';
  final inTheGreen = 'You are in the green';
  final oweMoreThanOwed = 'You owe more than you\'re owed';
  final awaitingTheirResponse = 'Awaiting their response';
  final awaitingYourResponse = 'Awaiting your response — check Notifications';
  final fullyRepaidToYou = 'Fully repaid to you';
  final fullyRepaid = 'Fully repaid';
  final defaulted = 'Defaulted';
  final currentDue = 'Current Due';
  final remaining = 'Remaining';
  final interestRate = 'Interest rate';
  final duration = 'Duration';
  final dueDate = 'Due date';
  final repaymentWindow = 'Repayment window';
  final totalRepaid = 'Total repaid';
  final viewRepaymentSchedule = 'View repayment schedule';
  final previewRepaymentSchedule = 'Preview repayment schedule';
  final exportContractPdf = 'Export contract (PDF)';
  final exportPromissoryNote = 'Export contract (PDF)';
  final contractPdfSummary = 'Minimal loan summary for your records';
  final formalLoanDocument = 'Minimal loan summary for your records';
  final reject = 'REJECT';
  final accept = 'ACCEPT';
  final awaitingOtherParty = 'Awaiting the other party\'s response.';
  final reviewTerms = 'Review the terms below and accept or reject.';
  final selectFriend = 'Select Friend';
  final enterEmailAddress = 'Enter email address';
  final emailTab = 'Email';
  final yearly = 'Yearly';
  final simple = 'Simple';
  final compound = 'Compound';
  final flat = 'Flat';
  final wantToLend = 'I want to lend';
  final wantToBorrow = 'I want to borrow';
  final monthlyRepaymentWindow = 'Monthly Repayment Window';
  final borrowerPayBetween =
      'Borrower should pay between these days each month:';
  final fromDay = 'From Day';
  final toDay = 'To Day';
  final toConnector = 'to';
  final sendOffer = 'SEND OFFER';
  final sendRequest = 'SEND REQUEST';
  final contractSent = 'Contract Sent!';
  final requestSent = 'Request Sent!';
  final offerSentBorrower =
      'Your loan offer has been sent to the borrower for approval.';
  final requestSentLender =
      'Your borrow request has been sent to the lender for approval.';
  final userNotFoundEmail = 'User not found with this email';
  final repaymentStartBeforeEnd =
      'Repayment start day must be on or before end day';
  final selectValidBorrower = 'Please select a valid borrower';
  final selectValidLender = 'Please select a valid lender';
  final enterValidEmail = 'Please enter a valid email';
  final cannotLoanSelf = 'You cannot create a loan with yourself';
  final createLoanFailedPrefix = 'Failed to create loan: ';
}

final class _Trips {
  const _Trips();
  final createTrip = 'Create Trip';
  final tripLedgerCurrency = 'Trip ledger currency';
  final multiCurrencyLedger = 'Multi-currency trip ledger';
  final tripName = 'Trip Name';
  final destination = 'Destination';
  final tripDates = 'Trip Dates';
  final tripCurrency = 'Trip currency';
  final tripNameHint = 'e.g. Goa Weekend 2026';
  final destinationHint = 'e.g. Goa, India';
  final selectDateRange = 'Select date range';
  final missingDatesTitle = 'Missing Dates';
  final selectTripDates = 'Please select trip dates';
  final tripCreatedTitle = '🎉 Trip Created';
  final tripCreatedMessage = 'Have an amazing trip!';
  final createFailedPrefix = 'Could not create trip: ';
  final totalSpent = 'Total Spent';
  final perDay = 'Per Day';
  final perDayAvg = 'Per Day (avg)';
  final transactions = 'Transactions';
  final mvp = 'MVP';
  final mvpLabel = '🏆 MVP';
  final topCategory = 'Top Category';
  final topCategoryLabel = '📂 Top Category';
  final biggestExpense = 'Biggest Expense';
  final biggestLabel = '💰 Biggest';
  final tripSummary = 'Trip Summary';
  final shareTrip = 'Share Trip';
  final tripCompleteShare = 'Trip complete — share your recap';
  final dayPrefix = 'Day ';
  final noExpensesDay = 'No expenses on this day';
  final daysSuffix = ' days';
  final all = 'All';
  final locationPinPrefix = '📍 ';
  final spentOverPrefix = ' spent over ';
  final sharedViaSuffix = '! Shared via ';
  final sharedViaSparkle = ' ✨';
}

final class _Insights {
  const _Insights();
  final title = 'Expense Insights';
  final screenTitle = 'Insights';
  final seeInsights = 'See insights →';
  final weeklyBriefing = 'Weekly briefing';
  final aiWeeklyBriefing = 'AI Weekly Briefing';
  final aiBriefingFeature = 'AI Briefing';
  final actionQueue = 'Action Queue';
  final smartActions = 'Smart Actions';
  final healthScores = 'Health Scores';
  final spendingCoach = 'Spending Coach';
  final socialTrust = 'Social Trust';
  final spendingTrend = 'Spending Trend';
  final spendingTrends = 'Spending Trends';
  final categories = 'Categories';
  final categoryBreakdown = 'Category Breakdown';
  final unusualExpenses = 'Unusual Expenses';
  final unusualThisMonth = 'Unusual This Month';
  final recurringBills = 'Recurring Bills';
  final likelySubscriptions = 'Likely Subscriptions';
  final aiBadge = 'AI';
  final overall = 'Overall';
  final spending = 'Spending';
  final settleUp = 'Settle-up';
  final settle = 'Settle';
  final badgeUnlocked = '🏆 Badge Unlocked';
  final proBadge = 'PRO';
  final upgradeToPro = 'Upgrade to Pro';
  final unlockFeature = 'Unlock ';
  final totalSpentThisMonth = 'Total Spent This Month';
  final recentTrend = 'Recent trend';
  final merchant = 'Merchant';
  final monthlyCharges = ' monthly charges';
  final nextApproxPrefix = ' · next ~';
  final vsLastMonth = ' vs last month';
  final noActionsNeeded = 'No actions needed — you\'re in good shape.';
  final monthEndProjection = 'Month-end projection';
  final categoryWatch = 'Category watch';
  final biggestExpense = 'Biggest expense';
  final noData = 'No data';
  final noTrendData = 'No trend data yet';
  final loadError = 'Could not load insights';
  final openExposure = 'Open exposure';
  final allClearNoBalances = 'All clear — no open balances';
  final youFrontGroupSpends = 'You front group spends';
  final settlementSpeed = 'Settlement speed';
  final staleBalances = 'Stale balances';
  final actionFallback = 'Action';
  final daySuffix = '/day';
  final atCurrentDailyBurn = 'At current daily burn of ';
  final scoreSuffix = ' score: ';
  final buildingHistoryPrefix = 'Building history — ';
  final buildingHistorySuffix = ' months tracked';
  final ofWord = ' of ';
  final acrossWord = ' across ';
  final groupSingular = 'group';
  final groupPlural = 'groups';
  final unsettled30PlusDays = ' unsettled 30+ days';
  final avgSettlementPrefix = 'Avg ';
  final avgSettlementSuffix = ' days from expense to settle-up';
  final groupExpensesThisMonth = '% of group expenses this month';
}

final class _Export {
  const _Export();
  final exportedOn = 'Exported ';
  final promissoryPrefix = 'promissory_';
}

final class _Sync {
  const _Sync();
  final syncing = 'Syncing changes...';
  final errorRetry = 'Sync error — will retry';
}

final class _Biometric {
  const _Biometric();
  final locked = 'Locked';
  final authenticating = 'Authenticating...';
  final tapToUnlock = 'Tap to unlock';
  final brandMonogram = 'S';
}

final class _Premium {
  const _Premium();
  final membership = 'PRO MEMBERSHIP';
  final plansTitle = 'Premium Plans';
  final headline = 'unlock the full\npotential.';
  final tagline = 'Charge for convenience, not your right to split.';
  final unlockWithProSuffix = ' with Pro';
  final cancelAnytime = 'Cancel anytime. No questions asked.';
  final refreshStatus = 'Refresh subscription status';
  final refreshFailedPrefix = 'Could not refresh status: ';
  final cancelSubscription = 'Cancel subscription';
  final cancelSubscriptionConfirm =
      'Cancel Pro at the end of this billing period?';
  final cancelSubscriptionFailedPrefix = 'Cancel failed: ';
  final subscriptionPending = 'Completing subscription…';
  final subscriptionCreateFailed = 'Could not start subscription checkout.';
  final subscriptionCheckoutTimeout = 'Subscription checkout timed out.';
  final subscriptionVerifyFailed = 'Payment verification failed.';
  final razorpayNotConfigured =
      'Razorpay is not configured. Add RAZORPAY_KEY_ID to continue.';
  final devPro = 'Enable dev Pro (debug only)';
  final monthly = 'Monthly';
  final yearlySave = 'Yearly  (Save 25%)';
  final yearlySaveCompact = 'Yearly (Save 25%)';
  final basic = 'BASIC';
  final currentPlan = 'CURRENT PLAN';
  final free = 'Free';
  final premium = 'PREMIUM';
  final recommended = 'RECOMMENDED';
  final onPro = "YOU'RE ON PRO ✦";
  final subscribePrefix = 'SUBSCRIBE — ';
  final purchaseFailedPrefix = 'Subscription failed: ';
  final billedAnnuallyFallback = 'Billed annually (₹66.58/mo)';
  final billedMonthlyFallback = 'Billed monthly';
  final yearlyPriceFallback = '₹799/yr';
  final monthlyPriceFallback = '₹89/mo';
  final featureUnlimitedSplitting = 'Unlimited expense splitting';
  final featureUnlimitedGroups = 'Unlimited groups';
  final featureBasicStats = 'Basic monthly stats';
  final featureStandardSupport = 'Standard support';
  final featureAiReceipt = 'AI Receipt scanning';
  final featureUpiSettle = 'UPI Quick Settle links';
  final featureAdvancedAnalytics = 'Advanced analytics';
  final featureExport = 'CSV / PDF export';
  final featureEverythingBasic = 'Everything in Basic';
  final featureAiReceiptOcr = 'AI Receipt Scanning (OCR)';
  final featureUpiSettleLinks = 'UPI Quick Settle Links';
  final featureAdvancedCharts = 'Advanced Analytics & Charts';
  final featureCsvPdfExport = 'CSV & PDF Export';
  final featureAiInsights = 'AI Insights briefing';
  final featureEliteBadge = 'Elite Splitr Badge';
  final restoreFailed = 'Restore failed';
}

final class _Reminders {
  const _Reminders();
  final settlementTitle = 'Settlement reminders';
  final settlementSubtitle = 'Friendly nudges when balances are still open.';
  final cadence = 'Cadence';
  final cadenceOff = 'Off';
  final cadenceDaily = 'Daily';
  final cadenceWeekly = 'Weekly';
  final cadenceBiweekly = 'Biweekly';
  final cadenceMonthly = 'Monthly';
  final escalatedCadence = 'Escalated reminder cadences';
  final tone = 'Tone';
  final friendly = 'Friendly';
  final casual = 'Casual';
  final formal = 'Formal';
  final professionalTone = 'Professional reminder tone';
  final muteFor = 'Mute reminders for';
}

final class _Comments {
  const _Comments();
  final title = 'Comments';
  final empty = 'Start the conversation';
  final hint = 'Add a comment...';
}

final class _Onboarding {
  const _Onboarding();
  final page1Title = 'Split Bills Instantly';
  final page1Desc =
      'Effortlessly divide expenses with friends, family, or roommates. No more awkward money conversations.';
  final page2Title = 'Track Every Penny';
  final page2Desc =
      'Get detailed spending insights, category breakdowns, and monthly recaps to stay on top of your finances.';
  final page3Title = 'Settle Up Simply';
  final page3Desc =
      'Smart debt simplification finds the fastest way to settle balances. One tap is all it takes.';
}

final class _BottomNav {
  const _BottomNav();
  final home = 'Home';
  final groups = 'Groups';
  final lending = 'Lending';
  final profile = 'Profile';
}

final class _A11y {
  const _A11y();
  final sort = 'Sort';
  final filter = 'Filter';
  final shareInviteLink = 'Share invite link';
}

final class _Recap {
  const _Recap();
  final noPriorMonthData = 'No prior month data';
  final unavailableTrend = '—';
  final noSpendingData = 'No spending data found for this month.';
  final readyToShare = 'READY TO SHARE';
  final thisMonthISpent = 'This month\nI spent';
  final poweredBy = 'POWERED BY';
  final tagline = '"Better experiences, better\nrewards, better rules."';
  final shareRecap = 'SHARE RECAP';
  final sharePackPreviewTitle = 'Share Pack';
  final sharePackOnSplitr = 'This month on Splitr';
  final sharePackPersonaPraise = 'Splitting bills like a pro.';
  final sharePackGoalHit = 'Goal hit';
  final includeMySpendInShare = 'Include my spend in share text';
  final shareWebLink = 'Copy web link';
  final backToProfile = 'BACK TO PROFILE';
  final moneyMovedSubtitle = "HERE'S HOW YOUR MONEY MOVED THIS MONTH";
  final spendingPatterns = 'Your spending patterns\nacross categories.';
  final viewFullRecap = 'VIEW FULL RECAP';
  final totalSpentThisMonth = 'TOTAL SPENT THIS MONTH';
  final spendingTrend = 'SPENDING TREND';
  final trendHigh = 'HIGH';
  final trendLow = 'LOW';
  final topCategories = 'TOP CATEGORIES';
  final chartEllipsis = '...';
  final noCategoricalData = 'No categorical data available';
  final next = 'NEXT';
  final securedByCredProtect = 'SECURED BY CRED PROTECT';
  final securedBySplitr = 'POWERED BY SPLITR';
  final your = 'Your';
  final favourite = 'favourite';
  final splitrId = 'SPLITR • ID 8821';
  final spentMostOn = 'You spent the most on';
  final impact = 'IMPACT';
  final ofTotalSpend = 'of your total spend';
  final tasteTagline =
      'Your taste is impeccable, just like your credit\nscore.';
  final categoryDominatedQuip = 'dominated your wallet this month.';
  final weekendSplurger = 'Weekend Splurger';
  final weekendSplurgerDesc =
      'Most of your spending landed on Saturdays and Sundays.';
  final weekdayGrinder = 'Weekday Grinder';
  final weekdayGrinderDesc =
      'You spend more on weekdays than weekends — steady work-week rhythm.';
  final steadySpender = 'Steady Spender';
  final steadySpenderDesc =
      'Your spending is spread evenly across the week.';
  final quietMonthHabit = 'Quiet Month';
  final quietMonthHabitDesc =
      'Not enough transactions this month to spot a clear rhythm yet.';
  final nextInsight = 'NEXT INSIGHT';
  final yourSpending = 'your spending';
  final habit = 'habit.';
  final averageDailySpend = 'AVERAGE DAILY SPEND';
  final trend = 'TREND';
  final weekendWarrior = 'Weekend Warrior';
  final weekendWarriorDesc =
      'Most of your high-value transactions happened on Saturdays and Sundays.';
  final biggest = 'Biggest';
  final payment = 'Payment';
  final biggestPaymentMade = 'Biggest payment you made';
  final vsLastMonth = 'vs Last Month';
  final categoryRank = 'Category Rank';
  final rankFirst = '#1';
  final seeSummary = 'SEE SUMMARY';
  final moneyEmoji = '💸';
  final perDay = '/day';
  final recapSuffix = ' RECAP';
  final shareImageLead = "Here's my spending wrap-up for this month! 🚀";
  final shareWebLead = 'My Splitr monthly recap:';
  final errorSharingWeb = 'Error sharing web recap:';
  final errorSharingImage = 'Error sharing recap:';
  final comparedToPrefix = 'compared to ';
  final splitSquad = 'Split';
  final squad = 'Squad';
  final splitWithGroups = 'You split with';
  final groupsThisMonth = 'groups this month';
  final topGroupLabel = 'Most active group';
  final topSplitBuddy = 'Top split buddy';
  final youFronted = 'You fronted';
  final ofGroupSpend = 'of group spend';
  final avgSettlement = 'Avg settlement';
  final daysUnit = 'days';
  final loansAnd = 'Loans &';
  final repayments = 'Repayments';
  final activeLoans = 'Active loans';
  final outstanding = 'Outstanding';
  final repaidThisMonth = 'Repaid this month';
  final loanPayments = 'Loan payments';
  final topLoan = 'Top loan';
  final disciplineLine = 'Steady repayments. Keep the ledger clean.';
  final goalsAnd = 'Goals';
  final momentum = 'Momentum';
  final addedThisMonth = 'Added this month';
  final activeGoals = 'Active goals';
  final topGoal = 'Top goal';
  final goalsOnTrack = 'On track — keep stacking.';
  final goalsNeedsPush = 'Needs push — deadline closing in.';
  final goalTargetHit = 'Target hit this month!';
  final yourPersona = 'Your';
  final persona = 'Persona';
  final badgeUnlocked = 'Badge unlocked';
  final personaSettlementHero = 'Settlement Hero';
  final personaSettlementHeroSub = 'You closed loops fast this month.';
  final personaGoalGrinder = 'Goal Grinder';
  final personaGoalGrinderSub = 'Savings ate a real share of spend.';
  final personaGroupHost = 'Group Host';
  final personaGroupHostSub = 'You fronted the squad.';
  final personaQuietMonth = 'Quiet Month';
  final personaQuietMonthSub = 'Spend cooled off — nice restraint.';
  final personaSocialSplitter = 'Social Splitter';
  final personaSocialSplitterSub = 'Groups carried your money story.';
  final personaSteadySplitter = 'Steady Splitter';
  final personaSteadySplitterSub = 'Balanced month — keep the rhythm.';
  final statSettlements = 'Settlements';
  final statGroups = 'Groups';
  final statSaved = 'Saved';
  final statSpendShare = 'Of spend saved';
  final statFronted = 'Fronted';
  final statSpendChange = 'Spend change';
  final statSpent = 'Spent';
  final shareToStory = 'Share to Story';
  final shareToFeed = 'Share square (feed)';
  final saveImage = 'Save image';
  final saveSquareImage = 'Save square image';
  final shareImageFailed = 'Could not create recap image.';
}

final class _Upi {
  const _Upi();
  final selectBank = 'Select bank or UPI app';
  final otherBank = 'Other';
}

final class _Durations {
  const _Durations();
  final daily = 'Daily';
  final weekly = 'Weekly';
  final monthly = 'Monthly';
  final yearly = 'Yearly';
}

final class _Services {
  const _Services();
  final auth = const _ServiceAuth();
  final ai = const _ServiceAi();
  final deepLink = const _ServiceDeepLink();
  final export_ = const _ServiceExport();
  final insights = const _ServiceInsights();
  final activity = const _ServiceActivity();
  final realtime = const _ServiceRealtime();
  final budget = const _ServiceBudget();
  final biometric = const _ServiceBiometric();
  final payment = const _ServicePayment();
  final reminders = const _ServiceReminders();
}

final class _ServiceAuth {
  const _ServiceAuth();
  final somethingWentWrong = 'Something went wrong.';
  final invalidUserDetails = 'Invalid user details!';
  final loggedOutSuccess = 'Logged out successfully.';
  final signUpFailed = 'Sign up failed! Please try again.';
  final unexpectedError = 'An unexpected error occurred.';
  final googleNoIdToken = 'Google sign-in did not return an ID token.';
  final googleSignInFailed = 'Google Sign In failed.';
  final emailAlreadyRegisteredUseGoogle =
      'This email is already registered. Sign in with Google.';
  final verifyEmailBeforeGoogle =
      'Verify your email before signing in with Google.';
  final enterEmailFirst = 'Enter your email address first.';
  final passwordResetSent = 'Password reset link sent. Check your email.';
  final tooManyResetEmails =
      'Too many reset emails. Wait a minute and try again.';
  final couldNotSendResetLink = 'Could not send reset link. Try again.';
  final rateLimitKeyword = 'rate limit';
}

final class _ServiceAi {
  const _ServiceAi();
  final deadlineFuture = 'Deadline must be in the future';
  final keyNotConfigured =
      'AI key not configured. Please enter amount manually.';
  final couldNotEstimate = 'Could not estimate cost. Please enter manually.';
  final monthlyBriefing = 'Your monthly briefing';
  final monthlySnapshotPrefix = 'Your ';
  final monthlySnapshotSuffix = ' snapshot';
  final monthlyFallback = 'monthly';
  final settleGroupBalances = 'Settle group balances';
  final stillOpen = ' still open';
  final reviewSpendingPrefix = 'Review ';
  final reviewSpendingSuffix = ' spending';
  final topCategoryReason = 'Your top category this month';
  final isoDateSplit = 'T';
}

final class _ServiceDeepLink {
  const _ServiceDeepLink();
  final googleSignInIncomplete = 'Google sign-in could not be completed.';
  final signInToAccept = 'Sign in to accept this invite';
  final signInQueued =
      'Sign in to accept this invite — we\'ll open it after login';
  final friendRequestSent = 'Friend request sent!';
  final joinedGroup = 'Joined group!';
  final couldNotProcessInvite = 'Could not process invite: ';
}

final class _ServiceExport {
  const _ServiceExport();
  final exportedPrefix = 'Exported ';
  final totalRows = 'Total rows: ';
  final combinedAmount = 'Combined amount: ';
  final generatedBy = 'Generated by ';
  final promissoryNote = 'PROMISSORY NOTE';
  final loanContract = 'Loan Contract';
  final loanAgreementSummary = 'LOAN AGREEMENT SUMMARY';
  final contractRefPrefix = 'Ref: ';
  final principalLabel = 'Principal';
  final interestAccrued = 'Interest accrued';
  final emiLabel = 'EMI';
  final perMonth = ' / month';
  final parties = 'PARTIES';
  final termsSection = 'TERMS';
  final startDate = 'Start date';
  final maturity = 'Maturity';
  final interestRateLabel = 'Interest rate';
  final durationLabel = 'Duration';
  final repaymentWindowLabel = 'Repayment window';
  final currencyLabel = 'Currency';
  final contractStatus = 'Status';
  final statusPendingAcceptance = 'Pending acceptance';
  final statusActive = 'Active';
  final statusRejected = 'Rejected';
  final statusCompleted = 'Completed';
  final statusDefaulted = 'Defaulted';
  final contractSubject = 'Contract — ';
  final contractShareText = ' loan contract';
  final contractDisclaimer =
      'This document is an informal peer-to-peer lending record. It does not constitute legal advice.';
  final generatedVia = 'Generated ';
  final via = ' via ';
  final promissoryBodyPrefix =
      'FOR VALUE RECEIVED, the undersigned Borrower promises to pay the Lender the principal sum of ';
  final promissoryBodyMid = ', together with interest computed as ';
  final interestAt = ' interest at ';
  final percentPer = '% per ';
  final year = 'year';
  final month = 'month';
  final commencing = ', commencing ';
  final lender = 'Lender: ';
  final borrower = 'Borrower: ';
  final maturityDate = 'Maturity date: ';
  final repaymentSummary = 'Repayment summary';
  final totalPayable = 'Total payable: ';
  final estimatedEmi = 'Estimated EMI (';
  final installments = ' installments): ';
  final installmentSchedule = 'Installment schedule';
  final legalDisclaimer =
      'This document is generated for informal peer-to-peer lending records and does not constitute legal advice.';
  final promissorySubject = 'Promissory note — ';
  final promissoryShareText = ' loan promissory note';
  final transactionExportSubject = ' — transaction export';
  final transactionExportText = ' export for ';
  final pdfExportSubject = ' — PDF export';
  final pdfExportText = ' PDF export for ';
  final paidBy = 'Paid By';
  final sharedWith = 'Shared With';
  final date = 'Date';
  final description = 'Description';
  final amount = 'Amount';
  final type = 'Type';
  final dueWindow = 'Due window';
  final status = 'Status';
  final hashSymbol = '#';
}

final class _ServiceInsights {
  const _ServiceInsights();
  final noSpendingDigest =
      'No tracked spending this month — your wallet stayed quiet.';
  final spentPrefix = 'You spent ';
  final inMonth = ' in ';
  final upFromLastMonth = 'up ';
  final downFromLastMonth = 'down ';
  final percentFromLastMonth = '% from last month';
  final steadyVsLastMonth = 'steady vs last month';
  final topCategoryPrefix = 'Top category: ';
  final balancesHealthy = 'Group balances look healthy. ';
  final balancesOpen =
      'Several group balances are still open — consider settling up. ';
  final unusualSpikePrefix = 'Unusual spike: ';
  final unsettledAcrossPrefix = ' unsettled across ';
  final groupSingular = ' group';
  final groupPlural = ' groups';
  final trustScoreSuffix = ' — see your trust score';
  final spendingUpPrefix = 'Spending up ';
  final spendingUpSuffix = '% this month — see what\'s driving it';
  final spendingDownPrefix = 'Spending down ';
  final spendingDownSuffix = '% — see your full breakdown';
  final promoGeneric =
      'New: AI spending briefing — tap to preview your insights';
  final overallExplanation =
      'Average of spending and settle-up scores. Higher means healthier finances.';
  final spendingJumped = 'Spending jumped ';
  final spendingUpReview = 'Spending is up ';
  final reviewTopCategories = '% — review top categories.';
  final spendingDownNice = 'Spending is down ';
  final niceRestraint = '% — nice restraint.';
  final spendingSteady = 'Spending is steady compared to last month.';
  final noOpenBalances = 'No open group balances — you\'re all settled.';
  final openBalancesTrust = ' in open balances — settling up improves trust.';
  final balancesSmall = 'Most balances are small — keep settling regularly.';
  final staleOpenPrefix = ' open for 30+ days';
  final acrossGroupsPrefix = ' across ';
  final groupsSuffix = ' groups';
  final upThisMonthPrefix = 'Up ';
  final thisMonthSuffix = '% this month (';
  final checkUnusualPrefix = ' — ';
  final goalFundedPrefix = ' is ';
  final goalFundedSuffix = '% funded';
  final vsLastMonth = ' vs last month.';
  final noActionAvailable = 'No action available';
}

final class _ServiceActivity {
  const _ServiceActivity();
  final owesAmount = ' owes ';
}

final class _ServiceRealtime {
  const _ServiceRealtime();
  final expenseToastPrefix = '💰 ';
  final expenseToastSeparator = ' — ';
  final newFriendRequest = '👋 New friend request!';
}

final class _ServiceBudget {
  const _ServiceBudget();
  final overBudgetPrefix = 'Over budget: ';
  final nearBudgetPrefix = 'Near budget: ';
  final overBodyPrefix = 'You spent ';
  final overBodyMid = ' in this period, above your ';
  final overBodySuffix = ' cap.';
  final nearBodyPrefix = 'You\'ve used ';
  final nearBodyMid = ' of your ';
  final nearBodySuffix = ' budget for this period.';
}

final class _ServiceBiometric {
  const _ServiceBiometric();
  final authenticateReason = 'Authenticate to unlock ';
  final notAvailable = 'Biometrics are not available on this device.';
  final setupFingerprint = 'Set up fingerprint unlock in device settings.';
  final tooManyAttempts = 'Too many attempts. Try again later.';
  final authFailed = 'Authentication failed. Tap to retry.';
}

final class _ServicePayment {
  const _ServicePayment();
  final razorpayKeyMissing =
      'Add RAZORPAY_KEY_ID to .env or --dart-define to enable payments.';
  final checkoutOpenFailed = 'Could not open Razorpay checkout.';
  final paymentFailed = 'Payment failed';
  final externalWalletPrefix = 'External wallet: ';
  final themeColor = '#18C595';
}

final class _ServiceReminders {
  const _ServiceReminders();
  final settlementChannelName = 'Settlement Reminders';
  final settlementChannelDesc = 'Friendly reminders to settle up';
  final budgetChannelName = 'Budget Alerts';
  final budgetChannelDesc = 'Spending cap warnings';
  final notificationTitleSeparator = ' — ';
  final namePlaceholder = '{name}';
  final amountPlaceholder = '{amount}';
  final groupPlaceholder = '{group}';
}

/// Helpers for templates with placeholders.
abstract final class AppStringFormat {
  static String owesYou(String name, String amount) => '$name owes You $amount';

  static String youOwe(String name, String amount) => 'You owe $name $amount';

  static String paidBy(String name) => 'Paid by $name';

  static String groupCount(int count) => count == 1 ? ' group' : ' groups';

  static String shareCount(int count) => count == 1 ? 'share' : 'shares';

  static String noUsersFoundFor(String query) =>
      'No users found for "$query".';

  static String inviteCount(int count) => 'Invite ($count)';

  static String groupReady(String groupName) => '$groupName is ready!';

  static String errorWithDetail(Object error) => 'Error: $error';

  static String exportFailedWithDetail(Object error) => 'Export failed: $error';

  static String somethingWentWrongWithDetail(Object error) =>
      'Something went wrong! \n$error';

  static String payeeNoUpiManualEntry(String payeeName) =>
      '$payeeName has not added a UPI account yet. Enter their UPI ID below to pay.';

  static String bySharingMode(String mode) => 'By $mode';

  static String addedBy(String name) => 'Added by $name';

  static String estimatedAmountLabel(String symbol) =>
      'Estimated Amount ($symbol)';

  static String removeMemberFromGroup(String name) =>
      'Remove $name from this group?';

  static String memberWasRemoved(String name) => '$name was removed.';

  static String transfersNeeded(int count) =>
      '$count transfer${count == 1 ? '' : 's'} needed';

  static String fromGroupsCount(int count) =>
      'from $count ${count == 1 ? 'group' : 'groups'}';

  static String toGroupsCount(int count) =>
      'to $count ${count == 1 ? 'group' : 'groups'}';

  static String upgradeToBrandPro(String brandPro) =>
      'Upgrade to $brandPro';

  static String itemsFound(int count) =>
      '$count item${count == 1 ? '' : 's'} found';

  static String totalWithSymbol(String symbol, String amount) =>
      'Total: $symbol$amount';

  static String settlementShareText(
    String fromName,
    String symbol,
    String amount,
    String toName,
    String brandName,
  ) =>
      '$fromName settled $symbol$amount with $toName on $brandName!';

  static String settleWith(String name) => 'Settle with $name';

  /// UPI transaction note (kept short for PSP limits).
  static String upiSettleNote(String payeeName) {
    const maxLen = 50;
    final trimmed = payeeName.trim();
    const prefix = '${AppBranding.brandPro} - squaring up with ';
    final note = '$prefix$trimmed';
    if (note.length <= maxLen) return _sanitizeUpiNote(note);
    final allowed = maxLen - prefix.length - 1;
    if (allowed < 1) return _sanitizeUpiNote('${AppBranding.brandPro} settle-up');
    return _sanitizeUpiNote('$prefix${trimmed.substring(0, allowed)}');
  }

  static String _sanitizeUpiNote(String note) {
    return note
        .replaceAll(RegExp(r'[^\w\s@.\-&,]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static String settlementRecordedToast(String payeeName) =>
      'Squared up with $payeeName! ${AppBranding.brandPro} says '
      'friendship restored - no awkward reminders needed';

  static String dontOwnMoneyTo(String name) =>
      "You don't own any money to $name";

  static String onlyOweAmount(String symbol, String amount) =>
      'You only owe $symbol$amount';

  static String peopleCount(int count) => count == 1 ? 'Person' : 'People';

  static String itemLabel(int index) => 'Item $index';

  static String amountOfTotal(String symbol, String current, String total) =>
      '$symbol$current of $symbol$total';

  static String amountLeft(String symbol, String amount) =>
      '$symbol$amount left';

  static String percentageOfTotal(String current, int total) =>
      '$current% of $total%';

  static String percentageLeft(String remaining) => '$remaining% left';

  static String perShareRate(String symbol, String amount) =>
      '$symbol$amount ${AppStrings.groups.perShareSuffix}';

  static String perPersonRate(String symbol, String amount) =>
      '$symbol$amount ${AppStrings.groups.perPersonSuffix}';

  static String sharesTotalCount(int count) =>
      '($count ${shareCount(count)} total)';

  /// Preserves legacy plural label "Peoples" in even-share tab.
  static String evenSharePeopleLabel(int count) =>
      '($count ${count > 1 ? 'Peoples' : 'People'})';

  static String splitAmountsMustEqual(String symbol, String amount) =>
      'Split amounts must equal $symbol$amount';

  static String itemTotalsMustEqual(String symbol, String amount) =>
      'Item totals must equal $symbol$amount';

  static String percentagesMustAddUp(String current) =>
      'Percentages must add up to 100% (currently $current%)';

  static String confirmSettlement(String symbol, String amount) =>
      'Confirm settlement of $symbol$amount';

  static String settlementRecorded(
          String fromName, String symbol, String amount) =>
      '$fromName recorded a settlement of $symbol$amount';

  static String friendRequestTitle(String senderName) =>
      '$senderName sent you a friend request';

  static String friendRequestBody(String brandName) =>
      'Open $brandName to accept.';

  static String fullName(String? firstName, String? lastName) =>
      '${firstName ?? ''} ${lastName ?? ''}'.trim();

  static String monthYearLabel(String monthAbbr, int year) =>
      '$monthAbbr$AppSeparators.monthYearJoiner$year';

  static String payerGroupDedupeKey(String payerId, String groupId) =>
      '$payerId${AppSeparators.compositeKeyJoiner}$groupId';

  static String groupCategoryDedupeKey(String groupId, String category) =>
      '$groupId${AppSeparators.compositeKeyJoiner}$category';

  static String progressPercent(int value) => '$value%';

  static String daySpendTotal(String symbol, String amount) =>
      '$symbol$amount${AppStrings.home.chartSpentSuffix}';

  static String categoryShareLine(
    String category,
    String symbol,
    String amount,
    int pct,
  ) =>
      '$category: $symbol$amount ($pct%)';

  static String currencySet(String name, String symbol) =>
      '${AppStrings.currency.setPrefix}$name ($symbol)';

  static String splitwiseImportSuccess(String groupName, int imported) =>
      'Created group "$groupName" and imported $imported expense rows. Review and move into the group as needed.';

  static String monthlyLimit(String symbol) =>
      '${AppStrings.budget.monthlyLimitLabel} ($symbol)';

  static String budgetLimit(String symbol) =>
      '${AppStrings.budget.limitLabel} ($symbol)';

  static String donateAmount(double amount) =>
      '${AppStrings.donate.donateAmountPrefix}${amount.toStringAsFixed(0)}';

  static String unlockFeature(String feature) =>
      'Unlock $feature${AppStrings.premium.unlockWithProSuffix}';

  static String premiumSubscribe(String price) =>
      '${AppStrings.premium.subscribePrefix}$price';

  static String amountCompact(String symbol, double value) {
    String trimDecimal(double v) {
      if (v == v.truncateToDouble()) return v.truncate().toString();
      return v.toStringAsFixed(1);
    }

    final abs = value.abs();
    if (abs >= 1e7) {
      return '$symbol${trimDecimal(abs / 1e7)}${AppAmountSuffix.crore}';
    }
    if (abs >= 1e5) {
      return '$symbol${trimDecimal(abs / 1e5)}${AppAmountSuffix.lakh}';
    }
    if (abs >= 1e3) {
      return '$symbol${trimDecimal(abs / 1e3)}${AppAmountSuffix.thousand}';
    }
    return '$symbol${abs.toStringAsFixed(0)}';
  }

  static String timeAgoMinutes(int minutes) =>
      '$minutes${AppStrings.dates.minutesAgoSuffix}';

  static String timeAgoHours(int hours) =>
      '$hours${AppStrings.dates.hoursAgoSuffix}';

  static String timeAgoDays(int days) =>
      '$days${AppStrings.dates.daysAgoSuffix}';

  static String insightsPercentVsLastMonth(String pct) =>
      '$pct${AppStrings.insights.vsLastMonth}';

  static String insightsSeeAllActions(int count) => 'See all $count actions';

  static String insightsDailyBurnSubtitle(String symbol, String dailyBurn) =>
      '${AppStrings.insights.atCurrentDailyBurn}$symbol$dailyBurn${AppStrings.insights.daySuffix}';

  static String insightsCategoryWatchSubtitle(
    String pct,
    String symbol,
    String amount,
  ) =>
      '$pct${AppStrings.insights.vsLastMonth}${AppSeparators.bullet}$symbol$amount';

  static String insightsBiggestExpenseSubtitle(
    String symbol,
    String amount,
    String category,
  ) =>
      '$symbol$amount${AppSeparators.bullet}$category';

  static String insightsBuildingHistory(int tracked, int total) =>
      '${AppStrings.insights.buildingHistoryPrefix}$tracked${AppStrings.insights.ofWord}$total${AppStrings.insights.buildingHistorySuffix}';

  static String insightsOpenExposure(
    String symbol,
    String amount,
    int groupCount,
  ) =>
      '$symbol$amount${AppStrings.insights.acrossWord}$groupCount ${groupCount == 1 ? AppStrings.insights.groupSingular : AppStrings.insights.groupPlural}';

  static String insightsPayerRatio(String pct) =>
      '$pct${AppStrings.insights.groupExpensesThisMonth}';

  static String insightsSettlementSpeed(int days) =>
      '${AppStrings.insights.avgSettlementPrefix}$days${AppStrings.insights.avgSettlementSuffix}';

  static String insightsStaleBalances(String symbol, String amount) =>
      '$symbol$amount${AppStrings.insights.unsettled30PlusDays}';

  static String insightsMonthlyCharges(int count) =>
      '$count${AppStrings.insights.monthlyCharges}';

  static String insightsScoreBreakdown(String label, int score) =>
      '$label${AppStrings.insights.scoreSuffix}$score';

  static String chartTooltip(String label, String symbol, String amount) =>
      '$label: $symbol$amount';

  static String paidAmount(String symbol, String amount) =>
      '${AppStrings.groups.paid} $symbol$amount';

  static String shareAmount(String symbol, String amount) =>
      '${AppStrings.analytics.share} $symbol$amount';

  static String isOwedAmount(String symbol, String amount) =>
      '${AppStrings.analytics.isOwed} $symbol$amount';

  static String owesAmount(String symbol, String amount) =>
      '${AppStrings.analytics.owes} $symbol$amount';

  static String truncateChartLabel(String name, int maxLength) {
    if (name.length > maxLength) {
      return '${name.substring(0, maxLength - 1)}${AppSeparators.ellipsis}';
    }
    return name;
  }

  static String recapTrendVsMonth(String signedPct, String prevMonth) =>
      '$signedPct${AppDisplaySymbols.percent} vs $prevMonth';

  static String recapSignedPercent(String signedPct, {int decimals = 0}) =>
      '$signedPct${AppDisplaySymbols.percent}';

  static String recapSignedPercentFromValue(
    double pct, {
    int decimals = 1,
  }) {
    final sign = pct > 0 ? '+' : '';
    return '$sign${pct.toStringAsFixed(decimals)}${AppDisplaySymbols.percent}';
  }

  static String recapDateRange(String start, String end, int year) =>
      '$start${AppSeparators.recapDateRange}$end, $year';

  static String recapNameTitle(String firstName, String monthNameTitle) =>
      '$firstName $monthNameTitle${AppStrings.recap.recapSuffix}';

  static String yourMonthRecap(String monthName) => 'Your\n$monthName\nRecap';

  static String monthYearCaps(String monthName, int year) =>
      '${monthName.toUpperCase()} $year';

  static String comparedToMonth(String prevMonthName) =>
      '${AppStrings.recap.comparedToPrefix}$prevMonthName';

  static String impactPercent(int value) =>
      '$value${AppDisplaySymbols.percent}';

  static String monthlyRecapLabel(String monthName) =>
      'MONTHLY RECAP${AppSeparators.bullet}${monthName.toUpperCase()}';

  static String categoryWithBrand(String category) =>
      '$category${AppSeparators.bullet}SPLITR';

  static String settlementsClosedShare(int count) =>
      '$count settlements closed this month';

  static String goalProgressPercent(double percent) =>
      '${percent.round()}% to goal';

  static String shareWebRecap(String url) =>
      '${AppStrings.recap.shareWebLead} $url ${AppBranding.shareHashtag}';

  static String shareImageRecap() =>
      '${AppStrings.recap.shareImageLead} ${AppBranding.shareHashtag}';

  static String recapFilename(int timestamp) =>
      '${FilenamePatterns.monthlyRecapPrefix}$timestamp${FilenamePatterns.shareCardSuffix}';

  static String recapSquareFilename(int timestamp) =>
      '${FilenamePatterns.monthlyRecapPrefix}$timestamp${FilenamePatterns.shareCardSuffix}_square';

  static String recapDropReady(String monthName) =>
      'Your $monthName recap so far';

  static String shortAmountK(double val) =>
      '${(val / 1000).toStringAsFixed(1)}k';

  static String dueOn(String formatted) => 'Due $formatted';

  static String endsOn(String formatted) => 'Ends on $formatted';

  static String payBetween(String start, String end) =>
      'Pay between $start${AppSeparators.weekRange}$end';

  static String monthLabel(int index) => 'Month $index';

  static String paidOfAmount(String symbol, String paid, String total) =>
      '$symbol$paid paid of $symbol$total';

  static String interestRateWithPeriod(String period) =>
      'Interest Rate ($period)';

  static String repaymentWindowMonthly(int start, int end) =>
      'Day $start${AppSeparators.weekRange}$end each month';

  static String currentInstallmentDue(String symbol, String amount) =>
      'Current installment due: $symbol$amount';

  static String remainingBalance(String symbol, String amount) =>
      'Remaining balance: $symbol$amount';

  static String tripDurationDays(int days) =>
      '$days${AppStrings.trips.daysSuffix}';

  static String tripDayNumber(int dayNumber) =>
      '${AppStrings.trips.dayPrefix}$dayNumber';

  static String tripDateRange(String start, String end) =>
      '$start${AppSeparators.flowArrow}$end';

  static String tripShareCardDateRange(
    String start,
    String end,
    int year,
    int days,
  ) =>
      '$start${AppSeparators.weekRange}$end, $year  •  ${tripDurationDays(days)}';

  static String tripShareMessage({
    required String tripName,
    required String symbol,
    required String spentAmount,
    required int totalDays,
  }) =>
      '$tripName — $symbol$spentAmount${AppStrings.trips.spentOverPrefix}'
      '${tripDurationDays(totalDays)}${AppStrings.trips.sharedViaSuffix}'
      '${AppBranding.brandName}${AppStrings.trips.sharedViaSparkle}';
}

abstract final class AppAmountSuffix {
  static const crore = 'Cr';
  static const lakh = 'L';
  static const thousand = 'K';
}
