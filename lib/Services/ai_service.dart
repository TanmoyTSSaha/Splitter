import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'package:splitter/Model/financial_goal_model.dart';
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
        lower.contains("vacation")) return "✈️";
    if (lower.contains("car") || lower.contains("bike")) return "🚗";
    if (lower.contains("home") || lower.contains("house")) return "🏠";
    if (lower.contains("gift") || lower.contains("birthday")) return "🎁";
    if (lower.contains("phone") || lower.contains("laptop")) return "📱";
    if (lower.contains("emergency")) return "sos";
    return "🎯";
  }
}
