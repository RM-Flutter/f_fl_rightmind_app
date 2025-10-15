import 'dart:convert';
import 'package:cpanal/constants/app_colors.dart';
import 'package:cpanal/constants/app_strings.dart';
import 'package:cpanal/constants/user_consts.dart';
import 'package:cpanal/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:cpanal/models/settings/user_settings.model.dart';
import 'package:cpanal/modules/cpanel/logic/auto_response_provider.dart';
import 'package:cpanal/modules/cpanel/logic/email_forward_provider.dart';
import 'package:cpanal/modules/cpanel/widget/email_forward/create_forward_bottom_sheet.dart';
import 'package:cpanal/modules/cpanel/widget/email_forward/delete_forward_bottom_sheet.dart';
import 'package:cpanal/modules/cpanel/widget/email_forward/edit_forward_bottom_sheet.dart';
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

class EmailForwardScreen extends StatefulWidget {
  final String? name;
  final String? dominId;
  EmailForwardScreen({this.name, this.dominId});

  @override
  State<EmailForwardScreen> createState() => _EmailForwardScreenState();
}

class _EmailForwardScreenState extends State<EmailForwardScreen> {
  List<Email> emails = [];
  List<Email> selectedEmails = [];
  bool isSelectionMode = false;
  late ScrollController _scrollController;
  late final EmailForwardProvider emailProvider;
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
    await emailProvider.getEmailForward(actionType: "emails",username: "test",
      context,
      domainId: widget.dominId,
    );await emailProvider.getDomainForward(actionType: "domains",username: "test",
      context,
      domainId: widget.dominId,
    );
  }
  @override
  void initState() {
    super.initState();
    emailProvider = EmailForwardProvider();
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
        emailProvider.emailForward.isNotEmpty) {
      emailProvider.getEmailForward(actionType: "emails",username: "test",
        context,
        domainId: widget.dominId,
        isNewPage: true,
      ); emailProvider.getDomainForward(actionType: "domains",username: "test",
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

    return ChangeNotifierProvider<EmailForwardProvider>.value(
      value: emailProvider,
      child: Consumer<EmailForwardProvider>(
        builder: (context, value, child) {
          return TemplatePage(
            pageContext: context,
            title: AppStrings.emailForwarders.tr().toUpperCase(),
            onRefresh: () async {
              emailProvider.pageNumber = 1;
              emailProvider.emailForward.clear();
              await emailProvider.getEmailForward(actionType: "emails",username: "test",context,  domainId: widget.dominId);
              await emailProvider.getDomainForward(actionType: "domains",username: "test",context,  domainId: widget.dominId);
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
              child: SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.8,
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(AppSizes.s12),
                  children: [
                     Text(
                       AppStrings.email_forwarders_description.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(AppColors.dark)),
                    ),
                    const SizedBox(height: 15),
                     Center(
                       child: ConstrainedBox(
                         constraints: BoxConstraints(
                           maxWidth: kIsWeb ? 1100 : double.infinity,
                         ),
                         child: Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: [
                             SizedBox(
                               width: kIsWeb ? MediaQuery.sizeOf(context).width * 0.4:MediaQuery.sizeOf(context).width * 0.75,
                               child: Text(
                                AppStrings.forwardAllEmailForADomain.tr(),
                                textAlign: TextAlign.start,
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(AppColors.c4)),
                                                 ),
                             ),
                             FloatingActionButton(
                               onPressed: () async{
                                 await showModalBottomSheet(
                                   context: context,
                                   isScrollControlled: true,
                                   backgroundColor: Colors.transparent,
                                   builder: (_) => Padding(
                                     padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                                     child: CreateEmailFowardBottomSheet(
                                       domain: true,dominId: widget.dominId,dominName: widget.name, actionType: "domains",
                                     ),
                                   ),
                                 );
                                 await emailcickle();
                               },
                               backgroundColor: Colors.pink,
                               child: const Icon(Icons.add, color: Colors.white),
                             ),
                           ],
                         ),
                       ),
                     ),
                    SizedBox(height: 10,),
                    Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: kIsWeb ? 1100 : double.infinity,
                        ),
                        child: ListView.separated(
                          itemCount: value.isLoading && value.pageNumber == 1 ? 3 : value.domainForward.length,
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
                            final email = value.domainForward[index];
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
                                  key: ValueKey(value.domainForward[index]['forward']),
                                  endActionPane: ActionPane(
                                    motion: const DrawerMotion(),
                                    extentRatio: 0.6,
                                    children: [
                                      CustomSlidableAction(
                                        onPressed: (_) async{
                                          final obj = value.domainForward[index]['dest'];
                                          await Clipboard.setData(ClipboardData(text: "domain : $obj"));
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
                                              child: DeleteAccountBottomSheet(
                                                dominId: widget.dominId, actionType: "domains",
                                                type:  AppStrings.domain,
                                                dest: value.domainForward[index]['dest'],
                                                forward:  value.domainForward[index]['forward']
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
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  value.domainForward[index]['dest'],
                                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(AppColors.dark)),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 5),
                                            Row(
                                              children: [
                                                SvgPicture.asset("assets/images/svg/message.svg", color: Color(0xffE93F81)),
                                                const SizedBox(width: 5),
                                                Text(
                                                  value.domainForward[index]['forward'],
                                                  style: const TextStyle(color: Color(0xffE93F81), fontWeight: FontWeight.bold, fontSize: 12),
                                                ),

                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (selectedEmails.any((e) => e.address == value.domainForward[index]['email']))
                                        const Icon(Icons.check_circle, color: Colors.green),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 30,),
                    Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: kIsWeb ? 1100 : double.infinity,
                        ),
                        child: Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: [
                             SizedBox(
                               width: kIsWeb ? MediaQuery.sizeOf(context).width * 0.4:MediaQuery.sizeOf(context).width * 0.75,
                               child: Text(
                                AppStrings.emailAccountForwarders.tr(),
                                textAlign: TextAlign.start,
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(AppColors.c4)),
                                                 ),
                             ),
                             FloatingActionButton(
                               onPressed: () async{
                                 await showModalBottomSheet(
                                   context: context,
                                   isScrollControlled: true,
                                   backgroundColor: Colors.transparent,
                                   builder: (_) => Padding(
                                     padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                                     child: CreateEmailFowardBottomSheet(
                                       dominId: widget.dominId,dominName: widget.name, actionType: "emails",
                                     domain: false,
                                     ),
                                   ),
                                 );
                                 await emailcickle();
                               },
                               backgroundColor: Colors.pink,
                               child: const Icon(Icons.add, color: Colors.white),
                             ),
                           ],
                         ),
                      ),
                    ),
                    SizedBox(height: 10,),
                    Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: kIsWeb ? 1100 : double.infinity,
                        ),
                        child: ListView.separated(
                          itemCount: value.isLoading && value.pageNumber == 1 ? 3 : value.emailForward.length,
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
                            final email = value.emailForward[index];
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
                                  key: ValueKey(value.emailForward[index]['forward']),
                                  endActionPane: ActionPane(
                                    motion: const DrawerMotion(),
                                    extentRatio: 0.6,
                                    children: [
                                      CustomSlidableAction(
                                        onPressed: (_) async{
                                          final obj = value.emailForward[index]['dest'];
                                          await Clipboard.setData(ClipboardData(text: "Email : $obj"));
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
                                        await  showModalBottomSheet(
                                            context: safeContext,
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                            builder: (_) => Padding(
                                              padding: EdgeInsets.only(bottom: MediaQuery.of(safeContext).viewInsets.bottom),
                                              child: DeleteAccountBottomSheet(
                                                dominId: widget.dominId,
                                                  actionType : "emails",
                                                  type: AppStrings.email,
                                                  dest: value.emailForward[index]['dest'],
                                                  forward:  value.emailForward[index]['forward']
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
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  value.emailForward[index]['dest'],
                                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(AppColors.dark)),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 5),
                                            Row(
                                              children: [
                                                SvgPicture.asset("assets/images/svg/message.svg", color: Color(0xffE93F81)),
                                                const SizedBox(width: 5),
                                                Text(
                                                  value.emailForward[index]['forward'],
                                                  style: const TextStyle(color: Color(0xffE93F81), fontWeight: FontWeight.bold, fontSize: 12),
                                                ),

                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (selectedEmails.any((e) => e.address == value.emailForward[index]['email']))
                                        const Icon(Icons.check_circle, color: Colors.green),
                                    ],
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
