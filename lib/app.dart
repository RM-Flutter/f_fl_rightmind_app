import 'package:cpanal/modules/choose_domain/choose_domin_screen.dart';
import 'package:cpanal/modules/cpanel/email_account/email_account_screen.dart';
import 'package:cpanal/modules/cpanel/email_account/create_multi_accounts_screen.dart';
import 'package:cpanal/modules/cpanel/email_filter/email_filter_screen.dart';
import 'package:cpanal/modules/more/views/more_screen.dart';
import 'package:cpanal/modules/splash_and_onboarding/views/splash_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cpanal/constants/app_constants.dart';
import 'package:cpanal/general_services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:cpanal/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:cpanal/modules/home/view/home_screen.dart';
import 'constants/app_images.dart';
import 'general_services/app_theme.service.dart';
import 'general_services/notification_service.dart';
import 'platform/platform_is.dart';
import 'routing/app_router.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
class MyApp extends StatelessWidget {
  MyApp({super.key});
  NotificationService? notificationService;
  @override
  Widget build(BuildContext context) {
    DioHelper.initail(context);
    notificationService = NotificationService();
    notificationService!.init(context);

    if(CacheHelper.getString("lang") == ""){
      CacheHelper.setString(key: "lang", value: context.locale.languageCode);
    }
    precacheImage(const AssetImage(AppImages.splashScreenBackground), context);
     final appGoRouter = goRouter(context);
    // return MaterialApp(
    //   title: 'C Panel',
    //   restorationScopeId: 'app',
    //   localizationsDelegates: context.localizationDelegates,
    //   supportedLocales: context.supportedLocales,
    //   locale: context.locale,
    //   home: CreateMultiAccountsScreen(),
    //   debugShowCheckedModeBanner: false,
    //   themeMode: ThemeMode.light,
    //   theme: AppThemeService.getTheme(isDark: false, context: context),
    //   darkTheme: AppThemeService.getTheme(isDark: true, context: context),
    //   scrollBehavior: PlatformIs.web ? AppScrollBehavior() : null,
    // );
    return MaterialApp.router(
      title: 'C Panel',
      restorationScopeId: 'app',
      routerDelegate: appGoRouter.routerDelegate,
      routeInformationParser: appGoRouter.routeInformationParser,
      routeInformationProvider: appGoRouter.routeInformationProvider,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: AppThemeService.getTheme(isDark: false, context: context),
      darkTheme: AppThemeService.getTheme(isDark: true, context: context),
      scrollBehavior: PlatformIs.web ? AppScrollBehavior() : null,
    );
  }
}

class AppScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
        PointerDeviceKind.invertedStylus,
        PointerDeviceKind.trackpad,
      };
}
