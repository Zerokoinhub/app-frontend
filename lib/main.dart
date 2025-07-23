import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:zero_koin/controllers/theme_controller.dart';
import 'package:zero_koin/controllers/user_controller.dart';
import 'package:zero_koin/controllers/user_stats_controller.dart';
import 'package:zero_koin/controllers/course_controller.dart'; // Import CourseController
import 'package:zero_koin/controllers/notification_controller.dart'; // Import NotificationController
import 'package:zero_koin/controllers/session_controller.dart'; // Import SessionController
import 'package:zero_koin/controller/language_controller.dart'; // Import LanguageController
import 'package:zero_koin/controllers/admob_controller.dart'; // Import AdMobController
import 'package:zero_koin/services/auth_service.dart';
import 'package:zero_koin/services/notification_service.dart';
import 'package:zero_koin/services/admob_service.dart';
import 'package:zero_koin/services/time_validation_service.dart';
import 'package:zero_koin/view/splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase only if not already initialized
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // Initialize ThemeController
  Get.put(ThemeController());

  // Initialize AuthService
  Get.put(AuthService());

  // Initialize UserController
  Get.put(UserController());

  // Initialize LanguageController
  Get.put(LanguageController());

  // Initialize UserStatsController
  Get.put(UserStatsController());

  // Initialize CourseController
  Get.put(CourseController());

  // Initialize NotificationController
  Get.put(NotificationController());

  // Initialize TimeValidationService first (required by SessionController)
  Get.put(TimeValidationService());

  // Initialize SessionController (depends on TimeValidationService)
  Get.put(SessionController());

  // Initialize NotificationService
  Get.put(NotificationService());

  // Initialize AdMob
  await AdMobService.initialize();

  // Initialize AdMobController
  Get.put(AdMobController());

  // Set status bar to light content (white text/icons)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeController.lightTheme,
      darkTheme: themeController.darkTheme,
      themeMode: ThemeMode.system, // This will be overridden by Get.changeTheme
      home: const SplashScreen(),
    );
  }
}
