import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiService {
  Future<List<String>> generateBudgetTips({
    required double income,
    required double expenses,
    required Map<String, double> categories,
    String? timestamp,
  }) async {
    debugPrint(
        'AiService: Generating budget tip with income=$income, expenses=$expenses, categories=$categories, timestamp=$timestamp');
    try {
      // Validate input
      if (expenses <= 0 || categories.isEmpty) {
        debugPrint(
            'AiService: Invalid input data (no expenses or categories), returning empty tip');
        return ['No tip generated due to insufficient spending data.'];
      }

      // Initialize Gemini model
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        debugPrint('AiService: GEMINI_API_KEY is missing');
        return ['Error: Missing API key.'];
      }

      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
      );

      // Randomize tip focus
      final tipFocusOptions = [
        'boosting your savings',
        'cutting back on fun extras',
        'streamlining daily essentials',
        'building a safety net',
        'planning for your big dreams',
      ];
      final randomFocus =
          (DateTime.now().millisecondsSinceEpoch % tipFocusOptions.length)
              .toInt();
      final selectedFocus = tipFocusOptions[randomFocus];

      // Create a dynamic prompt
      final prompt = '''
You’re a friendly financial coach. Based on the financial data below, provide **one concise, practical budget tip** to help optimize spending, savings, and money management, focusing on $selectedFocus. The tip should be human, approachable, and tailored to the data, using a warm and encouraging tone. Keep it to one sentence, make it actionable. Use the following guidelines:
- If income is \$0, focus on reducing expenses (e.g., cut specific category spending) or reallocating to essential categories (e.g., prioritize Food over Entertainment).
- If income is positive, suggest saving a percentage (e.g., 10% of income) or reducing high-spending categories (e.g., cut 20% from Entertainment).
- Provide specific actions (e.g., "cut \$50 from Entertainment," "save \$20 monthly") based on income-to-expense ratio or category data.
- Encourage mindful money behavior (e.g., "plan purchases in advance," "avoid impulse buys").
- Use category data to identify high-spending areas or essentials.

- Monthly Income (Balance): \$${income.toStringAsFixed(2)}
- Monthly Expenses: \$${expenses.toStringAsFixed(2)}
- Spending by Category: ${categories.entries.map((e) => '${e.key}: \$${e.value.toStringAsFixed(2)}').join(', ')}
- Timestamp: $timestamp

Return the tip as a single line, without any asterisks or bullet points.
''';

      debugPrint('AiService: Sending prompt to Gemini: $prompt');

      // Call Gemini API
      final response = await model.generateContent([Content.text(prompt)]);
      final tip = response.text?.trim() ?? '';

      debugPrint('AiService: Generated tip: $tip');

      if (tip.isEmpty) {
        debugPrint('AiService: Gemini returned empty tip');
        return ['Review your spending to find small ways to save this month.'];
      }

      return [tip];
    } catch (e, stackTrace) {
      debugPrint('AiService: Error generating tip: $e\n$stackTrace');
      return ['Error generating tip: $e'];
    }
  }
}
