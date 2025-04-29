import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'Controllers/auth_controller.dart';
import 'Controllers/home_controller.dart';
import 'Controllers/analysis_controller.dart';
import 'Controllers/transaction_controller.dart';
import 'Controllers/savings_controller.dart';
import 'Models/analysis_model.dart';
import 'Services/data_service.dart';
import 'Services/ai_service.dart';
import 'Services/notification_service.dart';
import 'Services/automation_service.dart';
import 'Route/app_router.dart';
import 'Controllers/category_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    debugPrint('Main: Firebase initialized successfully');
  } catch (e, stackTrace) {
    debugPrint('Main: Error initializing Firebase: $e\n$stackTrace');
  }

  try {
    await dotenv.load(fileName: '.env');
    debugPrint('Main: .env loaded successfully');
  } catch (e, stackTrace) {
    debugPrint('Main: Error loading .env: $e\n$stackTrace');
  }

  final notificationService = NotificationService();
  try {
    await notificationService.init();
    debugPrint('Main: NotificationService initialized successfully');
  } catch (e, stackTrace) {
    debugPrint('Main: Error initializing NotificationService: $e\n$stackTrace');
  }

  if (Platform.isAndroid) {
    try {
      debugPrint('Main: Starting AutomationService setup for Android');
      await AutomationService.init();
      debugPrint('Main: AutomationService initialized');
      await AutomationService.scheduleWeeklyAnalysis();
      debugPrint('Main: AutomationService scheduled');
      final plugin = FlutterLocalNotificationsPlugin();
      final androidPlugin = plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();
        debugPrint('Main: Requested notification permission');
      } else {
        debugPrint('Main: Android notification plugin not available');
      }
    } catch (e, stackTrace) {
      debugPrint('Main: Error setting up AutomationService: $e\n$stackTrace');
    }
  } else {
    debugPrint('Main: Skipping AutomationService setup (not Android)');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => DataService()),
        Provider(create: (_) => AiService()),
        Provider(create: (_) => NotificationService()),
        ChangeNotifierProvider(create: (context) => AuthController()),
        ChangeNotifierProvider(
            create: (context) => HomeController(context.read<DataService>())),
        ChangeNotifierProvider(create: (context) => SavingsController()),
        ChangeNotifierProvider(
          create: (context) => AnalysisController(
            AnalysisModel(),
            context.read<DataService>(),
            context.read<SavingsController>(),
            context.read<AiService>(),
            context.read<NotificationService>(),
          ),
        ),
        ChangeNotifierProvider(
            create: (context) =>
                TransactionController(context.read<DataService>())),
        ChangeNotifierProvider(create: (_) => CategoryController()),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
      ),
    );
  }
}
