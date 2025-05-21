import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../Controllers/notification_controller.dart';
import '../../../Services/notification_service.dart';
import '../../../Services/notification_permission_service.dart';
import '../../../Services/ai_service.dart';
import '../../../Services/data_service.dart';
import '../../../Models/notification_model.dart';

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
        builder: (context, controller, child) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            // Check notification permissions
            if (context.mounted) {
              await NotificationPermissionService.showEnableNotificationsDialog(context);
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
                  // Transaction Reminder Info Card
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
                              'Reminders are enabled and will notify you every 8 hours to update your transactions',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: Colors.white70,
                              ),
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
                        child: const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
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
                                              await controller.markTipAsDeleted(notification);
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
                      try {
                        final success = await controller.generateAndAddBudgetTip(context);
                        
                        if (!context.mounted) return;
                        
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('AI tip added')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'No tip generated. Add more transactions.')),
                          );
                        }
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${e.toString()}')),
                        );
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
