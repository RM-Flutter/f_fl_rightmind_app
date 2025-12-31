import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cpanal/constants/user_consts.dart';
import 'package:cpanal/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:cpanal/models/settings/user_settings.model.dart';
import 'package:cpanal/models/settings/user_settings_2.model.dart';
import 'package:cpanal/modules/home/view_models/home.viewmodel.dart';
import '../../../common_modules_widgets/update_app.dart';
import '../../../common_modules_widgets/dynamic_image_widget.dart';
import '../../../constants/app_images.dart';
import '../../../constants/app_sizes.dart';
import '../../../constants/app_strings.dart';
import '../../../general_services/device_info.service.dart';
import '../../../general_services/internet_check.dart';
import '../../../general_services/localization.service.dart';
import '../../../general_services/notification_service.dart';
import '../view_models/splash_onboarding.viewmodel.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final OnboardingViewModel viewModel;
  late final HomeViewModel homeViewModel;
  bool _initializationCompleted = false;
  bool _isInitializing = false;
  ConnectionService? _connectionService;

  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      bool isArabic = LocalizationService.isArabic(context: context);
      if(isArabic == true){CacheHelper.setString(key: "lang", value: "ar");}
      if(isArabic == false){CacheHelper.setString(key: "lang", value: "en");}

      // Use `isArabic` to control any logic based on language
    });
    homeViewModel = HomeViewModel();
    viewModel = OnboardingViewModel();
    initializeHomeAndSplash();
    NotificationService().init(context);
    //playTest();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Save reference to ConnectionService for safe access in dispose()
    if (_connectionService == null) {
      _connectionService = Provider.of<ConnectionService>(context, listen: false);
      // Register callback in ConnectionService to resume initialization when connection is restored
      _connectionService!.onConnectionRestored = _resumeInitialization;
    }
  }

  @override
  void dispose() {
    // Unregister callback safely
    if (_connectionService != null) {
      _connectionService!.onConnectionRestored = null;
    }
    super.dispose();
  }

  // Callback to resume initialization when connection is restored
  void _resumeInitialization() {
    if (!_initializationCompleted && !_isInitializing && mounted) {
      debugPrint("🔄 Connection restored, resuming initialization...");
      initializeHomeAndSplash();
    }
  }
  Future<void> initializeHomeAndSplash() async {
    if (!mounted || _isInitializing) return;
    
    _isInitializing = true;
    
    // Wait a bit to ensure ConnectionService is fully initialized
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Check connection status before making any API calls
    final connectionService = _connectionService ?? Provider.of<ConnectionService>(context, listen: false);
    await connectionService.checkConnection();
    
    // Double-check connection status after a brief delay
    await Future.delayed(const Duration(milliseconds: 200));
    await connectionService.checkConnection();
    
    // If offline, skip API calls and use cached data only
    if (!connectionService.isConnected) {
      debugPrint("⚠️ Offline detected: Skipping ALL API calls, using cached data only");
      debugPrint("⚠️ Connection status: ${connectionService.isConnected}");
      
      // Only initialize device info (doesn't require network)
      try {
        await DeviceInformationService.initializeAndSetDeviceInfo(context: context);
      } catch (e) {
        debugPrint("❌ Error in initializeAndSetDeviceInfo, continuing anyway: $e");
      }
      
      // Skip initializeHomeScreen which makes API calls
      // The overlay will be shown automatically by ConnectionService
      debugPrint("⚠️ Exiting initializeHomeAndSplash early - no API calls will be made");
      _isInitializing = false;
      return;
    }
    
    debugPrint("✅ Online: Proceeding with normal initialization");
    
    // Online: proceed with normal initialization
    try {
      await DeviceInformationService.initializeAndSetDeviceInfo(context: context);
    } catch (e) {
      debugPrint("❌ Error in initializeAndSetDeviceInfo, continuing anyway: $e");
    }
    
    try {
      await homeViewModel.initializeHomeScreen(context, null);
    } catch (e) {
      debugPrint("❌ Error in initializeHomeScreen, continuing anyway: $e");
    }
    
    try {
      await UpdateApp.checkForForceUpdate(context);
    } catch (e) {
      debugPrint("❌ Error in checkForForceUpdate, continuing anyway: $e");
    }
    final jsonString = CacheHelper.getString("US1");
    final json2String = CacheHelper.getString("US2");
    var us1Cache;
    var us2Cache;
    if (jsonString != null && jsonString != "") {
      us1Cache = json.decode(jsonString) as Map<String, dynamic>;// Convert String back to JSON
    }
    if (json2String != null && json2String != "") {
      us2Cache = json.decode(json2String) as Map<String, dynamic>;// Convert String back to JSON
    }
    if (us1Cache != null && us1Cache.isNotEmpty && us1Cache != "") {
      try {
        // Decode JSON string into a Map
        // Convert the Map to the appropriate type (e.g., UserSettingsModel)
        UserSettingConst.userSettings = UserSettingsModel.fromJson(us1Cache);
      } catch (e) {
        print("Error decoding user settings: $e");
      }
    }
    else {
      print("us1Cache is null or empty.");
    }
    if (us2Cache != null && us2Cache.isNotEmpty && us2Cache != "") {
      try {
        // Decode JSON string into a Map
        // Convert the Map to the appropriate type (e.g., UserSettingsModel)
        UserSettingConst.userSettings2 = UserSettings2Model.fromJson(us2Cache);
      } catch (e) {
        print("Error decoding user settings: $e");
      }
    }
    else {
      print("us2Cache is null or empty.");
    }
    viewModel.initializeSplashScreen(
        context: context,
        role: (UserSettingConst.userSettings != null)? UserSettingConst.userSettings!.role : CacheHelper.getString("roles")
    );
    
    _initializationCompleted = true;
    _isInitializing = false;
    debugPrint("✅ Initialization completed successfully");
  }


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<OnboardingViewModel>(
        create: (context) => viewModel,
        child: Scaffold(
            body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(kIsWeb ? "assets/images/png/splash_web.jpg":AppImages.splashScreenBackground,
                fit: BoxFit.cover,
                key: const ValueKey<String>(AppImages.splashScreenBackground)),
          //  const OverlayGradientWidget(),
            Positioned(
              bottom: AppSizes.s48,
              left: AppSizes.s0,
              right: AppSizes.s0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DynamicImageWidget(
                    imageUrl: AppImages.logo,
                    height: AppSizes.s75,
                    width: AppSizes.s75,
                    key: ValueKey<String>(AppImages.logo),
                  ),
                  Text(
                    AppStrings.loading.tr(),
                    style: LocalizationService.isArabic(context: context)
                        ? Theme.of(context)
                            .textTheme
                            .displayMedium
                            ?.copyWith(letterSpacing: 0)
                        : Theme.of(context).textTheme.displayMedium,
                  )
                ],
              ),
            ),
          ],
        )));
  }
}
