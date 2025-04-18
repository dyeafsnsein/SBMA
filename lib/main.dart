import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Controllers/auth_controller.dart';
import 'Controllers/home_controller.dart';
import 'Controllers/analysis_controller.dart';
import 'Controllers/transaction_controller.dart';
import 'Models/analysis_model.dart';
import 'services/data_service.dart';
import 'Route/app_router.dart';
import 'Controllers/category_controller.dart';
import 'Controllers/savings_controller.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => DataService()),
        ChangeNotifierProvider(create: (context) => AuthController()),
        ChangeNotifierProvider(create: (context) => HomeController(context.read<DataService>())),
        ChangeNotifierProvider(create: (context) => AnalysisController(AnalysisModel(), context.read<DataService>())),
        ChangeNotifierProvider(create: (context) => TransactionController(context.read<DataService>())),
        ChangeNotifierProvider(create: (_) => CategoryController()),
        ChangeNotifierProvider(create: (_) => SavingsController()),

        // Add other controllers like NotificationController if needed
      ],
      child: MaterialApp.router(
        routerConfig: router,
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
      ),
    );
  }
}