/// SharedPreferences, env, Supabase schema, and map key constants.
abstract final class EnvFiles {
  static const dotenv = '.env';
  static const example = '.env.example';
  static const dartDefineFile = 'env.json';
}

abstract final class SupabaseRelationKeys {
  static const lender = 'lender';
  static const borrower = 'borrower';
}

abstract final class PrefKeys {
  static const hasSeenOnboarding = 'hasSeenOnboarding';
  static const themeMode = 'theme_mode';
  static const selectedCurrency = 'selected_currency';
  static const premiumActive = 'premium_active';
  static const premiumExpiresAt = 'premium_expires_at';
  static const notificationsLastViewedAt = 'notifications_last_viewed_at';
  static const pendingDeepLinkUri = 'pending_deep_link_uri';
  static const biometricLockEnabled = 'biometric_lock_enabled';
  static const fxRatesCache = 'fx_rates_cache';
  static const fxRatesTimestamp = 'fx_rates_timestamp';
  static const budgetAlertSentV1 = 'budget_alert_sent_v1';
  static const insightsBriefingPayload = 'insights_briefing_payload';
  static const insightsBriefingMonthSpend = 'insights_briefing_month_spend';
  static const insightsBriefingCachedAt = 'insights_briefing_cached_at';
  static const insightsBriefingGeneratedAt = 'insights_briefing_generated_at';
  static const insightsBriefingSpendSnapshot =
      'insights_briefing_spend_snapshot';
  static const personalCategoriesV1 = 'personal_categories_v1';
  static const remindersSilentMode = 'reminders_silent_mode';
  static const reminderSettingsPrefix = 'reminder_settings_';
  static const insightsPromoDismissedAt = 'insights_promo_dismissed_at';
  static const insightsPromoSessionShown = 'insights_promo_session_shown';
  static const recapLastViewedMonth = 'recap_last_viewed_month';
  static const recapDropSeen = 'recap_drop_seen';
  static const recapDropNotifiedPrefix = 'recap_drop_notified_';
  static const lastUsedLoginMethod = 'last_used_login_method';
}

abstract final class SupabaseTables {
  static const groups = 'groups';
  static const groupMembers = 'group_members';
  static const groupTransaction = 'group_transaction';
  static const groupBalance = 'group_balance';
  static const users = 'users';
  static const personalTransaction = 'personal_transaction';
  static const masterProductCategory = 'master_product_category';
  static const friends = 'friends';
  static const shareableInvites = 'shareable_invites';
  static const publicShareLinks = 'public_share_links';
  static const tripMetadata = 'trip_metadata';
  static const groupWishlists = 'group_wishlists';
  static const wishlistUpvotes = 'wishlist_upvotes';
  static const activityReactions = 'activity_reactions';
  static const activityComments = 'activity_comments';
  static const notifications = 'notifications';
  static const deviceTokens = 'device_tokens';
  static const pushPreferences = 'push_preferences';
  static const reminderSettings = 'reminder_settings';
  static const personalBudgets = 'personal_budgets';
  static const financialGoals = 'financial_goals';
  static const goalTransactions = 'goal_transactions';
  static const loanPayments = 'loan_payments';
  static const loans = 'loans';
  static const groupCustomCategory = 'group_custom_category';
  static const personalCustomCategory = 'personal_custom_category';
  static const featureRequests = 'feature_requests';
  static const featureRequestVotes = 'feature_request_votes';
  static const groupInvites = 'group_invites';
  static const userUpiAccounts = 'user_upi_accounts';
  static const masterUpiBank = 'master_upi_bank';
  static const premiumSubscriptions = 'premium_subscriptions';
  static const achievements = 'achievements';
  static const userAchievements = 'user_achievements';
}

abstract final class SupabaseColumns {
  static const groupId = 'group_id';
  static const groupName = 'group_name';
  static const groupBalance = 'group_balance';
  static const transactionId = 'transaction_id';
  static const transactionGroupId = 'transaction_group_id';
  static const paidBy = 'paid_by';
  static const sharedWith = 'shared_with';
  static const sharingType = 'sharing_type';
  static const isSettledUp = 'is_settled_up';
  static const exchangeRateToInr = 'exchange_rate_to_inr';
  static const userId = 'user_id';
  static const firstname = 'firstname';
  static const lastname = 'lastname';
  static const userName = 'user_name';
  static const userEmail = 'user_email';
  static const profilePictureUrl = 'profile_picture_url';
  static const isPremium = 'is_premium';
  static const premiumExpiresAt = 'premium_expires_at';
  static const currency = 'currency';
  static const isArchived = 'is_archived';
  static const donorId = 'donor_id';
  static const receiverId = 'receiver_id';
  static const amount = 'amount';
  static const status = 'status';
  static const token = 'token';
  static const category = 'category';
  static const categoryLogo = 'category_logo';
  static const iconUrl = 'icon_url';
  static const activityId = 'activity_id';
  static const emoji = 'emoji';
  static const id = 'id';
  static const requestId = 'request_id';
  static const voteCount = 'vote_count';
  static const createdAt = 'created_at';
  static const title = 'title';
  static const name = 'name';
  static const description = 'description';
  static const priority = 'priority';
  static const pGroupName = 'p_group_name';
  static const friendId = 'friend_id';
  static const transactionDate = 'transaction_date';
  static const totalTransactionAmount = 'total_transaction_amount';
  static const sharedTransactionAmount = 'shared_transaction_amount';
  static const sharedPercentage = 'shared_percentage';
  static const selfShareAmount = 'self_share_amount';
  static const selfSharePercentage = 'self_share_percentage';
  static const transactionPhoto = 'transaction_photo';
  static const transactionNote = 'transaction_note';
  static const transactionDescription = 'transaction_description';
  static const lenderId = 'lender_id';
  static const borrowerId = 'borrower_id';
  static const loanId = 'loan_id';
  static const paymentDate = 'payment_date';
  static const createdBy = 'created_by';
  static const slug = 'slug';
  static const ruleType = 'rule_type';
  static const ruleParams = 'rule_params';
  static const achievementId = 'achievement_id';
  static const unlockedAt = 'unlocked_at';
  static const unlockSource = 'unlock_source';
  static const celebrationShown = 'celebration_shown';
  static const timezone = 'timezone';
  static const updatedOn = 'updated_on';
  static const isRead = 'is_read';
  static const body = 'body';
  static const phone = 'phone';
  static const vpa = 'vpa';
  static const bankAlias = 'bank_alias';
  static const isPrimary = 'is_primary';
  static const bankSlug = 'bank_slug';
  static const bankName = 'bank_name';
  static const sortOrder = 'sort_order';
  static const isActive = 'is_active';
  static const payload = 'payload';
  static const expiresAt = 'expires_at';
  static const inviteType = 'invite_type';
  static const creatorId = 'creator_id';
  static const destination = 'destination';
  static const startDate = 'start_date';
  static const endDate = 'end_date';
  static const tripCurrency = 'trip_currency';
  static const isTrip = 'is_trip';
  static const monthlyLimit = 'monthly_limit';
  static const limitAmount = 'limit_amount';
  static const period = 'period';
  static const includeGroupExpenses = 'include_group_expenses';
  static const alertThreshold = 'alert_threshold';
  static const mutedMemberIds = 'muted_member_ids';
  static const cadence = 'cadence';
  static const tone = 'tone';
  static const updatedAt = 'updated_at';
  static const repaymentAmount = 'repayment_amount';
  static const isCredit = 'is_credit';
  static const paymentMethod = 'payment_method';
  static const wishlistItemId = 'wishlist_item_id';
  static const addedBy = 'added_by';
  static const estimatedAmount = 'estimated_amount';
  static const isAddedToExpenses = 'is_added_to_expenses';
  static const principalAmount = 'principal_amount';
  static const interestRate = 'interest_rate';
  static const interestType = 'interest_type';
  static const interestPeriod = 'interest_period';
  static const dueDate = 'due_date';
  static const duration = 'duration';
  static const durationUnit = 'duration_unit';
  static const repaymentStartDate = 'repayment_start_date';
  static const repaymentEndDate = 'repayment_end_date';
  static const repaymentStartDay = 'repayment_start_day';
  static const repaymentEndDay = 'repayment_end_day';
  static const targetAmount = 'target_amount';
  static const currentAmount = 'current_amount';
  static const deadline = 'deadline';
  static const colorHex = 'color_hex';
  static const iconKey = 'icon_key';
  static const smartRecommendationId = 'smart_recommendation_id';
  static const estimatedCompletionDate = 'estimated_completion_date';
  static const goalType = 'goal_type';
  static const goalId = 'goal_id';
  static const note = 'note';
  static const type = 'type';
  static const productName = 'product_name';
  static const tripName = 'trip_name';
  static const memberIds = 'member_ids';
  static const coverImageUrl = 'cover_image_url';
  static const invitedBy = 'invited_by';
  static const invitedUserId = 'invited_user_id';
  static const actorId = 'actor_id';
  static const actorName = 'actor_name';
  static const actorPic = 'actor_pic';
  static const commentCount = 'comment_count';
  static const totalSpent = 'total_spent';
  static const totalReceived = 'total_received';
  static const email = 'email';
  static const reactions = 'reactions';
  static const metadata = 'metadata';
  static const masterCategory = 'master_category';
  static const masterProductCategory = 'master_product_category';
  static const icon = 'icon';
  static const pGroupId = 'p_group_id';
  static const pUserIds = 'p_user_ids';
  static const pTripName = 'p_trip_name';
  static const pDestination = 'p_destination';
  static const pStartDate = 'p_start_date';
  static const pEndDate = 'p_end_date';
  static const pTripCurrency = 'p_trip_currency';
}

abstract final class SupabaseRpc {
  static const createGroupWithMember = 'create_group_with_member';
  static const leaveGroup = 'leave_group';
  static const removeGroupMember = 'remove_group_member';
  static const addGroupMembers = 'add_group_members';
  static const joinGroupAsMember = 'join_group_as_member';
  static const createTripWithMember = 'create_trip_with_member';
  static const respondToGroupInvite = 'respond_to_group_invite';
  static const markAchievementCelebrated = 'mark_achievement_celebrated';
  static const pMemberId = 'p_member_id';
  static const pAchievementId = 'p_achievement_id';
}

abstract final class SupabaseStorageBuckets {
  static const avatars = 'avatars';
}

abstract final class MetadataKeys {
  static const splitSummary = 'split_summary';
  static const type = 'type';
  static const fromUserId = 'from_user_id';
}

abstract final class SplitDetailKeys {
  static const userId = 'user_id';
  static const amount = 'amount';
  static const percentage = 'percentage';
  static const shares = 'shares';
  static const name = 'name';
  static const price = 'price';
  static const assignees = 'assignees';
}

abstract final class AnalyticsKeys {
  static const paid = 'paid';
  static const share = 'share';
  static const userAmount = 'userAmount';
  static const groupAvgAmount = 'groupAvgAmount';
  static const name = 'name';
  static const userId = 'user_id';
  static const netBalance = 'netBalance';
}

abstract final class GroupBalanceKeys {
  static const donor = 'donor';
  static const donorId = 'donor_id';
  static const receiver = 'receiver';
  static const receiverId = 'receiver_id';
  static const amount = 'amount';
}

abstract final class ConsolidatedTxnKeys {
  static const sharedWithUuid = 'shared_with_uuid';
  static const sharedWithName = 'shared_with_name';
  static const sharedTransactionAmount = 'shared_transaction_amount';
  static const sharedPercentage = 'shared_percentage';
}

abstract final class FriendJoinKeys {
  static const friendName = 'friend_name';
  static const friendEmail = 'friend_email';
  static const friendPic = 'friend_pic';
}

abstract final class RecurringMerchantKeys {
  static const label = 'label';
  static const typicalAmount = 'typicalAmount';
  static const occurrenceCount = 'occurrenceCount';
  static const nextExpected = 'nextExpected';
}

abstract final class UserSearchResultKeys {
  static const userId = 'user_id';
  static const userName = 'user_name';
  static const userEmail = 'user_email';
}

abstract final class FeatureRequestKeys {
  static const voteCount = 'vote_count';
  static const newest = 'newest';
  static const status = 'status';
}

abstract final class HeroTags {
  static const homeFab = 'home_make_transaction_fab';
  static const groupsFab = 'groups_fab';
  static const lendingFab = 'lending_fab';
}

abstract final class DeepLinkPaths {
  static const invite = 'invite';
  static const friend = 'friend';
  static const join = 'join';
  static const publicShare = '/share/?t=';
  static const loginCallback = 'login-callback';
  static const authCallback = '/auth/callback';
}

abstract final class FxApiConfig {
  static const host = 'api.frankfurter.app';
}

abstract final class AiConfigIds {
  static const geminiModel = 'gemini-3-flash-preview';
}

abstract final class NotificationIcons {
  static const launcher = '@mipmap/ic_launcher';
}

abstract final class TimezoneDefaults {
  static const local = 'Asia/Kolkata';
}

abstract final class SupabaseAuthMetadata {
  static const userName = 'user_name';
  static const firstName = 'first_name';
  static const lastName = 'last_name';
}

abstract final class SupabaseAuthQuery {
  static const type = 'type';
  static const recovery = 'recovery';
}

abstract final class FxApiPaths {
  static const latest = '/latest';
  static const fromParam = 'from';
  static const ratesKey = 'rates';
}

abstract final class UpiQueryParams {
  static const payeeAddress = 'pa';
  static const payeeName = 'pn';
  static const amount = 'am';
  static const currency = 'cu';
  static const note = 'tn';
}

abstract final class RazorpayOptionKeys {
  static const key = 'key';
  static const amount = 'amount';
  static const name = 'name';
  static const description = 'description';
  static const prefill = 'prefill';
  static const contact = 'contact';
  static const email = 'email';
  static const theme = 'theme';
  static const subscriptionId = 'subscription_id';
  static const color = 'color';
}

abstract final class RealtimeChannelPrefixes {
  static const group = 'group_';
  static const friends = 'friends_';
  static const achievements = 'achievements_';
  static const notifications = 'notifications_';
}

abstract final class RealtimeSchemas {
  static const public = 'public';
}

abstract final class ShareTokenChars {
  static const alphanumeric = 'abcdefghijklmnopqrstuvwxyz0123456789';
}

abstract final class UnifiedTxnResponseKeys {
  static const type = 'type';
  static const id = 'id';
  static const title = 'title';
  static const subtitle = 'subtitle';
  static const amount = 'amount';
  static const rawAmount = 'raw_amount';
  static const currency = 'currency';
  static const date = 'date';
  static const isCredit = 'is_credit';
  static const category = 'category';
  static const paymentMethod = 'payment_method';
  static const dedupeKey = 'dedupe_key';
  static const isPayer = 'is_payer';
  static const isSettlement = 'is_settlement';
  static const groupId = 'group_id';
  static const transactionGroupId = 'transaction_group_id';
  static const context = 'context';
  static const total = 'total';
  static const month = 'month';
  static const label = 'label';
  static const zScore = 'zScore';
  static const percentChange = 'percentChange';
  static const current = 'current';
  static const previous = 'previous';
  static const priority = 'priority';
  static const reason = 'reason';
  static const actionType = 'action_type';
  static const groupName = 'group_name';
  static const goalId = 'goal_id';
  static const goal = 'goal';
}

abstract final class InsightsContextKeys {
  static const thisMonthTotal = 'this_month_total';
  static const percentChange = 'percent_change';
  static const topCategory = 'top_category';
  static const openExposure = 'open_exposure';
  static const currency = 'currency';
  static const month = 'month';
}

abstract final class BriefingActionKeys {
  static const title = 'title';
  static const reason = 'reason';
  static const actionType = 'action_type';
  static const category = 'category';
}

abstract final class RecapDataKeys {
  static const month = 'month';
  static const totalSpent = 'totalSpent';
  static const expenseTotal = 'expenseTotal';
  static const lastMonthTotal = 'lastMonthTotal';
  static const topCategory = 'topCategory';
  static const topCategoryAmount = 'topCategoryAmount';
  static const categoryBreakdown = 'categoryBreakdown';
  static const biggestExpenseAmount = 'biggestExpenseAmount';
  static const biggestExpenseTitle = 'biggestExpenseTitle';
  static const biggestExpenseCategory = 'biggestExpenseCategory';
  static const biggestExpenseDate = 'biggestExpenseDate';
  static const averageDailySpend = 'averageDailySpend';
  static const message = 'message';
  static const spendingTrend = 'spendingTrend';
  static const habitType = 'habitType';
  static const habitTransactionCount = 'habitTransactionCount';
  static const topCategoryRank = 'topCategoryRank';
  static const groupCount = 'groupCount';
  static const openExposure = 'openExposure';
  static const topGroupName = 'topGroupName';
  static const payerRatio = 'payerRatio';
  static const settlementAvgDays = 'settlementAvgDays';
  static const settleUpHealthScore = 'settleUpHealthScore';
  static const settlementsClosedCount = 'settlementsClosedCount';
  static const hasGroupActivity = 'hasGroupActivity';
  static const topFriendName = 'topFriendName';
  static const topFriendId = 'topFriendId';
  static const groupFriendPeerIds = 'groupFriendPeerIds';
  static const groupFriendPeers = 'groupFriendPeers';
  static const hasLendingActivity = 'hasLendingActivity';
  static const activeLoanCount = 'activeLoanCount';
  static const totalLoanOutstanding = 'totalLoanOutstanding';
  static const loansWithPaymentThisMonth = 'loansWithPaymentThisMonth';
  static const totalRepaidThisMonth = 'totalRepaidThisMonth';
  static const topLoanTitle = 'topLoanTitle';
  static const topLoanProgress = 'topLoanProgress';
  static const loansCompletedThisMonth = 'loansCompletedThisMonth';
  static const lendingLedgerRows = 'lendingLedgerRows';
  static const hasGoalsActivity = 'hasGoalsActivity';
  static const activeGoalsCount = 'activeGoalsCount';
  static const bestGoalTitle = 'bestGoalTitle';
  static const bestGoalProgress = 'bestGoalProgress';
  static const goalsContributedThisMonth = 'goalsContributedThisMonth';
  static const goalsMotivationLine = 'goalsMotivationLine';
  static const goalsAtTargetCount = 'goalsAtTargetCount';
  static const goalCompletedInMonth = 'goalCompletedInMonth';
  static const hasPersonaSlide = 'hasPersonaSlide';
  static const personaType = 'personaType';
  static const personaStatOneLabel = 'personaStatOneLabel';
  static const personaStatOneValue = 'personaStatOneValue';
  static const personaStatTwoLabel = 'personaStatTwoLabel';
  static const personaStatTwoValue = 'personaStatTwoValue';
  static const hasMonthlyBadge = 'hasMonthlyBadge';
  static const monthlyBadgeName = 'monthlyBadgeName';
  static const monthlyBadgeDescription = 'monthlyBadgeDescription';
}

abstract final class RecapSharePayloadKeys {
  static const totalSpent = 'totalSpent';
  static const monthLabel = 'monthLabel';
  static const trendLabel = 'trendLabel';
  static const topCategory = 'topCategory';
  static const persona = 'persona';
  static const groupHighlight = 'groupHighlight';
  static const goalHighlight = 'goalHighlight';
}

abstract final class ProfileStatsKeys {
  static const totalSpent = 'totalSpent';
  static const totalReceived = 'totalReceived';
}

abstract final class InsightsPayloadKeys {
  static const thisMonthTotal = 'thisMonthTotal';
  static const lastMonthTotal = 'lastMonthTotal';
  static const percentChange = 'percentChange';
  static const topCategory = 'topCategory';
  static const topCategoryAmount = 'topCategoryAmount';
  static const healthScore = 'healthScore';
  static const spendingHealthScore = 'spendingHealthScore';
  static const settleUpHealthScore = 'settleUpHealthScore';
  static const scoreBreakdown = 'scoreBreakdown';
  static const unusualExpenses = 'unusualExpenses';
  static const recurringSubscriptions = 'recurringSubscriptions';
  static const monthlyDigest = 'monthlyDigest';
  static const spendingTrend = 'spendingTrend';
  static const spendingCoach = 'spendingCoach';
  static const socialTrust = 'socialTrust';
  static const actionQueue = 'actionQueue';
  static const monthsWithData = 'monthsWithData';
}

abstract final class InsightsLiteKeys {
  static const thisMonthTotal = 'thisMonthTotal';
  static const lastMonthTotal = 'lastMonthTotal';
  static const percentChange = 'percentChange';
  static const miniTrend = 'miniTrend';
  static const monthlyDigest = 'monthlyDigest';
}

abstract final class SocialTrustKeys {
  static const openExposure = 'openExposure';
  static const groupCount = 'groupCount';
  static const staleBalanceAmount = 'staleBalanceAmount';
  static const staleBalanceCount = 'staleBalanceCount';
  static const payerRatio = 'payerRatio';
  static const settlementAvgDays = 'settlementAvgDays';
  static const topGroupId = 'topGroupId';
  static const topGroupName = 'topGroupName';
}

abstract final class ScoreBreakdownKeys {
  static const overall = 'overall';
  static const spending = 'spending';
  static const settleUp = 'settleUp';
  static const score = 'score';
  static const explanation = 'explanation';
}

abstract final class SpendingCoachKeys {
  static const projection = 'projection';
  static const dailyBurn = 'dailyBurn';
  static const topLeak = 'topLeak';
  static const biggestExpense = 'biggestExpense';
}
