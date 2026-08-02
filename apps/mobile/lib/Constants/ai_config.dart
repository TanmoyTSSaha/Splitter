/// Gemini model, prompts, and response-contract strings.
abstract final class AiConfig {
  static const model = 'gemini-3-flash-preview';
}

abstract final class AiPrompts {
  static const feasibilityThresholdAmbitious = 50000;
  static const feasibilityThresholdExtreme = 100000;

  static String feasibility({
    required String currencySymbol,
    required double targetAmount,
    required String deadlineIso,
    required String months,
    required String monthlySaving,
  }) =>
      '''
      Analyze this financial goal:
      Target: $currencySymbol$targetAmount
      Deadline: $deadlineIso ($months months from now)
      Required Monthly Saving: $currencySymbol$monthlySaving
      
      Give a 1-sentence feedback on feasibility. Be encouraging but realistic. 
      If it's > ₹50,000/month, call it "Ambitious". 
      If > ₹1,00,000/month, call it "Extreme".
      ''';

  static String estimateAmount({
    required String title,
    required String description,
    required String category,
  }) =>
      '''
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

  static const insightsBriefing = '''
You are a personal finance copilot for a bill-splitting app called Splitr.
Analyze this structured spending summary and return actionable insights.
Be concise, encouraging, and specific. Use the currency symbol from context.

Context JSON:
{context}

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
}

abstract final class GoalIconHeuristics {
  static const defaultIcon = '🎯';
  static const emergencyIcon = 'sos';

  static String iconForTitle(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('trip') ||
        lower.contains('travel') ||
        lower.contains('vacation')) {
      return '✈️';
    }
    if (lower.contains('car') || lower.contains('bike')) return '🚗';
    if (lower.contains('home') || lower.contains('house')) return '🏠';
    if (lower.contains('gift') || lower.contains('birthday')) return '🎁';
    if (lower.contains('phone') || lower.contains('laptop')) return '📱';
    if (lower.contains('emergency')) return emergencyIcon;
    return defaultIcon;
  }
}

abstract final class AiResponseCleanup {
  static const jsonFenceOpen = '```json';
  static const fenceClose = '```';
  static const emptyJson = '{}';
  static const emptyJsonBraces = '{}';
}

abstract final class AiPromptPlaceholders {
  static const context = '{context}';
}
