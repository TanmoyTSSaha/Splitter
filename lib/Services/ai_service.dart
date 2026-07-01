import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'package:splitter/Model/financial_goal_model.dart';
import 'package:splitter/Services/insights_briefing_cache.dart';
import 'package:splitter/git_ignore.dart';

class AIService {
  late GenerativeModel _model;

  AIService() {
    // Use the variable from git_ignore.dart
    _model = GenerativeModel(
      model: 'gemini-3-flash-preview',
      apiKey: geminiApiKey,
    );
  }

  // Generate suggestions based on user profile/history
  Future<List<FinancialGoalModel>> getGoalSuggestions() async {
    if (geminiApiKey == 'YOUR_GEMINI_API_KEY') {
      debugPrint("Gemini API Key not set. Skipping suggestions.");
      return [];
    }

    try {
      // Future implementation:
      // Define prompt, call API, parse JSON.
      // For now, returning empty to avoid mock data as requested.
      return [];
    } catch (e) {
      debugPrint("Error fetching goal suggestions: $e");
      return [];
    }
  }

  // Returns a message about feasibility using Gemini
  Future<String> checkFeasibility(
      double targetAmount, DateTime deadline) async {
    if (geminiApiKey == 'YOUR_GEMINI_API_KEY') {
      debugPrint("Gemini API Key not set. Skipping feasibility check.");
      return "";
    }

    try {
      final now = DateTime.now();
      final difference = deadline.difference(now).inDays;
      final months = difference / 30;

      if (months <= 0) return "Deadline must be in the future";

      final monthlySaving = targetAmount / months;

      final prompt = '''
      Analyze this financial goal:
      Target: ₹$targetAmount
      Deadline: ${deadline.toIso8601String().split('T')[0]} (${months.toStringAsFixed(1)} months from now)
      Required Monthly Saving: ₹${monthlySaving.toStringAsFixed(0)}
      
      Give a 1-sentence feedback on feasibility. Be encouraging but realistic. 
      If it's > ₹50,000/month, call it "Ambitious". 
      If > ₹1,00,000/month, call it "Extreme".
      ''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? "";
    } catch (e) {
      debugPrint("Error checking feasibility: $e");
      return "";
    }
  }

  Future<Map<String, dynamic>> getEstimatedAmount(
      String title, String description, String category) async {
    if (geminiApiKey == 'YOUR_GEMINI_API_KEY') {
      return {
        "estimated_amount": 0.0,
        "currency": "INR",
        "reasoning": "AI key not configured. Please enter amount manually."
      };
    }

    try {
      final prompt = '''
      User wants to save for "$title" (Category: $category).
      Description: "$description".
      Estimate the cost in INR (Indian Rupees).
      Return strictly a JSON object with no markdown formatting.
      Format:
      {
        "estimated_amount": 150000,
        "currency": "INR",
        "reasoning": "Based on average costs for..."
      }
      ''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      final text = response.text
              ?.replaceAll('```json', '')
              .replaceAll('```', '')
              .trim() ??
          "{}";
      return jsonDecode(text);
    } catch (e) {
      debugPrint("AI ESTIMATE ERROR: $e");
      return {
        "estimated_amount": 0.0,
        "currency": "INR",
        "reasoning": "Could not estimate cost. Please enter manually."
      };
    }
  }

  String getIconForGoal(String title) {
    final lower = title.toLowerCase();
    if (lower.contains("trip") ||
        lower.contains("travel") ||
        lower.contains("vacation")) {
      return "✈️";
    }
    if (lower.contains("car") || lower.contains("bike")) return "🚗";
    if (lower.contains("home") || lower.contains("house")) return "🏠";
    if (lower.contains("gift") || lower.contains("birthday")) return "🎁";
    if (lower.contains("phone") || lower.contains("laptop")) return "📱";
    if (lower.contains("emergency")) return "sos";
    return "🎯";
  }

  /// Generates or returns cached AI insights briefing for the Expense Insights screen.
  Future<Map<String, dynamic>> generateInsightsBriefing({
    required Map<String, dynamic> context,
    required String fallbackDigest,
    bool forceRefresh = false,
  }) async {
    final monthSpend =
        (context['this_month_total'] as num?)?.toDouble() ?? 0.0;

    if (!forceRefresh) {
      final fresh = await InsightsBriefingCache.isFresh(
        currentMonthSpend: monthSpend,
      );
      if (fresh) {
        final cached = await InsightsBriefingCache.read();
        if (cached != null) return cached;
      }
    }

    if (geminiApiKey == 'YOUR_GEMINI_API_KEY') {
      return _fallbackBriefing(context, fallbackDigest);
    }

    try {
      final prompt = '''
You are a personal finance copilot for a bill-splitting app called Splitter.
Analyze this structured spending summary and return actionable insights.
Be concise, encouraging, and specific. Use the currency symbol from context.

Context JSON:
${jsonEncode(context)}

Return strictly a JSON object with no markdown:
{
  "headline": "short punchy headline under 60 chars",
  "narrative": "3-4 sentences weaving spending, groups, and goals",
  "actions": [
    {
      "title": "action label",
      "reason": "why this matters",
      "action_type": "settle_up|review_category|view_goal|view_expense"
    }
  ]
}
Provide 2-3 actions max. action_type must be one of the listed values.
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      final text = response.text
              ?.replaceAll('```json', '')
              .replaceAll('```', '')
              .trim() ??
          '{}';
      final parsed = jsonDecode(text) as Map<String, dynamic>;
      final briefing = {
        'headline': parsed['headline'] ?? 'Your monthly briefing',
        'narrative': parsed['narrative'] ?? fallbackDigest,
        'actions': (parsed['actions'] as List<dynamic>?)
                ?.map((a) => Map<String, dynamic>.from(a as Map))
                .toList() ??
            <Map<String, dynamic>>[],
        'is_ai': true,
      };

      await InsightsBriefingCache.write(
        briefing: briefing,
        monthSpendSnapshot: monthSpend,
      );
      return briefing;
    } catch (e) {
      debugPrint('generateInsightsBriefing: $e');
      return _fallbackBriefing(context, fallbackDigest);
    }
  }

  Map<String, dynamic> _fallbackBriefing(
    Map<String, dynamic> context,
    String fallbackDigest,
  ) {
    final actions = <Map<String, dynamic>>[];
    final openExposure = (context['open_exposure'] as num?)?.toDouble() ?? 0;
    if (openExposure >= 500) {
      actions.add({
        'title': 'Settle group balances',
        'reason':
            '${context['currency'] ?? '₹'}${openExposure.toStringAsFixed(0)} still open',
        'action_type': 'settle_up',
      });
    }
    final topCat = context['top_category'] as String?;
    if (topCat != null && topCat != '-') {
      actions.add({
        'title': 'Review $topCat spending',
        'reason': 'Your top category this month',
        'action_type': 'review_category',
        'category': topCat,
      });
    }

    return {
      'headline': 'Your ${_monthFromContext(context)} snapshot',
      'narrative': fallbackDigest,
      'actions': actions,
      'is_ai': false,
    };
  }

  String _monthFromContext(Map<String, dynamic> context) {
    return context['month']?.toString() ?? 'monthly';
  }
}
