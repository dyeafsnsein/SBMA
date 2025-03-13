import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auto_route/auto_route.dart';
import 'package:provider/provider.dart';
import '../../../Controllers/notification_controller.dart';
import '../../../Models/notification_model.dart';

@RoutePage()
class NotificationPage extends StatelessWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NotificationController(NotificationModel()),
      child: Consumer<NotificationController>(
        builder: (context, controller, child) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
            ),
            child: Scaffold(
              backgroundColor: const Color(0xFF202422),
              body: Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        flex: 16,
                        child: Container(
                          color: const Color(0xFF202422),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(25, 60, 25, 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                  ),
                                ),
                                const Text(
                                  'Notification',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF050505),
                                    borderRadius: BorderRadius.circular(25.71),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.notifications,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 84,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1FFF3),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(40),
                              topRight: Radius.circular(40),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: ListView.builder(
                              itemCount: controller.notifications.length,
                              itemBuilder: (context, index) {
                                final notification = controller.notifications[index];
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (index == 0) const Text('Today'),
                                    if (index == 2) const Text('Yesterday'),
                                    if (index == 4) const Text('This Weekend'),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF202422),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Center(
                                            child: Image.asset(
                                              notification['icon'] as String,
                                              width: 24,
                                              height: 24,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                notification['title']!,
                                                style: const TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF202422),
                                                ),
                                              ),
                                              Text(
                                                notification['message']!,
                                                style: const TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400,
                                                  color: Color(0xFF202422),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Text(
                                          notification['time']!,
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xFF202422),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(
                                      color: Color(0xFF202422),
                                      thickness: 1,
                                      height: 20,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
