import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/user_controller.dart';
import '../controllers/notification_controller.dart';

class NotificationService extends GetxService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Notification channel for Android
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'zerokoin_notifications',
    'ZeroKoin Notifications',
    description: 'Notifications for ZeroKoin app',
    importance: Importance.high,
    playSound: true,
  );

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    try {
      // Request permissions
      await _requestPermissions();

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Initialize Firebase Messaging
      await _initializeFirebaseMessaging();

      // Set up token refresh handling
      _handleTokenRefresh();

      // Note: FCM token will be sent to backend when user logs in
      // This is handled by UserController after successful authentication

      print('NotificationService initialized successfully');
    } catch (e) {
      print('Error initializing NotificationService: $e');
    }
  }

  Future<void> _requestPermissions() async {
    // Request FCM permissions
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('FCM Permission granted: ${settings.authorizationStatus}');

    // Request local notification permissions for iOS
    if (Platform.isIOS) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }

    // Request notification permission for Android 13+
    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    }
  }

  Future<void> _initializeLocalNotifications() async {
    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/ic_stat_notificationlogo');

    // iOS initialization settings
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(_channel);
    }
  }

  Future<void> _initializeFirebaseMessaging() async {
    // Get FCM token
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification taps when app is in background/terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Handle initial message if app was opened from notification
    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    print('Received foreground message: ${message.messageId}');

    // Check if this is an admin notification
    final notificationType = message.data['type'];

    if (notificationType == 'admin_notification') {
      // Handle admin notification
      _handleAdminNotification(message);
    } else {
      // Handle regular notification (like session unlocked)
      _showLocalNotification(
        title: message.notification?.title ?? 'ZeroKoin',
        body: message.notification?.body ?? 'You have a new notification',
        payload: message.data.toString(),
      );
    }
  }

  void _handleAdminNotification(RemoteMessage message) {
    print('Received admin notification: ${message.messageId}');

    // Show local notification for admin notification
    _showLocalNotification(
      title: message.notification?.title ?? message.data['title'] ?? 'ZeroKoin',
      body:
          message.notification?.body ??
          message.data['description'] ??
          'You have a new notification',
      payload: message.data.toString(),
    );

    // Refresh notifications in the notification controller if available
    try {
      final notificationController = Get.find<NotificationController>();
      notificationController.fetchNotifications();
      // Also refresh unread count for badge
      notificationController.fetchUnreadCount();
    } catch (e) {
      print('NotificationController not found: $e');
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    print('Notification tapped: ${message.messageId}');
    // Handle notification tap - navigate to specific screen if needed
  }

  void _onNotificationTapped(NotificationResponse response) {
    print('Local notification tapped: ${response.payload}');
    // Handle local notification tap
  }

  // Show local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'zerokoin_notifications',
          'ZeroKoin Notifications',
          channelDescription: 'Notifications for ZeroKoin app',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          icon: '@drawable/ic_stat_notificationlogo',
          largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          color: Color(0xFF0682A2), // App's primary color
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  // Public method to show session unlocked notification
  Future<void> showSessionUnlockedNotification() async {
    await _showLocalNotification(
      title: 'ZeroKoin',
      body: 'Session unlocked! Complete the session to claim 30 Zero Koins.',
    );
  }

  // Public method to show admin notification
  Future<void> showAdminNotification({
    required String title,
    required String body,
    String? imageUrl,
    Map<String, String>? data,
  }) async {
    await _showLocalNotification(
      title: title,
      body: body,
      payload: data?.toString(),
    );
  }

  // Get FCM token
  Future<String?> getFCMToken() async {
    return await _firebaseMessaging.getToken();
  }

  // Send FCM token to backend
  Future<void> sendFCMTokenToBackend() async {
    try {
      print('🔄 Starting FCM token send to backend...');

      final token = await getFCMToken();
      if (token == null) {
        print('❌ No FCM token available');
        return;
      }

      print('✅ FCM token obtained: ${token.substring(0, 20)}...');

      // Get device info
      String? platform;
      if (Platform.isAndroid) {
        platform = 'android';
      } else if (Platform.isIOS) {
        platform = 'ios';
      }

      print('📱 Platform detected: $platform');

      // Check if user is logged in
      try {
        final userController = Get.find<UserController>();
        if (!userController.isUserDataLoaded) {
          print('⚠️ User not logged in yet, skipping FCM token send');
          return;
        }

        print('👤 User is logged in, sending token...');

        // Send to backend
        final success = await userController.updateFCMToken(token, platform);

        if (success) {
          print('✅ FCM token sent to backend successfully');
        } else {
          print('❌ Failed to send FCM token to backend');
        }
      } catch (userControllerError) {
        print(
          '⚠️ UserController not found or user not logged in: $userControllerError',
        );
      }
    } catch (e) {
      print('❌ Error sending FCM token to backend: $e');
    }
  }

  // Handle token refresh
  void _handleTokenRefresh() {
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      print('FCM token refreshed: $newToken');
      // Send new token to backend
      sendFCMTokenToBackend();
    });
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
}
