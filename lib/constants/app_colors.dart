import '../general_services/dynamic_app_config.service.dart';

abstract class AppColors {

  static int get buttonColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('buttonColor'),
    0xFFE93F81,
  );
  static int get buttonSecondaryColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('buttonSecondaryColor'),
    0xFF3489EF,
  );
  static int get buttonDisabledColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('buttonDisabledColor'),
    0xffB9C0C9,
  );

  // Text Colors
  static int get titleTextColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('titleTextColor'),
    0xff1E2D74,
  );
  static int get bodyTextColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('bodyTextColor'),
    0xFF000000,
  );
  static int get subtitleTextColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('subtitleTextColor'),
    0xff606060,
  );
  static int get hintTextColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('hintTextColor'),
    0xFFA3A3A3,
  );
  static int get linkTextColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('linkTextColor'),
    0xFFE93F81,
  );

  // Background Colors
  static int get backgroundColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('backgroundColor'),
    0xFFFFFFFF,
  );
  static int get scaffoldBackgroundColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('scaffoldBackgroundColor'),
    0xFFF5F8FA,
  );
  static int get cardBackgroundColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('cardBackgroundColor'),
    0xFFF1F6FF,
  );
  static int get modalBackgroundColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('modalBackgroundColor'),
    0xffFFFFFF,
  );

  // AppBar Colors
  static int get appBarColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('appBarColor'),
    0x00000000, // transparent
  );
  static int get appBarTextColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('appBarTextColor'),
    0xffFFFFFF,
  );
  static int get appBarIconColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('appBarIconColor'),
    0xffFFFFFF,
  );

  // Border Colors
  static int get borderColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('borderColor'),
    0xffE3E5E5,
  );
  static int get dividerColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('dividerColor'),
    0xFFDFDFDF,
  );
  static int get focusedBorderColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('focusedBorderColor'),
    0xFFE93F81,
  );

  // Icon Colors
  static int get iconColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('iconColor'),
    0xff1E2D74,
  );
  static int get iconSecondaryColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('iconSecondaryColor'),
    0xff707070,
  );

  // Status Colors
  static int get successColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('successColor'),
    0xff2D6A4F,
  );
  static int get errorColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('errorColor'),
    0xffc72c41,
  );
  static int get warningColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('warningColor'),
    0xffFCA652,
  );
  static int get infoColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('infoColor'),
    0xff3282B8,
  );

  // Input Field Colors
  static int get inputFillColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('inputFillColor'),
    0xFFFFFFFF,
  );
  static int get inputBorderColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('inputBorderColor'),
    0xffDFDFDF,
  );
  static int get inputFocusedBorderColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('inputFocusedBorderColor'),
    0xFFE93F81,
  );
  static int get inputErrorBorderColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('inputErrorBorderColor'),
    0xffc72c41,
  );

  // Shadow & Overlay Colors
  static int get shadowColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('shadowColor'),
    0xff231F20,
  );
  static int get overlayColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('overlayColor'),
    0xff191C1F,
  );

  // Tab & Navigation Colors
  static int get tabActiveColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('tabActiveColor'),
    0xFFE93F81,
  );
  static int get tabInactiveColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('tabInactiveColor'),
    0xff707070,
  );
  static int get navBarColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('navBarColor'),
    0xffFFFFFF,
  );
  static int get navBarActiveColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('navBarActiveColor'),
    0xFFE93F81,
  );

  // Chip & Tag Colors
  static int get chipBackgroundColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('chipBackgroundColor'),
    0xFFF1F6FF,
  );
  static int get chipTextColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('chipTextColor'),
    0xff1E2D74,
  );

  // ============================================
  // الألوان القديمة (Legacy Aliases - للتوافق)
  // ============================================
  
  static const int oC2Color = 0xFFE93F81;
  static int get primary => buttonColor;
  static int get blue => buttonSecondaryColor;
  static const int black = 0xFF000000;
  static int get dark => titleTextColor;
  static const int red = 0xFFBD1316;
  static int get grey50 => dividerColor;
  static const int pink = 0xFFff1493;
  
  // Legacy aliases for old code compatibility
  static int get c1 => titleTextColor;
  static int get c2 => titleTextColor;
  static int get c3 => black;
  static int get c4 => buttonColor;
  static int get bgC1 => titleTextColor;
  static int get bgC2 => buttonColor;
  static int get bgC3 => backgroundColor;
  static int get bgC4 => cardBackgroundColor;
  static int get textC1 => titleTextColor;
  static int get textC2 => buttonColor;
  static int get textC3 => black;
  static int get textC4 => subtitleTextColor;
  static int get textC5 => backgroundColor;
  static int get appBarBackgroundColor => appBarColor;
  static int get bodyBackgroundColor => backgroundColor;
  static int get btmAppBarBackgroundColor => navBarColor;
  static int get fabBackgroundColor => buttonColor;
  static int get fabIconColor => appBarIconColor;
  static int get inputHintColor => shadowColor;
  static int get inputLabelColor => dividerColor;
  static int get inputTextColor => shadowColor;
}
