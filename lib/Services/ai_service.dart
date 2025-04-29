import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../Models/transaction_model.dart';

class AiService {
  static const List<Map<String, dynamic>> _tipTemplates = [
    {
      'condition': 'amount > 100',
      'template': 'You spent \${amount} on \${category} this week. '
          'Consider budgeting \${(amount * 0.8)} next week to save.',
    },
    {
      'condition': '50 <= amount <= 100',
      'template': 'Your \${category} spending was \${amount}. '
          'Try allocating 10% to savings for better financial health.',
    },
    {
      'condition': 'amount > 0',
      'template': 'Nice job keeping \${category} spending at \${amount}! '
          'Set a weekly budget to maintain control.',
    },
  ];

  Future<List<String>> generateBudgetTips(
      List<TransactionModel> transactions) async {
    try {
      if (transactions.isEmpty) {
        debugPrint(
            'AiService: No transactions provided, returning default tips');
        return [
          'No transactions this week. Start tracking expenses!',
          'Set a weekly budget to manage finances.',
          'Add transactions to get personalized tips.',
        ];
      }

      // Validate transactions
      for (var t in transactions) {
        if (!['income', 'expense'].contains(t.type)) {
          debugPrint(
              'AiService: Invalid transaction type: ${t.type} for ID: ${t.id}');
          throw Exception('Invalid transaction type: ${t.type}');
        }
        if (t.amount.isNaN || t.amount.isInfinite) {
          debugPrint('AiService: Invalid amount: ${t.amount} for ID: ${t.id}');
          throw Exception('Invalid amount: ${t.amount}');
        }
        if (t.category.isEmpty) {
          debugPrint('AiService: Empty category for ID: ${t.id}');
          throw Exception('Empty category in transaction');
        }
      }

      // Summarize expenses
      final Map<String, double> spendingByCategory = {};
      double totalSpending = 0;
      for (var t in transactions.where((t) => t.type == 'expense')) {
        final amount = t.amount.abs();
        final category = t.category;
        spendingByCategory.update(category, (value) => value + amount,
            ifAbsent: () => amount);
        totalSpending += amount;
      }
      final summary =
          '${spendingByCategory.entries.map((e) => '${e.key}: \$${e.value.toStringAsFixed(2)}').join(', ')}. Total: \$${totalSpending.toStringAsFixed(2)}';
      debugPrint('AiService: Spending summary: $summary');

      // Call OpenAI GPT
      final apiKey = dotenv.env['OPENAI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        debugPrint('AiService: OpenAI API key not found in .env');
        throw Exception('OpenAI API key not found');
      }

      debugPrint('AiService: Sending request to OpenAI API');
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a financial advisor. Analyze the user\'s weekly spending and provide exactly 3 concise, actionable budgeting tips. Focus on high-spending categories and practical advice.',
            },
            {
              'role': 'user',
              'content':
                  'My spending this week: $summary. Provide 3 budgeting tips.',
            },
          ],
          'max_tokens': 150,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode != 200) {
        debugPrint(
            'AiService: OpenAI API error: ${response.statusCode} - ${response.body}');
        throw Exception(
            'OpenAI API error: ${response.statusCode} - ${response.body}');
      }

      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['choices'] == null || jsonResponse['choices'].isEmpty) {
        debugPrint('AiService: Invalid GPT response: $jsonResponse');
        throw Exception('Invalid GPT response: No choices found');
      }

      final tips = (jsonResponse['choices'][0]['message']['content'] as String)
          .split('\n')
          .where((tip) => tip.trim().isNotEmpty)
          .take(3)
          .map((tip) => tip.replaceAll(RegExp(r'^- |\* '), ''))
          .toList();

      if (tips.length < 3) {
        debugPrint('AiService: Insufficient tips from GPT: $tips');
        throw Exception(
            'Insufficient tips from GPT: ${tips.length} tips received');
      }

      debugPrint('AiService: Successfully generated GPT tips: $tips');
      return tips;
    } catch (e, stackTrace) {
      debugPrint('AiService: Error generating tips: $e\n$stackTrace');
      return _generateRuleBasedTips(transactions);
    }
  }

  List<String> _generateRuleBasedTips(List<TransactionModel> transactions) {
    final Map<String, double> spendingByCategory = {};
    for (var t in transactions.where((t) => t.type == 'expense')) {
      final amount = t.amount.abs();
      final category = t.category.isEmpty ? 'Unknown' : t.category;
      spendingByCategory.update(category, (value) => value + amount,
          ifAbsent: () => amount);
    }

    List<String> tips = [];
    spendingByCategory.forEach((category, amount) {
      for (var template in _tipTemplates) {
        bool conditionMet;
        if (template['condition'] == 'amount > 100') {
          conditionMet = amount > 100;
        } else if (template['condition'] == '50 <= amount <= 100') {
          conditionMet = amount >= 50 && amount <= 100;
        } else {
          conditionMet = amount > 0;
        }
        if (conditionMet && tips.length < 3) {
          var tip = template['template'] as String;
          tip = tip
              .replaceAll('\${amount}', amount.toStringAsFixed(2))
              .replaceAll('\${category}', category)
              .replaceAll(
                  '\${(amount * 0.8)}', (amount * 0.8).toStringAsFixed(2));
          tips.add(tip);
          break;
        }
      }
    });

    while (tips.length < 3) {
      double totalSpending =
          spendingByCategory.values.fold(0, (sum, amount) => sum + amount);
      tips.add(
        'Your total spending this week was \$${totalSpending.toStringAsFixed(2)}. '
        'Try setting a weekly budget to stay on track.',
      );
    }
    debugPrint('AiService: Generated rule-based tips: $tips');
    return tips.take(3).toList();
  }
}
