import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:zero_koin/services/auth_service.dart';

class BiometricService extends GetxService {
  static const String _biometricEnabledKey = 'biometric_enabled_';
  static const String _biometricUserKey = 'biometric_user_';
  static const String _biometricJustEnabledKey = 'biometric_just_enabled_';
  static const String _biometricLastAuthKey = 'biometric_last_auth_';
  
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  // =========== AUTHENTICATION METHODS ===========
    Future<void> updateLastAuthTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUser = Get.find<AuthService>().currentUser;
      
      if (currentUser != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        await prefs.setInt('${_biometricLastAuthKey}${currentUser.uid}', now);
        print('✅ Updated last auth time for user: ${currentUser.uid}');
      }
    } catch (e) {
      print('❌ Error updating last auth time: $e');
    }
  }
   Future<DateTime?> getLastAuthTime(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastAuthMillis = prefs.getInt('${_biometricLastAuthKey}$userId');
      
      if (lastAuthMillis != null) {
        return DateTime.fromMillisecondsSinceEpoch(lastAuthMillis);
      }
      return null;
    } catch (e) {
      print('❌ Error getting last auth time: $e');
      return null;
    }
  }
   Future<bool> isAuthStillValid(String userId, {Duration validDuration = const Duration(minutes: 5)}) async {
    try {
      final lastAuth = await getLastAuthTime(userId);
      if (lastAuth == null) return false;
      
      final now = DateTime.now();
      final difference = now.difference(lastAuth);
      
      return difference < validDuration;
    } catch (e) {
      print('❌ Error checking auth validity: $e');
      return false;
    }
  }
  // Authenticate user with biometric
  Future<bool> authenticate({String? localizedReason}) async {
    try {
      print('🔐 Starting REAL biometric authentication...');
      
      // Check if biometrics are available
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (!canCheckBiometrics) {
        print('❌ Cannot check biometrics');
        return false;
      }
      
      // Get available biometrics
      final biometrics = await _localAuth.getAvailableBiometrics();
      if (biometrics.isEmpty) {
        print('❌ No biometrics available');
        return false;
      }
      
      print('✅ Available biometrics: $biometrics');
      
      // Authenticate with proper configuration
      var authenticated = await _localAuth.authenticate(
  localizedReason: localizedReason ?? 'Authenticate to access your account',

  biometricOnly: true, // IMPORTANT: Only biometric, not device credentials
);
      
      print('✅ Authentication result: $authenticated');
      return authenticated;
    } catch (e) {
      print('❌ Authentication error: $e');
      return false;
    }
  }
  
  // Check if device supports biometric
  Future<bool> checkBiometricSupport() async {
    try {
      final isSupported = await _localAuth.isDeviceSupported();
      final biometrics = await _localAuth.getAvailableBiometrics();
      return isSupported && biometrics.isNotEmpty;
    } catch (e) {
      print('❌ Error checking biometric support: $e');
      return false;
    }
  }
  
  // =========== STORAGE METHODS ===========
  
  // Check if biometric is enabled for a user
  Future<bool> isBiometricEnabled(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bool isEnabled = prefs.getBool('$_biometricEnabledKey$userId') ?? false;
      
      // Check if we just enabled biometric (should skip on next open)
      final bool justEnabled = prefs.getBool('$_biometricJustEnabledKey$userId') ?? false;
      
      if (justEnabled) {
        // Clear the "just enabled" flag so next time it will show biometric
        await prefs.setBool('$_biometricJustEnabledKey$userId', false);
        print('🔄 Just enabled flag cleared for user: $userId');
        return true; // Still return true, biometric is enabled
      }
      
      return isEnabled;
    } catch (e) {
      print('❌ Error checking biometric status: $e');
      return false;
    }
  }
  
  // Enable biometric for a user
  Future<void> enableBiometricForUser(String userId, {bool skipNextTime = true}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Enable biometric
      await prefs.setBool('$_biometricEnabledKey$userId', true);
      
      // Set flag to skip biometric on next app open (optional)
      if (skipNextTime) {
        await prefs.setBool('$_biometricJustEnabledKey$userId', true);
        print('✅ Skip next biometric enabled for user: $userId');
      }
      
      print('✅ Biometric enabled for user: $userId');
    } catch (e) {
      print('❌ Error enabling biometric: $e');
      rethrow;
    }
  }
  
  // Disable biometric for a user
  Future<void> disableBiometricForUser(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Remove all biometric flags for this user
      await prefs.remove('$_biometricEnabledKey$userId');
      await prefs.remove('$_biometricJustEnabledKey$userId');
      await _secureStorage.delete(key: '$_biometricUserKey$userId');
      
      print('✅ Biometric disabled for user: $userId');
    } catch (e) {
      print('❌ Error disabling biometric: $e');
      rethrow;
    }
  }
  
  // ALIAS METHODS (for compatibility with your existing code)
  Future<void> setBiometricEnabled(bool value, String userId) async {
    if (value) {
      await enableBiometricForUser(userId);
    } else {
      await disableBiometricForUser(userId);
    }
  }
  
  // Store user data securely for biometric login
  Future<void> storeUserForBiometric(String userId, String email) async {
    try {
      await _secureStorage.write(
        key: '$_biometricUserKey$userId',
        value: email,
      );
      print('✅ User stored for biometric: $userId');
    } catch (e) {
      print('❌ Error storing user for biometric: $e');
      rethrow;
    }
  }
  
  // ALIAS METHOD (for compatibility)
  Future<void> saveUserForBiometric(String userId, String email) async {
    await storeUserForBiometric(userId, email);
  }
  
  // Get stored user data for biometric login
  Future<String?> getStoredUserForBiometric(String userId) async {
    try {
      return await _secureStorage.read(key: '$_biometricUserKey$userId');
    } catch (e) {
      print('❌ Error getting stored user: $e');
      return null;
    }
  }
  
  // Clear ALL biometric flags (use carefully)
  Future<void> clearAllBiometricData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => 
          key.startsWith(_biometricEnabledKey) || 
          key.startsWith(_biometricJustEnabledKey)).toList();
      
      for (final key in keys) {
        await prefs.remove(key);
      }
      
      // Clear secure storage
      await _secureStorage.deleteAll();
      print('✅ All biometric data cleared');
    } catch (e) {
      print('❌ Error clearing biometric data: $e');
    }
  }
}