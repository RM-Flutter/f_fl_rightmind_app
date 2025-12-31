import 'dart:ui_web' as ui;
import 'dart:html';
import 'package:cpanal/common_modules_widgets/comments/logic/view_model.dart';
import 'package:cpanal/controller/device_sys/device_controller.dart';
import 'package:cpanal/modules/cpanel/logic/auto_response_provider.dart';
import 'package:cpanal/modules/cpanel/logic/dns_provider.dart';
import 'package:cpanal/modules/cpanel/logic/email_account_provider.dart';
import 'package:cpanal/modules/cpanel/logic/email_filter_provider.dart';
import 'package:cpanal/modules/cpanel/logic/email_forward_provider.dart';
import 'package:cpanal/modules/cpanel/logic/ftp_provider.dart';
import 'package:cpanal/modules/cpanel/logic/sql_provider.dart';
import 'package:cpanal/platform/platform_is.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hive/hive.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:cpanal/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:cpanal/general_services/connections.service.dart';
import 'package:cpanal/modules/more/views/blog/controller/blog_controller.dart';
import 'package:cpanal/modules/more/views/notification/logic/notification_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'app.dart';
import 'controller/request_controller/request_controller.dart';
import 'firebase_options.dart';
import 'general_services/app_config.service.dart';
import 'general_services/sentry_service.dart';
import 'utils/error_handling/global_error_handler.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'general_services/conditional_imports/change_url_strategy.service.dart';
import 'general_services/internet_check.dart';
import 'general_services/notification_service.dart';
import 'modules/home/view_models/home.viewmodel.dart';
import 'modules/main_screen/view_models/main_viewmodel.dart';
import 'modules/points/logic/points_cubit/points_provider.dart';
GlobalKey<NavigatorState>? navigatorKey = GlobalKey<NavigatorState>();
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

// Background handler for Firebase messages
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("🔹 Background Notification: ${message.notification?.title}");
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Sentry before anything else
  await SentryService.init();
  
  // Register global error handlers
  registerErrorHandlers();

  await CacheHelper.init();
  //await ConnectionsService.init();
  await EasyLocalization.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // ignore: undefined_prefixed_name
  ui.platformViewRegistry.registerViewFactory(
    'iframeElement',
        (int viewId) => IFrameElement()
      ..src = CacheHelper.getString("webViewUrl") ?? "https://flutter.dev" // لينك افتراضي
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '600px', // حط أي ارتفاع مناسب
  );


  GoRouter.optionURLReflectsImperativeAPIs = true;
  try {
    final appDocumentDirectory = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDirectory.path);
  } catch (ex, t) {
    debugPrint('Failed to initialize Hive Database $ex $t');
  }
  runApp(EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/json/lang',
      fallbackLocale: const Locale('en'),
      // Enable saving the selected locale in local storage
      saveLocale: true,
      child: MultiProvider(
        // inject all providers to make it accessable intire all application via context.
        providers: [
          ChangeNotifierProvider<AppConfigService>(
            create: (_) => AppConfigService(),
          ),
          ChangeNotifierProvider<MainScreenViewModel>(
            create: (_) => MainScreenViewModel(),
          ),
          ChangeNotifierProvider<HomeViewModel>(
            create: (_) => HomeViewModel(),
          ),
          ChangeNotifierProvider<EmailAccountProvider>(
            create: (_) => EmailAccountProvider(),
          ),
          ChangeNotifierProvider<AutoResponseProvider>(
            create: (_) => AutoResponseProvider(),
          ),
          ChangeNotifierProvider(create: (_) => AppConfigService()),
          ChangeNotifierProxyProvider<AppConfigService, GoRouterRefreshNotifier>(
            create: (_) => GoRouterRefreshNotifier(),
            update: (_, appConfigService, notifier) => notifier!..update(appConfigService),
          ),
          ChangeNotifierProvider(create: (context) => RequestController()),
          ChangeNotifierProvider(create: (context) => BlogProviderModel()),
          ChangeNotifierProvider(create: (context) => EmailForwardProvider()),
          ChangeNotifierProvider(create: (context) => FtpProvider()),
          ChangeNotifierProvider(create: (context) => ConnectionService()),
          ChangeNotifierProvider(create: (context) => EmailFilterProvider()),
          ChangeNotifierProvider(create: (context) => SqlProvider()),
          ChangeNotifierProvider(create: (context) => HomeViewModel()),
          ChangeNotifierProvider(create: (context) => DNSProvider()),
          ChangeNotifierProvider(create: (context) => CommentProvider()),
          ChangeNotifierProvider(create: (context) => NotificationProviderModel()),
          ChangeNotifierProvider(create: (context) => PointsProvider()),
          ChangeNotifierProvider(create: (context) => DeviceControllerProvider()),
        ],
        child: MyApp(),
      )));
}
class GoRouterRefreshNotifier extends ChangeNotifier {
  void update(AppConfigService service) {
    // نربط notifier ده مع appConfigService
    service.addListener(notifyListeners);
  }

  @override
  void dispose() {
    super.dispose();
  }
}