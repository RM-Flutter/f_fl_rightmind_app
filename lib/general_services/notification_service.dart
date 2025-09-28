import 'package:cpanal/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:cpanal/general_services/general_listener.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:universal_html/html.dart' as html;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  Future<void> init(BuildContext? context) async {
    await _requestPermissions(context);
    _initializeLocalNotifications(context);
    _setupForegroundMessages();
    _setupBackgroundMessages(context);
    await _checkInitialMessage();
    await _safeRetrieveFcmToken();
  }

  Future<void> _requestPermissions(BuildContext? context) async {
    if (kIsWeb) {
      final permission = html.Notification.permission; // "granted", "denied", "default"
      if (permission == "denied") {
        _showWebToast("تم رفض الإشعارات من المتصفح. لتفعيلها افتح Site Settings واختر Allow.");
      }
      return; // لا تنادي أي دوال Firebase لو محجوبة
    }

    // Native
    try {
      final settings = await _messaging.requestPermission(alert: true, badge: true, sound: true);
      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        debugPrint("❌ Notifications not granted");
      }
    } catch (e) {
      debugPrint("⚠️ Failed to request native permissions: $e");
    }
  }

  void _showWebToast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 5,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  Future<void> _safeRetrieveFcmToken() async {
    if (kIsWeb) {
      final permission = html.Notification.permission;
      if (permission != "granted") {
        debugPrint("⚠️ Cannot get FCM token: permission blocked on web");
        return;
      }
    }

    try {
      String? token = await _messaging.getToken();
      debugPrint("🔑 FCM Token: $token");
    } catch (e) {
      debugPrint("⚠️ Failed to get FCM token: $e");
    }
  }

  void _initializeLocalNotifications(BuildContext? context) {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOSSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(android: androidSettings, iOS: iOSSettings);

    flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          _handleMessage(response.payload!, context);
        }
      },
    );
  }

  void _handleMessage(String popup, BuildContext? context) {
    // Safe call
    try {
      GeneralListener.linksAction(popup: popup);
    } catch (e) {
      debugPrint("⚠️ Failed to handle message: $e");
    }
  }

  void _setupForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("🔔 Foreground Notification: ${message.notification?.title}");
      _showNotification(message);
    });
  }

  void _setupBackgroundMessages(BuildContext? context) {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessage(message.data['endpoint'], context);
    });

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _handleMessage(message.data['endpoint'], context);
      }
    });
  }

  void _showNotification(RemoteMessage message) async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const androidDetails = AndroidNotificationDetails(
      'channel_id',
      'High Importance Notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      icon: '@drawable/notif_icon',
    );
    const iOSDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iOSDetails);

    try {
      await flutterLocalNotificationsPlugin.show(
        0,
        message.data['title'] ?? message.notification?.title ?? "No Title",
        message.data['body'] ?? message.notification?.body ?? "No Body",
        details,
        payload: message.data['endpoint'],
      );
    } catch (e) {
      debugPrint("⚠️ Failed to show local notification: $e");
    }
  }

  Future<void> _checkInitialMessage() async {
    try {
      RemoteMessage? initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        await CacheHelper.setString(
          key: 'initialNotification',
          value: initialMessage.data['endpoint'],
        );
      }
    } catch (e) {
      debugPrint("⚠️ Failed to check initial message: $e");
    }
  }

  static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    debugPrint("🔹 Background Notification: ${message.notification?.title}");
  }
}
