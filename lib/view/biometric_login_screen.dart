// import 'package:flutter/material.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:get/get_instance/src/extension_instance.dart';
// import 'package:get/get_navigation/src/extension_navigation.dart';
// import 'package:local_auth/local_auth.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:zero_koin/services/auth_service.dart';
// import 'package:zero_koin/services/biometric_service.dart';
// import 'package:zero_koin/view/home_screen.dart';
// import 'package:zero_koin/view/user_registeration_screen.dart';

// class BiometricLockScreen extends StatefulWidget {
//   const BiometricLockScreen({Key? key}) : super(key: key);

//   @override
//   _BiometricLockScreenState createState() => _BiometricLockScreenState();
// }

// class _BiometricLockScreenState extends State<BiometricLockScreen> {
//   final LocalAuthentication _localAuth = LocalAuthentication();
//   final AuthService _authService = Get.find<AuthService>();
//   final BiometricService _biometricService = Get.find<BiometricService>();
  
//   bool _isReady = false;
//   bool _isScanning = false;
//   bool _hasError = false;
//   String _status = 'Tap to unlock';
  
//   @override
//   void initState() {
//     super.initState();
//     _initializeScreen();
//   }
  
//   Future<void> _initializeScreen() async {
//     // Wait a bit for UI to build
//     await Future.delayed(Duration(milliseconds: 300));
    
//     if (mounted) {
//       setState(() {
//         _isReady = true;
//       });
//     }
    
//     print('🔒 LOCK SCREEN: Ready - Waiting for user to tap fingerprint');
//   }
  
//   Future<void> _scanFingerprint() async {
//     if (_isScanning || !_isReady) return;
    
//     print('👆 USER TAPPED: Starting fingerprint scan');
    
//     setState(() {
//       _isScanning = true;
//       _hasError = false;
//       _status = 'Scanning...';
//     });
    
//     try {
//       final currentUser = _authService.currentUser;
//       if (currentUser == null) {
//         _showError('No user found');
//         return;
//       }
      
//       // Check hardware
//       final canCheckBiometrics = await _localAuth.canCheckBiometrics;
//       if (!canCheckBiometrics) {
//         _showError('Biometric not available');
//         return;
//       }
      
//       final biometrics = await _localAuth.getAvailableBiometrics();
//       if (biometrics.isEmpty) {
//         _showError('No fingerprint enrolled');
//         return;
//       }
      
//       // IMPORTANT: Clear any "skip next biometric" flags
//       await _clearSkipFlags(currentUser.uid);
      
//       // Now trigger the fingerprint sensor
//       print('🔐 Triggering fingerprint sensor...');
      
//       final authenticated = await _localAuth.authenticate(
//         localizedReason: 'Scan your fingerprint to unlock',
//       );
      
//       if (authenticated) {
//         print('✅ Fingerprint authenticated!');
//         // Record successful authentication
//         await _recordSuccessfulAuth(currentUser.uid);
        
//         // Navigate to home
//         Get.offAll(() => HomeScreen());
//       } else {
//         print('❌ Fingerprint authentication failed');
//         _showError('Authentication failed. Try again.');
//       }
//     } catch (e) {
//       print('❌ Error: $e');
//       _showError('Error: ${e.toString().split(',')[0]}');
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isScanning = false;
//         });
//       }
//     }
//   }
  
//   Future<void> _clearSkipFlags(String userId) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove('biometric_just_enabled_$userId');
//       print('🧹 Cleared skip flags for user: $userId');
//     } catch (e) {
//       print('Error clearing skip flags: $e');
//     }
//   }
  
//   Future<void> _recordSuccessfulAuth(String userId) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final now = DateTime.now().millisecondsSinceEpoch;
//       await prefs.setInt('biometric_last_success_$userId', now);
//       print('✅ Recorded successful auth for user: $userId');
//     } catch (e) {
//       print('Error recording auth: $e');
//     }
//   }
  
//   void _showError(String message) {
//     setState(() {
//       _hasError = true;
//       _status = message;
//       _isScanning = false;
//     });
    
//     Future.delayed(Duration(seconds: 2), () {
//       if (mounted) {
//         setState(() {
//           _hasError = false;
//           _status = 'Tap to unlock';
//         });
//       }
//     });
//   }
  
//   void _usePasswordLogin() {
//     print('🔑 User chose password login');
    
//     // Disable biometric
//     final currentUser = _authService.currentUser;
//     if (currentUser != null) {
//       _biometricService.disableBiometricForUser(currentUser.uid);
//     }
    
//     Get.offAll(() => UserRegisterationScreen());
//   }
  
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         // Prevent back button
//         return false;
//       },
//       child: Scaffold(
//         backgroundColor: Colors.black,
//         body: SafeArea(
//           child: Center(
//             child: Padding(
//               padding: const EdgeInsets.all(24.0),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   // App Logo/Title
//                   Column(
//                     children: [
//                       Icon(
//                         Icons.security,
//                         size: 60,
//                         color: Colors.white,
//                       ),
//                       SizedBox(height: 16),
//                       Text(
//                         'SECURE LOGIN',
//                         style: TextStyle(
//                           fontSize: 32,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                           letterSpacing: 2,
//                         ),
//                       ),
//                       SizedBox(height: 8),
//                       Text(
//                         'Zero Koin Wallet',
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.grey.shade400,
//                         ),
//                       ),
//                     ],
//                   ),
                  
//                   SizedBox(height: 60),
                  
//                   // Fingerprint Button (ONLY way to trigger biometric)
//                   GestureDetector(
//                     onTap: _scanFingerprint,
//                     child: AnimatedContainer(
//                       duration: Duration(milliseconds: 300),
//                       width: 180,
//                       height: 180,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: _isScanning ? Colors.blue.shade900 : Colors.grey.shade900,
//                         border: Border.all(
//                           color: _isScanning ? Colors.blue : Colors.grey.shade700,
//                           width: 3,
//                         ),
//                         boxShadow: [
//                           BoxShadow(
//                             color: _isScanning 
//                                 ? Colors.blue.withOpacity(0.5) 
//                                 : Colors.black.withOpacity(0.5),
//                             blurRadius: 20,
//                             spreadRadius: 5,
//                           ),
//                         ],
//                       ),
//                       child: Stack(
//                         alignment: Alignment.center,
//                         children: [
//                           Icon(
//                             Icons.fingerprint,
//                             size: 100,
//                             color: _isScanning ? Colors.blue : Colors.white,
//                           ),
                          
//                           if (_isScanning)
//                             CircularProgressIndicator(
//                               strokeWidth: 4,
//                               valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
//                               backgroundColor: Colors.transparent,
//                             ),
//                         ],
//                       ),
//                     ),
//                   ),
                  
//                   SizedBox(height: 40),
                  
//                   // Status
//                   Container(
//                     width: double.infinity,
//                     padding: EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade900,
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(
//                         color: _hasError ? Colors.red : Colors.grey.shade700,
//                       ),
//                     ),
//                     child: Column(
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             if (_isScanning)
//                               SizedBox(
//                                 width: 20,
//                                 height: 20,
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 2,
//                                   color: Colors.blue,
//                                 ),
//                               ),
//                             SizedBox(width: 10),
//                             Text(
//                               _status,
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 color: _hasError ? Colors.red : Colors.white,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ],
//                         ),
                        
//                         SizedBox(height: 8),
                        
//                         Text(
//                           'This screen will NOT auto-close',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey.shade500,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
                  
//                   SizedBox(height: 20),
                  
//                   // Instructions
//                   Text(
//                     'Tap the fingerprint icon to scan\nDo not press cancel on system dialog',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey.shade500,
//                       height: 1.5,
//                     ),
//                   ),
                  
//                   SizedBox(height: 50),
                  
//                   // Alternative login button
//                   OutlinedButton(
//                     onPressed: _usePasswordLogin,
//                     style: OutlinedButton.styleFrom(
//                       side: BorderSide(color: Colors.grey.shade700),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//                     ),
//                     child: Text(
//                       'USE PASSWORD INSTEAD',
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.grey.shade400,
//                       ),
//                     ),
//                   ),
                  
//                   SizedBox(height: 20),
                  
//                   // Note
//                   Text(
//                     'Screen stays until fingerprint is scanned',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey.shade600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }