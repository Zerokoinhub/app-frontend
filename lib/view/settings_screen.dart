import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zero_koin/controllers/theme_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zero_koin/services/auth_service.dart';
import 'package:zero_koin/services/biometric_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationEnabled = true;
  bool _biometricEnabled = false;
  bool _hasBiometricHardware = false;
  bool _isLoadingBiometric = true;
  bool _biometricSupportChecked = false;
  bool _isAuthenticating = false;
  late ThemeController _themeController;
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _disposed = false;
  final BiometricService _biometricService = BiometricService();
  bool _isLoading = false; 
  @override
  void initState() {
    super.initState();
    _themeController = Get.find<ThemeController>();
    _loadPreferences();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
Future<void> _loadPreferences() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final authService = Get.find<AuthService>();
    final currentUser = authService.currentUser;
    
    if (currentUser != null) {
      // Use user-specific key
      _biometricEnabled = prefs.getBool('biometric_enabled_${currentUser.uid}') ?? 
                         prefs.getBool('biometric_enabled') ?? false;
    } else {
      // Fallback to legacy key
      _biometricEnabled = prefs.getBool('biometric_enabled') ?? false;
    }
    
    print('✓ Loaded biometric enabled: $_biometricEnabled');
    
    // Check biometric hardware
    await _checkBiometricHardware();
  } catch (e) {
    print('✗ Error loading preferences: $e');
  } finally {
    if (!_disposed && mounted) {
      setState(() {
        _isLoadingBiometric = false;
      });
    }
  }
}
  Future<void> _checkBiometricHardware() async {
    try {
      print('🔍 Checking biometric hardware...');
      
      // Use isDeviceSupported() for better detection
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      print('✓ Device supported: $isDeviceSupported');
      
      if (isDeviceSupported) {
        // Check available biometrics
        final biometrics = await _localAuth.getAvailableBiometrics();
        print('✓ Available biometrics: $biometrics');
        
        _hasBiometricHardware = biometrics.isNotEmpty;
        print('✓ Has biometric hardware: $_hasBiometricHardware');
      } else {
        _hasBiometricHardware = false;
        print('✗ Device not supported for biometrics');
      }
    } catch (e) {
      print('✗ Error checking biometric hardware: $e');
      _hasBiometricHardware = false;
    } finally {
      if (!_disposed && mounted) {
        setState(() {
          _biometricSupportChecked = true;
        });
      }
    }
  }

// Clear any existing biometric session flags when app starts
Future<void> clearBiometricSessions() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    
    for (final key in keys) {
      if (key.startsWith('biometric_authenticated_') || 
          key.startsWith('biometric_last_auth_')) {
        await prefs.remove(key);
        print('🧹 Cleared biometric session: $key');
      }
    }
  } catch (e) {
    print('Error clearing biometric sessions: $e');
  }
}
Future<void> _toggleBiometric(bool value) async {
  if (_isAuthenticating) return;
  
  setState(() {
    _isAuthenticating = true;
  });

  try {
    final authService = Get.find<AuthService>();
    final currentUser = authService.currentUser;
    
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please login first')),
      );
      return;
    }

    if (value) {
      // Enable biometric
      await _enableBiometric(currentUser.uid, currentUser.email);
    } else {
      // Disable biometric
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('biometric_enabled_${currentUser.uid}');
      await prefs.remove('biometric_enabled');
      
      setState(() {
        _biometricEnabled = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Biometric authentication disabled'),
          backgroundColor: Colors.green,
        ),
      );
      
      print('✓ Biometric disabled for user: ${currentUser.uid}');
    }
  } catch (e) {
    print('✗ Error toggling biometric: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to update biometric setting: ${e.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
    
    // Revert the switch value on error
    setState(() {
      _biometricEnabled = !value;
    });
  } finally {
    if (mounted && !_disposed) {
      setState(() {
        _isAuthenticating = false;
      });
    }
  }
}
Future<void> _enableBiometric(String userId, String? userEmail) async {
  try {
    print('🔐 Starting biometric authentication...');
    
    // Check available biometrics first
    final biometrics = await _localAuth.getAvailableBiometrics();
    print('✅ Available biometrics: $biometrics');
    
    if (biometrics.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No biometric sensors available. Please set up fingerprint/face ID in device settings.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    // FIXED: Use the biometric service properly
    final authenticated = await _biometricService.authenticate(
      localizedReason: 'Scan your fingerprint to enable biometric login',
    );
    
    if (authenticated) {
      // Save biometric preference WITH skipNextTime flag
      await _biometricService.enableBiometricForUser(
        userId, 
        skipNextTime: true  // Skip biometric on next app open
      );
      
      // Save user email for biometric login
      if (userEmail != null) {
        await _biometricService.storeUserForBiometric(userId, userEmail);
      }

      // Update UI state
      setState(() {
        _biometricEnabled = true;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Biometric authentication enabled successfully!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
      
      print('✅ Biometric enabled for user: $userId');
    } else {
      // Authentication failed or cancelled
      await _biometricService.disableBiometricForUser(userId);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Biometric authentication failed or cancelled. Please try again.'),
          backgroundColor: Colors.orange,
        ),
      );
      
      setState(() {
        _biometricEnabled = false;
      });
    }
  } catch (e) {
    print('💥 Error enabling biometric: $e');
    await _biometricService.disableBiometricForUser(userId);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to enable biometric authentication: ${e.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
    
    setState(() {
      _biometricEnabled = false;
    });
  }
}
Future<void> _checkBiometricState() async {
  final authService = Get.find<AuthService>();
  final currentUser = authService.currentUser;
  
  if (currentUser == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No user logged in'))
    );
    return;
  }
  
  final prefs = await SharedPreferences.getInstance(); 
  final biometricService = BiometricService(
    
  );
  
  final userId = currentUser.uid;
  
  print('\n🔍 === BIOMETRIC DEBUG INFO ===');
  print('User ID: $userId');
  print('User Email: ${currentUser.email}');
  
  // Check all possible keys
  final allKeys = prefs.getKeys();
  final biometricKeys = allKeys.where((key) => key.contains('biometric') || key.contains(userId)).toList();
  
  print('\n📋 All biometric-related keys:');
  for (final key in biometricKeys) {
    final value = prefs.get(key);
    print('  $key: $value');
  }
  
  // Specific checks
  final enabledUser = biometricService.isBiometricEnabled(userId);
  final enabledGlobal = prefs.getBool('biometric_enabled') ?? false;
  final justEnabled = prefs.getBool('just_enabled_biometric_$userId') ?? false;
  final authenticated = prefs.getBool('biometric_authenticated_$userId') ?? false;
  
  print('\n🎯 Specific checks:');
  print('  biometric_enabled_$userId: $enabledUser');
  print('  biometric_enabled (global): $enabledGlobal');
  print('  just_enabled_biometric_$userId: $justEnabled');
  print('  biometric_authenticated_$userId: $authenticated');
  
  // Show in dialog
  Get.dialog(
    AlertDialog(
      title: Text('Biometric Debug Info'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('User: ${currentUser.email}'),
            Text('UID: $userId'),
            Divider(),
            Text('Enabled (user): $enabledUser'),
            Text('Enabled (global): $enabledGlobal'),
            Text('Just Enabled: $justEnabled'),
            Text('Authenticated: $authenticated'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Clear all flags to test fresh start
                await prefs.remove('just_enabled_biometric_$userId');
                await prefs.remove('biometric_authenticated_$userId');
                Get.back();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Cleared biometric flags'))
                );
              },
              child: Text('Clear Flags'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: Text('Close'),
        ),
      ],
    ),
  );
}
  Future<bool> _authenticateUser(String reason) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
      
      );
    } catch (e) {
      print('💥 Authentication error: $e');
      
      // If it's the FragmentActivity error, try with a delay
      if (e.toString().contains('FragmentActivity')) {
        await Future.delayed(const Duration(milliseconds: 500));
        try {
          return await _localAuth.authenticate(
            localizedReason: reason,
          
          );
        } catch (retryError) {
          print('💥 Retry authentication error: $retryError');
          return false;
        }
      }
      return false;
    }
  }

  Future<void> _testBiometric() async {
    setState(() {
      _isAuthenticating = true;
    });
    
    try {
      final authenticated = await _authenticateUser(
        'Test your biometric authentication',
      );
      
      if (authenticated) {
        Get.snackbar(
          'Success!',
          'Biometric authentication test passed ✓',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Test Failed',
          'Biometric authentication failed or was cancelled',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Test error: ${e.toString().split(',')[0]}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (!_disposed && mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }

  // Build method remains mostly the same, but with loading indicator
  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.sizeOf(context).height;
    return Scaffold(
      backgroundColor: _themeController.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header - UNCHANGED
            SizedBox(
              height: screenHeight * 0.2,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: [
                      const Color(0xFF08647C),
                      const Color(0xFF08627A),
                      const Color(0xFF8B880D),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Settings",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Settings Content
            Expanded(
              child: Container(
                color: _themeController.contentBackgroundColor,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Notification Toggle
                      _buildSettingItem('Notification', _notificationEnabled, (value) {
                        setState(() {
                          _notificationEnabled = value;
                        });
                      }),
                      
                      const SizedBox(height: 16),
                      
                      // Dark Mode Toggle
                      _buildSettingItem(
                        'Dark Mode',
                        _themeController.isDarkMode,
                        (value) {
                          _themeController.setTheme(value);
                          setState(() {});
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Cache Used
                      _buildInfoItem('Cache Used', '20.8 MB'),
                      
                      const SizedBox(height: 16),
                      
                      // App Version
                      _buildInfoItem('App Version', '1.0.0'),
                      
                      const SizedBox(height: 24),
                
                      // Biometric Section - UPDATED
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: _themeController.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _themeController.borderColor.withOpacity(0.5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header with loading
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    _isAuthenticating
                                        ? SizedBox(
                                            width: 28,
                                            height: 28,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 3,
                                              color: Colors.blue,
                                            ),
                                          )
                                        : Icon(
                                            Icons.fingerprint,
                                            color: _biometricEnabled
                                                ? Colors.green
                                                : Colors.grey,
                                            size: 28,
                                          ),
                                    const SizedBox(width: 16),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Biometric Login',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: _themeController.textColor,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        if (_isLoadingBiometric)
                                          Row(
                                            children: [
                                              SizedBox(
                                                width: 12,
                                                height: 12,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: _themeController.subtitleColor,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'Checking...',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: _themeController.subtitleColor,
                                                ),
                                              ),
                                            ],
                                          )
                                        else if (!_hasBiometricHardware)
                                          Text(
                                            'Not available',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.red,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          )
                                        else
                                          Text(
                                            _biometricEnabled ? 'Enabled ✓' : 'Disabled',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: _biometricEnabled ? Colors.green : Colors.orange,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                                // Switch with loading state
                                if (_isAuthenticating)
                                  SizedBox(
                                    width: 48,
                                    height: 24,
                                    child: Center(
                                      child: SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  Switch(
                                    value: _biometricEnabled,
                                    onChanged: _hasBiometricHardware && !_isAuthenticating
                                        ? _toggleBiometric
                                        : null,
                                    activeColor: Colors.green,
                                    activeTrackColor: Colors.green.withOpacity(0.3),
                                  ),
                              ],
                            ),
                            
                            // Description
                            Padding(
                              padding: const EdgeInsets.only(top: 16, left: 44),
                              child: Text(
                                'Use your fingerprint or face ID to quickly and securely log into the app',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _themeController.subtitleColor,
                                  height: 1.4,
                                ),
                              ),
                            ),
                            
                            // Test Button (shows when enabled AND we have hardware)
                            if (_biometricEnabled && _hasBiometricHardware && !_isAuthenticating)
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: _isAuthenticating ? null : _testBiometric,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _themeController.isDarkMode
                                          ? Colors.blue.shade800
                                          : Colors.blue.shade600,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 2,
                                    ),
                                    icon: const Icon(Icons.fingerprint, size: 22),
                                    label: Text(
                                      _isAuthenticating ? 'Testing...' : 'Test Biometric',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            
                            // Hardware not available message
                            if (!_hasBiometricHardware && !_isLoadingBiometric)
                              Padding(
                                padding: const EdgeInsets.only(top: 16, left: 44),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.red.withOpacity(0.2)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: Colors.red,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'Your device does not support biometric authentication or no biometrics are enrolled',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.red.shade700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      
                      // Debug Button
                      const SizedBox(height: 30),
                      // Rest of your UI remains the same...
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: _themeController.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: _themeController.isDarkMode
                                  ? Colors.black.withOpacity(0.3)
                                  : Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Blockchain',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w500,
                                color: _themeController.subtitleColor,
                              ),
                            ),
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: () => _launchUrl(
                                'https://bscscan.com/token/0x220c0A61747832Bf6F61cB181d4Adf72Daf05014',
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 25,
                                    child: Image.asset(
                                      'assets/image.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'BscScan',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: _themeController.textColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Zerokoin verified Contract',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _themeController.subtitleColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods remain the same
  Widget _buildSettingItem(String title, bool value, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: _themeController.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _themeController.borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: _themeController.textColor,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.green,
            activeTrackColor: Colors.green.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: _themeController.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _themeController.borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: _themeController.textColor,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: _themeController.subtitleColor,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Error',
          'Could not launch $url',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not launch URL: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}