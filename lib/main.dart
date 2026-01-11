import 'dart:async';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zero_koin/controllers/theme_controller.dart';
import 'package:zero_koin/controllers/user_controller.dart';
import 'package:zero_koin/controllers/user_stats_controller.dart';
import 'package:zero_koin/controllers/course_controller.dart';
import 'package:zero_koin/controllers/notification_controller.dart';
import 'package:zero_koin/controllers/session_controller.dart';
import 'package:zero_koin/controllers/admob_controller.dart';
import 'package:zero_koin/services/admob_service.dart';
import 'package:zero_koin/services/auth_service.dart';
import 'package:zero_koin/services/biometric_service.dart';
import 'package:zero_koin/services/notification_service.dart';
import 'package:zero_koin/services/time_validation_service.dart';

import 'package:zero_koin/view/biometric_login_screen.dart';
import 'package:zero_koin/view/home_screen.dart';
import 'package:zero_koin/view/splash_screen.dart';
import 'package:zero_koin/view/user_registeration_screen.dart';
import 'firebase_options.dart';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart' show debugPrint;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase and AdMob in parallel for faster startup
  await Future.wait([
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
    AdMobService.initialize(),
    MobileAds.instance.initialize().then((initializationStatus) {
      initializationStatus.adapterStatuses.forEach((key, value) {
        developer.log('Adapter status for $key: ${value.description}');
      });
    }),
  ]);

  // Initialize essential controllers only (fast startup)
  Get.put(TimeValidationService()); // Required early
  Get.put(ThemeController()); // UI needs this
  Get.put(AuthService()); // Auth check needed
  Get.put(BiometricService()); // ADD THIS - Biometric service

  // Initialize AdMob separately for ads
  Get.put(AdMobController());

  // Lazy initialize other controllers after splash (faster startup)
  Get.lazyPut(() => UserController(), fenix: true);
  Get.lazyPut(() => UserStatsController(), fenix: true);
  Get.lazyPut(() => CourseController(), fenix: true);
  Get.lazyPut(() => NotificationController(), fenix: true);
  Get.lazyPut(() => NotificationService(), fenix: true);
  Get.lazyPut(() => SessionController(), fenix: true);

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
    
    // Notify NotificationService when first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final notificationService = Get.find<NotificationService>();
        notificationService.onAppReady();
      } catch (e) {
        // ignore if service not available
      }
    });

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeController.lightTheme,
      darkTheme: themeController.darkTheme,
      themeMode: ThemeMode.system,
      home: AuthFlowController(), // Use the new auth flow controller
    );
  }
}

// NEW: Auth Flow Controller Widget
class AuthFlowController extends StatefulWidget {
  @override
  _AuthFlowControllerState createState() => _AuthFlowControllerState();
}

class _AuthFlowControllerState extends State<AuthFlowController> {
  bool _isCheckingAuth = true;
  bool _shouldShowBiometric = false;
  User? _currentUser;
  bool _authInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAuthFlow();
  }

  Future<void> _initializeAuthFlow() async {
    try {
      // Step 1: Wait for Firebase auth to initialize
      await Future.delayed(Duration(seconds: 1));
      
      // Step 2: Get current user
      final authService = Get.find<AuthService>();
      _currentUser = authService.currentUser;
      
      print('🔍 Initial Auth Check:');
      print('  User: ${_currentUser?.email ?? "No user"}');
      print('  UID: ${_currentUser?.uid ?? "No UID"}');
      
      if (_currentUser != null) {
        // Step 3: Check biometric status
        final biometricService = Get.find<BiometricService>();
        final isBiometricEnabled = await biometricService.isBiometricEnabled(_currentUser!.uid);
        
        print('  Biometric Enabled: $isBiometricEnabled');
        
        if (mounted) {
          setState(() {
            _shouldShowBiometric = isBiometricEnabled;
            _isCheckingAuth = false;
            _authInitialized = true;
          });
        }
      } else {
        // No user logged in
        if (mounted) {
          setState(() {
            _isCheckingAuth = false;
            _authInitialized = true;
            _shouldShowBiometric = false;
          });
        }
      }
    } catch (e) {
      print('❌ Error initializing auth flow: $e');
      if (mounted) {
        setState(() {
          _isCheckingAuth = false;
          _authInitialized = true;
          _shouldShowBiometric = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAuth) {
      return SplashScreen();
    }
    
    if (_shouldShowBiometric) {
      // Use the NEW BiometricLockScreen instead of old biometric_login_screen
      return SplashScreen(); // CREATE THIS NEW FILE
    }
    
    // Normal auth flow
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !_authInitialized) {
          return SplashScreen();
        }
        
        if (snapshot.hasData) {
          return HomeScreen();
        } else {
          return UserRegisterationScreen();
        }
      },
    );
  }
}