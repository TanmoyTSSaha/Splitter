import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:splitr/Constants/ai_config.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/business_rules.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Model/financial_goal_model.dart';
import 'package:splitr/Services/insights_briefing_cache.dart';
import 'package:splitr/Utils/app_error_reporter.dart';
import 'package:splitr/Utils/currency_utils.dart';
import 'package:splitr/config/app_secrets.dart';

class AIService {
  late GenerativeModel _model;

  AIService() {
    _model = GenerativeModel(
      model: AiConfig.model,
      apiKey: AppSecrets.geminiApiKey,
    );
  }

  Future<List<FinancialGoalModel>> getGoalSuggestions() async {
    if (AppSecrets.geminiApiKey.isEmpty) {
      debugPrint('Gemini API Key not set. Skipping suggestions.');
      return [];
    }

    try {
      return [];
    } catch (e, stack) {
      AppErrorReporter.report(
        'AIService.getGoalSuggestions failed',
        error: e,
        stack: stack,
        context: {'feature': 'ai', 'operation': 'getGoalSuggestions'},
      );
      return [];
    }
  }

  Future<String> checkFeasibility(
      double targetAmount, DateTime deadline) async {
    if (AppSecrets.geminiApiKey.isEmpty) {
      debugPrint('Gemini API Key not set. Skipping feasibility check.');
      return '';
    }

    try {
      final now = DateTime.now();
      final difference = deadline.difference(now).inDays;
      final months = difference / 30;

      if (months <= 0) return AppStrings.services.ai.deadlineFuture;

      final monthlySaving = targetAmount / months;

      final prompt = AiPrompts.feasibility(
        currencySymbol: userCurrencySymbol(),
        targetAmount: targetAmount,
        deadlineIso: deadline
            .toIso8601String()
            .split(AppStrings.services.ai.isoDateSplit)[0],
        months: months.toStringAsFixed(1),
        monthlySaving: monthlySaving.toStringAsFixed(0),
      );

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? '';
    } catch (e, stack) {
      AppErrorReporter.report(
        'AIService.checkFeasibility failed',
        error: e,
        stack: stack,
        context: {'feature': 'ai', 'operation': 'checkFeasibility'},
      );
      return '';
    }
  }

  Future<Map<String, dynamic>> getEstimatedAmount(
      String title, String description, String category) async {
    if (AppSecrets.geminiApiKey.isEmpty) {
      return {
        AiResponseKeys.estimatedAmount: 0.0,
        AiResponseKeys.currency: CurrencyDefaults.code,
        AiResponseKeys.reasoning: AppStrings.services.ai.keyNotConfigured,
      };
    }

    try {
      final prompt = AiPrompts.estimateAmount(
        title: title,
        description: description,
        category: category,
      );

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      final text = response.text
              ?.replaceAll(AiResponseCleanup.jsonFenceOpen, '')
              .replaceAll(AiResponseCleanup.fenceClose, '')
              .trim() ??
          AiResponseCleanup.emptyJsonBraces;
      return jsonDecode(text);
    } catch (e, stack) {
      AppErrorReporter.report(
        'AIService.getEstimatedAmount failed',
        error: e,
        stack: stack,
        context: {'feature': 'ai', 'operation': 'getEstimatedAmount'},
      );
      return {
        AiResponseKeys.estimatedAmount: 0.0,
        AiResponseKeys.currency: CurrencyDefaults.code,
        AiResponseKeys.reasoning: AppStrings.services.ai.couldNotEstimate,
      };
    }
  }

  String getIconForGoal(String title) => GoalIconHeuristics.iconForTitle(title);

  Future<Map<String, dynamic>> generateInsightsBriefing({
    required Map<String, dynamic> context,
    required String fallbackDigest,
    bool forceRefresh = false,
  }) async {
    final monthSpend =
        (context[InsightsContextKeys.thisMonthTotal] as num?)?.toDouble() ??
            0.0;

    if (!forceRefresh) {
      final fresh = await InsightsBriefingCache.isFresh(
        currentMonthSpend: monthSpend,
      );
      if (fresh) {
        final cached = await InsightsBriefingCache.read();
        if (cached != null) return cached;
      }
    }

    if (AppSecrets.geminiApiKey.isEmpty) {
      return _fallbackBriefing(context, fallbackDigest);
    }

    try {
      final prompt = AiPrompts.insightsBriefing.replaceFirst(
        AiPromptPlaceholders.context,
        jsonEncode(context),
      );

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      final text = response.text
              ?.replaceAll(AiResponseCleanup.jsonFenceOpen, '')
              .replaceAll(AiResponseCleanup.fenceClose, '')
              .trim() ??
          AiResponseCleanup.emptyJson;
      final parsed = jsonDecode(text) as Map<String, dynamic>;
      final briefing = {
        AiResponseKeys.headline: parsed[AiResponseKeys.headline] ??
            AppStrings.services.ai.monthlyBriefing,
        AiResponseKeys.narrative:
            parsed[AiResponseKeys.narrative] ?? fallbackDigest,
        AiResponseKeys.actions:
            (parsed[AiResponseKeys.actions] as List<dynamic>?)
                    ?.map((a) => Map<String, dynamic>.from(a as Map))
                    .toList() ??
                <Map<String, dynamic>>[],
        AiResponseKeys.isAi: true,
      };

      await InsightsBriefingCache.write(
        briefing: briefing,
        monthSpendSnapshot: monthSpend,
      );
      return briefing;
    } catch (e, stack) {
      AppErrorReporter.report(
        'AIService.generateInsightsBriefing failed',
        error: e,
        stack: stack,
        context: {'feature': 'ai', 'operation': 'generateInsightsBriefing'},
      );
      return _fallbackBriefing(context, fallbackDigest);
    }
  }

  Map<String, dynamic> _fallbackBriefing(
    Map<String, dynamic> context,
    String fallbackDigest,
  ) {
    final actions = <Map<String, dynamic>>[];
    final openExposure =
        (context[InsightsContextKeys.openExposure] as num?)?.toDouble() ?? 0;
    if (openExposure >= AiThresholds.openExposureSettleUpInr) {
      actions.add({
        BriefingActionKeys.title: AppStrings.services.ai.settleGroupBalances,
        BriefingActionKeys.reason:
            '${context[InsightsContextKeys.currency] ?? userCurrencySymbol()}${openExposure.toStringAsFixed(0)}${AppStrings.services.ai.stillOpen}',
        BriefingActionKeys.actionType: InsightActionTypes.settleUp,
      });
    }
    final topCat = context[InsightsContextKeys.topCategory] as String?;
    if (topCat != null && topCat != CategoryDefaults.dash) {
      actions.add({
        BriefingActionKeys.title:
            '${AppStrings.services.ai.reviewSpendingPrefix}$topCat${AppStrings.services.ai.reviewSpendingSuffix}',
        BriefingActionKeys.reason: AppStrings.services.ai.topCategoryReason,
        BriefingActionKeys.actionType: InsightActionTypes.reviewCategory,
        BriefingActionKeys.category: topCat,
      });
    }

    return {
      AiResponseKeys.headline:
          '${AppStrings.services.ai.monthlySnapshotPrefix}${_monthFromContext(context)}${AppStrings.services.ai.monthlySnapshotSuffix}',
      AiResponseKeys.narrative: fallbackDigest,
      AiResponseKeys.actions: actions,
      AiResponseKeys.isAi: false,
    };
  }

  String _monthFromContext(Map<String, dynamic> context) {
    return context[InsightsContextKeys.month]?.toString() ??
        AppStrings.services.ai.monthlyFallback;
  }
}
