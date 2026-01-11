// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:zero_koin/services/biometric_service.dart';
// import 'package:zero_koin/view/home_screen.dart';
// import 'package:zero_koin/view/user_registeration_screen.dart';

// class BiometricPromptScreen extends StatefulWidget {
//   final User user;
  
//   const BiometricPromptScreen({super.key, required this.user});

//   @override
//   State<BiometricPromptScreen> createState() => _BiometricPromptScreenState();
// }

// class _BiometricPromptScreenState extends State<BiometricPromptScreen> {
//   bool _isAuthenticating = false;
//   bool _showManualLogin = false;
//   bool _authenticationFailed = false;
//   late BiometricManager _biometricService;
  
//   @override
//   void initState() {
//     super.initState();
//     _initBiometricService();
//     // Start biometric authentication automatically
//     Future.delayed(const Duration(milliseconds: 500), () {
//       _authenticateWithBiometric();
//     });
//   }

//   Future<void> _initBiometricService() async {
//     final prefs = await SharedPreferences.getInstance();
//     _biometricService = BiometricManager();
//   }

//   Future<void> _authenticateWithBiometric() async {
//     if (_isAuthenticating) return;
    
//     setState(() {
//       _isAuthenticating = true;
//       _authenticationFailed = false;
//     });
    
//     try {
     
      
//       if  {
//         // Success - navigate to home
//         Get.offAll(() => const HomeScreen());
//       } else {
//         // Failed or cancelled
//         setState(() {
//           _authenticationFailed = true;
//           _isAuthenticating = false;
//           _showManualLogin = true;
//         });
//       }
//     } catch (e) {
//       print('Biometric authentication error: $e');
//       setState(() {
//         _authenticationFailed = true;
//         _isAuthenticating = false;
//         _showManualLogin = true;
//       });
//     }
//   }

//   Future<void> _signOutAndGoToLogin() async {
//     try {
//       // Sign out from Firebase
//       await FirebaseAuth.instance.signOut();
      
//       // Disable biometric for this user
//       await _biometricService.disableBiometric(widget.user.uid);
      
//       // Navigate to login
//       Get.offAll(() => const UserRegisterationScreen());
//     } catch (e) {
//       print('Error signing out: $e');
//     }
//   }

//   Future<void> _disableBiometricAndContinue() async {
//     await _biometricService.disableBiometric(widget.user.uid);
//     Get.offAll(() => const HomeScreen());
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // App Logo or Icon
//               Icon(
//                 Icons.fingerprint,
//                 size: 100,
//                 color: _isAuthenticating ? Colors.blue : Colors.grey[600],
//               ),
              
//               const SizedBox(height: 40),
              
//               // Title
//               Text(
//                 'Secure Login',
//                 style: TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.grey[800],
//                 ),
//               ),
              
//               const SizedBox(height: 16),
              
//               // Welcome message
//               Text(
//                 'Welcome back, ${widget.user.displayName ?? widget.user.email?.split('@').first ?? 'User'}!',
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.grey[600],
//                 ),
//                 textAlign: TextAlign.center,
//               ),
              
//               const SizedBox(height: 8),
              
//               Text(
//                 'Please authenticate to continue',
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.grey[500],
//                 ),
//               ),
              
//               const SizedBox(height: 40),
              
//               // Status indicators
//               if (_isAuthenticating) ...[
//                 Column(
//                   children: [
//                     const CircularProgressIndicator(),
//                     const SizedBox(height: 20),
//                     Text(
//                       'Waiting for your fingerprint or face...',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey[600],
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
              
//               if (_authenticationFailed) ...[
//                 Column(
//                   children: [
//                     Icon(
//                       Icons.error_outline,
//                       color: Colors.red,
//                       size: 40,
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       'Authentication failed',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.red,
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     Text(
//                       'Please try again or use manual login',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey[500],
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ),
//               ],
              
//               const Spacer(),
              
//               // Action buttons
//               Column(
//                 children: [
//                   // Retry button
//                   if (_authenticationFailed && !_isAuthenticating)
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: _authenticateWithBiometric,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.blue,
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         child: const Text(
//                           'Try Again',
//                           style: TextStyle(fontSize: 16),
//                         ),
//                       ),
//                     ),
                  
//                   const SizedBox(height: 16),
                  
//                   // Manual login option
//                   if (_showManualLogin)
//                     SizedBox(
//                       width: double.infinity,
//                       child: OutlinedButton(
//                         onPressed: _signOutAndGoToLogin,
//                         style: OutlinedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           side: BorderSide(color: Colors.grey[300]!),
//                         ),
//                         child: Text(
//                           'Use Different Account',
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.grey[700],
//                           ),
//                         ),
//                       ),
//                     ),
                  
//                   const SizedBox(height: 12),
                  
//                   // Disable biometric option
//                   TextButton(
//                     onPressed: _disableBiometricAndContinue,
//                     child: Text(
//                       'Disable Biometric Login',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey[600],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }