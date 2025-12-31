import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cpanal/modules/more/views/company_structure/company_structure_screen.dart';
import 'package:cpanal/modules/personal_profile/views/personal_profile_screen.dart';
import 'package:cpanal/modules/splash_and_onboarding/views/splash_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:cpanal/constants/user_consts.dart';
import 'package:cpanal/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:cpanal/modules/more/widgets/customize_notification_screen.dart';
import 'package:cpanal/utils/custom_shimmer_loading/shimmer_animated_loading.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_sizes.dart';
import '../../../constants/app_strings.dart';
import '../../../constants/web_image.dart';
import '../../../general_services/localization.service.dart';
import '../../../models/settings/user_settings.model.dart';
import '../../../general_services/app_config.service.dart';
import '../../../routing/app_router.dart';
import '../../home/view_models/home.viewmodel.dart';
import '../../personal_profile/viewmodels/personal_profile.viewmodel.dart';
//import 'dart:html' as html;

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  final ValueNotifier<bool?> isLogout = ValueNotifier<bool?>(null);

  @override
  void initState() {
    super.initState();
    isLogout.addListener(() {
      if (isLogout.value == false) {
        context.pop();
      } else if (isLogout.value == true) {
        context.pop();

        PersonalProfileViewModel().logout(context: context);
      }
    });
  }

  @override
  void dispose() {
    isLogout.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var jsonString;
    var gCache;
    jsonString = CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      gCache = json.decode(jsonString)
          as Map<String, dynamic>; // Convert String back to JSON
      UserSettingConst.userSettings = UserSettingsModel.fromJson(gCache);
    }

    return Consumer<HomeViewModel>(
      builder: (context, value, child) {
        return WillPopScope(
          onWillPop: () async {
            return true;
          },
          child: Scaffold(
            body: Stack(
              alignment: Alignment.center,
              children: [
                Stack(
                  alignment: Alignment.topLeft,
                  children: [
                    Container(
                      padding: EdgeInsets.zero,
                      alignment: Alignment.topCenter,
                      color: Color(AppColors.dark),
                      child: SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.25,
                        child: Image.asset(
                          "assets/images/png/more_back.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsGeometry.only(left: 16, top: 40, right: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                              onTap: () {Navigator.pop(context);},
                              child: Icon(Icons.arrow_back, color: Color(AppColors.backgroundColor))),
                          Text(
                            AppStrings.accountAndSettings.tr(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: AppSizes.s14,
                              letterSpacing: 1.4,
                              color: Color(AppColors.backgroundColor),
                            ),
                          ),
                          GestureDetector(
                              onTap: () {},
                              child: Icon(Icons.arrow_back, color: Colors.transparent)),
                        ],
                      ),
                    )
                  ],
                ),
                Positioned.fill(
                  top: MediaQuery.sizeOf(context).height * 0.25,
                  child: Container(
                    // height: MediaQuery.sizeOf(context).height * 0.66,
                    decoration: const ShapeDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(0, 0),
                        end: Alignment(1, 0),
                        colors: [Color(AppColors.backgroundColor), Color(AppColors.bgC4)],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.15,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: ListView(
                              children: [
                                Center(
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: kIsWeb ? 1070 : double.infinity,
                                    ),
                                    child: Container(
                                      alignment: LocalizationService.isArabic(context: context)? Alignment.centerRight:Alignment.centerLeft,
                                      child: Text(AppStrings.more.tr().toUpperCase(),
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Color(AppColors.primary))),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                DefaultListTile(
                                  title: AppStrings.cpanal.tr(),
                                  src: "assets/images/svg/h-cpanal.svg",
                                  onTap: () {
                                    context.pushNamed(
                                      AppRoutes.chooseDomain.name,
                                      pathParameters: {
                                        "lang": context.locale.languageCode,
                                      },
                                    );
                                  },
                                ),
                                DefaultListTile(
                                  title: AppStrings.ticketSystem.tr(),
                                  src: "assets/images/svg/mts.svg",
                                  onTap: () {
                                    context.pushNamed(
                                      AppRoutes.ComplainScreen.name,
                                      pathParameters: {
                                        "lang": context.locale.languageCode,
                                      },
                                    );
                                  },
                                ),
                                // DefaultListTile(
                                //   title: AppStrings.companyStructure.tr(),
                                //   src: "assets/images/svg/mcs.svg",
                                //   onTap: () async{
                                //     var loadingPercentage = 0;
                                //     WebViewController? controller;
                                //     late String url;
                                //     final jsonString = CacheHelper.getString("USG");
                                //     Map<String, dynamic>? gCache;
                                //     if (jsonString != null && jsonString.isNotEmpty) {
                                //       gCache = json.decode(jsonString) as Map<String, dynamic>;
                                //     }
                                //     url = gCache?['company_structure_url'] ?? "https://www.google.com/";
                                //
                                //     if (!kIsWeb) {
                                //       // ✅ موبايل
                                //       controller = WebViewController()
                                //         ..setJavaScriptMode(JavaScriptMode.unrestricted)
                                //         ..setNavigationDelegate(
                                //           NavigationDelegate(
                                //             onPageStarted: (_) => setState(() => loadingPercentage = 0),
                                //             onProgress: (progress) =>
                                //                 setState(() => loadingPercentage = progress),
                                //             onPageFinished: (_) =>
                                //                 setState(() => loadingPercentage = 100),
                                //           ),
                                //         )
                                //         ..addJavaScriptChannel(
                                //           'SnackBar',
                                //           onMessageReceived: (message) {
                                //             ScaffoldMessenger.of(context).showSnackBar(
                                //               SnackBar(content: Text(message.message)),
                                //             );
                                //           },
                                //         )
                                //         ..loadRequest(Uri.parse(url));
                                //     } else {
                                //       html.window.open(url, "_blank");
                                //     }
                                //     if(kIsWeb){
                                //       Center(
                                //         child: Column(
                                //           mainAxisAlignment: MainAxisAlignment.center,
                                //           children: [
                                //             const Icon(Icons.open_in_new, size: 60, color: Colors.blue),
                                //             const SizedBox(height: 16),
                                //             const Text("تم فتح الرابط في تبويب جديد"),
                                //             const SizedBox(height: 16),
                                //             ElevatedButton(
                                //               onPressed: () {
                                //                 html.window.open(url, "_blank");
                                //               },
                                //               child: const Text("إعادة فتح الرابط"),
                                //             )
                                //           ],
                                //         ),
                                //       );
                                //     }else{
                                //       Stack(
                                //         children: [
                                //           WebViewWidget(controller: controller!), // للموبايل
                                //           if (loadingPercentage < 100)
                                //             LinearProgressIndicator(value: loadingPercentage / 100.0),
                                //         ],
                                //       );
                                //     }
                                //   // await  Navigator.push(
                                //   //       context,
                                //   //       MaterialPageRoute(
                                //   //         builder: (context) => WebViewStack(),
                                //   //       ));
                                //   //  Navigator.pop(context);
                                //   },
                                // ),
                                DefaultListTile(
                                  title: AppStrings.notifications.tr(),
                                  src: "assets/images/svg/notification.svg",
                                  onTap: () {
                                    if (kIsWeb) {
                                      context.pushNamed(
                                        AppRoutes.defaultListPage.name,
                                        pathParameters: {
                                          "lang": context.locale.languageCode,
                                          "type": "rmnotifications"
                                        },
                                      );
                                    } else {
                                      context.pushNamed(
                                        AppRoutes.defaultPage.name,
                                        pathParameters: {
                                          "lang": context.locale.languageCode,
                                          "type": "rmnotifications"
                                        },
                                      );
                                    }
                                  },
                                ),
                                // DefaultListTile(
                                //   title: AppStrings.articlesNew.tr(),
                                //   src: "assets/images/svg/man.svg",
                                //   onTap: () {
                                //     if (kIsWeb) {
                                //       context.pushNamed(
                                //         AppRoutes.defaultListPage.name,
                                //         pathParameters: {
                                //           "lang": context.locale.languageCode,
                                //           "type": "blogs"
                                //         },
                                //       );
                                //     } else {
                                //       context.pushNamed(
                                //         AppRoutes.defaultPage.name,
                                //         pathParameters: {
                                //           "lang": context.locale.languageCode,
                                //           "type": "blogs"
                                //         },
                                //       );
                                //     }
                                //   },
                                // ),
                                DefaultListTile(
                                  title: AppStrings.aboutComapny.tr(),
                                  src: "assets/images/svg/map.svg",
                                  onTap: () {
                                    context.pushNamed(
                                      AppRoutes.aboutUsScreen.name,
                                      pathParameters: {
                                        "lang": context.locale.languageCode,
                                      },
                                    );
                                  },
                                ),
                                DefaultListTile(
                                  title: AppStrings.contactUs.tr(),
                                  src: "assets/images/svg/s8.svg",
                                  onTap: () {
                                    context.pushNamed(
                                      AppRoutes.contactUs.name,
                                      pathParameters: {
                                        "lang": context.locale.languageCode,
                                      },
                                    );
                                  },
                                ),
                                // DefaultListTile(
                                //   title: AppStrings.faqs.tr(),
                                //   src: "assets/images/svg/faqqs.svg",
                                //   onTap: () {
                                //     context.pushNamed(
                                //       AppRoutes.faqScreen.name,
                                //       pathParameters: {
                                //         "lang": context.locale.languageCode,
                                //       },
                                //     );
                                //   },
                                // ),
                                const SizedBox(height: 15),
                                Center(
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: kIsWeb ? 1070 : double.infinity,
                                    ),
                                    child: Container(
                                      alignment: LocalizationService.isArabic(context: context)? Alignment.centerRight:Alignment.centerLeft,
                                      child: Text(AppStrings.myAccount.tr().toUpperCase(),
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Color(AppColors.primary))),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                DefaultListTile(
                                  title: AppStrings.customizeNotifications.tr(),
                                  src: "assets/images/svg/mcn.svg",
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return CustomizeNotificationScreen();
                                        });
                                  },
                                ),
                                DefaultListTile(
                                  title: AppStrings.languageSettings.tr(),
                                  src: "assets/images/svg/mls.svg",
                                  onTap: () {
                                    context.pushNamed(
                                        AppRoutes.langSettingScreen.name,
                                        pathParameters: {
                                          'lang': context.locale.languageCode,
                                        });
                                  },
                                ),
                                DefaultListTile(
                                  title: AppStrings.updatePassword.tr(),
                                  src: "assets/images/svg/mup.svg",
                                  onTap: () {
                                    context.pushNamed(
                                      AppRoutes.updatePassword.name,
                                      pathParameters: {
                                        "lang": context.locale.languageCode,
                                      },
                                    );
                                  },
                                ),
                                DefaultListTile(
                                  title: AppStrings.personalInfo.tr(),
                                  src: "assets/images/svg/mpi.svg",
                                  onTap: () {
                                    context.pushNamed(
                                      AppRoutes.personalProfile.name,
                                      pathParameters: {
                                        "lang": context.locale.languageCode,
                                      },
                                    );
                                  },
                                ),
                                DefaultListTile(
                                  title: AppStrings.userDevices.tr(),
                                  src: "assets/images/svg/mpi.svg",
                                  onTap: () {
                                    context.pushNamed(
                                      AppRoutes.userDevices.name,
                                      pathParameters: {
                                        "lang": context.locale.languageCode,
                                      },
                                    );
                                  },
                                ),
                                DefaultListTile(
                                  title: AppStrings.logout.tr(),
                                  src: "assets/images/svg/mlo.svg",
                                  onTap: () async {
                                    final appConfigService =
                                        Provider.of<AppConfigService>(context,
                                            listen: false);
                                    appConfigService.logout(context, viewAlert: true).then((v) {
                                     context.goNamed(
                                        AppRoutes.splash.name,
                                        pathParameters: {'lang': context.locale.languageCode,},
                                      );
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.sizeOf(context).height * 0.15,
                  child: Column(
                    children: [
                      ClipOval(
                        child: GestureDetector(
                          onTap: () {
                            context.pushNamed(
                              AppRoutes.personalProfile.name,
                              pathParameters: {
                                "lang": context.locale.languageCode,
                              },
                            );
                          },
                          child: SizedBox(
                            width: 124,
                            height: 124,
                            child:  CachedNetworkImage(
                                    imageUrl: (gCache != null)
                                        ? gCache['photo'] ?? ""
                                        : "",
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        const ShimmerAnimatedLoading(
                                      width: 124,
                                      height: 124,
                                      circularRaduis: 124,
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Icon(
                                            Icons.image_not_supported_outlined),
                                  )

                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        width: MediaQuery.sizeOf(context).width * 1,
                        child: Text(
                          (gCache != null && gCache['name'] != null ? gCache['name'] ?? '' : "")
                              .toUpperCase(),
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                // fontSize: 16,

                                // fontWeight: FontWeight.w700,
                                // height: 0,
                              ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        gCache != null && gCache['job_title'] != null ? gCache['job_title'] ?? "" : "",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Color(AppColors.subtitleTextColor),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              // height: 0,
                            ),

                        //      TextStyle(
                        // color: Color(0xFF4F4F4F),
                        // fontSize: 10,
                        //   fontFamily: 'Bai Jamjuree',
                        //   fontWeight: FontWeight.w500,
                        //   height: 0,
                        // ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class DefaultListTile extends StatelessWidget {
  final String src;
  final String? title;
  final VoidCallback? onTap;

  const DefaultListTile({
    super.key,
    required this.src,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: kIsWeb ? 1100 : double.infinity,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: EdgeInsets.zero,
          child: ListTile(
            leading: SvgPicture.asset(
              src,
              color: Color(AppColors.primary),
              fit: BoxFit.scaleDown,
              width: 20, height: 20,
            ),
            title: Text(
              title!.toUpperCase() ?? "",
              style: Theme.of(context).textTheme.labelSmall,
            ),
            // trailing: Icon(
            //   Icons.arrow_forward_ios,
            //   color: Theme.of(context).colorScheme.primary,
            // ),
            onTap: onTap ?? () {}, // Add your onTap functionality here
          ),
        ),
      ),
    );
  }
}
