import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:splitter/Model/user_details_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─── Palette ──────────────────────────────────────────────────────────────────
const Color _bg = Color(0xFFF0F0F5);
const Color _cardBg = Colors.white;
const Color _sectionLabel = Color(0xFF9E9E9E);
const Color _titleColor = Color(0xFF1A1A1A);
const Color _borderColor = Color(0xFFEEEEEE);
const Color _neopopYellow = Color(0xFFEAFF41);
const Color _premiumDark = Color(0xFF0F0F0F);
const Color _accentGreen = Color(0xFFB5F542);

// ─── Feature Request Model ─────────────────────────────────────────────────────
class FeatureRequestModel {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String category;
  final String priority;
  final int votes;
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
    required this.votes,
    required this.status,
    required this.createdAt,
    this.hasVoted = false,
  });

  factory FeatureRequestModel.fromMap(Map<String, dynamic> m) {
    return FeatureRequestModel(
      id: m['id'] as String,
      userId: m['user_id'] as String,
      title: m['title'] as String,
      description: m['description'] as String?,
      category: m['category'] as String,
      priority: m['priority'] as String,
      votes: m['votes'] as int? ?? 1,
      status: m['status'] as String? ?? 'open',
      createdAt: DateTime.parse(m['created_at'] as String),
    );
  }
}

// ─── Category meta ────────────────────────────────────────────────────────────
const Map<String, String> _categoryEmoji = {
  'splitting': '💸',
  'analytics': '📊',
  'payments': '⚡',
  'groups': '👥',
  'design': '🎨',
  'other': '🔧',
};
const Map<String, String> _categoryLabel = {
  'splitting': 'Splitting',
  'analytics': 'Analytics',
  'payments': 'Payments',
  'groups': 'Groups',
  'design': 'Design',
  'other': 'Other',
};
const Map<String, String> _priorityLabel = {
  'nice_to_have': '🙂 Nice to have',
  'really_need': '😮 I really need this',
  'deal_breaker': '🔥 Deal-breaker',
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
  String _sort = 'votes'; // 'votes' | 'newest'

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final uid = widget.user.userID ?? '';
      final order = _sort == 'votes' ? 'votes' : 'created_at';
      final data = await _supabase
          .from('feature_requests')
          .select()
          .eq('status', 'open')
          .order(order, ascending: false);
      final list = (data as List)
          .map((m) => FeatureRequestModel.fromMap(m as Map<String, dynamic>))
          .toList();

      // Fetch my votes
      final votes = await _supabase
          .from('feature_request_votes')
          .select('request_id')
          .eq('user_id', uid);
      final myIds =
          (votes as List).map((v) => v['request_id'] as String).toSet();

      for (final r in list) {
        r.hasVoted = myIds.contains(r.id);
      }

      if (mounted) {
        setState(() {
          _requests = list;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _vote(FeatureRequestModel req) async {
    final uid = widget.user.userID ?? '';
    if (req.hasVoted) {
      // Remove vote
      await _supabase
          .from('feature_request_votes')
          .delete()
          .eq('request_id', req.id)
          .eq('user_id', uid);
      await _supabase
          .from('feature_requests')
          .update({'votes': req.votes - 1}).eq('id', req.id);
      setState(() {
        req.hasVoted = false;
        req.votes > 0 ? req : null; // trigger rebuild via votes-- below
        final idx = _requests.indexOf(req);
        if (idx != -1) {
          _requests[idx] = FeatureRequestModel(
            id: req.id,
            userId: req.userId,
            title: req.title,
            description: req.description,
            category: req.category,
            priority: req.priority,
            votes: req.votes - 1,
            status: req.status,
            createdAt: req.createdAt,
            hasVoted: false,
          );
        }
      });
    } else {
      // Add vote
      await _supabase.from('feature_request_votes').insert({
        'request_id': req.id,
        'user_id': uid,
      });
      await _supabase
          .from('feature_requests')
          .update({'votes': req.votes + 1}).eq('id', req.id);
      setState(() {
        final idx = _requests.indexOf(req);
        if (idx != -1) {
          _requests[idx] = FeatureRequestModel(
            id: req.id,
            userId: req.userId,
            title: req.title,
            description: req.description,
            category: req.category,
            priority: req.priority,
            votes: req.votes + 1,
            status: req.status,
            createdAt: req.createdAt,
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
      backgroundColor: Colors.transparent,
      builder: (_) => _SubmitSheet(
        user: widget.user,
        onSubmitted: _load,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: _titleColor),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Request a Feature',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _titleColor,
          ),
        ),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openSubmitSheet,
        backgroundColor: _neopopYellow,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text(
          'Submit Idea',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                  color: _accentGreen, strokeWidth: 2))
          : Column(
              children: [
                // ── Header + sort toggle ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Community Wishlist',
                          style: TextStyle(
                            fontFamily: 'Albra',
                            fontSize: 22,
                            color: _titleColor,
                          ),
                        ),
                      ),
                      _sortToggle('Most voted', 'votes'),
                      const SizedBox(width: 8),
                      _sortToggle('Newest', 'newest'),
                    ],
                  ),
                ),

                // ── Requests list ────────────────────────────────────────────
                Expanded(
                  child: _requests.isEmpty
                      ? _buildEmpty()
                      : RefreshIndicator(
                          onRefresh: _load,
                          color: _accentGreen,
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                            itemCount: _requests.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (_, i) =>
                                _buildRequestCard(_requests[i]),
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _sortToggle(String label, String value) {
    final isActive = _sort == value;
    return GestureDetector(
      onTap: () {
        setState(() => _sort = value);
        _load();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? _titleColor : _cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? _titleColor : _borderColor),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : _sectionLabel,
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(FeatureRequestModel r) {
    final emoji = _categoryEmoji[r.category] ?? '🔧';
    final catLabel = _categoryLabel[r.category] ?? r.category;

    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vote button
          GestureDetector(
            onTap: () => _vote(r),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: r.hasVoted ? _neopopYellow : _bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: r.hasVoted ? _neopopYellow : _borderColor,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.keyboard_arrow_up_rounded,
                    size: 20,
                    color: r.hasVoted ? Colors.black : _sectionLabel,
                  ),
                  Text(
                    '${r.votes}',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: r.hasVoted ? Colors.black : _titleColor,
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
                        color: _bg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _borderColor),
                      ),
                      child: Text(
                        '$emoji $catLabel',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _sectionLabel,
                        ),
                      ),
                    ),
                    if (r.status == 'in_progress') ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB5F542).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '🚧 In Progress',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  r.title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _titleColor,
                  ),
                ),
                if (r.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    r.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: _sectionLabel,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('💡', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          const Text(
            'No feature requests yet.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _titleColor,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Be the first to submit an idea!',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: _sectionLabel,
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
  String _category = 'splitting';
  String _priority = 'nice_to_have';
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
      await _supabase.from('feature_requests').insert({
        'user_id': widget.user.userID,
        'title': title,
        'description':
            _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        'category': _category,
        'priority': _priority,
      });
      // Also add the creator's vote to the junction table
      final row = await _supabase
          .from('feature_requests')
          .select('id')
          .eq('user_id', widget.user.userID!)
          .order('created_at', ascending: false)
          .limit(1)
          .single();
      await _supabase.from('feature_request_votes').insert({
        'request_id': row['id'],
        'user_id': widget.user.userID,
      });

      if (mounted) {
        Navigator.of(context).pop();
        widget.onSubmitted();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Idea submitted! Thanks 🙌',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            backgroundColor: _neopopYellow,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                  color: _borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Submit a new idea',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _titleColor,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            _label('TITLE'),
            const SizedBox(height: 6),
            _buildTextBox(
              controller: _titleCtrl,
              hint: 'e.g. Add UPI QR code to settle',
              maxLength: 80,
              maxLines: 1,
            ),
            const SizedBox(height: 16),

            // Category
            _label('CATEGORY'),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive ? _premiumDark : _bg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive ? _premiumDark : _borderColor,
                      ),
                    ),
                    child: Text(
                      '${e.value} ${_categoryLabel[e.key]}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isActive ? Colors.white : _sectionLabel,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Description
            _label('DESCRIPTION (OPTIONAL)'),
            const SizedBox(height: 6),
            _buildTextBox(
              controller: _descCtrl,
              hint: 'Describe the feature in a bit more detail...',
              maxLength: 300,
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Priority
            _label('HOW IMPORTANT IS THIS?'),
            const SizedBox(height: 8),
            ..._priorityLabel.entries.map((e) {
              final isActive = _priority == e.key;
              return GestureDetector(
                onTap: () => setState(() => _priority = e.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isActive ? _premiumDark : _bg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isActive ? _premiumDark : _borderColor,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          e.value,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isActive ? Colors.white : _titleColor,
                          ),
                        ),
                      ),
                      if (isActive)
                        const Icon(Icons.check_circle_rounded,
                            size: 18, color: _accentGreen),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),

            // Submit
            GestureDetector(
              onTap: _submitting ? null : _submit,
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: _titleCtrl.text.trim().isEmpty
                      ? const Color(0xFFDDDDDD)
                      : _neopopYellow,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: _submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.black,
                        ),
                      )
                    : const Text(
                        'SUBMIT IDEA',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: Colors.black,
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
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.4,
        color: _sectionLabel,
      ),
    );
  }

  Widget _buildTextBox({
    required TextEditingController controller,
    required String hint,
    required int maxLength,
    required int maxLines,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        maxLength: maxLength,
        inputFormatters: [LengthLimitingTextInputFormatter(maxLength)],
        onChanged: (_) => setState(() {}),
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          color: _titleColor,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: _sectionLabel.withOpacity(0.6),
          ),
          isDense: true,
          contentPadding: EdgeInsets.zero,
          counterText: '',
        ),
      ),
    );
  }
}
