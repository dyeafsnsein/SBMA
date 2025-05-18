import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Controllers/notification_controller.dart';
import '../../../Controllers/analysis_controller.dart';
import '../../../Models/notification_model.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NotificationController(NotificationModel()),
      child: Consumer<NotificationController>(
        builder: (context, controller, child) {
          // Load cached tips from SharedPreferences
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            debugPrint(
                'NotificationPage: Checking SharedPreferences for cached tips');
            final prefs = await SharedPreferences.getInstance();
            for (int i = 0; i < 3; i++) {
              final tip = prefs.getString('budget_tip_$i');
              if (tip != null) {
                final parts = tip.split('|');
                if (parts.length == 3) {
                  controller.addNotification(
                    parts[0], // icon
                    parts[1], // title
                    parts[2].replaceAll('\n', ' '), // message
                    DateTime.now().toIso8601String(),
                  );
                  debugPrint(
                      'NotificationPage: Loaded cached tip $i: ${parts[1]}');
                }
              }
            }
          });

          final screenWidth = MediaQuery.of(context).size.width;
          final screenHeight = MediaQuery.of(context).size.height;

          return Scaffold(
            backgroundColor: const Color(0xFF202422),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  if (!context.mounted) return;
                  context.go('/');
                  debugPrint('NotificationPage: Back button pressed');
                },
              ),
              title: const Text(
                'Notifications',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.06,
                  vertical: screenHeight * 0.02,
                ),
                child: controller.notifications.isEmpty
                    ? const Center(
                        child: Text(
                          'No notifications available',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: controller.notifications.length,
                        itemBuilder: (context, index) {
                          final notification = controller.notifications[index];
                          return Card(
                            color: const Color(0xFF2A2E2C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: Image.asset(
                                notification['icon'] ??
                                    'lib/assets/Notification.png',
                                width: 24,
                                height: 24,
                                errorBuilder: (context, error, stackTrace) {
                                  debugPrint(
                                      'NotificationPage: Failed to load icon: ${notification['icon']}, error: $error');
                                  return const Icon(
                                    Icons.notifications,
                                    color: Colors.white70,
                                  );
                                },
                              ),
                              title: Text(
                                notification['title'] ?? 'Untitled',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                notification['message']
                                        ?.replaceAll('\n', ' ') ??
                                    'No message',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.white70),
                                onPressed: () {
                                  controller
                                      .removeNotification(notification['id']);
                                  debugPrint(
                                      'NotificationPage: Removed notification ${notification['id']}');
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                debugPrint('NotificationPage: Generating AI budget tips');
                final analysisController = context.read<AnalysisController>();
                try {
                  // Clear previous tips in SharedPreferences
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('budget_tip_0');
                  await prefs.remove('budget_tip_1');
                  await prefs.remove('budget_tip_2');
                  debugPrint('NotificationPage: Cleared cached tips');

                  final timestamp = DateTime.now().toIso8601String();
                  final tips = await analysisController.generateBudgetTips(
                    context: context,
                    timestamp: timestamp,
                  );
                  if (!context.mounted) return;

                  if (tips.isNotEmpty && !tips.contains('No sufficient data')) {
                    for (int i = 0; i < tips.length && i < 3; i++) {
                      controller.addNotification(
                        'lib/assets/Notification.png',
                        'AI Budget Tip ${i + 1}',
                        tips[i].replaceAll('\n', ' '),
                        DateTime.now().toIso8601String(),
                      );
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('AI tips added')),
                    );
                    debugPrint(
                        'NotificationPage: AI tips added successfully: $tips');
                  } else {
                    controller.addNotification(
                      'lib/assets/Error.png',
                      'AI Budget Tip Error',
                      'No budget tips generated. Please add more transactions.',
                      DateTime.now().toIso8601String(),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('No tips generated. Add transactions.')),
                    );
                    debugPrint(
                        'NotificationPage: No valid tips generated: $tips');
                  }
                } catch (e, stackTrace) {
                  if (!context.mounted) return;
                  String errorMessage = 'Failed to generate tips: $e';
                  if (e.toString().contains('NotInitializedError')) {
                    errorMessage =
                        'AI service not initialized. Please try again later.';
                  }
                  controller.addNotification(
                    'lib/assets/Error.png',
                    'AI Error',
                    errorMessage,
                    DateTime.now().toIso8601String(),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(errorMessage)),
                  );
                  debugPrint(
                      'NotificationPage: AI tips generation failed: $e\n$stackTrace');
                }
              },
              backgroundColor: const Color(0xFF00FF94),
              child: const Icon(Icons.auto_awesome),
              tooltip: 'Generate AI Budget Tips',
            ),
          );
        },
      ),
    );
  }
}
