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
  // Ensure Flutter binding is initialized first
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await Firebase.initializeApp();
    if (kDebugMode) print('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Failed to initialize Firebase: $e');
  }

  try {
    // Load environment variables
    await dotenv.load(fileName: '.env');
    if (dotenv.env['GEMINI_API_KEY']?.isEmpty ?? true) {
      debugPrint('Warning: GEMINI_API_KEY is missing or empty');
    }
  } catch (e) {
    debugPrint('Failed to load environment variables: $e');
  }

  // Initialize notification service
  final notificationService = NotificationService();
  try {
    await notificationService.init();
    await notificationService.requestPermissions();

    // Show debug notification if enabled
    final prefs = await SharedPreferences.getInstance();
    final debugMode = prefs.getBool('debug_notifications') ?? false;
    if (debugMode && kDebugMode) {
      await notificationService.showImmediateDebugNotification();
    }
  } catch (e) {
    debugPrint('Notification service initialization failed: $e');
  }

  // Notifications are now always enabled and handled by NotificationController

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
