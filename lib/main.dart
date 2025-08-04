// lib/main.dart
import 'package:expense_tracker/controllers/auth_controller.dart';
import 'package:expense_tracker/controllers/expense_controller.dart';
import 'package:expense_tracker/controllers/navigation_controller.dart';
import 'package:expense_tracker/firebase_options.dart';
import 'package:expense_tracker/screens/auth_wrapper.dart';
import 'package:expense_tracker/screens/settings_screen.dart';
import 'package:expense_tracker/services/theme_service.dart';
import 'package:expense_tracker/screens/app_shell.dart';
import 'package:expense_tracker/screens/login_screen.dart';
import 'package:expense_tracker/screens/signup_screen.dart';
// import 'package:expense_tracker/screens/otp_screen.dart'; // <<< DELETED THIS LINE
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ThemeService(), permanent: true);
    Get.put(AuthController(), permanent: true);
    Get.put(ExpenseController(), permanent: true);
    Get.put(NavigationController(), permanent: true);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = ThemeService();

    return GetMaterialApp(
      title: 'Expense Tracker',
      
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.teal,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey.shade100,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.teal, brightness: Brightness.dark),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal.shade700,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
      ),

      themeMode: themeService.theme,
      debugShowCheckedModeBanner: false,
      initialBinding: AppBinding(),
      home: const AuthWrapper(),
      
      getPages: [
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/signup', page: () => SignupScreen()),
        // GetPage(name: '/otp', page: () => OTPScreen()), // <<< DELETED THIS LINE
        GetPage(name: '/home', page: () => const AppShell()),
        GetPage(name: '/settings', page: () => const SettingsScreen()),
      ],
    );
  }
}