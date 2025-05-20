import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Controllers/auth_controller.dart';
import 'Controllers/home_controller.dart';
import 'Controllers/analysis_controller.dart';
import 'Controllers/transaction_controller.dart';
import 'Controllers/savings_controller.dart';
import 'Controllers/notification_controller.dart';
import 'Controllers/category_controller.dart';
import 'Models/analysis_model.dart';
import 'Models/notification_model.dart';
import 'Services/data_service.dart';
import 'Services/ai_service.dart';
import 'Services/notification_service.dart';
import 'Route/app_router.dart';

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
    final geminiApiKey = dotenv.env['GEMINI_API_KEY'];
    debugPrint('Main: GEMINI_API_KEY Loaded: ${geminiApiKey?.isNotEmpty}');
    if (geminiApiKey == null || geminiApiKey.isEmpty) {
      debugPrint('Main: GEMINI_API_KEY is missing or empty');
    }
  } catch (e, stackTrace) {
    debugPrint('Main: Error loading .env: $e\n$stackTrace');
  }
  final notificationService = NotificationService();
  try {
    await notificationService.init();
    debugPrint('Main: NotificationService initialized successfully');
    
    // Request notification permissions explicitly
    await notificationService.requestPermissions();
    debugPrint('Main: Notification permissions requested');
    
    // Test the notification service with an immediate debug notification if enabled
    final prefs = await SharedPreferences.getInstance();
    final debugMode = prefs.getBool('debug_notifications') ?? false;
    if (debugMode) {
      // Only show this in debug mode
      await notificationService.showImmediateDebugNotification();
      debugPrint('Main: Sent debug notification during startup');
    }
  } catch (e, stackTrace) {
    debugPrint('Main: Error initializing NotificationService: $e\n$stackTrace');
  }
  if (Platform.isAndroid) {
    try {
      debugPrint('Main: Starting NotificationController setup for Android');
      await NotificationController.scheduleWeeklyAnalysis();
      
      // Check if transaction reminders should be enabled
      final prefs = await SharedPreferences.getInstance();
      final remindersEnabled = prefs.getBool('transaction_reminders_enabled') ?? false;
      if (remindersEnabled) {
        debugPrint('Main: Initializing transaction reminders');
        final aiService = AiService();
        final dataService = DataService();
        final notificationController = NotificationController(
          NotificationModel(),
          dataService,
          notificationService,
          aiService,
        );
        await notificationController.enableTransactionReminders(testMode: true, notify: false);
        debugPrint('Main: Transaction reminders enabled');
        notificationController.dispose();
      }
      
      debugPrint('Main: NotificationController scheduled');
    } catch (e, stackTrace) {
      debugPrint(
          'Main: Error setting up NotificationController: $e\n$stackTrace');
    }
  } else {
    debugPrint('Main: Skipping NotificationController setup (not Android)');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DataService()),
        Provider(create: (_) => AiService()),
        Provider(create: (_) => NotificationService()),
        ChangeNotifierProvider(create: (context) => AuthController()),
        ChangeNotifierProvider(
            create: (context) => HomeController(context.read<DataService>())),
        ChangeNotifierProvider(create: (context) => SavingsController()),
        ChangeNotifierProvider(create: (context) => CategoryController()),
        ChangeNotifierProvider(
          create: (context) => AnalysisController(
            AnalysisModel(),
            context.read<DataService>(),
            context.read<SavingsController>(),
          ),
        ),
        ChangeNotifierProvider(
            create: (context) =>
                TransactionController(context.read<DataService>())),
        ChangeNotifierProvider(
          create: (context) => NotificationController(
            NotificationModel(),
            context.read<DataService>(),
            context.read<NotificationService>(),
            context.read<AiService>(),
          ),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
      ),
    );
  }
}
