import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../Controllers/notification_controller.dart';
import '../../../Controllers/analysis_controller.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Consumer<NotificationController>(
      builder: (context, controller, child) {
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
                            leading: Icon(
                              Icons.notifications,
                              color: Colors.white70,
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
                              notification['message'] ?? 'No message',
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
              final analysisController = context.read<AnalysisController>();
              try {
                final tips = await analysisController.generateBudgetTips();
                if (context.mounted) {
                  controller.addNotification(
                    'notifications', // Icon name or path
                    'AI Budget Tips',
                    tips.isNotEmpty ? tips.join('\n') : 'No tips generated.',
                    DateTime.now().toIso8601String(),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  controller.addNotification(
                    'error',
                    'AI Error',
                    'Failed to generate tips: $e',
                    DateTime.now().toIso8601String(),
                  );
                }
              }
            },
            backgroundColor: const Color(0xFF00FF94),
            child: const Icon(Icons.auto_awesome),
            tooltip: 'Test AI Model',
          ),
        );
      },
    );
  }
}
