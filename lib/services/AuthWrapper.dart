// simple_auth_flow.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zero_koin/services/auth_service.dart';
import 'package:zero_koin/services/biometric_service.dart';
import 'package:zero_koin/view/biometric_login_screen.dart';
import 'package:zero_koin/view/home_screen.dart';
import 'package:zero_koin/view/splash_screen.dart';
import 'package:zero_koin/view/user_registeration_screen.dart';


class SimpleAuthFlow extends StatefulWidget {
  const SimpleAuthFlow({super.key});

  @override
  State<SimpleAuthFlow> createState() => _SimpleAuthFlowState();
}

class _SimpleAuthFlowState extends State<SimpleAuthFlow> {
  bool _checkingBiometric = true;
  bool _showBiometric = false;
  String? _userId;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    print('🔍 SIMPLE AUTH FLOW STARTED');
    
    // Listen to auth changes
    final authService = Provider.of<AuthService>(context, listen: false);
    
    authService.userStream.listen((user) async {
      print('👤 Auth state changed: ${user?.email}');
      
      if (user != null) {
        _userId = user.uid;
        _userEmail = user.email;
        
        // Check biometric
        final shouldShow = await BiometricService().isBiometricEnabled(user.uid);
        
        setState(() {
          _checkingBiometric = false;
          _showBiometric = shouldShow;
        });
        
        print('🎯 Biometric decision: $shouldShow');
      } else {
        setState(() {
          _checkingBiometric = false;
          _showBiometric = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print('🏗️ Building SimpleAuthFlow');
    print('  - Checking biometric: $_checkingBiometric');
    print('  - Show biometric: $_showBiometric');
    print('  - User ID: $_userId');
    
    if (_checkingBiometric) {
      print('⏳ Showing splash while checking...');
      return const SplashScreen();
    }
    
    if (_showBiometric && _userId != null) {
      print('🚀 Navigating to biometric screen!');
      return SplashScreen(
      
      );
    }
    
    // Check if user is logged in
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;
    
    if (user != null) {
      print('🏠 Going to home screen');
      return const HomeScreen();
    }
    
    print('👤 Going to registration screen');
    return const UserRegisterationScreen();
  }
}