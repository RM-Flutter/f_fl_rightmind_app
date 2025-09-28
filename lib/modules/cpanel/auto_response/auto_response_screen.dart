import 'dart:convert';
import 'package:cpanal/constants/app_colors.dart';
import 'package:cpanal/constants/app_strings.dart';
import 'package:cpanal/constants/user_consts.dart';
import 'package:cpanal/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:cpanal/models/settings/user_settings.model.dart';
import 'package:cpanal/modules/cpanel/logic/auto_response_provider.dart';
import 'package:cpanal/modules/cpanel/widget/auto_res/create_auto_bottom_sheet.dart';
import 'package:cpanal/modules/cpanel/widget/auto_res/delete_auto_bottom_sheet.dart';
import 'package:cpanal/modules/cpanel/widget/auto_res/edit_auto_bottom_sheet.dart';
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
import '../../choose_domain/choose_domin_screen.dart' show ChooseDomainScreen;
import '../../more/views/more_screen.dart';

class AutoResponseScreen extends StatefulWidget {
  final String? name;
  final String? dominId;
  AutoResponseScreen({this.name, this.dominId});

  @override
  State<AutoResponseScreen> createState() => _AutoResponseScreenState();
}

class _AutoResponseScreenState extends State<AutoResponseScreen> {
  List<Email> emails = [];
  List<Email> selectedEmails = [];
  bool isSelectionMode = false;
  late ScrollController _scrollController;
  late final AutoResponseProvider emailProvider;
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
    await emailProvider.getAutoRes(
      context,
      domainId: widget.dominId,
    ).then((_) {
      setState(() {
        emails = emailProvider.autoRes
            .map((e) => Email(e['email'], "Unrestricted", "${e['humandiskquota']} / ${e['humandiskused']}"))
            .toList();
      });
    });
  }
  @override
  void initState() {
    super.initState();
    emailProvider = AutoResponseProvider();
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
        emailProvider.autoRes.isNotEmpty) {
      emailProvider.getAutoRes(
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

    return ChangeNotifierProvider<AutoResponseProvider>.value(
      value: emailProvider,
      child: Consumer<AutoResponseProvider>(
        builder: (context, value, child) {
          return TemplatePage(
            pageContext: context,
            title: AppStrings.autoresponders.tr().toUpperCase(),
            onRefresh: () async {
              emailProvider.pageNumber = 1;
              emailProvider.autoRes.clear();
              await emailProvider.getAutoRes(context,  domainId: widget.dominId);
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
                      AppStrings.email_auto_responders_description.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(AppColors.dark)),
                    ),
                    const SizedBox(height: 15),
                    if (selectedEmails.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        decoration: BoxDecoration(
                          color: const Color(AppColors.primary),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        width: double.infinity,
                        child: Row(
                          children: [
                            Text(
                              "${AppStrings.select.tr().toUpperCase()} ${selectedEmails.length} ${AppStrings.email.tr().toUpperCase()}",
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: ()async{
                               await showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) => Padding(
                                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                                    child: EditEmailBottomSheet(multi: false,dominName:  widget.name.toString(), dominId: widget.dominId.toString()),
                                  ),
                                );
                               await emailcickle();
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                                child: SvgPicture.asset("assets/images/svg/edit.svg"),
                              ),
                            ),
                            const SizedBox(width: 5),
                            GestureDetector(
                              onTap: ()async{
                               await showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) => Padding(
                                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                                    child: DeleteAccountBottomSheet(multi: true, emails:  accountsPayload, domainId: widget.dominId.toString()),
                                  ),
                                );
                               await emailcickle();
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                                child: (value.isLoading == false)?
                                SvgPicture.asset("assets/images/svg/delete.svg") : const CircularProgressIndicator(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: kIsWeb ? 1100 : double.infinity,
                        ),
                        child: ListView.separated(
                          itemCount: value.isLoading && value.pageNumber == 1 ? 3 : value.autoRes.length,
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

                            final email = emails[index];
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
                                  key: ValueKey(value.autoRes[index]['email']),
                                  endActionPane: ActionPane(
                                    motion: const DrawerMotion(),
                                    extentRatio: 0.6,
                                    children: [
                                      // CustomSlidableAction(
                                      //   onPressed: (_) {
                                      //     showModalBottomSheet(
                                      //       context: safeContext,
                                      //       isScrollControlled: true,
                                      //       backgroundColor: Colors.transparent,
                                      //       builder: (_) => Padding(
                                      //         padding: EdgeInsets.only(bottom: MediaQuery.of(safeContext).viewInsets.bottom),
                                      //         child: EditEmailBottomSheet(multi: false,dominName:  widget.name.toString(), dominId: widget.dominId.toString()),
                                      //       ),
                                      //     );
                                      //   },
                                      //   child: Container(
                                      //     width: 50,
                                      //     height: 50,
                                      //     decoration: BoxDecoration(
                                      //       color: Color(0xFFA372FF),
                                      //       shape: BoxShape.circle,
                                      //     ),
                                      //     child: SvgPicture.asset("assets/images/svg/swip_edit.svg", fit: BoxFit.scaleDown),
                                      //   ),
                                      // ),
                                      CustomSlidableAction(
                                        onPressed: (_) async{
                                          final obj = value.autoRes[index]['email'];
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
                                          await showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                            builder: (_) => Padding(
                                              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                                              child: EditEmailBottomSheet(multi: false,dominName:  widget.name.toString(),
                                                  dominId: widget.dominId.toString(),
                                                index: value.autoRes[index]
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
                                                email: value.autoRes[index]['email'],
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
                                                  value.autoRes[index]['email'],
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
                                                  value.autoRes[index]['subject'],
                                                  style: const TextStyle(color: Color(0xffE93F81), fontWeight: FontWeight.bold, fontSize: 12),
                                                ),

                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (selectedEmails.any((e) => e.address == value.autoRes[index]['email']))
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
                        child: CreateAutoBottomSheet(dominId: widget.dominId,dominName: widget.name,
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
