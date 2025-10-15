import 'dart:convert';
import 'package:cpanal/constants/app_colors.dart';
import 'package:cpanal/constants/app_strings.dart';
import 'package:cpanal/constants/user_consts.dart';
import 'package:cpanal/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:cpanal/models/settings/user_settings.model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../common_modules_widgets/template_page.widget.dart';
import '../../../../constants/app_sizes.dart';
import '../../../common_modules_widgets/custom_elevated_button.widget.dart';
import '../../../utils/componentes/general_components/gradient_bg_image.dart';
import '../../more/views/more_screen.dart';
import '../logic/ssl_provider.dart';

class SSLControllerScreen extends StatefulWidget {
  final String? name;
  final String? dominId;
  SSLControllerScreen({this.name, this.dominId});

  @override
  State<SSLControllerScreen> createState() => _SSLControllerScreenState();
}

class _SSLControllerScreenState extends State<SSLControllerScreen> {
  List<Email> emails = [];
  List<Email> selectedEmails = [];
  bool isSelectionMode = false;
  late ScrollController _scrollController;
  late final SSLProvider emailProvider;
  List<String> get selectedAccountsDeleted =>
      selectedEmails.map((e) => e.address).toList();
  var accountsPayload;
  void printSelectedAccounts() {
    accountsPayload = {
      "accounts": selectedEmails.map((e) => e.address).toList(),
    };
    print(jsonEncode(accountsPayload));
  }

  void onLongPress(int index) {
    setState(() {
      isSelectionMode = true;
      emails[index].isSelected = true;
      selectedEmails.add(emails[index]);
      printSelectedAccounts(); // ✅ هنا
    });
  }

  void onTap(int index) {
    if (isSelectionMode) {
      setState(() {
        emails[index].isSelected = !emails[index].isSelected;
        if (emails[index].isSelected) {
          selectedEmails.add(emails[index]);
        } else {
          selectedEmails.removeWhere(
              (element) => element.address == emails[index].address);
        }
        if (!emails.any((e) => e.isSelected)) {
          isSelectionMode = false;
        }
        printSelectedAccounts();
      });
    }
  }

  emailcickle() async {
    await emailProvider.getSSLEmails(
      context,
      domainId: widget.dominId,
    );
  }

  @override
  void initState() {
    super.initState();
    emailProvider = SSLProvider();
    _scrollController = ScrollController();
    emailcickle();
    //  _scrollController.addListener(_scrollListener);
  }

  // void _scrollListener() {
  //   if (!_scrollController.hasClients) return;
  //   final position = _scrollController.position;
  //   if (!position.hasContentDimensions || position.maxScrollExtent == 0) return;
  //
  //   final isCloseToBottom = position.pixels >= position.maxScrollExtent - 200;
  //   if (isCloseToBottom &&
  //       !emailProvider.isLoading &&
  //       emailProvider.hasMore &&
  //       emailProvider.SSLS.isNotEmpty) {
  //     emailProvider.getSSLEmails(
  //       context,
  //
  //       domainId: widget.dominId,
  //       isNewPage: true,
  //     );
  //   }
  // }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var jsonString = CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty) {
      var gCache = json.decode(jsonString);
      UserSettingConst.userSettings = UserSettingsModel.fromJson(gCache);
    }

    return ChangeNotifierProvider<SSLProvider>.value(
      value: emailProvider,
      child: Consumer<SSLProvider>(
        builder: (context, value, child) {
          return TemplatePage(
            pageContext: context,
            title: AppStrings.sslControl.tr().toUpperCase(),
            onRefresh: () async {
              emailProvider.pageNumber = 1;
              emailProvider.SSLS.clear();
              await emailProvider.getSSLEmails(context,
                  domainId: widget.dominId);
              await emailcickle();
            },
            bottomNavigationBar: Container(
              width: double.infinity,
              height: 82,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xffC9CFD2).withOpacity(0.5),
                    blurRadius: AppSizes.s5,
                    spreadRadius: 1,
                  )
                ],
                borderRadius: BorderRadius.circular(35),
              ),
              alignment: Alignment.center,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: Text(widget.name!,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(AppColors.dark))),
                  ),
                  const SizedBox(width: 5),
                  GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: SvgPicture.asset(
                          "assets/images/svg/cpanal_bottom_nav_icon.svg")),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MoreScreen(),
                          ));
                    },
                    child:
                        const Icon(Icons.menu, color: Color(AppColors.primary)),
                  )
                ],
              ),
            ),
            body: GradientBgImage(
              padding: EdgeInsets.all(0),
              child: SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.8,
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(AppSizes.s12),
                  children: [
                    Text(
                      AppStrings.sslMessage.tr(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(AppColors.dark)),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!value.isLoadingRun)
                          CustomElevatedButton(
                            title: AppStrings.runAutoSSL.tr().toUpperCase(),
                            onPressed: () async {
                              value.runSSL(context, domainId: widget.dominId);
                            },
                            isPrimaryBackground: false,
                          ),
                        if (value.isLoadingRun) const CircularProgressIndicator()
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: kIsWeb ? 1100 : double.infinity,
                        ),
                        child: ListView.separated(
                          itemCount: value.isLoading && value.pageNumber == 1
                              ? 3
                              : value.SSLS.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          separatorBuilder: (_, __) => const SizedBox(height: 15),
                          itemBuilder: (context, index) {
                            final safeContext = context; // ✅ هذا هو الـ context الآمن

                            if (value.isLoading && value.pageNumber == 1) {
                              return Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                child: Container(
                                    height: 100,
                                    width: double.infinity,
                                    color: Colors.white),
                              );
                            }
                            return GestureDetector(
                              // onLongPress: () => onLongPress(index),
                              // onTap: () => onTap(index),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Color(0x0C000000),
                                        blurRadius: 10,
                                        offset: Offset(0, 1))
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    defaultSSLContainer(
                                        title1: AppStrings.name.tr(),
                                        index: value.SSLS[index],
                                        title2:
                                            "${value.SSLS[index]['name'] ?? AppStrings.unKnown.tr()}"),
                                    const SizedBox(height: 5),
                                    defaultSSLContainer(
                                        title1: AppStrings.certificate.tr(),
                                        title2:
                                            "${value.SSLS[index]['certificate'] ?? AppStrings.unKnown.tr()}"),
                                    const SizedBox(height: 5),
                                    defaultSSLContainer(
                                        title1: AppStrings.isAutossl.tr(),
                                        title2:
                                            "${value.SSLS[index]['is_autossl'] ?? AppStrings.unKnown.tr()}"),
                                    const SizedBox(height: 5),
                                    defaultSSLContainer(
                                        title1: AppStrings.safety.tr(),
                                        title2:
                                            "${value.SSLS[index]['safety'] ?? AppStrings.unKnown.tr()}"),
                                    const SizedBox(height: 5),
                                    defaultSSLContainer(
                                        title1: AppStrings.expiration.tr(),
                                        title2:
                                            "${value.SSLS[index]['expiration'] ?? AppStrings.unKnown.tr()}"),
                                    const SizedBox(height: 5),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    if (value.isLoading && value.pageNumber != 1)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                  ],
                ),
              ),
            ),
            // floatingActionButton: isSelectionMode
            //     ? null
            //     : Column(
            //   mainAxisAlignment: MainAxisAlignment.end,
            //   children: [
            //     FloatingActionButton(
            //       onPressed: ()async {
            //         await showModalBottomSheet(
            //           context: context,
            //           isScrollControlled: true,
            //           backgroundColor: Colors.transparent,
            //           builder: (_) => Padding(
            //             padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            //             child: CreateEmailBottomSheet(dominId: widget.dominId,dominName: widget.name,),
            //           ),
            //         );
            //         await emailcickle();
            //       },
            //       backgroundColor: Colors.pink,
            //       child: const Icon(Icons.add, color: Colors.white),
            //     ),
            //   ],
            // ),
          );
        },
      ),
    );
  }

  Widget defaultSSLContainer({title1, title2, index}) => Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: MediaQuery.sizeOf(context).width * 0.25,
            child: Text(
              "$title1 : ",
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(AppColors.dark)),
            ),
          ),
          SizedBox(
            width: kIsWeb? MediaQuery.sizeOf(context).width * 0.24:MediaQuery.sizeOf(context).width * 0.48,
            child: Text(
              title2,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(AppColors.primary)),
            ),
          ),
          Spacer(),
         if(index != null) GestureDetector(
              onTap: () async {
                final name = index['name'];
                final certificate = index['certificate'];
                final is_autossl = index['is_autossl'];
                final expiration = index['expiration'];
                await Clipboard.setData(ClipboardData(text:
                "Name : $name \n Certificate : $certificate \n Auto SSL : $is_autossl \n Expiration : $expiration"
                ));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("${AppStrings.copied.tr()}")),
                );
              },
              child: const Icon(Icons.copy, color: Color(AppColors.primary)))
        ],
      );
}

class Email {
  final String address;
  final String status;
  final String usage;
  bool isSelected;
  Email(this.address, this.status, this.usage, {this.isSelected = false});
}
