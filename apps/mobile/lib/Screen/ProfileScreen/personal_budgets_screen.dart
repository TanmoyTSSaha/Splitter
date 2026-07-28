import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/theme_accent_colors.dart';
import 'package:splitr/Controllers/currency_controller.dart';
import 'package:splitr/Model/personal_budget_model.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Screen/ProfileScreen/widgets/budget_editor_sheet.dart';
import 'package:splitr/Services/budget_spend_service.dart';
import 'package:splitr/Services/personal_budget_service.dart';
import 'package:splitr/Services/supabase_service.dart';
import 'package:splitr/Utils/app_error_reporter.dart';
import 'package:splitr/Utils/budget_period_resolver.dart';
import 'package:splitr/Widgets/budget_progress_bar.dart';
import 'package:splitr/Widgets/splitr_detail_app_bar.dart';

class PersonalBudgetsScreen extends StatefulWidget {
  const PersonalBudgetsScreen({super.key});

  @override
  State<PersonalBudgetsScreen> createState() => _PersonalBudgetsScreenState();
}

class _PersonalBudgetsScreenState extends State<PersonalBudgetsScreen> {
  final _service = PersonalBudgetService();
  final _spend = BudgetSpendService();
  final _userId = SupabaseAuth().supabaseGetUserID();

  List<PersonalBudget> _budgets = [];
  Map<String, double> _spentByBudgetId = {};
  bool _loading = true;
  String? _error;

  String get _sym => Get.find<CurrencyController>().symbol;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final budgets = await _service.listBudgets(_userId);
      final spent = await _spend.getSpendForBudgets(
        budgets: budgets,
        userId: _userId,
      );
      if (!mounted) return;
      setState(() {
        _budgets = budgets;
        _spentByBudgetId = spent;
        _loading = false;
      });
    } catch (e, stack) {
      AppErrorReporter.report(
        AppStrings.errors.loadBudgets,
        error: e,
        stack: stack,
      );
      if (!mounted) return;
      setState(() {
        _error = AppStrings.errors.loadBudgets;
        _loading = false;
      });
    }
  }

  Future<void> _openEditor({PersonalBudget? existing}) async {
    final saved = await BudgetEditorSheet.show(
      context,
      userId: _userId,
      existingBudgets: _budgets,
      existing: existing,
    );
    if (saved == true) {
      await _load();
      await reevaluateBudgetAlerts(_userId);
    }
  }

  String _periodChipLabel(String period) =>
      BudgetPeriodResolver.periodDisplayLabel(period);

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: surface,
      appBar: SplitrDetailAppBar(title: AppStrings.budget.title),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        backgroundColor: neopopAccent,
        icon: const Icon(Icons.add, color: neopopBackground),
        label: Text(AppStrings.budget.addBudget),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: neopopAccent))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: body2_text),
                      TextButton(
                        onPressed: _load,
                        child: Text(
                          AppStrings.actions.tryAgain,
                          style: body2_text.copyWith(color: neopopAccent),
                        ),
                      ),
                    ],
                  ),
                )
              : _budgets.isEmpty
                  ? Center(
                      child: Text(
                        AppStrings.budget.emptyState,
                        textAlign: TextAlign.center,
                        style: body2_text.copyWith(color: groupOnSurfaceMuted),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(groupGutter),
                        itemCount: _budgets.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: groupGapMd),
                        itemBuilder: (context, index) {
                          final b = _budgets[index];
                          final spent = _spentByBudgetId[b.id] ?? 0;
                          final window =
                              BudgetPeriodResolver.resolve(b.period, now);
                          final overAlert =
                              spent >= b.limitAmount * b.alertThreshold;
                          final isOver = spent > b.limitAmount;

                          return Card(
                            child: ListTile(
                              title: Text(
                                '${b.displayLabel} · ${_periodChipLabel(b.period)}',
                                style: body1_text.copyWith(
                                  color: groupOnSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    window.displayLabel,
                                    style: caption_text.copyWith(
                                      color: groupOnSurfaceMuted,
                                    ),
                                  ),
                                  if (!b.includeGroupExpenses)
                                    Text(
                                      AppStrings.budget.personalOnlyHint,
                                      style: caption_text.copyWith(
                                        color: groupOnSurfaceMuted,
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                  BudgetProgressBar(
                                    spent: spent,
                                    limit: b.limitAmount,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '$_sym${spent.toStringAsFixed(0)} / $_sym${b.limitAmount.toStringAsFixed(0)}',
                                    style: caption_text.copyWith(
                                      color: groupOnSurfaceMuted,
                                    ),
                                  ),
                                  if (overAlert)
                                    Text(
                                      isOver
                                          ? AppStrings.budget.overBudget
                                          : AppStrings.budget.nearLimit,
                                      style: caption_text.copyWith(
                                        color: isOver
                                            ? neopopError
                                            : ThemeAccentColors.oweWarning(
                                                context),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (v) async {
                                  if (v == 'edit') {
                                    await _openEditor(existing: b);
                                  } else if (v == 'delete') {
                                    await _service.deleteBudget(b.id);
                                    await _load();
                                    await reevaluateBudgetAlerts(_userId);
                                  }
                                },
                                itemBuilder: (_) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Text(AppStrings.actions.edit),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text(AppStrings.actions.delete),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
