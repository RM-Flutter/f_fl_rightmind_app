import 'dart:convert';
import 'package:cpanal/constants/app_colors.dart';
import 'package:cpanal/constants/app_constants.dart';
import 'package:cpanal/constants/app_strings.dart';
import 'package:cpanal/constants/user_consts.dart';
import 'package:cpanal/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:cpanal/models/settings/user_settings.model.dart';
import 'package:cpanal/modules/cpanel/logic/auto_response_provider.dart';
import 'package:cpanal/modules/cpanel/logic/dns_provider.dart';
import 'package:cpanal/modules/cpanel/logic/dns_provider.dart';
import 'package:cpanal/modules/cpanel/logic/dns_provider.dart';
import 'package:cpanal/modules/cpanel/logic/dns_provider.dart';
import 'package:cpanal/modules/cpanel/widget/dns/create_dns_bottom_sheet.dart';
import 'package:cpanal/modules/cpanel/widget/dns/delete_dns_bottom_sheet.dart';
import 'package:cpanal/modules/cpanel/widget/dns/edit_dns_bottom_sheet.dart';
import 'package:cpanal/modules/cpanel/widget/email_account/search_account_bottomsheet.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../common_modules_widgets/template_page.widget.dart';
import '../../../../constants/app_sizes.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../utils/componentes/general_components/gradient_bg_image.dart';
import '../../choose_domain/choose_domin_screen.dart';
import '../../more/views/more_screen.dart';

class DNSScreen extends StatefulWidget {
  final String? name;
  final String? dominId;
  DNSScreen({this.name, this.dominId});

  @override
  State<DNSScreen> createState() => _DNSScreenState();
}

class _DNSScreenState extends State<DNSScreen> {
  List<Email> emails = [];
  List<Email> selectedEmails = [];
  bool isSelectionMode = false;
  var searchTitle;
  late ScrollController _scrollController;
  late final DNSProvider emailProvider;
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
          selectedEmails.removeWhere((element) => element.address == emails[index].address);
        }
        if (!emails.any((e) => e.isSelected)) {
          isSelectionMode = false;
        }
        printSelectedAccounts();
      });
    }
  }
  emailcickle()async{
    await emailProvider.getDns(context, dominId: widget.dominId).then((_) {
      setState(() {
        emails = AppConstants.accountsEmailsDNSFilter!
            .map((e) => Email(e['name'], "Unrestricted", "${e['humandiskquota']} / ${e['humandiskused']}"))
            .toList();
      });
    });
  }
  @override
  void initState() {
    super.initState();
    emailProvider = DNSProvider();
    _scrollController = ScrollController();
    emailcickle();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (!position.hasContentDimensions || position.maxScrollExtent == 0) return;

    final isCloseToBottom = position.pixels >= position.maxScrollExtent - 200;
    if (isCloseToBottom &&
        !emailProvider.isLoading &&
        emailProvider.hasMore &&
        AppConstants.accountsEmailsDNSFilter!.isNotEmpty) {
      emailProvider.getDns(context, isNewPage: true, dominId: widget.dominId);
    }
  }

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

    return ChangeNotifierProvider<DNSProvider>.value(
      value: emailProvider,
      child: Consumer<DNSProvider>(
        builder: (context, value, child) {
          return TemplatePage(
            pageContext: context,
            title: AppStrings.dnsControl.tr().toUpperCase(),
            onRefresh: () async {
              emailProvider.pageNumber = 1;
              AppConstants.accountsEmailsDNSFilter!.clear();
              await emailProvider.getDns(context, dominId: widget.dominId);
              await emailcickle();
            },
            actions: [
              Padding(
                padding: const EdgeInsets.all(AppSizes.s10),
                child: InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => SearchAccountBottomSheet(
                        title: AppStrings.dnsSearch.tr().toUpperCase(),
                        onSearch: (query) {
                          final allEmails = emailProvider.dns;
                          if (query == null || query.trim().isEmpty) {
                            AppConstants.accountsEmailsDNSFilter = allEmails;
                          } else {
                            AppConstants.accountsEmailsDNSFilter = allEmails.where((item) {
                              final email = item['name']?.toString().toLowerCase() ?? '';
                              return email.contains(query.toLowerCase());
                            }).toList();
                          }

                          setState(() {
                            searchTitle = query.toString();
                            emails = AppConstants.accountsEmailsDNSFilter!
                                .map((e) => Email(e['name'], "Unrestricted", "${e['humandiskquota']} / ${e['humandiskused']}"))
                                .toList();
                          });
                        },
                      ),
                    );
                  },

                  child: Container(
                    height: 35,
                    width: 35,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xffB289FF)),
                    child: const Icon(Icons.search, color: Colors.white, size: AppSizes.s18),
                  ),
                ),
              )
            ],
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
                      onTap: (){
                        Navigator.pop(context);
                        Navigator.pop(context);                      },
                      child: Text(widget.name!,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(AppColors.dark))),
                  ),
                  const SizedBox(width: 5),
                  GestureDetector(
                      onTap: (){
                        Navigator.pop(context);
                        Navigator.pop(context);                      },
                      child: SvgPicture.asset("assets/images/svg/cpanal_bottom_nav_icon.svg")),
                  const Spacer(),
                  GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const MoreScreen(),));
                    },
                    child: const Icon(Icons.menu, color: Color(AppColors.primary)),
                  )
                ],
              ),
            ),
            body: GradientBgImage(
              padding: EdgeInsets.all(0),
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      if(searchTitle != null)Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: ()async{
                              searchTitle = null;
                              await emailcickle();
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: Color(AppColors.dark),
                                  borderRadius: BorderRadius.circular(20)),
                              padding: EdgeInsetsGeometry.symmetric(vertical: 4, horizontal: 10),
                              child:  Row(
                                children: [
                                  Text(
                                    searchTitle,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                                  ),
                                  const SizedBox(width: 10,),
                                  Icon(Icons.close, color: Colors.white,)
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      if(searchTitle != null) const SizedBox(height: 15),
                       Text(
                         AppStrings.dns_control_description.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(AppColors.dark)),
                      ),
                      const SizedBox(height: 15),
                      Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: kIsWeb ? 1100 : double.infinity,
                          ),
                          child: ListView.separated(
                            itemCount: value.isLoading && value.pageNumber == 1 ? 3 : AppConstants.accountsEmailsDNSFilter!.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            separatorBuilder: (_, __) => const SizedBox(height: 15),
                            itemBuilder: (context, index) {
                              final safeContext = context; // ✅ هذا هو الـ context الآمن

                              if (value.isLoading && value.pageNumber == 1) {
                                return Shimmer.fromColors(
                                  baseColor: Colors.grey.shade300,
                                  highlightColor: Colors.grey.shade100,
                                  child: Container(height: 100, width: double.infinity, color: Colors.white),
                                );
                              }
                              return GestureDetector(
                                // onLongPress: () => onLongPress(index),
                                // onTap: () => onTap(index),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: const [BoxShadow(color: Color(0x0C000000), blurRadius: 10, offset: Offset(0, 1))],
                                  ),
                                  child: Slidable(
                                    key: ValueKey(AppConstants.accountsEmailsDNSFilter![index]['name']),
                                    endActionPane: ActionPane(
                                      motion: const DrawerMotion(),
                                      extentRatio: 0.6,
                                      children: [
                                        CustomSlidableAction(
                                          onPressed: (_) async{
                                            final objName = AppConstants.accountsEmailsDNSFilter![index]['name'];
                                            final objType = AppConstants.accountsEmailsDNSFilter![index]['type'];
                                            final objContent = AppConstants.accountsEmailsDNSFilter![index]['content'];
                                            final objTTL = AppConstants.accountsEmailsDNSFilter![index]['ttl'];
                                            await Clipboard.setData(ClipboardData(text: "Name : $objName \n Type : $objType \n Content : $objContent \n TTL : $objTTL"));
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text("${AppStrings.copied.tr()}")),
                                            );
                                          },
                                          child: Container(
                                            width: 50,
                                            height: 50,
                                            decoration: const BoxDecoration(
                                              color: Color(AppColors.dark),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(Icons.copy, color: Colors.white,),
                                          ),
                                        ),
                                        CustomSlidableAction(
                                          onPressed: (_) async{
                                           await showModalBottomSheet(
                                              context: safeContext,
                                              isScrollControlled: true,
                                              backgroundColor: Colors.transparent,
                                              builder: (_) => Padding(
                                                padding: EdgeInsets.only(bottom: MediaQuery.of(safeContext).viewInsets.bottom),
                                                child: EditEmailBottomSheet(multi: false,
                                                    dominName:  widget.name.toString(),
                                                    dominId: widget.dominId.toString(),
                                                object: AppConstants.accountsEmailsDNSFilter![index],
                                                ),
                                              ),
                                            );
                                           await emailcickle();
                                          },
                                          child: Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: Color(0xFFA372FF),
                                              shape: BoxShape.circle,
                                            ),
                                            child: SvgPicture.asset("assets/images/svg/swip_edit.svg", fit: BoxFit.scaleDown),
                                          ),
                                        ),
                                        CustomSlidableAction(
                                          onPressed: (_) async{
                                            await showModalBottomSheet(
                                              context: safeContext,
                                              isScrollControlled: true,
                                              backgroundColor: Colors.transparent,
                                              builder: (_) => Padding(
                                                padding: EdgeInsets.only(bottom: MediaQuery.of(safeContext).viewInsets.bottom),
                                                child: DeleteAccountBottomSheet(
                                                  domainId: widget.dominId,
                                                  multi: false,
                                                  recordId: AppConstants.accountsEmailsDNSFilter![index]['id'],
                                                  email: AppConstants.accountsEmailsDNSFilter![index]['name'],
                                                ),
                                              ),
                                            );
                                            await emailcickle();
                                          },
                                          child: Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: Color(0xFFE93F81),
                                              shape: BoxShape.circle,
                                            ),
                                            child: SvgPicture.asset("assets/images/svg/menu_delete.svg", fit: BoxFit.scaleDown, color: Colors.white,),
                                          ),
                                        ),
                                      ],
                                    ),
                                    child: GestureDetector(
                                      onTap: ()async{
                                        await showModalBottomSheet(
                                          context: safeContext,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder: (_) => Padding(
                                            padding: EdgeInsets.only(bottom: MediaQuery.of(safeContext).viewInsets.bottom),
                                            child: EditEmailBottomSheet(multi: false,
                                              dominName:  widget.name.toString(),
                                              dominId: widget.dominId.toString(),
                                              object: AppConstants.accountsEmailsDNSFilter![index],
                                            ),
                                          ),
                                        );
                                        await emailcickle();
                                      },
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    SizedBox(
                                                      width: kIsWeb? MediaQuery.sizeOf(context).width * 0.25:MediaQuery.sizeOf(context).width * 0.6,
                                                      child: Text(
                                                        AppConstants.accountsEmailsDNSFilter![index]['name'],
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(AppColors.dark),
                                                        ),
                                                      ),
                                                    ),
                                                    const Spacer(),

                                                    if(AppConstants.accountsEmailsDNSFilter![index]['proxied'] == true)SvgPicture.asset("assets/images/svg/check.svg"),
                                                    if(AppConstants.accountsEmailsDNSFilter![index]['proxied'] == false)SvgPicture.asset("assets/images/svg/warning.svg",
                                                      width: 15, height: 15, fit: BoxFit.scaleDown, color: Colors.orange,),
                                                    const SizedBox(width: 5,),
                                                    Text(AppConstants.accountsEmailsDNSFilter![index]['ttl'].toString() == "1"?
                                                    AppStrings.auto.tr() : AppConstants.accountsEmailsDNSFilter![index]['ttl'].toString(), style: const TextStyle(fontSize: 12, color: Color(0xff34A853), fontWeight: FontWeight.w500),),
                                                   ],
                                                ),
                                                const SizedBox(height: 5),
                                                Row(
                                                  children: [
                                                    SvgPicture.asset("assets/images/svg/personal.svg", color: Color(0xffE93F81)),
                                                    const SizedBox(width: 5),
                                                    Text(
                                                      AppConstants.accountsEmailsDNSFilter![index]['type'],
                                                      style: const TextStyle(color: Color(0xffE93F81), fontWeight: FontWeight.bold, fontSize: 12),
                                                    ),
                                                    Spacer(),
                                                    Container(
                                                      alignment: Alignment.centerRight,
                                                      width: !kIsWeb? MediaQuery.sizeOf(context).width * 0.55:MediaQuery.sizeOf(context).width * 0.3,
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                        children: [
                                                          SvgPicture.asset("assets/images/svg/ip.svg"),
                                                          const SizedBox(width: 5),
                                                          SizedBox(
                                                            width:!kIsWeb? MediaQuery.sizeOf(context).width * 0.49:MediaQuery.sizeOf(context).width * 0.15,
                                                            child: Text(
                                                              AppConstants.accountsEmailsDNSFilter![index]['content'],
                                                              style: const TextStyle(color: Color(0xff122730), fontWeight: FontWeight.bold, fontSize: 12),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (selectedEmails.any((e) => e.address == AppConstants.accountsEmailsDNSFilter![index]['name']))
                                            const Icon(Icons.check_circle, color: Colors.green),
                                        ],
                                      ),
                                    ),
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
            ),
            floatingActionButton: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  onPressed: () async{
                    await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => Padding(
                        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: CreateEmailBottomSheet(dominId: widget.dominId,dominName: widget.name,),
                      ),
                    );
                    await emailcickle();
                  },
                  backgroundColor: Colors.pink,
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class Email {
  final String address;
  final String status;
  final String usage;
  bool isSelected;
  Email(this.address, this.status, this.usage, {this.isSelected = false});
}
