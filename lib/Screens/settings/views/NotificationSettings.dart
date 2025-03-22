import 'package:flutter/material.dart';
import '../../../shared_components/custom_header.dart';
import '../../../shared_components/settings_toggle.dart';

class NotificationSettings extends StatefulWidget {
  const NotificationSettings({Key? key}) : super(key: key);

  @override
  _NotificationSettingsState createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  // State for toggle switches
  bool isSoundEnabled = false;
  bool isSoundCallEnabled = false;
  bool isVibrateEnabled = false;
  bool isTransactionUpdateEnabled = false;
  bool isBudgetNotificationsEnabled = false;
  bool isLowBalanceAlertsEnabled = false;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF202422),
      body: SafeArea(
        bottom: false, // Allow content to extend under bottom nav
        child: Column(
          children: [
            const CustomHeader(title: 'Notification Settings'),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF1FFF3),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: screenHeight * 0.03),
                        // General Notification Section
                        Text(
                          'General Notification',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: screenWidth * 0.045 > 20 ? 20 : screenWidth * 0.045,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF202422),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        SettingsToggle(
                          label: 'Sound',
                          value: isSoundEnabled,
                          onChanged: (value) {
                            setState(() => isSoundEnabled = value);
                          },
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        SettingsToggle(
                          label: 'Sound Call',
                          value: isSoundCallEnabled,
                          onChanged: (value) {
                            setState(() => isSoundCallEnabled = value);
                          },
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        SettingsToggle(
                          label: 'Vibrate',
                          value: isVibrateEnabled,
                          onChanged: (value) {
                            setState(() => isVibrateEnabled = value);
                          },
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        // Transaction Update Section
                        Text(
                          'Transaction Update',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: screenWidth * 0.045 > 20 ? 20 : screenWidth * 0.045,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF202422),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        SettingsToggle(
                          label: 'Transaction Update',
                          value: isTransactionUpdateEnabled,
                          onChanged: (value) {
                            setState(() => isTransactionUpdateEnabled = value);
                          },
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        // Expense Reminder Section
                        Text(
                          'Expense Reminder',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: screenWidth * 0.045 > 20 ? 20 : screenWidth * 0.045,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF202422),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        SettingsToggle(
                          label: 'Budget Notifications',
                          value: isBudgetNotificationsEnabled,
                          onChanged: (value) {
                            setState(() => isBudgetNotificationsEnabled = value);
                          },
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        SettingsToggle(
                          label: 'Low Balance Alerts',
                          value: isLowBalanceAlertsEnabled,
                          onChanged: (value) {
                            setState(() => isLowBalanceAlertsEnabled = value);
                          },
                        ),
                        SizedBox(height: screenHeight * 0.1 + bottomPadding + 20), // Space for bottom nav
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}