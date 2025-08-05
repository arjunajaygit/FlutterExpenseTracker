// lib/main.dart
import 'package:expense_tracker/controllers/auth_controller.dart';
import 'package:expense_tracker/controllers/expense_controller.dart';
import 'package:expense_tracker/controllers/navigation_controller.dart';
import 'package:expense_tracker/firebase_options.dart';
import 'package:expense_tracker/screens/auth_wrapper.dart';
import 'package:expense_tracker/services/theme_service.dart';
import 'package:expense_tracker/screens/app_shell.dart';
import 'package:expense_tracker/screens/login_screen.dart';
import 'package:expense_tracker/screens/signup_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primaryColor = Color(0xFF2F2F2F);
  static const Color secondaryColor = Color(0xFF757575);
  static const Color bgColor = Color(0xFFF6F6F6);
  static const Color cardColor = Colors.white;

  // Dark Theme Colors
  static const Color darkBgColor = Color(0xFF1E1E1E);
  static const Color darkCardColor = Color(0xFF2C2C2C);
  static const Color darkPrimaryColor = Colors.white;
  static const Color darkSecondaryColor = Colors.grey;

  static const Gradient primaryGradient = LinearGradient(
    colors: [Color(0xFF8B50F3), Color(0xFFF14285)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

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

    // --- LIGHT THEME DEFINITION ---
    final lightTheme = ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primaryColor,
      scaffoldBackgroundColor: AppColors.bgColor,
      cardColor: AppColors.cardColor,
      textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme).apply(
        bodyColor: AppColors.primaryColor,
        displayColor: AppColors.primaryColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.primaryColor),
        titleTextStyle: TextStyle(
          color: AppColors.primaryColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardColor,
        elevation: 0.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(
          color: AppColors.secondaryColor,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
    
    // --- DARK THEME DEFINITION (THE FIX) ---
    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.darkPrimaryColor,
      scaffoldBackgroundColor: AppColors.darkBgColor,
      cardColor: AppColors.darkCardColor,
      textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme).apply(
        bodyColor: AppColors.darkPrimaryColor,
        displayColor: AppColors.darkPrimaryColor,
      ),
       appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.darkPrimaryColor),
        titleTextStyle: TextStyle(
          color: AppColors.darkPrimaryColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCardColor,
        elevation: 0.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCardColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(
          color: AppColors.darkSecondaryColor,
          fontWeight: FontWeight.normal,
        ),
      ),
    );

    return GetMaterialApp(
      title: 'Expense Tracker',
      theme: lightTheme,
      darkTheme: darkTheme, // <<< THIS IS THE FIX
      themeMode: themeService.theme,
      debugShowCheckedModeBanner: false,
      initialBinding: AppBinding(),
      home: const AuthWrapper(),
      getPages: [
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/signup', page: () => SignupScreen()),
        GetPage(name: '/home', page: () => const AppShell()),
      ],
    );
  }
}