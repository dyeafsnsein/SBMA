import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
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
    await notificationService.requestPermissions();
    debugPrint('Main: Notification permissions requested');
  } catch (e, stackTrace) {
    debugPrint('Main: Error initializing NotificationService: $e\n$stackTrace');
  }

  if (Platform.isAndroid) {
    try {
      debugPrint('Main: Starting NotificationController setup for Android');
      await NotificationController.scheduleWeeklyAnalysis();
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
    return MultiProvider(      providers: [
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
            context.read<AiService>(),
            context.read<NotificationService>(),
            context.read<CategoryController>(),
          ),
        ),
        ChangeNotifierProvider(
            create: (context) =>
                TransactionController(context.read<DataService>())),
        ChangeNotifierProvider(
            create: (context) => NotificationController(NotificationModel())),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
      ),
    );
  }
}
