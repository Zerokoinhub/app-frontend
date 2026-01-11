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
    print('🔐 Opening phone fingerprint sensor after 2 seconds...');
    
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
        _navigateToHome();
        return;
      }

      final biometrics = await _localAuth.getAvailableBiometrics();
      if (biometrics.isEmpty) {
        print('❌ No biometrics enrolled');
        _navigateToHome();
        return;
      }

      // SIMPLEST VERSION - This should work
      print('👆 Opening phone fingerprint sensor NOW...');
      
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Unlock Zero Koin Wallet',
      );

      if (authenticated) {
        print('✅ Fingerprint authenticated successfully!');
        _navigateToHome();
      } else {
        print('❌ Fingerprint failed or canceled');
        // Retry after 2 seconds
        Timer(const Duration(seconds: 2), _triggerPhoneFingerprintSensor);
      }
    } catch (e) {
      print('❌ Error: $e');
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    _fingerprintTimer?.cancel();
    Get.offAll(() => const BottomBar());
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

    return Scaffold(
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
        ],
      ),
    );
  }
}