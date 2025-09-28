import 'dart:math';

import 'package:cpanal/common_modules_widgets/custom_elevated_button.widget.dart';
import 'package:cpanal/constants/app_colors.dart';
import 'package:cpanal/constants/app_strings.dart';
import 'package:cpanal/modules/cpanel/logic/auto_response_provider.dart';
import 'package:cpanal/modules/cpanel/logic/email_account_provider.dart';
import 'package:cpanal/modules/cpanel/logic/email_forward_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../general_services/validation_service.dart';

class CreateEmailFowardBottomSheet extends StatefulWidget {
  var email;
  var dominId;
  var dominName;
  var actionType;
  bool domain = true;
  CreateEmailFowardBottomSheet({this.dominId,this.dominName,this.actionType,this.email, required this.domain});

  @override
  State<CreateEmailFowardBottomSheet> createState() => _CreateEmailFowardBottomSheetState();
}

class _CreateEmailFowardBottomSheetState extends State<CreateEmailFowardBottomSheet> {
  TextEditingController emailController = TextEditingController();
  TextEditingController fromController = TextEditingController();
  TextEditingController subjectController = TextEditingController();
  TextEditingController bodyController = TextEditingController();
  bool isContainsHtml = true;
  String generateRandomPassword({int length = 12}) {
    const String chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()-_=+[]{};:,.<>?/|';
    final rand = Random.secure();
    return List.generate(length, (index) => chars[rand.nextInt(chars.length)]).join();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EmailForwardProvider>(
        builder: (context, value, child) {
          return DraggableScrollableSheet(
            initialChildSize: 0.65,
            maxChildSize: 0.9,
            minChildSize: 0.4,
            builder: (_, controller) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: ListView(
                  controller: controller,
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
                       widget.domain == false? AppStrings.addANewEmailForwarder.tr().toUpperCase():
                       AppStrings.addANewDomainForwarder.tr().toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(AppColors.primary),
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    SizedBox(height: 15,),
                     Center(
                      child: Text(
                        widget.domain == false? "${AppStrings.forwardMessage.tr()} ${AppStrings.email.tr()}":"${AppStrings.forwardMessage.tr()} ${AppStrings.domain.tr()}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(AppColors.dark),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    if(widget.actionType == "emails") TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: AppStrings.fromUserName.tr(),
                      ),
                    ),
                     SizedBox(height: 15,),
                    if(widget.email == null) TextFormField(
                      controller: bodyController,
                      validator: (val) => widget.email == null? ValidationService.validateEmail(val):ValidationService.validateEmail(val),
                      decoration: InputDecoration(
                        hintText: widget.domain == true ?AppStrings.toForwardDomain.tr():AppStrings.toForwardEmail.tr(),
                      ),
                    ),
                    if(widget.email == null)   const SizedBox(height: 30),
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
                          child: CustomElevatedButton(
                            width: null,
                            backgroundColor: const Color(AppColors.dark),
                            title: AppStrings.add.tr().toUpperCase(),
                            onPressed: () async {
                              value.addEmailForward(context,
                              domainId: widget.dominId.toString(),
                                  email: emailController.text,
                                actionType: widget.actionType,
                                forwardTo:widget.email?? bodyController.text
                              );
                            },
                            isPrimaryBackground: false,
                          )
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
          );
        },
    );
  }

  Widget _buildInputWithSuffix(
      String label,
      String suffixText,
      double width, {
        TextEditingController? controller,
        bool isNumber = false, // باراميتر جديد
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        fillColor: Colors.white,
        labelText: label,
        suffixIcon: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: width,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xffDFDFDF),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              suffixText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: Color(AppColors.dark),
              ),
            ),
          ),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

}
