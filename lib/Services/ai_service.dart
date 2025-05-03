import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiService {
  Future<List<String>> generateBudgetTips({
    required double income,
    required double expenses,
    required Map<String, double> categories,
  }) async {
    debugPrint(
        'AiService: Generating budget tips with income=$income, expenses=$expenses, categories=$categories');
    try {
      // Validate input
      if (income <= 0 || expenses <= 0 || categories.isEmpty) {
        debugPrint('AiService: Invalid input data, returning empty tips');
        return ['No tips generated due to invalid data.'];
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

      // Create a prompt for Gemini
      final prompt = '''
You are a financial advisor. Based on the following financial data, provide 3-5 concise budget tips to help optimize spending and savings. Each tip should be a single sentence and focus on practical advice.

- Monthly Income: \$${income.toStringAsFixed(2)}
- Monthly Expenses: \$${expenses.toStringAsFixed(2)}
- Spending by Category: ${categories.entries.map((e) => '${e.key}: \$${e.value.toStringAsFixed(2)}').join(', ')}

Please format the response as a list of tips, one per line.
''';

      debugPrint('AiService: Sending prompt to Gemini: $prompt');

      // Call Gemini API
      final response = await model.generateContent([Content.text(prompt)]);
      final tips = response.text
              ?.split('\n')
              .map((line) => line.trim())
              .where((line) => line.isNotEmpty)
              .toList() ??
          [];

      debugPrint('AiService: Generated tips: $tips');

      if (tips.isEmpty) {
        debugPrint('AiService: Gemini returned empty tips');
        return ['Review your spending for potential savings.'];
      }

      return tips;
    } catch (e) {
      debugPrint('AiService: Error generating tips: $e');
      return ['Error generating tips: $e'];
    }
  }
}
