import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cpanal/common_modules_widgets/custom_elevated_button.widget.dart';
import 'package:cpanal/constants/app_colors.dart';
import 'package:cpanal/constants/app_strings.dart';
import 'package:cpanal/constants/user_consts.dart';
import 'package:cpanal/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:cpanal/models/settings/user_settings.model.dart';
import 'package:cpanal/modules/choose_domain/logic/domain_provider.dart';
import 'package:cpanal/modules/dashboard/dashboard_screen.dart';
import 'package:cpanal/utils/custom_shimmer_loading/shimmer_animated_loading.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../common_modules_widgets/template_page.widget.dart';
import '../../../constants/app_sizes.dart';
import '../../constants/web_image.dart';
import '../../routing/app_router.dart';
import '../../utils/componentes/general_components/gradient_bg_image.dart';
import '../cpanel/email_account/email_account_screen.dart';

class ChooseDomainScreen extends StatefulWidget {

  @override
  State<ChooseDomainScreen> createState() =>
      _ChooseDomainScreenState();
}

class _ChooseDomainScreenState extends State<ChooseDomainScreen> {

  @override
  Widget build(BuildContext context) {
    var jsonString;
    var gCache;
    jsonString = CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      gCache = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
      UserSettingConst.userSettings = UserSettingsModel.fromJson(gCache);
    }
    return ChangeNotifierProvider(
      create: (context) => DomainProvider()..getUserDomains(context),
      child: Consumer<DomainProvider>(
        builder: (context, value, child) {
          return TemplatePage(
              pageContext: context,
              title: AppStrings.chooseTheDomain.tr().toUpperCase(),
              onRefresh: () async {
                await value.getUserDomains(context);
              },
              body: GradientBgImage(
                padding: EdgeInsets.all(0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.s12, horizontal: AppSizes.s25),
                  child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(AppStrings.pleaseChooseTheDomainYouWantToControl.tr().toUpperCase(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(AppColors.primary)),
                          ),
                          const SizedBox(height: 20,),
                          if(kIsWeb)GridView.builder(
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3, // 3 عناصر في الصف
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.75, // تحكم في ارتفاع/عرض الكارد
                            ),
                            itemCount: value.isLoading ? 5 : value.domains.length,
                            itemBuilder: (context, index) {
                              return (value.isLoading)
                                  ? Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                child: Container(
                                  height: 180,
                                  width: double.infinity,
                                  color: Colors.white,
                                ),
                              )
                                  : Column(
                                children: [
                                  if (value.domains[index]['logo'].isNotEmpty)
                                    CachedNetworkImage(
                                      width: double.infinity,
                                      height: 120, // تصغير شوية في الويب
                                      fit: BoxFit.contain,
                                      imageUrl: value.domains[index]['logo'][0]['file'],
                                      placeholder: (context, url) =>
                                      const ShimmerAnimatedLoading(),
                                      errorWidget: (context, url, error) =>
                                      const Icon(Icons.image_not_supported_outlined),
                                    ),
                                  const SizedBox(height: 10),
                                  Text(
                                    value.domains[index]['domain'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 10),
                                  CustomElevatedButton(
                                    title: AppStrings.select.tr().toUpperCase(),
                                    onPressed: ()async {
                                      await CacheHelper.setString(
                                        key:  "USER_PERMISSIONS",
                                        value:  json.encode(value.domains[index]['user_permissions']),
                                      );
                                     await context.pushNamed(
                                        AppRoutes.DominDashboard.name,
                                        pathParameters: {
                                          'lang': context.locale.languageCode,
                                          'id': value.domains[index]['id'].toString(),
                                          'name': value.domains[index]['domain'],
                                        },
                                        extra: EmailAccountExtra(
                                          begin: const Offset(1.0, 0.0),
                                          permissions: value.domains[index]['user_permissions'],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                          if(!kIsWeb)ListView.separated(
                              padding: EdgeInsets.zero,
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              reverse: false,
                              itemBuilder: (context, index) =>(value.isLoading)?
                              Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                child: Column(
                                  children: [
                                    // Shimmer placeholder for image
                                    Container(
                                      height: 180,
                                      width: double.infinity,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(height: 10),
                                    // Shimmer placeholder for text
                                    Container(
                                      height: 20,
                                      width: 200,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(height: 10),
                                    // Shimmer placeholder for button
                                    Container(
                                      height: 50,
                                      width: double.infinity,
                                      margin: const EdgeInsets.symmetric(horizontal: 16),
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              )
                                  :Column(
                                  children: [
                                    if(value.domains[index]['logo'].isNotEmpty)SizedBox(
                                      width:double.infinity,
                                      child:CachedNetworkImage(
                                        width: double.infinity,
                                        height: MediaQuery.of(context).size.height * 0.225,
                                        fit: BoxFit.contain,
                                        imageUrl: value.domains[index]['logo'].isNotEmpty?value.domains[index]['logo'][0]['file'] : "",
                                        placeholder: (context, url) =>
                                        const ShimmerAnimatedLoading(),
                                        errorWidget: (context, url, error) => const Icon(
                                          Icons.image_not_supported_outlined,
                                          size: AppSizes.s32,
                                          color: Colors.white,
                                        ),
                                      ),

                                    ),
                                    if(value.domains[index]['logo'].isNotEmpty)const SizedBox(height: 10,),
                                    Text(value.domains[index]['domain'], style: const TextStyle(color: Color(AppColors.dark), fontWeight: FontWeight.w700,fontSize: 18),),
                                    const SizedBox(height: 10,),
                                    CustomElevatedButton(
                                      title: AppStrings.select.tr().toUpperCase(),
                                      onPressed: () async {
                                        context.pushNamed(
                                          AppRoutes.DominDashboard.name,
                                          pathParameters: {
                                            'lang': context.locale.languageCode,
                                            'id': value.domains[index]['id'].toString(),
                                            'name': value.domains[index]['domain'],
                                          },
                                          extra: EmailAccountExtra(
                                            begin: const Offset(1.0, 0.0),
                                            permissions: value.domains[index]['user_permissions'],
                                          ),
                                        );
                                      },
                                      isPrimaryBackground: false,
                                    ),
                                  ]
                              ),
                              separatorBuilder: (context, index) => const SizedBox(height: 40,),
                              itemCount: (value.isLoading)? 5 : value.domains.length),
                          const SizedBox(height: 20,),
                        ],
                      )
                  ),
                ),
              ));
        },
      ),
    );
  }
}
