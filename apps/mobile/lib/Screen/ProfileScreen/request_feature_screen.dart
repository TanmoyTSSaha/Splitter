import 'package:splitr/Widgets/splitr_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Model/user_details_model.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Widgets/splitr_detail_app_bar.dart';
import 'package:splitr/Widgets/bordered_input_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:splitr/Constants/app_motion.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Utils/app_error_reporter.dart';

// ─── Feature Request Model ─────────────────────────────────────────────────────
class FeatureRequestModel {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String category;
  final String priority;
  final int voteCount;
  final String status;
  final DateTime createdAt;
  bool hasVoted; // client-side tracking

  FeatureRequestModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.category,
    required this.priority,
    required this.voteCount,
    this.status = FeatureRequestStatuses.open,
    required this.createdAt,
    this.hasVoted = false,
  });

  factory FeatureRequestModel.fromMap(Map<String, dynamic> m) {
    return FeatureRequestModel(
      id: m[SupabaseColumns.id] as String,
      userId: m[UserSearchResultKeys.userId] as String,
      title: m[UnifiedTxnKeys.title] as String,
      description: m[SupabaseColumns.description] as String?,
      category: m[UnifiedTxnKeys.category] as String? ??
          FeatureRequestCategories.other,
      priority: m[SupabaseColumns.priority] as String? ??
          FeatureRequestPriorities.niceToHave,
      voteCount: m[FeatureRequestKeys.voteCount] as int? ?? 0,
      status: m[FeatureRequestKeys.status] as String? ??
          FeatureRequestStatuses.open,
      createdAt: DateTime.parse(m[SupabaseColumns.createdAt] as String),
    );
  }

  FeatureRequestModel copyWith({
    int? voteCount,
    bool? hasVoted,
  }) {
    return FeatureRequestModel(
      id: id,
      userId: userId,
      title: title,
      description: description,
      category: category,
      priority: priority,
      voteCount: voteCount ?? this.voteCount,
      status: status,
      createdAt: createdAt,
      hasVoted: hasVoted ?? this.hasVoted,
    );
  }
}

// ─── Category meta ────────────────────────────────────────────────────────────
const Map<String, String> _categoryEmoji = {
  FeatureRequestCategories.splitting: '💸',
  FeatureRequestCategories.analytics: '📊',
  FeatureRequestCategories.payments: '⚡',
  SupabaseTables.groups: '👥',
  FeatureRequestCategories.design: '🎨',
  FeatureRequestCategories.other: '🔧',
};
final Map<String, String> _categoryLabel = {
  FeatureRequestCategories.splitting:
      AppStrings.featureRequest.categorySplitting,
  FeatureRequestCategories.analytics:
      AppStrings.featureRequest.categoryAnalytics,
  FeatureRequestCategories.payments: AppStrings.featureRequest.categoryPayments,
  SupabaseTables.groups: AppStrings.bottomNav.groups,
  FeatureRequestCategories.design: AppStrings.featureRequest.categoryDesign,
  FeatureRequestCategories.other: CategoryDefaults.other,
};
final Map<String, String> _priorityLabel = {
  FeatureRequestPriorities.niceToHave:
      AppStrings.featureRequest.priorityNiceToHave,
  FeatureRequestPriorities.reallyNeed:
      AppStrings.featureRequest.priorityReallyNeed,
  FeatureRequestPriorities.dealBreaker:
      AppStrings.featureRequest.priorityDealBreaker,
};

// ─── Main Screen ──────────────────────────────────────────────────────────────
class RequestFeatureScreen extends StatefulWidget {
  final UserDetails user;
  const RequestFeatureScreen({super.key, required this.user});

  @override
  State<RequestFeatureScreen> createState() => _RequestFeatureScreenState();
}

class _RequestFeatureScreenState extends State<RequestFeatureScreen> {
  final _supabase = Supabase.instance.client;
  List<FeatureRequestModel> _requests = [];
  bool _loading = true;
  String? _loadError;
  String _sort = FeatureRequestKeys
      .voteCount; // FeatureRequestKeys.voteCount | FeatureRequestKeys.newest

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final uid = widget.user.userID ?? '';
      final order = _sort == FeatureRequestKeys.voteCount
          ? FeatureRequestKeys.voteCount
          : SupabaseColumns.createdAt;
      final data = await _supabase
          .from(SupabaseTables.featureRequests)
          .select()
          .order(order, ascending: false);
      final list = (data as List)
          .map((m) => FeatureRequestModel.fromMap(m as Map<String, dynamic>))
          .toList();

      // Fetch my votes
      final votes = await _supabase
          .from(SupabaseTables.featureRequestVotes)
          .select(SupabaseColumns.requestId)
          .eq(UserSearchResultKeys.userId, uid);
      final myIds = (votes as List)
          .map((v) => v[SupabaseColumns.requestId] as String)
          .toSet();

      for (final r in list) {
        r.hasVoted = myIds.contains(r.id);
      }

      if (mounted) {
        setState(() {
          _requests = list;
          _loading = false;
          _loadError = null;
        });
      }
    } catch (e, stack) {
      AppErrorReporter.report(
        AppStrings.featureRequest.loadError,
        error: e,
        stack: stack,
      );
      if (mounted) {
        setState(() {
          _loading = false;
          _loadError = AppStrings.featureRequest.loadError;
        });
      }
    }
  }

  Future<void> _vote(FeatureRequestModel req) async {
    final uid = widget.user.userID ?? '';
    if (req.hasVoted) {
      await _supabase
          .from(SupabaseTables.featureRequestVotes)
          .delete()
          .eq(SupabaseColumns.requestId, req.id)
          .eq(UserSearchResultKeys.userId, uid);
      setState(() {
        final idx = _requests.indexOf(req);
        if (idx != -1) {
          _requests[idx] = req.copyWith(
            voteCount: req.voteCount > 0 ? req.voteCount - 1 : 0,
            hasVoted: false,
          );
        }
      });
    } else {
      await _supabase.from(SupabaseTables.featureRequestVotes).insert({
        SupabaseColumns.requestId: req.id,
        UserSearchResultKeys.userId: uid,
      });
      setState(() {
        final idx = _requests.indexOf(req);
        if (idx != -1) {
          _requests[idx] = req.copyWith(
            voteCount: req.voteCount + 1,
            hasVoted: true,
          );
        }
      });
    }
  }

  void _openSubmitSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: groupTransparent,
      builder: (_) => _SubmitSheet(
        user: widget.user,
        onSubmitted: _load,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    final borderColor = groupMutedBorderHairline;
    final mutedFill = groupMutedFillFaint;
    return Scaffold(
      backgroundColor: surface,
      appBar: SplitrDetailAppBar(title: AppStrings.featureRequest.title),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openSubmitSheet,
        backgroundColor: neopopYellow,
        foregroundColor: groupOnSurface,
        icon: const Icon(Icons.add_rounded, size: 20),
        label: Text(
          AppStrings.featureRequest.submitIdea,
          style: TextStyle(
            fontFamily: kFontPoppins,
            fontSize: splitrFontBodySm,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                  color: neopopAccent, strokeWidth: groupProgressStrokeWidth))
          : _loadError != null
              ? _buildError()
              : Column(
                  children: [
                    // ── Header + sort toggle ──────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              AppStrings.featureRequest.communityWishlist,
                              style: TextStyle(
                                fontFamily: kFontAlbra,
                                fontSize: splitrFontSubheadLg,
                                color: groupOnSurface,
                              ),
                            ),
                          ),
                          _sortToggle(
                              context,
                              AppStrings.featureRequest.mostVoted,
                              FeatureRequestKeys.voteCount),
                          const SizedBox(width: 8),
                          _sortToggle(context, AppStrings.featureRequest.newest,
                              FeatureRequestKeys.newest),
                        ],
                      ),
                    ),

                    // ── Requests list ────────────────────────────────────────────
                    Expanded(
                      child: _requests.isEmpty
                          ? _buildEmpty()
                          : RefreshIndicator(
                              onRefresh: _load,
                              color: neopopAccent,
                              child: ListView.separated(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 0, 20, 100),
                                itemCount: _requests.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (_, i) => _buildRequestCard(
                                  context,
                                  _requests[i],
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _sortToggle(BuildContext context, String label, String value) {
    final borderColor = groupMutedBorderHairline;
    final isActive = _sort == value;
    return GestureDetector(
      onTap: () {
        setState(() => _sort = value);
        _load();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
            horizontal: groupCarouselGap, vertical: groupGapXs),
        decoration: BoxDecoration(
          color:
              isActive ? groupOnSurface : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(groupCardRadiusLg),
          border: Border.all(color: isActive ? groupOnSurface : borderColor),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: kFontPoppins,
            fontSize: splitrFontCaptionSm,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : groupOnSurfaceMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, FeatureRequestModel r) {
    final surface = Theme.of(context).colorScheme.surface;
    final borderColor = groupMutedBorderHairline;
    final mutedFill = groupMutedFillFaint;
    final emoji = _categoryEmoji[r.category] ?? '🔧';
    final catLabel = _categoryLabel[r.category] ?? r.category;
    final isImplemented = r.status == FeatureRequestStatuses.implemented;
    final isClosed = r.status == FeatureRequestStatuses.closed;
    final isDeemphasized = isImplemented || isClosed;

    return Opacity(
      opacity: isDeemphasized ? 0.72 : 1,
      child: Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(groupCardRadius),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.all(groupGutter),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vote button
          GestureDetector(
            onTap: () => _vote(r),
            child: AnimatedContainer(
              duration: AppMotion.standard,
              width: 48,
              padding: const EdgeInsets.symmetric(vertical: groupGapSm),
              decoration: BoxDecoration(
                color: r.hasVoted ? neopopYellow : mutedFill,
                borderRadius: BorderRadius.circular(groupControlRadius),
                border: Border.all(
                  color: r.hasVoted ? neopopYellow : borderColor,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.keyboard_arrow_up_rounded,
                    size: 20,
                    color: r.hasVoted ? groupOnSurface : groupOnSurfaceMuted,
                  ),
                  Text(
                    '${r.voteCount}',
                    style: TextStyle(
                      fontFamily: kFontPoppins,
                      fontSize: splitrFontBodySm,
                      fontWeight: FontWeight.w700,
                      color: r.hasVoted ? groupOnSurface : groupOnSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: mutedFill,
                        borderRadius: BorderRadius.circular(groupCardRadiusLg),
                        border: Border.all(color: borderColor),
                      ),
                      child: Text(
                        '$emoji $catLabel',
                        style: TextStyle(
                          fontFamily: kFontPoppins,
                          fontSize: splitrFontMicro,
                          fontWeight: FontWeight.w600,
                          color: groupOnSurfaceMuted,
                        ),
                      ),
                    ),
                    if (isImplemented) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: neopopYellow.withValues(alpha: 0.35),
                          borderRadius:
                              BorderRadius.circular(groupCardRadiusLg),
                          border: Border.all(color: neopopYellow),
                        ),
                        child: Text(
                          AppStrings.featureRequest.statusImplemented,
                          style: TextStyle(
                            fontFamily: kFontPoppins,
                            fontSize: splitrFontMicro,
                            fontWeight: FontWeight.w700,
                            color: groupOnSurface,
                          ),
                        ),
                      ),
                    ] else if (isClosed) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: mutedFill,
                          borderRadius:
                              BorderRadius.circular(groupCardRadiusLg),
                          border: Border.all(color: borderColor),
                        ),
                        child: Text(
                          AppStrings.featureRequest.statusClosed,
                          style: TextStyle(
                            fontFamily: kFontPoppins,
                            fontSize: splitrFontMicro,
                            fontWeight: FontWeight.w600,
                            color: groupOnSurfaceMuted,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  r.title,
                  style: TextStyle(
                    fontFamily: kFontPoppins,
                    fontSize: splitrFontBody,
                    fontWeight: FontWeight.w600,
                    color: groupOnSurface,
                  ),
                ),
                if (r.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    r.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: kFontPoppins,
                      fontSize: splitrFontCaption,
                      color: groupOnSurfaceMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 48, color: groupOnSurfaceMuted),
            const SizedBox(height: groupGapMd),
            Text(
              _loadError!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: kFontPoppins,
                fontSize: splitrFontBodyMd,
                fontWeight: FontWeight.w600,
                color: groupOnSurface,
              ),
            ),
            const SizedBox(height: groupGapLg),
            ElevatedButton(
              onPressed: _load,
              style: ElevatedButton.styleFrom(
                backgroundColor: neopopAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(groupControlRadius),
                ),
              ),
              child: Text(
                AppStrings.groups.retry,
                style: TextStyle(
                  fontFamily: kFontPoppins,
                  fontWeight: FontWeight.w700,
                  color: groupOnSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('💡', style: TextStyle(fontSize: splitrFontRecapXl)),
          const SizedBox(height: groupGapMd),
          Text(
            AppStrings.featureRequest.emptyTitle,
            style: const TextStyle(
              fontFamily: kFontPoppins,
              fontSize: splitrFontBodyLg,
              fontWeight: FontWeight.w600,
              color: groupOnSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppStrings.featureRequest.emptySubtitle,
            style: const TextStyle(
              fontFamily: kFontPoppins,
              fontSize: splitrFontBodySm,
              color: groupOnSurfaceMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Submit Sheet ─────────────────────────────────────────────────────────────
class _SubmitSheet extends StatefulWidget {
  final UserDetails user;
  final VoidCallback onSubmitted;
  const _SubmitSheet({required this.user, required this.onSubmitted});

  @override
  State<_SubmitSheet> createState() => _SubmitSheetState();
}

class _SubmitSheetState extends State<_SubmitSheet> {
  final _supabase = Supabase.instance.client;
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _category = FeatureRequestCategories.splitting;
  String _priority = FeatureRequestPriorities.niceToHave;
  bool _submitting = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;
    setState(() => _submitting = true);
    try {
      await _supabase.from(SupabaseTables.featureRequests).insert({
        UserSearchResultKeys.userId: widget.user.userID,
        UnifiedTxnKeys.title: title,
        SupabaseColumns.description:
            _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        UnifiedTxnKeys.category: _category,
        SupabaseColumns.priority: _priority,
      });
      // Also add the creator's vote to the junction table
      final row = await _supabase
          .from(SupabaseTables.featureRequests)
          .select(SupabaseColumns.id)
          .eq(UserSearchResultKeys.userId, widget.user.userID!)
          .order(SupabaseColumns.createdAt, ascending: false)
          .limit(1)
          .single();
      await _supabase.from(SupabaseTables.featureRequestVotes).insert({
        SupabaseColumns.requestId: row[SupabaseColumns.id],
        UserSearchResultKeys.userId: widget.user.userID,
      });

      if (mounted) {
        Navigator.of(context).pop();
        widget.onSubmitted();
        SplitrToast.showFromContext(
            context, AppStrings.featureRequest.ideaSubmitted);
      }
    } catch (e, stack) {
      AppErrorReporter.reportActionFailure(
        'Feature request submission failed',
        error: e,
        stack: stack,
      );
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    final borderColor = groupMutedBorderHairline;
    final mutedFill = groupMutedFillFaint;
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: groupSheetTopBorderRadiusXl,
      ),
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: borderColor,
                  borderRadius: BorderRadius.circular(groupRadiusHairline),
                ),
              ),
            ),
            const SizedBox(height: groupGapLg),
            Text(
              AppStrings.featureRequest.submitNewIdea,
              style: TextStyle(
                fontFamily: kFontPoppins,
                fontSize: splitrFontSubhead,
                fontWeight: FontWeight.w700,
                color: groupOnSurface,
              ),
            ),
            const SizedBox(height: groupGapLg),

            // Title
            _label(AppStrings.featureRequest.titleLabel),
            const SizedBox(height: 6),
            _buildTextBox(
              context,
              controller: _titleCtrl,
              hint: AppStrings.featureRequest.titleHint,
              maxLength: 80,
              maxLines: 1,
            ),
            const SizedBox(height: groupGapMd),

            // Category
            _label(AppStrings.featureRequest.categoryLabel),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categoryEmoji.entries.map((e) {
                final isActive = _category == e.key;
                return GestureDetector(
                  onTap: () => setState(() => _category = e.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(
                        horizontal: groupCarouselGap, vertical: groupGapSm),
                    decoration: BoxDecoration(
                      color: isActive ? neopopBackground : mutedFill,
                      borderRadius: BorderRadius.circular(groupCardRadiusLg),
                      border: Border.all(
                        color: isActive ? neopopBackground : borderColor,
                      ),
                    ),
                    child: Text(
                      '${e.value} ${_categoryLabel[e.key]}',
                      style: TextStyle(
                        fontFamily: kFontPoppins,
                        fontSize: splitrFontCaption,
                        fontWeight: FontWeight.w600,
                        color: isActive ? Colors.white : groupOnSurfaceMuted,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: groupGapMd),

            // Description
            _label(AppStrings.featureRequest.descriptionLabel),
            const SizedBox(height: 6),
            _buildTextBox(
              context,
              controller: _descCtrl,
              hint: AppStrings.featureRequest.descriptionHint,
              maxLength: 300,
              maxLines: 3,
            ),
            const SizedBox(height: groupGapMd),

            // Priority
            _label(AppStrings.featureRequest.priorityLabel),
            const SizedBox(height: 8),
            ..._priorityLabel.entries.map((e) {
              final isActive = _priority == e.key;
              return GestureDetector(
                onTap: () => setState(() => _priority = e.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  margin: const EdgeInsets.only(bottom: groupGapSm),
                  padding: const EdgeInsets.symmetric(
                      horizontal: groupGutter, vertical: groupCarouselGap),
                  decoration: BoxDecoration(
                    color: isActive ? neopopBackground : mutedFill,
                    borderRadius: BorderRadius.circular(groupControlRadius),
                    border: Border.all(
                      color: isActive ? neopopBackground : borderColor,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          e.value,
                          style: TextStyle(
                            fontFamily: kFontPoppins,
                            fontSize: splitrFontBodySm,
                            fontWeight: FontWeight.w600,
                            color: isActive ? Colors.white : groupOnSurface,
                          ),
                        ),
                      ),
                      if (isActive)
                        const Icon(Icons.check_circle_rounded,
                            size: 18, color: neopopAccent),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: groupGapLg),

            // Submit
            GestureDetector(
              onTap: _submitting ? null : _submit,
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: _titleCtrl.text.trim().isEmpty
                      ? groupMutedBorderHairline
                      : neopopYellow,
                  borderRadius: BorderRadius.circular(groupRadiusLgSm),
                ),
                alignment: Alignment.center,
                child: _submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: groupProgressStrokeWidthMedium,
                          color: groupOnSurface,
                        ),
                      )
                    : Text(
                        AppStrings.featureRequest.submitIdeaButton,
                        style: TextStyle(
                          fontFamily: kFontPoppins,
                          fontSize: splitrFontBodySm,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: groupOnSurface,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: kFontPoppins,
        fontSize: splitrFontCaptionSm,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.4,
        color: groupOnSurfaceMuted,
      ),
    );
  }

  Widget _buildTextBox(
    BuildContext context, {
    required TextEditingController controller,
    required String hint,
    required int maxLength,
    required int maxLines,
  }) {
    return BorderedInputField(
      controller: controller,
      hintText: hint,
      maxLines: maxLines,
      inputFormatters: [LengthLimitingTextInputFormatter(maxLength)],
      onChanged: (_) => setState(() {}),
      style: TextStyle(
        fontFamily: kFontPoppins,
        fontSize: splitrFontBodySm,
        color: groupOnSurface,
      ),
    );
  }
}
