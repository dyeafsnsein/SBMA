import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Controllers/notification_controller.dart';
import '../../../Controllers/analysis_controller.dart';
import '../../../Models/notification_model.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NotificationController(NotificationModel()),
      child: Consumer<NotificationController>(
        builder: (context, controller, child) {
          // Load cached tip from SharedPreferences once
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            debugPrint(
                'NotificationPage: Checking SharedPreferences for cached tip');
            final prefs = await SharedPreferences.getInstance();
            final tip = prefs.getString('budget_tip_0');
            final deletedTip = prefs.getString('deleted_tip');
            if (tip != null && deletedTip != tip) {
              final parts = tip.split('|');
              if (parts.length == 3) {
                // Check for duplicates
                final exists = controller.notifications.any(
                    (n) => n['title'] == parts[1] && n['message'] == parts[2]);
                if (!exists) {
                  controller.addNotification(
                    parts[0], // icon
                    parts[1], // title
                    parts[2].replaceAll('\n', ' '), // message
                    DateFormat('d MMMM').format(DateTime.now()),
                  );
                  debugPrint(
                      'NotificationPage: Loaded cached tip: ${parts[1]}');
                } else {
                  debugPrint('NotificationPage: Skipped duplicate cached tip');
                }
              }
            } else {
              debugPrint('NotificationPage: Skipped loading deleted tip');
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
                                onPressed: () async {
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  final tipData =
                                      '${notification['icon']}|${notification['title']}|${notification['message']}';
                                  await prefs.setString('deleted_tip', tipData);
                                  controller
                                      .removeNotification(notification['id']);
                                  debugPrint(
                                      'NotificationPage: Removed notification ${notification['id']} and marked as deleted');
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
                debugPrint('NotificationPage: Generating AI budget tip');
                final analysisController = context.read<AnalysisController>();
                try {
                  // Clear previous tips and notifications
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('budget_tip_0');
                  await prefs.remove('budget_tip_1');
                  await prefs.remove('budget_tip_2');
                  await prefs.remove('deleted_tip');
                  controller.clearNotifications();
                  debugPrint(
                      'NotificationPage: Cleared cached tips, deleted tip flag, and notifications');

                  final timestamp = DateFormat('d MMMM').format(DateTime.now());
                  final tips = await analysisController.generateBudgetTips(
                    context: context,
                    timestamp: timestamp,
                  );
                  if (!context.mounted) return;

                  if (tips.isNotEmpty && !tips.contains('No sufficient data')) {
                    controller.addNotification(
                      'lib/assets/Notification.png',
                      'AI Budget Tip',
                      tips[0].replaceAll('\n', ' '),
                      timestamp,
                    );
                    // Cache the tip
                    final tipData =
                        'lib/assets/Notification.png|AI Budget Tip|${tips[0].replaceAll('\n', ' ')}';
                    await prefs.setString('budget_tip_0', tipData);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('AI tip added')),
                    );
                    debugPrint(
                        'NotificationPage: AI tip added successfully: $tips');
                  } else {
                    controller.addNotification(
                      'lib/assets/Error.png',
                      'AI Budget Tip',
                      'No budget tip generated. Please add more transactions.',
                      timestamp,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('No tip generated. Add transactions.')),
                    );
                    debugPrint(
                        'NotificationPage: No valid tip generated: $tips');
                  }
                } catch (e, stackTrace) {
                  if (!context.mounted) return;
                  String errorMessage = 'Failed to generate tip: $e';
                  if (e.toString().contains('NotInitializedError')) {
                    errorMessage =
                        'AI service not initialized. Please try again later.';
                  }
                  controller.addNotification(
                    'lib/assets/Error.png',
                    'AI Budget Tip',
                    errorMessage,
                    DateFormat('d MMMM').format(DateTime.now()),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(errorMessage)),
                  );
                  debugPrint(
                      'NotificationPage: AI tip generation failed: $e\n$stackTrace');
                }
              },
              backgroundColor: const Color(0xFF00FF94),
              child: const Icon(Icons.auto_awesome),
              tooltip: 'Generate AI Budget Tip',
            ),
          );
        },
      ),
    );
  }
}
