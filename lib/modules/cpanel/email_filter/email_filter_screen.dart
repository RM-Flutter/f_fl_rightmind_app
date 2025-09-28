import 'dart:convert';
import 'package:cpanal/constants/app_colors.dart';
import 'package:cpanal/constants/app_constants.dart';
import 'package:cpanal/constants/app_strings.dart';
import 'package:cpanal/constants/user_consts.dart';
import 'package:cpanal/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:cpanal/models/settings/user_settings.model.dart';
import 'package:cpanal/modules/cpanel/email_filter/filter_email_screen.dart';
import 'package:cpanal/modules/cpanel/logic/email_account_provider.dart';
import 'package:cpanal/modules/cpanel/widget/email_account/search_account_bottomsheet.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../common_modules_widgets/template_page.widget.dart';
import '../../../../constants/app_sizes.dart';
import '../../../routing/app_router.dart';
import '../../../utils/componentes/general_components/gradient_bg_image.dart';
import '../../choose_domain/choose_domin_screen.dart';
import '../../more/views/more_screen.dart';

class EmailFilterScreen extends StatefulWidget {
  final String? name;
  final String? dominId;
  EmailFilterScreen({this.name, this.dominId});

  @override
  State<EmailFilterScreen> createState() => _EmailFilterScreenState();
}

class _EmailFilterScreenState extends State<EmailFilterScreen> {
  List<Email> emails = [];
  List<Email> selectedEmails = [];
  bool isSelectionMode = false;
  var searchTitle;
  late ScrollController _scrollController;
  late final EmailAccountProvider emailProvider;
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
    await emailProvider.getEmails(actionType: "email_account",
      context,
      domainId: widget.dominId,
    );
  }
  @override
  void initState() {
    super.initState();
    emailProvider = EmailAccountProvider();
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
        emailProvider.accountsEmails.isNotEmpty) {
      emailProvider.getEmails(actionType: "email_account",
        context,
        domainId: widget.dominId,
        isNewPage: true,
      );
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

    return ChangeNotifierProvider<EmailAccountProvider>.value(
      value: emailProvider,
      child: Consumer<EmailAccountProvider>(
        builder: (context, value, child) {
          return TemplatePage(
            pageContext: context,
            title: AppStrings.emailFilters.tr().toUpperCase(),
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
                        title: AppStrings.filtersSearch.tr(),
                        onSearch: (query) {
                          final allEmails = emailProvider.accountsEmails;

                          if (query == null || query.trim().isEmpty) {
                            AppConstants.accountsEmailsFilter = allEmails;
                          } else {
                            AppConstants.accountsEmailsFilter = allEmails.where((item) {
                              final email = item['email']?.toString().toLowerCase() ?? '';
                              return email.contains(query.toLowerCase());
                            }).toList();
                          }

                          setState(() {
                            searchTitle = query.toString();
                            emails = AppConstants.accountsEmailsFilter!
                                .map((e) => Email(e['email'], "Unrestricted", "${e['humandiskquota']} / ${e['humandiskused']}"))
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
            onRefresh: () async {
              emailProvider.pageNumber = 1;
              emailProvider.accountsEmails.clear();
              await emailProvider.getEmails(actionType: "email_account",context,  domainId: widget.dominId);
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
                      onTap: (){
                        Navigator.pop(context);
                        Navigator.pop(context);
                        },
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
              child: SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.8,
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(AppSizes.s12),
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
                      AppStrings.filterEmailMessage.tr(),
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
                          itemCount: value.isLoading && value.pageNumber == 1 ? 3 : AppConstants.accountsEmailsFilter!.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          separatorBuilder: (_, __) => const SizedBox(height: 15),
                          itemBuilder: (context, index) {
                            final safeContext = context;
                            if (value.isLoading && value.pageNumber == 1) {
                              return Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                child: Container(height: 100, width: double.infinity, color: Colors.white),
                              );
                            }
                            final email = AppConstants.accountsEmailsFilter![index];
                            return GestureDetector(
                              // onLongPress: () => onLongPress(index),
                               onTap: () {
                                 context.pushNamed(
                                   AppRoutes.FilterEmail.name,
                                   pathParameters: {
                                     'lang': context.locale.languageCode,
                                     'id': widget.dominId.toString(),
                                     'name': widget.name!,
                                     'email': AppConstants.accountsEmailsFilter![index]['email'],
                                   },
                                 );
                               },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: const [BoxShadow(color: Color(0x0C000000), blurRadius: 10, offset: Offset(0, 1))],
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      AppConstants.accountsEmailsFilter![index]['email'],
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(AppColors.dark)),
                                    ),
                                    Spacer(),
                                    GestureDetector(
                                        onTap: () async {
                                          final obj = AppConstants.accountsEmailsFilter![index];
                                          final jsonString = const JsonEncoder.withIndent('  ').convert(obj); // تحويل object ل JSON مرتب
                                          await Clipboard.setData(ClipboardData(text: jsonString));
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text("${AppStrings.copied.tr()}")),
                                          );
                                        },
                                        child: const Icon(Icons.copy, color: Color(AppColors.primary)))
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
            // floatingActionButton: Column(
            //   mainAxisAlignment: MainAxisAlignment.end,
            //   children: [
            //     FloatingActionButton(
            //       onPressed: () {
            //         showModalBottomSheet(
            //           context: context,
            //           isScrollControlled: true,
            //           backgroundColor: Colors.transparent,
            //           builder: (_) => Padding(
            //             padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            //             child: CreateEmailBottomSheet(dominId: widget.dominId,dominName: widget.name,),
            //           ),
            //         );
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
}

class Email {
  final String address;
  final String status;
  final String usage;
  bool isSelected;
  Email(this.address, this.status, this.usage, {this.isSelected = false});
}
