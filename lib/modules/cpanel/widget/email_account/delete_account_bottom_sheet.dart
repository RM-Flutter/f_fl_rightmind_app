import 'package:cpanal/common_modules_widgets/custom_elevated_button.widget.dart';
import 'package:cpanal/constants/app_colors.dart';
import 'package:cpanal/constants/app_strings.dart';
import 'package:cpanal/modules/cpanel/email_account/create_multi_accounts_screen.dart';
import 'package:cpanal/modules/cpanel/logic/email_account_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeleteAccountBottomSheet extends StatelessWidget {
  var emails;
  var email;
  bool? multi = false;
  var domainId;
  DeleteAccountBottomSheet({this.emails,this.domainId,this.multi,this.email});
  @override
  Widget build(BuildContext context) {
    return Consumer<EmailAccountProvider>(
      builder: (context, value, child) {
        return Container(
          height: MediaQuery.sizeOf(context).height * 0.5,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  AppStrings.areYouSureToDelete.tr().toUpperCase(),
                  style: const TextStyle(
                    color: Color(AppColors.primary),
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Center(
                child: Text(
                  AppStrings.createEmailMessage.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ),
              const SizedBox(height: 15),
              if(multi == false)SizedBox(width: double.infinity,
              child: Center(
                child: Text(
                  email,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(AppColors.dark),
                  ),
                ),
              ),
              ),
              if(multi == true)GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                childAspectRatio: 8, // خلي القيمة أكبر عشان العناصر تبقى أقصر
                children: (emails['accounts'] as List<dynamic>).map((email) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                    ),
                    child: Text(
                      email,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(AppColors.dark),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 30),
              Row(
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
                  const SizedBox(width: 20,),
                  Expanded(
                    child:value.isLoading == false? CustomElevatedButton(
                      width: null,
                      backgroundColor: const Color(AppColors.dark),
                      title: AppStrings.delete.tr().toUpperCase(),
                      onPressed: () async {
                        if(multi == false){
                          value.deleteEmail(
                              context, domainId: domainId.toString(), account: email
                          );
                        }else{
                          value.deleteMutiEmail(
                              context, domainId: domainId.toString(), accounts: emails
                          );
                        }
                      },
                      isPrimaryBackground: false,
                    ) : Container(
                      width: 50, height: 50,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

}
