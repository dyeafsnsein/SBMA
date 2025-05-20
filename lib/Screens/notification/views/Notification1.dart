import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Controllers/notification_controller.dart';
import '../../../Services/notification_service.dart';
import '../../../Services/notification_permission_service.dart';
import '../../../Services/ai_service.dart';
import '../../../Services/data_service.dart';
import '../../../Models/notification_model.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => NotificationController(
        NotificationModel(),
        Provider.of<DataService>(context, listen: false),
        Provider.of<NotificationService>(context, listen: false),
        Provider.of<AiService>(context, listen: false),
      ),
      child: Consumer<NotificationController>(
        builder: (context, controller, child) {          WidgetsBinding.instance.addPostFrameCallback((_) async {
            debugPrint(
                'NotificationPage: Checking SharedPreferences for cached tip');
            
            // Check notification permissions
            if (context.mounted) {
              await NotificationPermissionService.showEnableNotificationsDialog(context);
            }
            
            // Auto-enable transaction reminders for testing
            if (!controller.transactionRemindersEnabled) {
              debugPrint('NotificationPage: Auto-enabling transaction reminders');
              try {
                await controller.enableTransactionReminders(testMode: true);
              } catch (e) {
                debugPrint('NotificationPage: Error auto-enabling reminders: $e');
              }
            }
            
            final prefs = await SharedPreferences.getInstance();
            final tip = prefs.getString('budget_tip_0');
            final deletedTip = prefs.getString('deleted_tip');
            if (tip != null && deletedTip != tip) {
              final parts = tip.split('|');
              if (parts.length == 3) {
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
              child: Column(
                children: [
                  // Transaction Reminder Settings Card
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.06,
                      vertical: screenHeight * 0.02,
                    ),
                    child: Card(
                      color: const Color(0xFF2A2E2C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Transaction Reminders',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Get daily reminders to fill in your transactions',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Enable daily reminders',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                Switch(
                                  value: controller.transactionRemindersEnabled,
                                  activeColor: const Color(0xFF00FF94),
                                  onChanged: (value) async {
                                    try {                                      if (value) {
                                        // For testing, use testMode: true to make it every 30 seconds
                                        // For production, use testMode: false for daily reminders
                                        await controller.enableTransactionReminders(testMode: true);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Transaction reminders enabled'),
                                            ),
                                          );
                                        }
                                      } else {
                                        await controller.disableTransactionReminders();
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Transaction reminders disabled'),
                                            ),
                                          );
                                        }
                                      }
                                    } catch (e) {
                                      debugPrint('NotificationPage: Error toggling reminders: $e');
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Error: $e'),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Debug button for testing notifications on physical devices
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.06,
                      vertical: screenHeight * 0.01,
                    ),
                    child: Card(
                      color: const Color(0xFF007FFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () async {
                          try {
                            await controller.showDebugNotification();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Debug notification sent. Check your notification shade.'),
                                  duration: Duration(seconds: 3),
                                ),
                              );
                            }
                          } catch (e) {
                            debugPrint('NotificationPage: Error sending debug notification: $e');
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error sending notification: $e'),
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            }
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.bug_report,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Test Notification on Device',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Notifications List
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.06,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Recent Notifications',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
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
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: controller.isAnalyzingTips
                  ? null
                  : () async {
                      debugPrint('NotificationPage: Generating AI budget tip');
                      final timestamp =
                          DateFormat('d MMMM').format(DateTime.now());
                      try {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove('budget_tip_0');
                        await prefs.remove('budget_tip_1');
                        await prefs.remove('budget_tip_2');
                        await prefs.remove('deleted_tip');
                        controller.clearNotifications();
                        debugPrint(
                            'NotificationPage: Cleared cached tips, deleted tip flag, and notifications');                        // First generate tips but don't show notifications yet
                        final tips = await controller.generateBudgetTips(
                          context: null, // Don't trigger notifications here
                          timestamp: timestamp,
                        );
                        if (!context.mounted) return;

                        if (tips.isNotEmpty &&
                            !tips.contains('No spending data')) {
                          final title = 'AI Budget Tip';
                          final message = tips[0].replaceAll('\n', ' ');
                          
                          // Check if this tip already exists in the notifications
                          final exists = controller.notifications
                              .any((n) => n['title'] == title && n['message'] == message);
                              
                          if (!exists) {
                            // Add to notifications list in the model/database
                            controller.addNotification(
                              'lib/assets/Notification.png',
                              title,
                              message,
                              timestamp,
                            );
                            
                            // Cache the tip
                            final tipData =
                                'lib/assets/Notification.png|$title|$message';
                            await prefs.setString('budget_tip_0', tipData);
                              // Now show the notification separately
                            final notificationService = Provider.of<NotificationService>(context, listen: false);
                            await notificationService.showBudgetTips(context, [message]);
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('AI tip added')),
                            );
                            debugPrint('NotificationPage: AI tip added successfully: $tips');
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('This tip already exists')),
                            );
                            debugPrint('NotificationPage: Skipped duplicate tip: $message');
                          }
                        } else {
                          controller.addNotification(
                            'lib/assets/Error.png',
                            'AI Budget Tip',
                            'No budget tip generated. Please add more transactions.',
                            timestamp,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'No tip generated. Add transactions.')),
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
                          timestamp,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(errorMessage)),
                        );
                        debugPrint(
                            'NotificationPage: AI tip generation failed: $e\n$stackTrace');
                      }
                    },
              backgroundColor: const Color(0xFF00FF94),
              child: controller.isAnalyzingTips
                  ? const CircularProgressIndicator()
                  : const Icon(Icons.auto_awesome),
              tooltip: 'Generate AI Budget Tip',
            ),
          );
        },
      ),
    );
  }
}
