import 'dart:convert';
import 'package:cpanal/common_modules_widgets/custom_elevated_button.widget.dart';
import 'package:cpanal/constants/app_colors.dart';
import 'package:cpanal/constants/app_strings.dart';
import 'package:cpanal/constants/user_consts.dart';
import 'package:cpanal/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:cpanal/models/settings/user_settings.model.dart';
import 'package:cpanal/modules/choose_domain/choose_domin_screen.dart';
import 'package:cpanal/modules/cpanel/logic/email_account_provider.dart';
import 'package:cpanal/modules/cpanel/widget/email_account/create_email_bottom_sheet.dart';
import 'package:cpanal/modules/cpanel/widget/email_account/delete_account_bottom_sheet.dart';
import 'package:cpanal/modules/cpanel/widget/email_account/edit_email_bottom_sheet.dart';
import 'package:cpanal/modules/cpanel/widget/email_account/load_from_files_bottom_sheet.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../common_modules_widgets/template_page.widget.dart';
import '../../../../constants/app_sizes.dart';
import '../../../utils/componentes/general_components/gradient_bg_image.dart';
import '../widget/email_account/edit_multi_email_bottom_sheet.dart';

class CreateMultiAccountsScreen extends StatefulWidget {
  var dominId;
  var name;
  CreateMultiAccountsScreen({this.name, this.dominId});
  @override
  State<CreateMultiAccountsScreen> createState() =>
      _CreateMultiAccountsScreenState();
}

class _CreateMultiAccountsScreenState extends State<CreateMultiAccountsScreen> {
  late EmailAccountProvider emailAccountProvider;
  @override
  void initState() {
    emailAccountProvider = EmailAccountProvider();
    emailAccountProvider.accountsMulti = [];
    super.initState();
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
    print("IS THIS");
    return Consumer<EmailAccountProvider>(builder: (context, value, child) {
      return TemplatePage(
        pageContext: context,
        title: AppStrings.createMulti.tr().toUpperCase(),
        onRefresh: () async {},
        bottomNavigationBar:  Container(
          height: 120,
          padding: const EdgeInsets.symmetric(horizontal: kIsWeb ? 220:20),
          decoration: BoxDecoration(
              color: Color(0xffFFFFFF),
              boxShadow: [
                BoxShadow(
                  color: Color(0xffC9CFD2).withOpacity(0.5),
                  blurRadius: AppSizes.s5,
                  spreadRadius: 1,
                )
              ],
              borderRadius: BorderRadius.circular(35)),
          alignment: Alignment.center,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: kIsWeb ? 1100 : double.infinity,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: CustomElevatedButton(
                      width: null,
                      backgroundColor: const Color(0xffD10A11),
                      title: AppStrings.cancel.tr().toUpperCase(),
                      onPressed: () async {
                        Navigator.pop(context);
                      },
                      isPrimaryBackground: false,
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: CustomElevatedButton(
                      width: null,
                      backgroundColor: const Color(AppColors.dark),
                      title: AppStrings.createEmails.tr().toUpperCase(),
                      onPressed: () async {
                        await value.addMultiEmails(
                          context,
                          domainId: widget.dominId.toString(),
                          accounts: emailAccountProvider.accountsMulti,
                        );
                      },
                      isPrimaryBackground: false,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: GradientBgImage(
          padding: EdgeInsets.all(0),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.s12),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.email_accounts_description.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(AppColors.dark)),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  if(emailAccountProvider.accountsMulti.isNotEmpty)Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: kIsWeb ? 1100 : double.infinity,
                      ),
                      child: ListView.separated(
                        itemCount: emailAccountProvider.accountsMulti.length,
                        padding: EdgeInsets.zero,
                        reverse: false,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: ()async{
                              await showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => Padding(
                                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                                child: EditMultiEmailBottomSheet(
                                  dominId: widget.dominId,
                                  email: emailAccountProvider.accountsMulti[index]['username'],
                                  password: emailAccountProvider.accountsMulti[index]['password'],
                                  storage: emailAccountProvider.accountsMulti[index]['quota'],
                                  index: index,
                                  dominName: widget.name,
                                  multiEmails:emailAccountProvider.accountsMulti
                                ),
                              ),
                              );
                              setState(() {});
                            },
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
                                    offset: Offset(0, 1),
                                    spreadRadius: 0,
                                  )
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
                                            SizedBox(
                                              width: kIsWeb? MediaQuery.sizeOf(context).width * 0.4:MediaQuery.sizeOf(context).width * 0.7,
                                              child: Text(emailAccountProvider.accountsMulti[index]['username'],
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w700,
                                                      color: Color(AppColors.dark))),
                                            ),
                                            const Spacer(),
                                            GestureDetector(
                                              onTap: ()async{
                                                final obj = emailAccountProvider.accountsMulti[index]['username'];
                                                await Clipboard.setData(ClipboardData(text: "Email : $obj"));
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text("${AppStrings.copied.tr()}")),
                                                );
                                                emailAccountProvider.accountsMulti.add({
                                                  "username" : emailAccountProvider.accountsMulti[index]['username'],
                                                  "password" : emailAccountProvider.accountsMulti[index]['password'],
                                                  "quota" : emailAccountProvider.accountsMulti[index]['quota']
                                                });
                                                setState(() {});
                                              },
                                              child: SvgPicture.asset(
                                                  "assets/images/svg/m-edit.svg"),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            GestureDetector(
                                                onTap: () {
                                                  emailAccountProvider.accountsMulti.removeAt(index);
                                                  setState(() {
                                                  });
                                                },
                                                child: SvgPicture.asset(
                                                    "assets/images/svg/m-delete.svg")),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          children: [
                                            SvgPicture.asset(
                                              "assets/images/svg/lock.svg",
                                              color:  Color(0xff34A853),
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              emailAccountProvider.accountsMulti[index]['password'],
                                              style: TextStyle(
                                                color: Color(0xff34A853),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const Spacer(),
                                            SvgPicture.asset(
                                              "assets/images/svg/speed.svg",
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              emailAccountProvider.accountsMulti[index]['quota'],
                                              style: const TextStyle(
                                                color: Color(AppColors.primary),
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) => const SizedBox(
                          height: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: kIsWeb ? 1100 : double.infinity,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            child: CustomElevatedButton(
                              width: null,
                              isOutlined: true,
                              titleColor: const Color(AppColors.primary),
                              title: AppStrings.addMore.tr().toUpperCase(),
                              onPressed: () async {
                                await showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) => Padding(
                                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                                    child: CreateEmailBottomSheet(dominId: widget.dominId,
                                        dominName: widget.name,
                                        multi: true,
                                        multiEmails: emailAccountProvider.accountsMulti
                                    ),
                                  ),
                                );
                                setState(() {});
                                print("EMILS IS --> ${emailAccountProvider.accountsMulti}");
                              },
                              isPrimaryBackground: false,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  child: CustomElevatedButton(
                                    width: null,
                                    title: AppStrings.loadFromFile.tr().toUpperCase(),
                                    onPressed: () async {
                                      await value.uploadExcel(emailAccountProvider.accountsMulti);
                                    },
                                    isPrimaryBackground: false,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              SizedBox(
                                height: 50,
                                child: GestureDetector(
                                  onTap: ()async{
                                    await value.downloadExcel(context);
                                  },
                                  child: SvgPicture.asset(
                                    height: 50,
                                      "assets/images/svg/cpanal_bottom_nav_icon.svg"),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    },);
  }
}

class Email {
  final String address;
  final String status;
  final String usage;
  bool isSelected;

  Email(this.address, this.status, this.usage, {this.isSelected = false});
}
