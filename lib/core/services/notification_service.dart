// =================================================================
// ملاحظات هامة:
// 1. تم تعطيل المنطق داخل دالتي `login` و `logout` مؤقتاً لتجنب الأخطاء.
// 2. يمكنك الآن إكمال عملك، وسنعود لهذه الدوال لاحقاً.
// =================================================================

import 'package:pusher_beams/pusher_beams.dart';

class NotificationService {
  /// Helper to get userId from your app's auth system
  static Future<String?> _getUserId() async {
    try {
      // TODO: Replace this with your actual user ID fetch logic from your auth system
      // For example, from shared preferences, secure storage, or a user provider
      // For now, returning a test user ID
      return 'patient-2';
    } catch (e) {
      print('❌ Error getting user ID: $e');
      return null;
    }
  }

  /// Helper to get the auth token for the user
  static String? _getAuthToken() {
    // TODO: Replace this with your actual auth token fetch logic
    // This should be the token you use to authenticate with your backend
    return '1|4sYXAgddePgPPUHOUFZVyBqETh39RKWqdWpzYAgTf2998f82';
  }

  // ================== تم وضع الـ Instance ID الخاص بك ==================
  static const _instanceId = '779f8602-f480-4c8a-a429-29f3bd06b930';
  // =======================================================================

  /// تهيئة خدمة الإشعارات عند بدء تشغيل التطبيق
  static Future<void> init() async {
    try {
      print('🔄 Initializing Pusher Beams...');
      
      // Start Pusher Beams and request notification permissions
      await PusherBeams.instance.start(_instanceId);
      print('✅ Pusher Beams instance started successfully');

      // Subscribe to debug channel for testing
      await PusherBeams.instance.addDeviceInterest('debug-hello');
      print('✅ Subscribed to debug channel');

      // Set up notification listeners
      _listenForNotifications();
      print('✅ Notification listeners configured');

      // If we have a user ID already, try to authenticate
      final userId = await _getUserId();
      if (userId != null && userId.isNotEmpty) {
        print('🔄 Found existing user, attempting to authenticate...');
        await login();
      }

    } catch (e, stackTrace) {
      print('❌ Error initializing Pusher Beams: $e');
      print('Stack trace: $stackTrace');
      // You might want to handle this error in your app's UI
    }
  }

  /// الاستماع للإشعارات التي تصل والتطبيق في الواجهة
  static void _listenForNotifications() {
    PusherBeams.instance.onMessageReceivedInTheForeground(
      (notification) {
        print('📬 New notification received:');
        
        // The notification is a Map<Object?, Object?>, so we need to cast it properly
        final Map<String, dynamic> notificationData = Map<String, dynamic>.from(notification);
        
        // Extract notification details
        final title = notificationData['title'] as String?;
        final body = notificationData['body'] as String?;
        final data = notificationData['data'] as Map<String, dynamic>?;
        
        print('Title: $title');
        print('Body: $body');
        print('Additional Data: $data');
        
        // TODO: Implement your notification handling logic here
        // For example:
        // - Show a custom dialog
        // - Update app state
        // - Navigate to a specific screen
        // - Update UI elements
      },
    );
  
  }

  /// تسجيل دخول المستخدم في Beams لإرسال إشعارات خاصة له
  static Future<void> login() async {
    try {
      print('🔄 Starting user authentication for notifications...');
      
      // Get the user ID from auth system
      final userId = await _getUserId();
      if (userId == null || userId.isEmpty) {
        print('❌ Authentication failed: No user ID available');
        return;
      }

      // Get the auth token
      final authToken = _getAuthToken();
      if (authToken == null || authToken.isEmpty) {
        print('❌ Authentication failed: No auth token available');
        return;
      }

      // Configure the BeamsAuthProvider
      final beamsAuthProvider = BeamsAuthProvider()
        ..authUrl = 'https://shifaa-backend.onrender.com/api/beams-token'
        ..headers = {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
          'Accept': 'application/json',
        }
        ..queryParams = {}
        ..credentials = 'omit';

      // Set the user ID with the configured auth provider
      print('🔄 Associating device with user ID: $userId');
      await PusherBeams.instance.setUserId(
        userId,
        beamsAuthProvider,
        (error) {
          if (error != null) {
            print('❌ Failed to associate device with user: $error');
            // You might want to handle this error in your app's UI
          } else {
            print('✅ Successfully authenticated user with Pusher Beams');
            // You might want to notify your app's UI of successful authentication
          }
        },
      );
    } catch (e, stackTrace) {
      print('❌ Error during notification login: $e');
      print('Stack trace: $stackTrace');
      // You might want to handle this error in your app's UI
    }
  }

  /// تسجيل خروج المستخدم من Beams
  static Future<void> logout() async {
    try {
      print('🔄 Logging out user from notification service...');
      
      // Clear the user authentication
      await PusherBeams.instance.clearDeviceInterests();
      print('✅ Cleared device interests');
      
      // Clear all state including the Device ID
      await PusherBeams.instance.clearAllState();
      print('✅ Cleared all Pusher Beams state');
      
      // Optionally reinitialize Pusher Beams if you want to continue receiving
      // notifications to public channels
      await PusherBeams.instance.start(_instanceId);
      print('✅ Reinitialized Pusher Beams for public notifications');
      
      // Subscribe to debug channel for testing
      await PusherBeams.instance.addDeviceInterest('debug-hello');
      print('✅ Resubscribed to debug channel');
      
    } catch (e, stackTrace) {
      print('❌ Error during notification logout: $e');
      print('Stack trace: $stackTrace');
      // You might want to handle this error in your app's UI
    }
  }
}
