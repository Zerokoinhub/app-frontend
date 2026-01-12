import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:zero_koin/services/auth_service.dart';
import 'package:zero_koin/view/bottom_bar.dart';
import 'package:zero_koin/view/user_registeration_screen.dart';
import 'package:zero_koin/controllers/admob_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _zoomController;
  late Animation<double> _glowAnimation;
  late Animation<double> _zoomAnimation;
  late Animation<double> _glowIntensityAnimation;
  late AdMobController _adMobController;
  final LocalAuthentication _localAuth = LocalAuthentication();
  Timer? _fingerprintTimer;
  bool _fingerprintDialogOpen = false;
  bool _fingerprintCompleted = false;
  int _attemptCount = 0;
  final int _maxAttempts = 5;

  @override
  void initState() {
    super.initState();

    // Get the existing AdMobController instance
    _adMobController = Get.find<AdMobController>();

    // Keep your original animations
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 5.0, end: 20.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _glowIntensityAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _zoomController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _zoomAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _zoomController, curve: Curves.easeInOut),
    );

    // Start fingerprint after 2 seconds
    _startFingerprintAfterDelay();
  }

  void _startFingerprintAfterDelay() {
    _fingerprintTimer = Timer(const Duration(seconds: 2), () {
      _triggerPhoneFingerprintSensor();
    });
  }

  Future<void> _triggerPhoneFingerprintSensor() async {
    if (_fingerprintCompleted || _attemptCount >= _maxAttempts) return;
    
    print('🔐 Opening phone fingerprint sensor...');
    
    try {
      // Check if user is logged in
      final authService = AuthService.instance;
      if (!authService.isSignedIn) {
        Get.offAll(() => const UserRegisterationScreen());
        return;
      }

      // Check biometric support
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (!canCheckBiometrics) {
        print('❌ No biometric hardware');
        _goToPasswordLogin();
        return;
      }

      final biometrics = await _localAuth.getAvailableBiometrics();
      if (biometrics.isEmpty) {
        print('❌ No biometrics enrolled');
        _goToPasswordLogin();
        return;
      }

      // Mark fingerprint dialog as open
      _fingerprintDialogOpen = true;
      _attemptCount++;

      print('👆 Attempt $_attemptCount/$_maxAttempts - Opening fingerprint sensor...');
      
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Scan your fingerprint to unlock Zero Koin',
      );

      // Mark dialog as closed
      _fingerprintDialogOpen = false;

      if (authenticated) {
        print('✅ Fingerprint authenticated successfully!');
        _fingerprintCompleted = true;
        _navigateToHome();
      } else {
        print('❌ Fingerprint failed or canceled - Attempt $_attemptCount');
        
        if (_attemptCount >= _maxAttempts) {
          print('🛑 Max attempts ($_maxAttempts) reached');
          _showMaxAttemptsMessage();
        } else {
          // Show message and retry after 2 seconds
          _showRetryMessage();
          Timer(const Duration(seconds: 2), _triggerPhoneFingerprintSensor);
        }
      }
    } catch (e) {
      print('❌ Error: $e');
      _fingerprintDialogOpen = false;
      _goToPasswordLogin();
    }
  }

  void _showRetryMessage() {
    if (!mounted) return;
    
    // You could show a snackbar or update UI here
    print('⚠️ Please try again. Attempt $_attemptCount/$_maxAttempts');
  }

  void _showMaxAttemptsMessage() {
    print('🛑 Maximum fingerprint attempts reached. Going to password login.');
    
    // Wait 2 seconds then go to password
    Timer(const Duration(seconds: 2), () {
      _goToPasswordLogin();
    });
  }

  void _goToPasswordLogin() {
    print('🔑 Going to password login');
    
    // Disable biometric for current user so they can login with password
    final currentUser = AuthService.instance.currentUser;
    if (currentUser != null) {
      // You might want to clear biometric settings here
      print('🔄 Biometric disabled for user: ${currentUser.uid}');
    }
    
    Get.offAll(() => const UserRegisterationScreen());
  }

  void _navigateToHome() {
    _fingerprintTimer?.cancel();
    Get.offAll(() => const BottomBar());
  }

  // Prevent back button when fingerprint dialog is open
  Future<bool> _onWillPop() async {
    if (_fingerprintDialogOpen) {
      print('⚠️ Back button blocked - fingerprint dialog is open');
      
      // Increment attempt when user tries to go back
      _attemptCount++;
      if (_attemptCount >= _maxAttempts) {
        _showMaxAttemptsMessage();
      }
      
      return false; // Block back button
    }
    return true;
  }

  @override
  void dispose() {
    _fingerprintTimer?.cancel();
    _glowController.dispose();
    _zoomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/Background.jpg', fit: BoxFit.cover),
            
            Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _glowAnimation,
                  _zoomAnimation,
                  _glowIntensityAnimation,
                ]),
                builder: (context, child) {
                  return Transform.scale(
                    scale: _zoomAnimation.value,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Glowing background circle
                        Container(
                          width: 200 + _glowAnimation.value * 4,
                          height: 200 + _glowAnimation.value * 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.white.withOpacity(
                                  _glowIntensityAnimation.value * 0.3,
                                ),
                                Colors.white.withOpacity(
                                  _glowIntensityAnimation.value * 0.15,
                                ),
                                Colors.white.withOpacity(
                                  _glowIntensityAnimation.value * 0.05,
                                ),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.4, 0.7, 1.0],
                            ),
                          ),
                        ),
                        Container(
                          width: 300 + _glowAnimation.value * 6,
                          height: 300 + _glowAnimation.value * 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.white.withOpacity(
                                  _glowIntensityAnimation.value * 0.1,
                                ),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 1.0],
                            ),
                          ),
                        ),
                        Image.asset(
                          'assets/bluelogo.png',
                          width: 150,
                          height: 150,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '© 2025 - 2026 Zero Koin',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap Learn & Earn',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            // Show attempt counter
            if (_attemptCount > 0 && !_fingerprintCompleted)
              Positioned(
                top: 100,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  color: Colors.black.withOpacity(0.5),
                  child: Text(
                    'Attempt $_attemptCount/$_maxAttempts',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}